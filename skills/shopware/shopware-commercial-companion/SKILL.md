---
name: shopware-commercial-companion
description: Pair a shopware/shopware PR with its companion PR in SwagCommercial (or Rufus) - same branch name, platform merges first and pulls the companion in, so both must be green and approved together. Use when a platform PR needs a downstream change, when its Commercial, Rufus or Downstream Mergeability check fails, and before merging a platform PR that has a companion.
---

# Commercial companion PRs

A platform PR in `shopware/shopware` sometimes needs a companion in `shopware/SwagCommercial` or `shopware/rufus`, e.g. when it changes something a downstream test relies on.
The platform workflows pair the two by **branch name**: the companion only counts when its head branch is named exactly like the platform PR's.
Source of truth: `.github/workflows/downstream.yml` and `merge-downstreams.yml` in shopware/shopware.

## How the pair behaves

- **Commercial / Rufus checks** test the downstream repo at the same-named branch, falling back to its trunk.
  A companion under another name is invisible and the check stays red.
- **Downstream Mergeability Check** fails unless the same-named downstream PR is clean: green, approved, no conflicts.
  It is a stale gate: it only reruns when the platform PR's CI runs.
- **Platform merges first.** Merging it squash-merges the open companion automatically.
  Nobody merges the companion by hand, unless that automatic merge fails; then it is urgent, because platform trunk is already ahead of downstream trunk.

So both PRs land within minutes of each other, and both must be green and approved before the platform PR merges.

## Before the platform PR merges

Whether by hand, merge queue or auto-merge:

1. `gh pr view <m> --repo shopware/SwagCommercial --json reviewDecision,mergeStateStatus` shows `APPROVED` and `CLEAN`.
2. Rerun the platform PR's Downstream Mergeability Check and see it pass.
3. Only then merge or enable auto-merge on the platform PR.
   Auto-merge already on while the companion lacks approval? Tell the user and offer to disable it.

After the merge, confirm the "Merge downstream PRs" run succeeded.

## Creating the companion

Branch from downstream trunk under the platform PR's exact head branch name, and link the platform PR in the description.
Where possible make the change work against both platform trunk and the platform branch, so downstream trunk stays green either way.
Then rerun the platform PR's Commercial/Rufus check.

A head branch cannot be renamed: a wrongly named companion needs a new PR under the right name.

## Keeping the pair current

Babysit the companion like the platform PR (`babysit-pr`), with two extras:

- Its CI tests the same-named platform branch, so a platform branch behind platform trunk can break it: bring platform trunk into the platform branch, then rerun.
- After every companion push or approval, rerun the platform PR's Commercial/Rufus check and its mergeability check.
