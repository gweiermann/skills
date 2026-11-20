# Backport review

A backport clones a PR that was already reviewed and approved.
The question is **fidelity**: does the backport do what the original does on the target branch, nothing more and nothing less?
The original's design and code quality are settled; do not re-review them.

These rules change the steps of `SKILL.md`; every step not named here runs unchanged.

## Find the original

The PR body or title names it (`backport of #1234`, `[1.x]`), or its commits carry `(cherry picked from commit <sha>)`.
Resolve it to the original PR number and the commit(s) that landed on the main branch (`gh pr view <n> --json mergeCommit,commits`).
Not found: ask the user for it; a fidelity review without the original is a normal review.

## Compare the two changes

Compare the original against the backport hunk by hunk:

```bash
gh pr diff <original> > <scratchpad>/original.diff
gh pr diff <backport> > <scratchpad>/backport.diff
git range-diff <orig-merge>^..<orig-merge> <bp-base>..<bp-head>   # when both are fetched
```

Sort every difference into one of these:

- **Missing**: a hunk, file, test, or changelog/upgrade entry of the original that the backport lacks.
- **Extra**: a change in the backport that the original does not have.
- **Adapted**: a hunk rewritten for the target branch (older API, PHP/Node version, missing feature flag, different file path, migration timestamp, changelog location).
  Check that the adaptation keeps the original's behaviour and is correct on the target branch.

Done when every hunk of both diffs is matched, or listed under one of the three.
A difference that only follows from the target branch being older and changes no behaviour is expected; note it in the implementation details, not as a finding.

## Collect findings

Run `code-review` and `user-review` as usual, then compare each finding with the original:

- **Fidelity finding**: caused by a missing, extra, or adapted hunk, or by the target branch behaving differently under the same code. These are the report's findings.
- **Original finding**: the same code in the original has the same issue.
  Keep it among the fidelity findings only when it is high priority (data loss, crash, security, broken main flow), marked `also in original #<n>`.
  Otherwise it goes to the low "Findings in the original PR" section, one line each, without reproduction or screenshots.

Prove "also in the original" by showing the identical hunk in the original diff, not by guessing.

## Run and reproduce

Run the backport end to end on its target branch, as in steps 2 and 3, for the fidelity findings only.
Walk the original PR's own test steps on the backport too: they show whether the backport behaves the same.

## Report

Replace "Findings in this PR" with "Fidelity", opened by a one-line verdict:

```text
Fidelity: faithful | faithful with adaptations | diverges
Missing: <n> · Extra: <n> · Adapted: <n>
```

List the fidelity findings below it in the usual code-block format.
Each missing, extra, or adapted item that is not a finding gets one line under "Implementation details".
Put "Findings in the original PR" right before "Out of scope".
