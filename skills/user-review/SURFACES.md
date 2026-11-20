# Surfaces

How to reach, drive, and judge each kind of surface.
Read the section of every kind in the PR's footprint; the questions here add to the seven in SKILL.md §4.
The project's docs may add surface kinds or say how to reach them in that project.

## Evidence

Every claim carries what the user saw, for **before** and **after**, saved under the review folder and linked individually:

| Surface | Evidence |
|---|---|
| screen | screenshot, read back before you cite it |
| API | the exact request (`curl` line, headers minus secrets, body) and the verbatim response with its status line, in `<n>-<step>.http.txt` |
| command, script | the exact command line, its full stdout and stderr, and `exit=<code>`, in `<n>-<step>.term.txt` |
| config, env | the value you set, where you set it, and the evidence of the surface that reacts to it |

Capture terminal runs as one block, so output and exit code cannot drift apart:

```bash
{ echo "$ <command>"; <command>; echo "exit=$?"; } > <n>-<step>.term.txt 2>&1
```

## Screens

Drive them with a browser automation tool on each version's URL.

- **Reach**: keyboard only, narrow viewport, visible focus.
- **Unsaved work**: what happens on navigate-away with pending changes?
- **Disabled controls**: does each one say why it is disabled?

## APIs

The integrator starts at the API reference, not the diff: find the endpoint there on each version and build the request from what the reference says.
A request you could only build by reading the server code is itself a finding.
Authenticate the way an integrator does, and with restricted credentials too when the endpoint is permission-guarded.

- **Contract**: does the response match the documented schema: field names, types, nullability, status code?
- **Errors**: invalid input gets a 4xx, never a 500; the error body names the field and says what is wrong in words an integrator can act on.
- **Consistency**: naming, casing, pagination, filtering, and error shape match the sibling endpoints.
- **Idempotency**: a retried request after a timeout does not duplicate data; a partial update leaves the other fields alone.
- **Scale**: a list endpoint stays bounded on a large dataset; a bulk path behaves like the single-record path.
- **Permissions**: a missing privilege answers 403 naming the privilege, not an empty list or a 500.

## CLI commands

The operator starts at the command list and `<command> --help`.
Run the command from each version's worktree, so each runs its own code against its own database.

- **Help**: does `--help` explain every argument and option, with a default and an example where the meaning is not obvious?
- **Output**: does it say what it did (counts, names), stay quiet on success where siblings do, and offer a machine-readable mode when siblings have one?
- **Exit code**: nonzero on failure, zero on success; errors go to stderr.
- **Non-interactive**: with no TTY, does it run or fail clearly, never hang on a prompt?
- **Re-run**: does a second run converge, or does it duplicate work or fail on its own leftovers?
- **Long runs**: progress output, a safe interrupt, and a restartable state.
- **Dangerous runs**: destructive actions ask first or need `--force`; a `--dry-run` exists where siblings have one.

## Scripts and developer tooling

The developer starts at the README, the package manager's script list, or the docs the PR touches.
Run each changed script from the worktree, the way the docs say, on a clean state.

- **Prerequisites**: a missing tool, env var, or service fails early, naming the thing and how to get it.
- **Location**: does it work from the directory the docs imply, and from the repo root?
- **Failure**: does it stop on the first error with a nonzero exit, instead of continuing on a broken state?
- **Re-run**: a second run is safe; a half-finished run can be retried.
- **Platform**: on every OS or container the script runs in (BSD vs GNU `sed`, `date`, `readlink`).

## Config, env vars, manifests

The operator or extension author starts at the docs, the `.env` template, the bundled default config, or the manifest schema.

- **Defaults**: a fresh setup works without setting the new key, and the default is the safe choice.
- **Invalid values**: a typo or wrong type fails at boot or install, naming the key and the accepted values, not deep inside a request later.
- **Discoverability**: the key appears where its siblings are documented or listed.
- **Effect**: changing the value changes the behaviour it promises, after the cache clear or restart the docs name.

## Logs and error messages

Someone reads these while something is already broken.

- Does the message name the entity, the ID, and the value that failed?
- Does it suggest the next step, or point at the setting or command that fixes it?
- Is it logged once, at a level that matches its severity?
