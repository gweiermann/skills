---
name: issue-create
description: Create a GitHub issue with the user's saved defaults (type, labels, assignee, project and its status column per repo) and a body that fills the repo's issue form. Use whenever the user asks to create/open/file an issue, ticket or bug report, or "put this on the board".
license: MIT
---

# Create an issue

## Preferences

`~/.agents/github/preferences.md` holds the user's standing answers under "Issues", one block per repository, shared with `pr-create`:

- issue type (e.g. `Bug`, `Story`, or "from the template");
- labels (e.g. `domain/<team>`), applied when they exist there;
- assignee (`@me`, a login, or none);
- project and the status a new issue lands in (e.g. project `<board>`, status `Backlog`);
- parent issue or milestone, when new issues usually hang under one.

Read it first. No answer for this repository yet ⇒ ask in plain chat, not a question tool: numbered questions, each with your recommendation, in one round.
Look the options up before asking so every recommendation is concrete: `gh label list`, the issue forms in `.github/ISSUE_TEMPLATE/`, `gh project list --owner <owner>` and the project's status options (`gh project field-list <number> --owner <owner>`).
Then ask whether to keep the answers for good or for this session only, and write the kept ones to the file.

## Procedure

1. **Pick the template.** The repo's issue forms (`.github/ISSUE_TEMPLATE/*.yml`, `*.md`) decide the body: choose the one matching the kind of issue, and fill every required field under its label, in order. A form's own `type:` and `labels:` apply on top of the preferences.
2. **Check for a duplicate**: `gh issue list --search "<key words>" --state all`. A likely duplicate ⇒ show it to the user and stop until they decide.
3. **Write for a cold reader.** The title names the observable problem or the outcome in plain words. A bug states what happens, what should happen, and the steps to get there; paste the real error or log once instead of describing it.
4. Write the body to a file in the scratchpad, never inline in the shell. Check title and body for secrets and private details (tokens, internal URLs, customer data).
5. Create it with the preferences applied:

   ```bash
   gh issue create --title "<title>" --body-file <scratchpad>/issue-body.md \
     [--type <type>] [--label <label>...] [--assignee <assignee>] [--project "<project title>"] [--parent <number>]
   ```

6. **Set the project status.** `--project` only adds the item. Get its id from `gh project item-add <number> --owner <owner> --url <issue URL> --format json` (returns the existing item), the status field and option ids (`gh project field-list <number> --owner <owner> --format json`), then `gh project item-edit --id <item> --project-id <project> --field-id <field> --single-select-option-id <option>`.
   Missing `project` scope ⇒ the user runs `gh auth refresh -s project`; say so and leave the status for after.
7. Report the issue URL and every default that did not apply (missing label, rejected type, no project access). Create the issue anyway; never drop a piece silently.
