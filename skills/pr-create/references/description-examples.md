# PR description examples

Approved samples from `shopware/shopware`, whose template numbers its sections:
section 1 is the why, section 2 the what. Read them for two things at once:

- **Altitude** — who the sentences are written for. Example 5 is the reference
  point: the only pair whose two halves are the same length, where just one of
  them is readable.
- **Length** — how much gets spelled out. Example 4 is the median PR. Example 2
  runs long only because it adds public API surface, and Example 1's section 2
  is a single sentence.
- **Detail** — how far into the change section 2 goes. Example 6 is the
  reference point; its negative is readable, short, and still three times too
  long, because it accounts for the change instead of pointing at it.

The contrast pairs (3, 4, 5, 6) put the shipped description **first** and the
draft it replaced second, in excerpt only. Read the positive as the model; read the
negative as a list of faults, not as prose to imitate.

Each example is wrapped in a four-backtick fence so its own code fences render
as part of the sample.

---

## Example 1 — skill signal for removed changelog entries

````
### 1. Why is this change necessary?

Changelog entries are gone (in favor of RELEASE_INFO-6.7.md).

Agents still don't know:
- because they are trained on old dataset
- there are stale `changelog/_unreleased/` files in the repository

Only `sw-review` informs the agent about the new `RELEASE_INFO-6.7.md`.

If I want to opt out of `sw-review` and use a different review skill the agent complains about a missing changelog entry.

Example run:
```
Nothing under changelog/_unreleased and no UPGRADE-*.md touch in this PR (checked origin/native-setup/02-transform...HEAD).

AGENTS.md → "Behavioural change, feature, deprecation, or config change? → check shopware-release-docs".

[...] Continues to enumerate what should be put inside changelog entries [...]
```

### 2. What does this change do, exactly?

Adds a clear signal in `shopware-release-docs` that changelog entries are in fact legacy.
````

**What makes it good:** section 1 names the mechanism (agents trained on the old
dataset + stale files still on disk), lists the causes as bullets, and proves
the failure with a real transcript excerpt instead of asserting it. Section 2 is
one sentence — it can be, because the "why" already carried the reader.

---

## Example 2 — Jest feature-flag helpers, with an accepted defect

````
### 1. Why is this change necessary?

Administration tests currently have to mutate the global feature-flag state manually. This adds boilerplate, can leak state between tests, and does not provide a declarative way to mark tests that become obsolete with a major feature flag.

### 2. What does this change do, exactly?

This extends Jest's `it` helper with two functions:

- `it.deprecated(removedIn)` normalizes the requested version and skips the test when the equivalent major feature flag is active.
- `it.activeFeatureFlags(featureFlags)` adds normalized flags to the default baseline for that test and restores the baseline afterward.


It also adds a `codemod:stabilize-feature-flag-in-jest` command. The command runs a dedicated `sw-test-rules/stabilize-feature-flag` ESLint autofix rule. It removes a stabilized flag from `it.activeFeatureFlags()` arrays and converts the helper to a regular `it()` call when no experimental flags remain.

**nit: introduced eslint bug:**
ESLint rule `jest/no-standalone-expect` would complain about that there are `expect` calls outside of `it`. with 

```js
additionalTestBlockFunctions: [
    'it.activeFeatureFlags',
    'it.deprecated',
]
```

has been fixed but the following bug was now introduced:

```js
it.activeFeatureFlags(['FLAG']).test('works', () => {
    expect(true).toBe(true);
});

// This should fail linting, but does not because it comes after the activeFeatureFlags() function
expect(true).toBe(true);
```

I think this bug is acceptable to happen (else we need to write that eslint rule on our own which I couldn't justify)
````

**What makes it good:** section 1 names three concrete costs of the status quo
(boilerplate, state leaking, no declarative marker) rather than "improves
testing". Section 2 is long *because* the change adds public surface — one
bullet per helper, each stating what it actually does, plus the codemod that
retires usages later.

**On the `nit:` — this is the exception, not a template.** It earns its place
because the PR knowingly ships a linting hole that a reviewer would otherwise
hit in review, and the snippet is the only way to show what still slips through.
This is the *only* example here that needed one. A PR with no accepted defect
gets no `nit:` section; do not manufacture one.

---

## Example 3 — native-setup tooling

**Shipped description (what to aim for):**

````
### 1. Why is this change necessary?

Native-setup authoring shipped its editor support
- for compile-time macros `swDefinePublic`/`swDefineOverride`/`useSw*`
- new ESLint rules: `valid-shopware-setup`, `native-setup-filename`
- but only as a template to manually copy to your plugin

The extension tooling (`admin:setup-extension-tooling`, #18331) already has a way to set up these files automatically.

Currently, it is also a bit unstable because the templates reach into node_module entries with private API.

### 2. What does this change do, exactly?

Makes native-setup config a first-class part of `admin:setup-extension-tooling`, then deletes the hand-copied templates.

**to be followed up** `.vue` files lose the *extra* type-aware ESLint coverage `.ts` files get.
That includes:
- unsafe-any usage
- floating promises, …

Making those work on `.vue` needs `@vue/eslint-config-typescript` and some plumbing in the extension tooling.
Follow up Issue: https://github.com/shopware/shopware/issues/19296
````

**What makes it good:** three short bullets carry the "why". The instability is
one sentence — "reach into node_module entries with private API" — not two
paragraphs. Section 2 is a single line and does **not** enumerate the touched
files; the reviewer reads the diff for that. The one thing the reviewer must
actually weigh (deferred `.vue` type-aware coverage) sits under a scannable
`**to be followed up**` marker with the issue link.

**The padded draft it replaced — excerpt only:**

````
Native-setup authoring shipped its editor support (the compile-time macro globals `swDefinePublic`/`swDefineOverride`/`useSw*`, the `valid-shopware-setup` and `native-setup-filename` lint rules, and the macro type declarations) only as a set of files the developer copies by hand from `build/vue-setup-transform/templates/custom-plugin-workspace` into `custom/`.

[… two more paragraphs on the deep `node_modules` paths, then the template README quoted verbatim in a fenced block …]

### 2. What does this change do, exactly?

- **`extension-tooling/eslint.mjs`** — the shared `shopwareAdminExtension` factory gains a … [one bullet per touched file, ~8 of them, each a paragraph] …
````

Its faults, in order of cost:

1. The point is buried under parentheticals — the reader reaches the verb three
   clauses late.
2. A verbatim README block where one clause did the job.
3. Section 2 is a file-by-file inventory. That is a changelog, and the diff
   already states it more precisely.
4. The deferred `.vue` coverage — the only thing needing a decision — was
   nowhere near the top.

---

## Example 4 — effect-scope fix (the median PR)

`### Problem` / `### Fix` here stand in for template sections 1 and 2.

**Shipped description (what to aim for):**

````
### Problem

In late overrides using `overrideComponentSetup` watchers are not unwatched because they are out of the effect scope.

### Fix

Run the override callback in the correct effect scope: `ownerScope.run(...)`. Unmounting will then automatically unwatch the watchers
````

**What makes it good:** a single-mechanism fix earns a two-sentence description.
Symptom, cause, one-line remedy — that is the entire reviewable content. This is
what most PRs should look like.

**The padded draft it replaced — excerpt only:**

````
`createExtendableSetup()` applies overrides through a watcher on the overrides array. Overrides that register **after** the component mounted (async Options API shim conversions, plugins registering late) therefore run inside that watcher's callback — where **no effect scope is active**. Any `watch()` or `computed()` such an override creates is never collected by Vue …

Overrides applied synchronously during setup are unaffected — they run inside the component's scope and dispose correctly.

### Fix
… No bookkeeping, no behavior change for already-working paths …

### Test
New spec: mounts an extendable component, registers an override **after** mount whose callback creates a `watch()` on an external ref, asserts the watcher fires while mounted and stays silent after `unmount()`. Fails without the fix, passes with it.
````

Its faults, in order of cost:

1. An interior-mechanics lecture on code the diff shows.
2. A paragraph on the path that already worked.
3. Defensive reassurance ("no bookkeeping, no behavior change").
4. A prose retelling of the new spec. Never narrate the test — a reviewer reads
   it.

---

## Example 5 — sw-block root elements: same length, wrong altitude

Section 1 only — altitude lives there. Both halves run about 270 words, so this
pair isolates altitude from length: the negative is **not** too long, it is
written for someone who already works inside the Vue renderer.

**Shipped description (what to aim for):**

````
### 1. Why is this change necessary?

Administration components are being converted to `<script setup>` SFCs, and their templates are wrapped in `<sw-block>` — the override system extensions hook into. Two unrelated bugs make the converted components misbehave: one hits every block-wrapped component at runtime, the other is in what the migration codemod generates.

**Every component wrapped in a block loses its root element.**

A Vue component normally has one root element. `sw-block` handed its content back as a *list* of nodes, and Vue turns any list into a fragment — a run of nodes with an invisible text marker where the root element would be. It does that even when the list holds exactly one element, so this hit every converted component, not only the ones with several blocks side by side. Two things break as a result:

- Attributes and listeners the caller puts on the component (`id="…"`, `@click`) are dropped, because Vue has no root element to put them on.
- `this.$el` returns the invisible marker instead of an element, so every piece of code that measures or positions a component breaks — `getBoundingClientRect()` in `popover.directive.ts`, plus `appendChild`, click-outside detection, `v-tooltip`, `v-draggable` and `<transition>` elsewhere.

**A `<script setup>` variable can silently take over a component tag.**

In `<script setup>`, Vue resolves a tag by first looking for a variable of that name in the setup scope — trying the tag as written, camelCased and Capitalized — and only then at registered components. So a prop named `routerLink` makes `<router-link>` render that prop's value. The same goes for template refs: a `ref="swTree"` takes over the `<sw-tree>` it points at. Since a ref is nearly always named after what it points at, that is the shape the codemod kept producing.
````

**What makes it good:** one scope sentence opens it, so the reader knows the
area and that two separate problems follow before any mechanism arrives. Each
problem gets a bolded plain-English heading to navigate by. Internal machinery
is described in the framework's user vocabulary — "handed its content back as a
*list*", "an invisible text marker where the root element would be" — and every
reference points at something already on the page. Issue numbers appear nowhere;
they are in section 4, each behind a label.

**The draft it replaced — same length, wrong altitude:**

````
`sw-block` returned the block slot's node array from `render()`, and Vue's `normalizeVNode` turns any array — even one of length 1 — into a `Fragment`. So **every** component whose template is a `<sw-block>` was fragment-rooted, not only the multi-block ones the issues describe:

- Vue can only clone fallthrough attributes onto an element or component root, so a caller's non-prop attribute was dropped (#19554).
- `$el` is `subTree.el`, which for a fragment is its start anchor `Text` node, so `popover.directive.ts` throwing on `$parent.$el.getBoundingClientRect()` (#19559) was going to happen for every converted component. Same for `sw-image-preview-modal` (`appendChild`), `sw-product-detail-context-prices`, …

#19477 is separate: a `<script setup>` template resolves a tag through Vue's `resolveSetupReference()`, which tries the tag as written, camelized and capitalized, and prefers a setup binding of any of those names over the registered component. …
````

Its faults, in order of cost:

1. **No scope sentence.** It opens on `render()` internals. The reader has no
   idea what area this is or that two separate bugs are coming.
2. **Implementer vocabulary as the load-bearing terms.** `normalizeVNode`,
   "the block slot's node array", `subTree.el`, `resolveSetupReference()` are
   doing the explaining, and nothing explains them.
3. **A dangling reference.** "even one of length 1" — of *what*? The reader
   retraces to find the array, and pays that toll on every such phrase.
4. **An issue number used as a subject.** "#19477 is separate" assumes the
   reader has the tracker memorised. An external reviewer never knew it.
5. **Unheaded problems.** The second bug starts mid-paragraph, so nothing marks
   the transition between two unrelated root causes.

Length is *not* on this list. The rewrite is the same size.

---

## Example 6 — floating-ui boundaries: a map, not an account

`## How?` stands in for section 2. This pair is neither about altitude nor
really about length — the negative is readable and only ~230 words. It gives a
full account of the change where the reviewer needed a map of it, and expects
prose to do the job the diff does.

**Shipped description (what to aim for):**

````
## How?

- Adds size() and flip() middlewares.
- It calculates the parent boundaries of the referenced element
- min height is 150px
````

**What makes it good:** three bullets name the three decisions a reviewer needs
to go looking for, and stop. It assumes what is true — the reviewer opens the
diff. Everything the long version adds is either a defence of a decision nobody
contested, or a restatement of code, and the diff carries both more precisely.

**The draft it replaced — a full account instead of a map:**

````
The floating content is teleported to `<body>` and positioned `fixed`, so its own clipping ancestors are only the viewport — sizing and flipping never learned about the dialog body the reference sits in. Both middlewares now take a **`boundary`** of the reference's scrollable ancestors (`overflow-y: auto | scroll`). `overflow: hidden` ancestors are skipped, because they are usually field-sized boxes that would collapse the boundary onto the reference itself. With no scrollable ancestor at all the boundary stays at floating-ui's default `"clippingAncestors"`, so popovers outside any scroll pane keep their current behaviour.

**`size()` runs before `flip()`**, so content that is merely too tall shrinks and scrolls where it is instead of jumping over the field it belongs to. Flipping was the first attempt here, and it swallowed the field's own label and everything filled in just above it. The cap never goes below 150px — three result rows — and whatever is still taller than the pane at that floor keeps overflowing, which is what leaves `flip()` a reason to change sides.

Content with no scrollable region ignores the cap and would only hide its overflow from `flip()`, so it is not capped at all: a context menu near the bottom of the viewport still moves sides rather than sitting half off-screen. `.mt-floating-ui__content` becomes a flex column so the cap reaches the slotted element — a block child with its own `max-height` would keep painting outside it.
````

Its faults, in order of cost:

1. **It reads as prose what the reader will read as code.** The exact
   properties (`overflow-y: auto | scroll`), the selector
   (`.mt-floating-ui__content` becoming a flex column), the library default
   kept (`"clippingAncestors"`), the call ordering, the chain between them.
   Every one is a line of the diff, restated less precisely than the diff
   states it.
2. **Every decision comes with its defence.** Why `overflow: hidden` is
   skipped, why `size()` runs before `flip()`, why the floor is 150px, why
   uncapped content still flips. Each is a `because` clause guarding against an
   objection the reviewer has not made.
3. **The "why" leaked into the "what".** The opening paragraph — teleported to
   `<body>`, clipping ancestors are only the viewport — is section 1 material.
   By section 2 the reader has already accepted the premise.
4. **A rejected attempt retold.** "Flipping was the first attempt here, and it
   swallowed the field's own label" is how the change was found, not what it is.
5. **Reassurance.** "popovers outside any scroll pane keep their current
   behaviour."

Note what the shipped version gives up: the ordering, the `overflow: hidden`
skip, the flex column, the 150px rationale. All real, all still in the diff,
none of them a thing a reviewer needs prose for.

---

<!-- Append new approved examples below as: ## Example N — <short slug> -->
