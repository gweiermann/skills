# skills

Agent skills I use every day.
They work in Claude Code, Codex and T3 Code, and adapt to whatever the harness offers.

| Skill | Say | What it does |
|---|---|---|
| `babysit-pr` | "babysit" | Keeps a PR or a stack green and current; opt-in: gets it merged and outwaits breakage that is not yours. |
| `babysit-all-prs` | "babysit all my PRs" | One long-lived session that babysits every PR you care about and routes decisions to separate sessions. |
| `pr-review` | "review this PR" | Reviews a PR and proves every finding end to end on an environment running it; backports get a fidelity check. |
| `user-review` | "user review" | Walks every surface a PR changes as the people who use it, before and after, and keeps only what the PR caused. |
| `post-findings` | "post this finding" | Puts review findings into your pending GitHub review, short and self-contained, for you to submit. |
| `worktree-attach` | (automatic) | Makes a fresh worktree runnable in seconds by attaching it to a running instance: copy-on-write dependencies, own dev server, shared backend. |

`babysit-all-prs` uses `babysit-pr`.
Your answers to their questions live in `~/.agents/babysit/`, so you can update the skills without losing them.

## Install

```bash
git clone https://github.com/gweiermann/skills ~/Documents/skills
for s in ~/Documents/skills/skills/*/SKILL.md; do ln -s "$(dirname "$s")" ~/.claude/skills/; done
```

Use `~/.codex/skills/` or `~/.agents/skills/` for other harnesses.

Requirements: an authenticated [GitHub CLI](https://cli.github.com), `python3` for `pr-wait`, and [`gh stack`](https://github.com/github/gh-stack) for linked stacks.

## Credits

`babysit-pr` builds on [Theo Browne](https://github.com/t3dotgg)'s [`babysit-pr`](https://github.com/t3dotgg/tstack/tree/main/skills/babysit-pr) from [tstack](https://github.com/t3dotgg/tstack), including its `pr-wait` script (MIT).
Thanks, Theo.

## License

[MIT](LICENSE)
