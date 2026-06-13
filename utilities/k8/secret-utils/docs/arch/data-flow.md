# Data Flow

## hydrate-envrc

Two-pass template processor that reads `.envrc.example` and produces a ready-to-source `.envrc`.

### Pass 1 - Collection

Scans all `export VAR=""` lines. For each empty-valued variable, inspects the trailing comment for directives:

| Directive | Action |
|-----------|--------|
| `generate:password` | `openssl rand -base64 32`, stripped to 32 alphanumeric chars |
| `generate:hex` | `openssl rand -hex 32` (64-char hex string) |
| `generate:django` | Python `secrets.choice` over extended charset (50 chars), falls back to hex |
| `inherit:OTHER_VAR` | Copies the value of `OTHER_VAR` |
| `REQUIRED` | Left blank with a post-run warning |
| _(none)_ | Left blank silently |

All values are stored in a Bash associative array keyed by variable name.

### Pass 2 - Forward Reference Resolution

Re-scans `inherit:` directives to resolve cases where the source variable appeared after the inheritor in Pass 1.

### Output

Writes the hydrated file with:
- Generator hints stripped from comments
- Header with generation timestamp
- `chmod 600` applied
- Summary of generated vs. still-required variables

## infisical-populate-secrets

### Authentication

Universal auth via `POST /api/v1/auth/universal-auth/login` using client ID + secret. Returns a bearer token reused for all subsequent calls.

### Folder Provisioning

Creates 18 secret folders via `POST /api/v2/folders` (parallel, 4 at a time). Idempotent: ignores "already exists" responses.

### Secret Population (prod)

For each secret:
1. `GET /api/v3/secrets/raw/{key}` to check current value
2. If absent: `POST` to create
3. If present but different: `PATCH` to update
4. If identical: skip (logged as unchanged)

All `set_secret` calls run as background jobs with a final `wait` barrier.

### Staging Mode

Copies all secrets from prod to staging by listing keys per folder (`GET` with `environment=prod`) then writing each to the staging environment. No generation occurs.

### Dry Run

Fetches current Infisical state and reports what would change (new/updated/unchanged) without writing.
