---
name: user-review
description: Review a pull request the way the humans who use it meet it — reproduce the bug it fixes, then walk every surface it changes, be it a screen, an API endpoint, a CLI command, a script, or a config option, and judge what is intuitive, confusing, or broken. Use when asked for a user review, UX or DX review, usability check, or a "use it like a user / integrator / developer" review of a PR. Findings stay inside the PR's footprint.
license: MIT
---

# User review

You are the first real user of the change.
Code reading only tells you where to look; every finding comes from using the running code.

Three leading words carry the whole review:

- **Surface**: anything a human operates or reads. A screen, dialog, field, label or notification; an API endpoint, its request schema, response and error body; a CLI command, its help text, prompts, output and exit code; a script or repo tool; an env var, config key or manifest field a person writes; a log line or error message someone reads to fix a problem.
- **Footprint**: the surfaces the PR touches, and the paths a human takes to reach them.
- **Journey**: one task a real user does, from where they start (the main menu, the API docs, `--help`, the README) to the outcome they wanted.

The project's own docs may define its personas and surface kinds; use those where they exist.

## 1. Read the promise

Fetch the PR, its linked issue, and the diff (`gh pr view <n> --json title,body,closingIssuesReferences,headRefName,baseRefName`, `gh pr diff <n>`).

Write down two things:

1. **The promise**, in one sentence from the user's side: "A user can now …", "An integrator gets a 400 naming the field instead of a 500 …", "`<command>` no longer …".
2. **The footprint**: each changed file mapped to the surface it changes, how a human reaches it (route, URL, endpoint, command, script, config key), and the persona who uses it:
   - end user of a UI, with full and with restricted rights;
   - integrator calling an API;
   - operator running CLI commands, deploying, setting env vars and config;
   - developer running the repo's scripts and tooling;
   - extension author writing a manifest, plugin config, or theme.

   Translations, error messages, validation messages and command output strings are footprint too.

Public code symbols belong to the code review; this review covers what a person types, reads, or clicks.

Done when every changed file is either mapped to a surface or marked "no human-facing surface" with the reason.

## 2. Get two running versions

You need **before** (the PR's merge base) and **after** (the PR head), side by side, each in its own worktree.
Learn from the project's own docs (`AGENTS.md`, README, a dev-environment skill) how to run a checkout.
Give each version what its footprint needs: a UI-only change may share one backend; server code, schema or API changes need a backend and a database copy per version, each on its own port.
Leave the user's own checkouts alone, and any instance or database the project's docs or the user's preferences protect.

How to reach and drive each surface kind lives in [`SURFACES.md`](SURFACES.md).
Read the section of every kind in the footprint before you start walking.

Done when you can reach every surface in the footprint on both versions, and you have confirmed each one runs its own worktree's code (a route, field, or output that only one side has).

## 3. Reproduce the fix

For a bug fix: follow the issue's steps on **before** and see the bug, then the same steps on **after** and see it gone.
Capture both (see the evidence rule in [`SURFACES.md`](SURFACES.md)).
When the bug does not reproduce on **before**, say so plainly; it is the most important line of the report.

For a feature: do the promise end to end once, on **after**, as the persona who asked for it.

Then vary the trigger.
A fix that holds only for the exact steps in the issue is a partial fix: try the second record, the other language, the reload, the back button, the save-then-edit-again; for an API, the other verb, the partial payload, the bulk path; for a command, the non-interactive run, the second run, the empty database.

## 4. Walk the journeys

For each surface in the footprint, walk each journey that crosses it, as its persona.
Start where that user starts, never on a deep link or a known payload: the user knows the main menu, the API reference, `--help`, and the README.

At every step, ask what a first-time user sees and expects:

- **Discovery**: can they find the entry point? Is it where a sibling feature, endpoint, or command lives?
- **Wording**: does each label, hint, message, and error say what happens, in the user's words, not the code's?
- **Feedback**: does the user learn the outcome? Does a refusal say why and how to recover?
- **Consistency**: does it behave like its siblings?
- **Recovery**: can they cancel, undo, retry, or re-run without losing work or doubling it?
- **States**: empty, one, many, very long values, invalid input, missing permissions, slow network or large data.
- **Persistence**: after reload, after re-reading the record, in the other language, in the other view of the same data.

[`SURFACES.md`](SURFACES.md) adds the questions specific to each surface kind.

Also walk the journeys that **pass through** the changed code without being its subject: a changed shared component or base class affects every surface that uses it.
Find those users by searching for the changed symbol, and walk the one or two most common.

Done when every footprint surface has at least one journey walked on **after**, and every suspicion has a matching walk on **before**.

## 5. Scope every finding to the PR

Keep a finding only when it passes the **base test**: walk the same steps on **before**.

| On before | On after | Verdict |
|---|---|---|
| fine | broken or confusing | **keep**: the PR introduced it |
| broken | still broken, and the PR claims to fix it | **keep**: the fix is incomplete |
| broken | still broken, and the PR touches that surface for a different reason | keep only when the PR makes it worse or newly reachable |
| same | same | **drop** |
| (new surface) | confusing | **keep**: it is the PR's own surface |

A dropped finding leaves the report entirely.

## 6. Report

Lead with the promise and its verdict in one line: does the fix reproduce and hold, or does the feature do what it says.

Then each finding, most user impact first:

- **Persona and journey**: who, doing what.
- **When / Expected / Actual**, with before and after evidence (read each piece back first and confirm it shows the claim).
- **Why**: the code that causes it, quoted as a snippet with a `path:line` link.
- **Suggestion**: what a user would need instead; a concrete code before/after when the fix is clear.

End with the surfaces you walked and found clean, one line each, and the surfaces you could not exercise and why.

Save evidence and notes under `~/.claude/pr-reviews/<owner>-<repo>-pr<n>/user-review/` and link every file individually.
Report in the chat; post on the PR only when the user asks.

## 7. Clean up

Delete data you created (records, integrations, tokens, users), stop every server you started, drop the database copies you made, and remove both worktrees.
Anything you changed server-side, put back.
