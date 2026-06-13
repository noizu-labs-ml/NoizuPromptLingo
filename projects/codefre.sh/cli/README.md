# codefresh CLI

Command-line client for Codefresh — runs prompt-eval scripts against agents from
a terminal or CI pipeline.

## Install

### From source

```bash
cd cli
mix deps.get
mix escript.build
# produces ./codefresh
./codefresh --version
```

Drop the resulting `codefresh` binary anywhere on `$PATH`. It requires an
Erlang/OTP runtime on the host (`erl` must resolve).

## Configure

`codefresh login` prompts for:

1. API base URL (default `https://api.codefre.sh`)
2. API token (create one in the web UI → Settings → API Tokens)
3. Default org slug (optional when your token is scoped to a single org)

Credentials are written to `~/.codefresh/config.json` with `0600` perms.

### Environment overrides

| Variable               | Effect                                            |
| ---------------------- | ------------------------------------------------- |
| `CODEFRESH_API_URL`    | Override stored API base URL                      |
| `CODEFRESH_API_TOKEN`  | Override stored token (use this in CI)            |
| `CODEFRESH_ORG`        | Override stored default org slug                  |
| `CODEFRESH_HOME`       | Override config home dir (testing)                |
| `NO_COLOR`             | Disable ANSI colours                              |

## Commands

```text
codefresh login                Authenticate and store credentials
codefresh logout               Purge stored credentials
codefresh whoami               Show the authenticated user + org

codefresh import <file.yaml>   Import a script from a YAML file
codefresh export <slug>@<ver>  Export a published script to YAML

codefresh run <script-slug>    Trigger a run and poll until it completes
    --agent <agent-slug>       (required)
    --persona <persona-slug>
    --threshold <0-1>
    --fail-on-warn
    --format junit
    --out <path>

codefresh runs list            List recent runs
    --status pass|fail|warn|running
    --limit N

codefresh --help
codefresh --version
```

## Exit codes

| Code | Meaning                                                  |
| ---- | -------------------------------------------------------- |
| 0    | Success / PASS verdict                                   |
| 1    | User error (missing file, bad args) / FAIL verdict       |
| 2    | API / network error / WARN verdict (no `--fail-on-warn`) |
| 3    | Auth error (not logged in, token revoked)                |
| 10   | Run-execution error (surfaced by `codefresh run`)        |

## CI usage

```yaml
# GitHub Actions
- name: Run codefresh checks
  env:
    CODEFRESH_API_TOKEN: ${{ secrets.CODEFRESH_API_TOKEN }}
    CODEFRESH_ORG: acme
  run: |
    codefresh run my-script --agent gpt-4o-echo --format junit --out junit.xml
```

## Testing

```bash
cd cli
mix deps.get
mix test
```

The test suite covers argument parsing, config roundtrip (including `0600`
perm check), env-var overrides, command dispatch, and JUnit XML rendering.
Integration tests requiring a live backend are out of scope for this
checkout; smoke-test against `localhost:4000` once the backend is running.
