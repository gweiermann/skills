---
name: pr-review
description: Full pull request review that collects findings, reproduces every one end to end on an environment running the PR, splits them into caused-by-this-PR and pre-existing, and writes a short human-readable report with impact and blast radius first. Reviews a backport for fidelity to its original PR. Use when asked to "review this PR", for a verified review, or for a reviewer-ready summary of a branch or diff.
---

# PR review

**Backport?** The PR targets a release branch, names an original PR, or carries `cherry picked from` commits:
read [`BACKPORT.md`](BACKPORT.md) first; it turns the review into a fidelity check against the original.

## 1. Collect findings

- A code review of the target (PR number, branch, or local diff): the `code-review` skill where the harness has one.
- A usability walk when the PR changes something a human uses (a screen, an API endpoint, a CLI command, a config option, a message): the `user-review` skill if installed.
  Skip it for test-only or purely internal changes, and say so in the report.
- Run them in parallel when both apply.

## 2. Run the PR end to end

Findings are proven on an environment that runs the PR's own code (and its base PR when stacked), never on an older build with a shim or mock.

Learn how this project runs from its own docs first: `AGENTS.md`, `README`, `CONTRIBUTING`, a dev-environment skill.
Then, cheapest first:

1. **Reuse** an environment already serving the PR head.
2. **Build one beside** what the user runs: a worktree of the PR, its own database copy, its own ports.
   Pick names and ports nobody uses; check before creating them.
3. **Take over** a shared environment only when it is disposable and nobody is using it.

The user's own checkouts and primary database stay as they are.

Go the full way, as close to a real user's setup as possible.
A mocked input or a unit-level check is a first probe, never the proof.
A broken environment is yours to repair; data a journey needs gets created for real (install the extension, write the rows, create the users with the right roles).
If something still blocks a step, name the step and why in the report.

## 3. Verify, reproduce and screenshot every finding

Check each finding against the PR head and its base.
Then walk it from the user's side in the running app:

- Mark the defect with a red 4px rectangle before the screenshot.
- One screenshot per step when the journey has several; for a finding without a visual defect, screenshot its visible symptom (toast, error, console, terminal output).
- Save them in the scratchpad as `<n>-<step>.png`.

Drop what you cannot prove; mention only the count.

Give every kept finding:

- **Confidence**: confirmed (reproduced end to end) or likely (strong code evidence; say what blocked the reproduction).
- **Priority**: high (data loss, crash, security, broken main flow), medium (wrong behaviour in an edge path), low (polish).
- **Relevance**: who reaches the broken path in normal use? Nitpicks that change nothing go out.

## 4. Split by scope

The question is whether the PR caused it.

- **In scope**: introduced or made worse by this PR: regressions, bugs in new code, broken compatibility, missing tests for the new behaviour, an incomplete fix of the issue the PR claims to fix.
- **Out of scope**: already true on the base branch.

Prove "pre-existing" on the base branch, not by guessing.

## 5. Assess impact

- **Public API**: changed or removed public symbols, routes, schemas, events, config, extension points.
  Use the project's breaking-change rules where it has them.
- **Blast radius**: who and what can be affected, and how far from the edited lines.
- **Risk**: low / medium / high, with one sentence why.

## 6. Report

Layered: summaries first, details below, screenshots last.
Run it through a de-AI-ing pass (the `humanizer` skill if installed).

````markdown
## What's new
2–4 sentences: what the PR changes, from the user's or developer's side.

## Impact and blast radius
- Public API: … (or "none")
- Breaking changes: … (or "none")
- Affected: …
- Risk: medium. One sentence why.

## Findings in this PR
Sorted by priority, then confidence. Each one a text code block:

```text
1. <short title>  ·  High · confirmed
   When <who or which condition>:
   - <what the system does>
   - <what the user sees>
   Suggestion: <fix>
```

## Implementation details
How the codebase shifts, so the reader gets its shape before reading the diff.
Three to five text code blocks, sorted by weight:

```text
1. <the shift in a few words>
   Before: <how it worked>
   After:  <how it works now>
```

## Details
### 1 · Reproduction
1. Setup: <user, role, data>
2. <step the user takes>
3. <what comes back>

Screenshots: [1-step2](<absolute path>), …
Evidence: <code snippet> + link to file:line

## Before merge
Missing tests, missing changelog entries, open questions for the author, what was not checked and why.

## Out of scope
Pre-existing issues worth a follow-up. One line each with a link.

## Try it yourself
URLs, logins and roles, seeded records, and how to stop the environment.
````

The finding summaries state observable behaviour only: no "because", no fix mixed into the bullets.
Leave the environment running for the user and leave empty sections out.
Post on GitHub only when asked.
