---
name: babysit-pr
description: Keep a pull request or a stack green and current until it merges - watch CI and reviews, fix lint and real failures, rerun flakes, bring the base in. Use right after opening a PR, when the user says babysit / watch / monitor a PR, and when they ask to get a PR or stack merged.
---

# Babysit PR

Built on Theo Browne's [`babysit-pr`](https://github.com/t3dotgg/tstack/tree/main/skills/babysit-pr) from [tstack](https://github.com/t3dotgg/tstack). Kudos to Theo; `scripts/pr-wait` is his (MIT), extended here.

You keep a PR mergeable so the user never pokes at CI.
Something wakes you when the PR changes; you fix what is the branch's fault, rerun what never was, and report what you decided with evidence.

## Preferences

`~/.agents/babysit/preferences.md` holds the user's standing answers: merge method, auto-merge takeover, GitHub posting, what to leave alone.
Read it first.
An answer given in a session holds for that session; write it to the file only when the user wants it kept.

**Posting on GitHub is opt-in.** Comments, replies, reviews and resolving threads happen only when the preferences allow them or the user asks; otherwise you draft the text in your report.

## Orchestrator

If `~/.agents/babysit/orchestrator` names a live session other than yours, a `babysit-all-prs` session owns babysitting.
Send it the PR URL, your session id, and what GitHub cannot show (stack order, decisions the user made, failures known to be foreign), stop watching, and tell the user in one line.
Before every later push of yours, fetch and merge your remote branch: the orchestrator may have pushed to it.

## Waiting

One watcher per PR, never a hand-written sleep loop:

- **T3 Code:** `watch_pull_request`, then settle the thread and end the turn.
- **A harness with a monitor tool:** `scripts/pr-wait <pr> --until green` under the monitor, so each printed line wakes you (`--until ready` when a review bot gates the repo).
  Restart it after a push, after handling exit 1, and after a resume. See `--help` for stacked bases without required checks.
- **Otherwise:** run `pr-wait` as one long blocking command.

A wake with nothing to do ends silently.

## On each wake

Act only on what is newer than the latest push.

| Failed check | Action |
|---|---|
| infra (runner, network, timeout) | rerun the failed jobs |
| flaky (unrelated to the diff, passes elsewhere) | rerun once; fails again ⇒ real |
| lint, format, generated files, snapshots the diff intends | run the repo's own fixer, commit |
| real | follow-up commit, touched tests green |
| foreign (also red on the base, not caused by the diff) | never fix it here; report with the base run as evidence |

At most two reruns per check; after that it is real or goes to the user.
Several failures: one subagent per check, in parallel, each following [`references/classify.md`](references/classify.md).

**Review findings:** verify each against the source, fix real bugs, and for the rest write a one-line reply with the reason.
A human reviewer's change request is a design conversation: hand it to the PR's author session, or to the user.
Keep the PR at the size its goal needs; review loops grow PRs one cheap fix at a time.

**Base moved, BEHIND or conflicting:** bring the base in and resolve.
Merge, don't rebase, once anyone may have the branch checked out or has reviewed it; follow the repo's convention otherwise.

## Stacks

A stack is one unit.
After pushing a layer, bring it into every layer above, bottom-up (`gh pr list --base <branch>`).
A stack linked on GitHub (`gh stack view`) cannot hold merge commits: sync it with `gh stack rebase` and `--force-with-lease` instead.
When a lower layer merges, GitHub retargets the next one; bring its new base in.

## Merge mode (opt-in)

Off until the user asks for the merge itself ("get it merged", "land the stack"), or auto-merge takeover fires.
From then on, follow [`references/merge-mode.md`](references/merge-mode.md).

**Auto-merge takeover.**
When preferences have no answer yet, ask once: "When you enable auto-merge on a PR yourself, should I take that as the go-ahead for merge mode?"
On yes, each wake checks `autoMergeRequest.enabledBy`: the user ⇒ merge mode is on for that PR, and you keep it alive when GitHub drops it.

## Report

One message per event, outcome first:

```markdown
PR #123: 2 failed, 1 rerun, 1 fixed, 0 for you.

| Check | Verdict | Evidence | Action |
|---|---|---|---|
| lint | real | `no-unused-vars` in the changed `cart.ts` | fixed in abc123 |
| e2e | flaky | unrelated spec, green on rerun | rerun |

Open for you: …
Replies to post: <finding> → <draft>
```

All green and nothing open: one line.
Keep watching until the PR merges or closes; unwatch whenever you hand back to the user.
