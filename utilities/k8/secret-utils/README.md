# secrets-tools — Secrets Management

Environment file generation and Infisical secret seeding.

## Installation

```bash
make install    # Installs hydrate-envrc, infisical-populate-secrets, infisical-bootstrap to ~/.local/bin
```

## Prerequisites

- `jq` for JSON parsing
- `curl` for Infisical API calls
- `openssl` for secret generation
- Infisical Universal Auth credentials (client ID + secret)

## Configuration

All configuration lives in `infra-config.yaml` with credentials in `.envrc.k8.dc` (see `~/.local/share/k8-lib/README.md` for setup).

### Relevant Sections

In `infra-config.yaml`:

```yaml
infisical:
  host: "https://infisical.noizu.com/api"
  project_id: "..."
```

In `.envrc.k8.dc` secrets layer:

```bash
# In .envrc.k8.dc
export K8_INFISICAL_CLIENT_ID="..."
export K8_INFISICAL_CLIENT_SECRET="..."
```

Or set equivalent environment variables:

```bash
export K8_INFISICAL_HOST="https://infisical.noizu.com/api"
export K8_INFISICAL_CLIENT_ID="..."
export K8_INFISICAL_CLIENT_SECRET="..."
```

## Tools

### hydrate-envrc

Generates `.envrc` from `.envrc.example` by processing generator directives:

```bash
hydrate-envrc                   # Generate .envrc from .envrc.example in CWD
```

Supported directives (in `.envrc.example` comments):

| Directive | Example | Action |
|-----------|---------|--------|
| `generate:password` | `export DB_PASS="" # generate:password` | Random 32-char password |
| `generate:hex` | `export SECRET="" # generate:hex` | Random 64-char hex string |
| `generate:django` | `export KEY="" # generate:django` | Django-style secret key |
| `inherit:VAR` | `export COPY="" # inherit:DB_PASS` | Copy value from another variable |
| `REQUIRED` | `export API_KEY="" # REQUIRED` | Left blank, flagged in output |

Output is written to `.envrc` with `chmod 600`.

### infisical-populate-secrets

Seeds secrets into Infisical for all service areas:

```bash
infisical-populate-secrets                  # Populate all sections
infisical-populate-secrets --section webui  # Single section only
infisical-populate-secrets --dry-run        # Preview without writing
infisical-populate-secrets --show-secrets   # Display values in output
```

Auto-generates missing secrets and persists them to `secrets/.envrc.auto` for reuse across runs. Precedence: explicit env var > `.envrc.auto` > auto-generate.

### infisical-bootstrap

Pre-creates the K8s Secrets that Infisical needs before it can manage its own secrets (tier 0 chicken-and-egg). Reads connection details from `infra-config.yaml` → `infisical_bootstrap` section.

```bash
infisical-bootstrap                             # Create app + TLS secrets
infisical-bootstrap --dry-run                   # Preview without creating
infisical-bootstrap --tls-only                  # Only create TLS secret
infisical-bootstrap --namespace my-ns           # Override namespace
```

#### Configuration

In `infra-config.yaml`:

```yaml
infisical_bootstrap:
  namespace: infisical
  secret_name: infisical-core-secrets
  tls_secret_name: cloudflare-infisical.example.com-tls
  site_url: https://infisical.example.com
  pg_user: infisical
  pg_db: infisicalDB
  db_host: postgresql
  redis_host: redis
```

All values overridable via `K8_INFISICAL_BOOTSTRAP_*` env vars (e.g., `K8_INFISICAL_BOOTSTRAP_SITE_URL`).

#### Required Environment Variables

| Variable | Purpose |
|----------|---------|
| `INFISICAL_POSTGRES_PASSWORD` | PostgreSQL password |
| `INFISICAL_ENCRYPTION_KEY` | Encryption key (hex) |
| `INFISICAL_AUTH_SECRET` | Auth secret |
| `INFISICAL_REDIS_PASSWORD` | Redis password |
| `TLS_CRT` / `TLS_KEY` | Base64-encoded TLS certificate and key (optional) |

### infisical-view-dc

View `dc get` directives from `.envrc.dc` files:

```bash
infisical-view-dc                        # List all dc get directives
infisical-view-dc --scope secrets        # Filter by scope
infisical-view-dc --path infisical.host  # Filter by item path
infisical-view-dc --show-values          # Show resolved values
infisical-view-dc --format json|table    # Output format
```

Useful for understanding how secrets are configured via direnv-config and tracing from secret names back to their dc configuration lines.

### infisical-find-dc-line

Locate specific `dc get` directives in `.envrc.dc` files:

```bash
infisical-find-dc-line <scope> <item_path>           # Find line with file context
infisical-find-dc-line secrets infisical.host        # Example
infisical-find-dc-line --inline <scope> <item_path>  # One-liner format
infisical-find-dc-line --env-path                    # Show .envrc.dc location
```

Returns the file path, line number, and line content, making it easy to jump to the location in your editor.

### infisical-verify

Verify secret chain integrity comparing all three sources:

```bash
infisical-verify                                        # Verify all secrets
infisical-verify --section <section_id>                 # Verify specific section
infisical-verify --secret <secret_name>                 # Verify specific secret
infisical-verify --env prod                             # Target environment
infisical-verify --fail-fast                            # Stop on first mismatch
infisical-verify --report-file ./verification.json     # Export report
```

Compares values across:
- `.infisical-secrets.yaml` (declarative mapping)
- `.envrc.dc` (via `dc get`)
- Infisical (remote storage)

Exit code 1 indicates verification failures.

### infisical-set-secret

Edit secrets by name, updating across the chain:

```bash
infisical-set-secret <secret_name>                      # Prompt for new value
infisical-set-secret <secret_name> --value "new-value"  # Set inline
infisical-set-secret <secret_name> --generate           # Auto-generate new value
infisical-set-secret <secret_name> --dry-run           # Preview changes
```

Auto-supported generation types: `password`, `hex`, `django`.

Updates:
1. dc store via `dc set`
2. Infisical remote storage
3. References the secret definition in `.infisical-secrets.yaml`

### infisical-audit

Generate comprehensive audit reports:

```bash
infisical-audit                              # Generate complete audit
infisical-audit --format markdown|json       # Output format
infisical-audit --show-diff                  # Show value differences (SENSITIVE!)
infisical-audit --export ./audit-report.md  # Save to file
```

Produces detailed reports showing:
- Summary statistics (total, verified, mismatched, missing)
- Mismatched secrets with actionable remediation steps
- Missing secrets with specific action guidance
- Value differences (when `--show-diff` is used)

### infisical-fetch-secrets

Fetch and display secrets from an Infisical path:

```bash
infisical-fetch-secrets /livebook                    # Table format
infisical-fetch-secrets /livebook --env=prod         # Explicit env
infisical-fetch-secrets /livebook --format=env       # Sourceable exports
infisical-fetch-secrets /livebook --format=json      # Raw JSON
```

### export-infisical-secrets

Full backup of all Infisical secrets to JSON files:

```bash
export-infisical-secrets --env=prod                  # Export prod (default)
export-infisical-secrets --env=staging               # Export staging only
export-infisical-secrets --show-secrets               # Include actual values
export-infisical-secrets --config=FILE               # Explicit config path
```

Output: `.tmp/infisical-backup-<env>-<timestamp>.json`

### Secret Engine Library

The `lib/secret-engine.sh` library provides reusable functions for custom scripts:

```bash
source /path/to/secrets-tools/lib/secret-engine.sh

# Infisical API client
infisical_auth "" "$PROJECT_ID" "$PROJECT_SLUG"
value=$(infisical_get_secret "/path" "key")
infisical_set_secret "/path" "key" "value" false  # false = write
secrets=$(infisical_list_secrets "/path")

# Secrets YAML parser
secret_def=$(secrets_get_by_name "config.yaml" "SECRET_NAME")
secret_names=$(secrets_list_names "config.yaml" "section_id")
structure=$(secrets_get_structure "config.yaml")

# .envrc.dc parser/parser
env_file=$(envrc_find_file)
lines=$(envrc_parse_get_lines "$env_file")
line_info=$(envrc_find_line "$env_file" "scope" "item.path")
envrc_edit_line "$env_file" 42 "new dc get line"

# Verification engine
verify_secret "config.yaml" "SECRET_NAME" "prod" false
verify_section "config.yaml" "section_id" "prod" false
verify_all "config.yaml" "prod" false
```

## Workflow Examples

### Verify all secrets are in sync

```bash
cd /my/project
infisical-verify --env prod
```

### Find where a secret is configured

```bash
infisical-find-dc-line secrets infisical.host
# Output: /path/to/.envrc.dc:42:dc get secrets infisical.host
```

### Change a secret value

```bash
# Generate new password and update everywhere
infisical-set-secret POSTGRES_PASSWORD --generate password 32

# Or set a specific value
infisical-set-secret API_KEY --value "new-api-key-12345"
```

### Audit and export a full report

```bash
infisical-audit --export ./audit-report.md --show-diff
```
