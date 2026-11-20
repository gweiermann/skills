# Classifying a failed check

One failed check in, one verdict with evidence out.
Reason from what the log shows, not from the check's name.

```bash
gh run view <run-id> --log-failed
gh pr diff <n> --name-only
```

Test the verdicts in this order:

- **infra**: the failing step never reached the build or test: lost runner, exit 143, pull or network timeout, cache or artifact download, registry errors during install. Evidence: the log line.
- **snapshot**: a screenshot comparison failed. Download the artifact, compare expected, actual and diff with what the PR intends: intended ⇒ update it the way the project's docs say; otherwise **real**.
- **flaky** needs all three, each quoted:
  1. the failing test and the code it exercises are not in the changed files;
  2. the failure has a flaky shape: a timeout waiting for something, a race, order dependence, a busy port, a date or random value;
  3. the same test failed recently on the base branch or other PRs (`gh run list --workflow <file> --branch <base> --status failure`).
  Missing one ⇒ **real**.
- **real**: the failure touches changed code, names a value the branch changed, or nothing above held. Evidence: the assertion and the changed file it points at, plus a fix hypothesis.
- **foreign**: real, but also failing on the base branch and not caused by the diff. Evidence: the base run.
- **unknown**: only when the log is missing or cut off and a rerun did not help.
