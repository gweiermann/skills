# Merge mode

Babysitting keeps a PR green; merge mode carries it until it lands.
It ends only when the PR merged or closed.

## Start

Name the PRs it covers; a stack counts as one unit.
A draft cannot auto-merge: ask once whether to mark it ready.
Use the merge method from preferences, else the one the repo allows (`gh repo view --json squashMergeAllowed,mergeCommitAllowed,rebaseMergeAllowed`).

First find out whether the PR is part of a stack linked on GitHub (`gh stack view`); a linked PR refuses plain auto-merge.

- **Single PR:** `gh pr merge <n> --auto --<method>`.
- **Linked GitHub stack:** once every layer is green and approved, `gh stack merge <top>`.
- **Plain stack:** auto-merge the bottom PR; when it lands and GitHub retargets the next one, bring the new base in, auto-merge it, walk up.

## Every wake

`gh pr view <n> --json autoMergeRequest,mergeStateStatus,reviewDecision`:

- Auto-merge gone without a merge (queue eject, dismissed by a push) ⇒ fix the cause, enable it again.
- BEHIND and the repo requires up-to-date branches ⇒ bring the base in.
- Not approved ⇒ say once that it waits for a reviewer, then keep watching.

## Outwait foreign failures

A foreign failure blocks the merge until the base fixes it.
Schedule a tick bound to this session, about every 30 minutes (T3 `schedule_task`, a cron or loop tool, a wakeup), and on each one:

1. Merged or closed? Finish.
2. Fixed upstream? The base's latest run of that workflow is green, or a base commit touches the failing path or names the error.
   Fix on the base ⇒ bring it in and push. Fix outside the repo (a service, a downstream repo) ⇒ rerun the failed jobs.
   Reruns after a fix landed do not count against the rerun cap.
3. Still red for the same cause ⇒ end silently. A new cause ⇒ classify it like any failure.

## Finish

Delete the tick, unwatch every PR, and report in one line: merged as `<sha>`, or closed by whom.
