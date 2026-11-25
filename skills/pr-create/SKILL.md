---
name: pr-create
description: Create a GitHub pull request with the user's saved defaults (draft or ready, assignee, labels per repo) and a tight description that follows the repo's own template. Use whenever the user asks to create/open/raise a PR, "put this up as a PR", "make a PR for this branch", or to fill in a PR description before opening it.
license: MIT
---

# Create a PR

## Preferences

`~/.agents/github/preferences.md` holds the user's standing answers under "Pull requests", shared with `issue-create`:

- draft or ready for review;
- assignee (`@me`, a login, or none);
- labels per repository (e.g. `domain/<team>`, `component/<area>`), applied when they exist there;
- description style rules on top of the ones below.

Read it first. No answer for this repository yet ⇒ ask in plain chat, not a question tool: numbered questions, each with your recommendation, in one round.
Look the options up before asking (`gh label list`, the PR template, the last PRs the user opened in this repo) so every recommendation is concrete.
Then ask whether to keep the answers for good or for this session only, and write the kept ones to the file.

## Procedure

1. **Read `references/description-examples.md`** before writing a single line of
   the description. It calibrates altitude and length together.
2. Follow the repo's own PR conventions: its pull request template verbatim
   (every section, in order, original headings), its title convention (e.g.
   a conventional title with scope, `fix(administration): …`), no AI
   attribution trailers, no invented extra sections. The subject says what the
   change achieves, not how it works:
   `fix(administration): keep the product filter after a reload`, not
   `fix(administration): persist filter state in the route query`.
3. Determine the **base branch** explicitly and stack if the user intends to.
4. Check whether the branch already has a PR: `gh pr view --json url,body`.
   If it has one, do not create a second one. Update its description in place,
   and first check whether the public description changed since you last
   updated it.
5. Review the diff against the base (`git diff --stat origin/<base>...HEAD`,
   then the diff itself). It must contain only this change. Stray files or
   commits from another branch in the stack ⇒ stop and report them.
6. Fill the **Impact** part of the what section from the `pr-review` skill's
   "Impact and blast radius" report, see Impact below.
7. Write the body to a file in the scratchpad, never inline in the shell:
   `gh pr create --body-file <path>`. Heredocs mangle the nested fenced code
   blocks the examples rely on.
8. Before creating: reread the draft against **every** check under Description
   style below. Altitude checks first (a draft can pass the length budget and
   still be unreadable.) Then check the title, the body and every quoted log or
   screenshot for secrets and private details (tokens, internal URLs, customer
   data).
9. Create it: no confirmation step, no preview-and-wait. A PR is cheap to
   edit; the user reviews it on GitHub, not in the terminal.
10. Report back with the PR URL, the base you chose, and anything you had to
    assume. Do not paste the body back into the chat.
11. Hand the PR to babysitting when `babysit-pr` is installed: its
    "Orchestrator" section says whether a `babysit-all-prs` session takes it over.

```bash
gh pr create [--draft] [--assignee <assignee>] [--label <label>...] --base <base> --title "<type>(<scope>): <subject>" --body-file <scratchpad>/pr-body.md
```

If a label or assignee is rejected (missing label, no write access), create the
PR anyway and report exactly which piece did not apply — never silently drop it.

# Description style

- **Altitude**: how deep into implementation detail a sentence reaches. Wrong
  altitude is unreadable at any length.
- **Detail**: how far into the change the what section goes. The reader opens the diff
  themselves; a draft that reads as substantial because it accounts for
  everything still cuts to a third of itself.
- **Length**: how much you spell out overall. Too long is unreadable at any
  altitude.

Fix them in that order. Altitude and detail are what a length cut alone never
finds: a draft can sit inside the budget and still be opaque, or still be doing
the reviewer's reading for them.

Use new lines to separate information visually. State what is, not what isn't.

## Altitude: write for a cold reader

The **cold reader** has not seen the branch, does not work in this subsystem,
and looks nothing up while reading. Every check below serves that one reader.

**Open the why section with a very short explanation of the scope**: what area this is, and how many
separate problems the PR contains. The reader needs a frame before the first
mechanism.

**Use the vocabulary of the framework's users, not its implementers.** Reach
for an internal symbol only when the reader has to grep it, and then define it
in the clause that introduces it.

| Implementer vocabulary | Cold-reader vocabulary |
|---|---|
| `normalizeVNode` turns the block slot's node array into a `Fragment` | `sw-block` handed its content back as a *list*, and Vue turns a list into a fragment |
| the component is fragment-rooted, so `$el` is `subTree.el` | `this.$el` returns that fragment instead of an element, so code that measures or positions the component breaks |

**Give each distinct problem a bolded plain-English heading** when the PR
carries more than one. The headings are what the reader navigates by.

## Detail: the what section is a map, not the territory

**Expect the reader to open the diff.** The why section had to land on a **cold
reader** with no lookups; the what section prepares the reader to dive in fully and use this section as a sparing partner.

Also, list your decisions here. Give one bullet per decision the reviewer:

| Too much detail | High level enough |
|---|---|
| `overflow: hidden` ancestors are skipped, because they are usually field-sized boxes that would collapse the boundary onto the reference itself | It calculates the parent overflow boundaries of the referenced element |
| The cap never goes below 150px — three result rows — and whatever is still taller than the pane at that floor keeps overflowing, which is what leaves `flip()` a reason to change sides | min height is 150px |
| `.mt-floating-ui__content` becomes a flex column so the cap reaches the slotted element — a block child with its own `max-height` would keep painting outside it | *(nothing — this is a line of the diff)* |

Two habits produce almost all of it:

- **Name the decision, drop the defence.** Say what the change does, not why
  each choice is the right one. Judging that *is* the review, and the reviewer
  does it against the diff. Every `because` clause looks like substance, which
  is why this survives length cuts that catch nothing else.
- **Name the thing, not how it is wired.** Selectors, CSS properties, exact
  default values, call ordering, type names, the chain of effects between them —
  all of it is the diff, stated less precisely.

Never a file-by-file tour: the diff is the file list. Sometimes the right amount
of detail for a real change is zero bullets, and the reviewer still sees it.

## Length — the budget

Overrun only for a reason you could say out loud. Scope, not effort, buys
length: two genuine root causes buy two blocks, a hard debugging session buys
nothing.

| Section | Budget |
|---|---|
| Why | one scope sentence, then 2–3 sentences per distinct problem plus its consequences as bullets |
| What | one bullet per decision the reviewer should look for |
| Evidence | one fenced block at most; a second is padding |

**The why section does the heavy lifting.** Name the concrete mechanism that is wrong
or missing, not the vibe ("improves DX"). The cold reader must understand *why
this is necessary* from the why section alone.

**Show, don't assert.** Paste the real thing once — the error, the failing
assertion, the agent transcript, the stale path. A quoted run beats three
sentences of description.

**Cut on sight:**

- reassurance — "no behaviour change", "no bookkeeping", "purely additive"
- prose retellings of the new test; a reviewer reads the spec
- the path that already worked correctly
- "as discussed", rejected alternatives, how the bug was found

## Impact — taken from pr-review

The what section always gets a `#### Impact` sub-section, written from the `pr-review`
skill's "Impact and blast radius" report:

- A `pr-review` report on this branch exists in the session ⇒ take its impact
  section.
- None exists ⇒ run only step 6 ("Assess impact") of `pr-review` against the
  diff. The full review with its environment and reproductions is not part of
  filing a PR.

Keep the report's bullets and order, and drop every bullet whose value is
"none": the template forbids stating what did not change.

```markdown
#### Impact

- Public API: new `sw-product-filter` prop `persistInRoute`
- Affected: product listing in the Administration, extensions overriding its filter block
- Risk: low. The filter falls back to the old behaviour when the route has no query.
```

A breaking change also names what the people building on it have to do.

## The remaining sections

**A testing section** gets real reproduction steps whenever the change has
observable behaviour — commands, clicks, before vs. after. Write "n/a" only
when there is genuinely nothing to observe.
**Comment stubs** the template leaves for the author stay out.
**A checklist** is ticked honestly — tests only if tests were written, release
notes or upgrade docs only if those files were actually touched. When a box
stays unticked for a defensible reason, add one visible line saying why; a
reviewer will ask otherwise.

## Known defects and deferred scope — the exception

**Most PRs have none. Do not go looking for one to fill a slot.** `nit:` is not
part of the default shape; it is rare.

Add a note only when you knowingly ship something the reviewer would otherwise
have to discover in review:

- **A defect you accept** — one line naming it, one clause on why living with it
  beats fixing it, and a snippet only when the failure is not obvious from that
  sentence. Example 2 is the shape.
- **Scope you deferred** — `**to be followed up**` plus the issue link.
  Example 3 is the shape.

Use it for an ordinary limitation, a "possible future improvement", or anything
the diff already makes plain, and it stops meaning anything.

# Growing the example set

When the user says "this is a good PR
description" / "add this as an example":

- Append a new `## Example N — <short slug>` section to
  `references/description-examples.md`, wrapped in a four-backtick fence so
  inner code fences survive. Excerpt it down to the sections that carry the
  lesson — a whole PR body is rarely needed.
- Add a one-line **What makes it good** note under it — the transferable rule,
  not a summary. When the example is unusually long, say what bought the length.
- Do not rewrite or "harmonise" older examples; the spread between them is the
  signal.
