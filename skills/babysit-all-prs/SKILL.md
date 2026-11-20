---
name: babysit-all-prs
description: Run one long-lived orchestrator session that babysits all of the user's open PRs and drafts, takes hand-offs from other sessions, and routes every human decision to a separate session. Use when the user wants all their PRs babysat, a PR orchestrator, or a "PR god".
---

# Babysit all PRs

One session owns every PR worth watching.
It applies `babysit-pr` to each, keeps a ledger so it survives compaction and restarts, and never blocks on the user: it is a worker that needs no attention.

## State

All in `~/.agents/babysit/`:

- `orchestrator`: this session's id, in whatever form the harness addresses sessions (a T3 thread id, …). Write it on start; other sessions read it to find you.
- `preferences.md`: scope filters and standing rules, shared with `babysit-pr`.
- `ledger.md`: per PR its state, owner session, merge mode, pending decision, and notes a fresh reader cannot get from GitHub.
  Read it first on every wake; update it after every action.

## First run

Without saved preferences, interview the user in plain chat, not a question tool: numbered questions, each with your recommendation, in one round:

- **Which PRs:** repos or orgs, own only or also assigned and review-requested, drafts, the inactivity cutoff after which a PR is left alone, anything to skip.
- **What you may do:** bring bases in, fix CI, merge (per-PR opt-in, or auto-merge takeover), post on GitHub (off unless they opt in).
- **What they never want.**

Then ask: keep these for future runs, or for this session only?
Show the resulting PR list and get a yes before watching anything.

## Sweep

On start and on a tick (as often as preferences say; hourly otherwise): list open PRs matching the filters, sort them into active and inactive, watch the new active ones, and stop touching ones that went stale.
Activity counts only the user's and their sessions' work, never this session's own pushes.
An inactive PR is left alone completely until the user works on it again or hands it over.

## Work

This session decides and keeps the ledger; children do the heavy work.
Fixes, conflicts and failure classification go to subagents (prefer ones that survive a restart of this session), each in its own temporary worktree for one PR, temp branches under a unique prefix.
Drafts have live authors: fetch right before every push, and a rejected push means fetch, merge, retry.

## Hand-offs

Sessions that open or update a PR send its URL, their session id, and context GitHub cannot show.
Record it in the ledger, start watching, confirm in one line.
The author session keeps the design of its draft; you keep it green and current.

## Decisions

When something needs the user (a hard conflict, an ambiguous fix, an opt-in like merging, any question `babysit-pr` would ask):

1. The PR's owner session is alive ⇒ send it the question; it asks the user, implements the answer, and reports back to you.
2. Otherwise start a new session titled `Decide: <PR> <topic>` with the full context, the options, your recommendation, and the instruction to get the decision, implement it, and report back to the id in `orchestrator`.

Record the pending decision in the ledger and carry on with everything else.

## Waiting

Watch per `babysit-pr`. A wake without news ends silently; in T3 Code, settle the thread.
