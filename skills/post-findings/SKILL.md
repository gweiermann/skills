---
name: post-findings
description: Post review findings to a GitHub pull request as comments in the user's pending draft review, written short for a human who decides whether to fix them. Use whenever a finding should go onto GitHub - "post this finding", "comment that on the PR", or "put findings 1 and 3 on GitHub".
---

# Review findings on GitHub

## Posting

Every finding goes into the user's **pending** review.
The user reads the draft on GitHub and submits it themselves.

```bash
<this skill's directory>/scripts/add_pending_comment.sh <owner/repo> <pr> <path> <body-file> [<line> [<start-line>]] [--side LEFT|RIGHT]
```

- The script adds the comment to the user's pending review on that PR, or opens one.
- `<line>` is the line in the PR head; use `--side LEFT` for a removed line, and `<start-line>` for a range.
- With no line, or a line outside the diff, the comment goes on the whole file.
- The script prints the comment URL. Posting is done when every finding has one.

Post through this script only.
`gh pr review`, `gh pr comment`, the REST `pulls/<n>/comments` endpoint and `submitPullRequestReview` all publish at once.

After posting, give the user each comment's text and URL, and say that the review is still pending.

## Communicating clearly

Write for an intelligent but low-context reader. The person reading has not seen your tool calls, your reasoning or the files you opened, and may be switching in from other work. Messages should generally be self-contained: the reader should understand what you mean without having to dig for other context. Put the key points in the first few sentences. Practice progressive disclosure in your sentence order, and do not use undefined references and ideas in line 1 that won't make sense until the reader reaches line 12.

Use plain words, and write in clear, understandable full sentences. Do not use a term or abbreviation that you made up during the work. Say what the thing is in a way any reader would understand. Write mostly in the style of ASD-STE100 Simplified Technical English: short sentences, one idea per sentence, active voice, and consistently using the same word for the same thing. Use a paragraph of flowing prose where ideas connect, and keep bullets for lists of separate items. Leave out unnecessary details unless the reader asks and practice concision, but do ensure that your messages have the key context. Aim to make your user-facing text as human-readable and clear as possible.

## Writing a finding

A human reads the comment first and decides whether it gets fixed.
An agent then does the fix and works out the edge cases on its own.
So the comment only has to make the problem clear at a glance.

- **The problem** in roughly one to three sentences: what goes wrong, and for whom.
  Describe the overall problem, not each case where it shows up.
- When a common name fits the finding, lead with it ("Code duplication: …", "Unused import: …").
  The name already carries the impact, so leave out the consequences everyone knows.
  The reader has not seen the diff, so the comment must make sense without it.
- **No evidence**: leave out repro steps, logs and stack traces.
- A short code snippet that breaks the problem into a digestible chunk helps a human understand it. Use as few as possible.
- **A suggestion only when it carries a decision**: a conclusion the user and you reached together, or reasoning the fixer would not find alone.
  Then add it as one sentence.
- No headings, bold labels or severity tags.

```text
Users without the `product.editor` privilege can no longer open the
product detail page. The new watcher writes to the store before the ACL
check, and that write throws an error.
```

With a decided suggestion:

```text
The cache key ignores the sales channel. One channel then shows the prices
of another channel. Use the sales channel ID as the key, not the context
hash: the context hash changes on every login and would empty the cache.
```
