---
name: worktree-attach
description: Make a fresh git worktree runnable in seconds by attaching it to an existing instance of the project - dependencies cloned copy-on-write, its own config and dev server port, the instance's backend shared. Use before running tests, linters, builds or a dev server from a worktree, when a worktree command fails on missing dependencies or generated files, and when writing an attach script for a project that has none.
---

# Worktree attach

A worktree is a bare checkout: no installed dependencies, no generated files, no local config.
Installing all of that per worktree costs minutes and gigabytes; running many agents in parallel multiplies it.

**Attaching** supplies the worktree from an **instance**, a full checkout of the same project that already runs (dependencies installed, backend and database up).
Instances are few and long-lived; worktrees are many and cheap.

## If the project has an attach script

Its docs or a project skill name it. Run it from the worktree, run the steps it prints, repeat until it reports ready.
Then run tests, lint and the dev server the way it tells you, against the worktree's path.

## Writing one

An attach script is idempotent, does only deterministic work, and prints what is left for the agent as numbered steps: a fresh install, a broken backend, anything that can fail in an interesting way.
Done when it prints `READY` with the exact commands for this worktree.
What it covers:

| Resource | How | Why |
|---|---|---|
| dependency trees (`node_modules`, `vendor`, `.venv`, …) | `scripts/clone-tree` from a store keyed by the lockfile's hash; a miss installs once and parks the result | copy-on-write is seconds and no disk; a symlink makes tools resolve paths through the link into the instance |
| store validity | `scripts/npm-tree-matches-lock` (or the ecosystem's equivalent) | a hash of the current lockfile also matches a tree installed from an older one |
| generated config (`.env`, caches, build dirs) | written fresh, project root pointing at the worktree | a copied config silently reads the instance's files |
| backend, database | shared with the instance; the worktree's dev server proxies to it | one database per instance, not per worktree |
| dev server | its own port, derived from the worktree | many worktrees serve at once |
| browser access | `scripts/forward.mjs <host> <port>` forwards `localhost:<port>` | browser agents may only type test logins on `localhost` |
| containers | the worktree must be inside the container's mounts, or mirror-mounted at its host path | the container runs the worktree's code, not the instance's |

A shared database means shared migrations: anything that changes the schema or bulk data hits every worktree on that instance.
Give such runs a database copy of their own.

The `.git` of the worktree (`git rev-parse --git-dir`) is the place for per-worktree notes like a subject or skip lists: never committed, deleted with the worktree.
