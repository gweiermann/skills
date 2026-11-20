#!/usr/bin/env bash
# Adds one comment to the viewer's PENDING review on a pull request.
# Creates the pending review when none exists. Never submits it.
#
# Usage: add_pending_comment.sh <owner/repo> <pr> <path> <body-file> [<line> [<start-line>]] [--side LEFT|RIGHT]
#   Without <line> the comment is attached to the whole file.
#   A <line> outside the diff falls back to a file-level comment.
set -euo pipefail

usage() {
    sed -n '5,7p' "$0" | sed 's/^# \{0,1\}//' >&2
    exit 1
}

[[ $# -ge 4 ]] || usage

REPO="$1" PR="$2" FILE_PATH="$3" BODY_FILE="$4"
shift 4
LINE="" START_LINE="" SIDE="RIGHT"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --side) SIDE="$2"; shift 2 ;;
        *)
            if [[ -z "$LINE" ]]; then LINE="$1"
            elif [[ -z "$START_LINE" ]]; then START_LINE="$1"
            else usage
            fi
            shift ;;
    esac
done

[[ -f "$BODY_FILE" ]] || { echo "Body file not found: $BODY_FILE" >&2; exit 1; }
OWNER="${REPO%%/*}" NAME="${REPO#*/}"

lookup="$(gh api graphql -F owner="$OWNER" -F name="$NAME" -F pr="$PR" -f query='
query($owner: String!, $name: String!, $pr: Int!) {
  viewer { login }
  repository(owner: $owner, name: $name) {
    pullRequest(number: $pr) {
      id
      reviews(states: PENDING, last: 10) { nodes { id author { login } } }
    }
  }
}')"

viewer="$(jq -r '.data.viewer.login' <<<"$lookup")"
pr_id="$(jq -r '.data.repository.pullRequest.id' <<<"$lookup")"
review_id="$(jq -r --arg v "$viewer" '[.data.repository.pullRequest.reviews.nodes[] | select(.author.login == $v)][0].id // empty' <<<"$lookup")"

if [[ -z "$review_id" ]]; then
    # addPullRequestReview without an event leaves the review PENDING.
    review_id="$(gh api graphql -F pr="$pr_id" -f query='
mutation($pr: ID!) {
  addPullRequestReview(input: { pullRequestId: $pr }) { pullRequestReview { id state } }
}' --jq '.data.addPullRequestReview.pullRequestReview.id')"
    echo "Created pending review $review_id" >&2
fi

add_thread() {
    local args=(-F review="$review_id" -F path="$FILE_PATH" -F body=@"$BODY_FILE")
    local vars='$review: ID!, $path: String!, $body: String!'
    local input='pullRequestReviewId: $review, path: $path, body: $body'
    if [[ "$1" == "line" ]]; then
        args+=(-F line="$LINE" -f side="$SIDE")
        vars+=', $line: Int!, $side: DiffSide!'
        input+=', line: $line, side: $side'
        if [[ -n "$START_LINE" ]]; then
            args+=(-F startLine="$START_LINE" -f startSide="$SIDE")
            vars+=', $startLine: Int!, $startSide: DiffSide!'
            input+=', startLine: $startLine, startSide: $startSide'
        fi
    else
        input+=', subjectType: FILE'
    fi
    gh api graphql "${args[@]}" -f query="
mutation($vars) {
  addPullRequestReviewThread(input: { $input }) { thread { id comments(first: 1) { nodes { url } } } }
}" --jq '.data.addPullRequestReviewThread.thread.comments.nodes[0].url'
}

if [[ -n "$LINE" ]]; then
    err="$(mktemp)"
    if url="$(add_thread line 2>"$err")" && [[ -n "$url" && "$url" != "null" ]]; then
        rm -f "$err"
        echo "$url"
        exit 0
    fi
    echo "Line $LINE is not commentable in the diff ($(cat "$err")); attaching to the file instead." >&2
    rm -f "$err"
fi
add_thread file
