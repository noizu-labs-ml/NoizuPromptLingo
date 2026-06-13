# direnv-config

YAML-backed configuration layer for [direnv](https://direnv.net/). Replaces sprawling `export VAR=value` `.envrc` files with structured, versioned, mergeable YAML configs — and exposes them as env vars automatically.

The key insight: **env vars are write-once from the parent's perspective**. A child process can't update the parent's environment. But a child *can* edit a file. `direnv-config` stores config in YAML files under `~/.local/state/direnv-config/`, and any process (parent, child, sibling, Claude Code) can read or mutate that shared state directly.

## Why

| Problem | direnv-config fix |
|---------|-------------------|
| `.envrc` files have 50+ `export` lines | One-liner `.envrc` that loads structured YAML |
| No hierarchy or grouping | Named YAML configs: `cluster`, `cloudflare`, `tab` — each with nested keys |
| Child processes can't update parent config | Edit the YAML file; parent reads on next access |
| No config layering (dev vs prod vs local) | Elixir-style deep merge: `base.yaml` → `env.yaml` → `local.yaml` |
| Secrets mixed with non-sensitive config | Separate `secrets.yaml` (gitignored) from `config.yaml` |
| No version history | Timestamped snapshots on every write |
| Can't share state with tabbing-on | `dc_set tab status "deploying"` → tab title updates |

## How It Works

```
┌──────────────────────────────────────────────────────────────┐
│  .envrc (project root)                                       │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  dc_yaml cluster <<'YAML'                              │  │
│  │  name: noizu                                           │  │
│  │  kubeconfig: ~/.kube/noizu/config                      │  │
│  │  YAML                                                  │  │
│  │  dc_yaml tab <<'YAML'                                  │  │
│  │  theme: kanagawa                                       │  │
│  │  YAML                                                  │  │
│  │  dc_export                                             │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│  ~/.local/state/direnv-config/{path-hash}/                   │
│                                                              │
│  .version           ← monotonic counter, bumped on write     │
│  .meta              ← source directory path                  │
│                                                              │
│  cluster/           ← one subdirectory per named config      │
│    base.yaml        ← checked into git (non-sensitive)       │
│    dev.yaml         ← environment overlay                    │
│    local.yaml       ← personal overrides / IPC writes        │
│    secrets.yaml     ← sensitive values (gitignored)          │
│    .active          ← resolved merge snapshot                │
│                                                              │
│  cloudflare/                                                 │
│    base.yaml                                                 │
│    secrets.yaml                                              │
│    .active                                                   │
│                                                              │
│  tab/                                                        │
│    base.yaml                                                 │
│    local.yaml       ← dc_set writes here (IPC target)       │
│    .active                                                   │
│                                                              │
│  _dc/               ← special: flattening rules             │
│    base.yaml                                                 │
│                                                              │
│  history/           ← timestamped snapshots (all configs)    │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│  Env vars exported to shell                                  │
│                                                              │
│  DC_ROOT=/path/to/.local/state/direnv-config/{hash}          │
│  DC_VERSION=17                                               │
│  DC_ENV=dev                                                  │
│  KUBECONFIG=~/.kube/noizu/config      (from cluster config)  │
│  CF_API_TOKEN=wuDcz...                (from cloudflare)      │
│  TAB_THEME=kanagawa                   (from tab)             │
│  ... (flattened per _dc flatten rules)                       │
└──────────────────────────────────────────────────────────────┘
```

### .envrc Functions

Every config has a **name**. The name is the first positional argument to every function. A single directory can have any number of named configs — `cluster`, `cloudflare`, `tab`, `app-codefresh`, etc. Each name gets its own YAML files, layers, and merge chain.

All functions accept heredoc YAML and operate on the config store for the current directory. If no store exists, it's created on first call. Every mutating call bumps the version counter and regenerates `.active`.

All functions are **idempotent** — running the same `.envrc` twice produces the same result with no side effects.

#### `dc_yaml NAME` — Deep Merge (default operation)

Merges the provided YAML into the named config's target layer. **Existing sibling keys are preserved.** This is the workhorse.

```bash
dc_yaml cluster <<'YAML'
name: noizu
kubeconfig: ~/.kube/noizu/config
YAML

dc_yaml tab <<'YAML'
theme: kanagawa
status: idle
YAML
```

If the store already has `cluster.context: noizu-dev` from a prior call or parent, it survives — `dc_yaml` only touches the keys you provide.

Multiple named configs in one `.envrc` is the normal case — each is independent.

#### `dc_yaml NAME --replace` — Overwrite an Entire Named Config

Replaces the entire named config's layer file instead of merging. Use when the child needs to completely redefine what the parent established.

```bash
# Parent defined cloudflare with account_id, zone_id, tunnel, access, etc.
# This wipes ALL of that and writes only what's here.
dc_yaml cloudflare --replace <<'YAML'
account_id: staging-cf-account
zone_id: staging-zone-id
YAML
```

After `--replace`, the named config contains **only** what's in the heredoc. Parent keys not re-declared are gone.

#### `dc_yaml NAME --replace-key KEY` — Replace One Branch

Replaces a specific key's subtree within the named config. Sibling keys in the same config survive.

```bash
# Parent's cluster config has: name, kubeconfig, context, region, node_pool{min,max,instance_type}
# Replace ONLY node_pool — name, kubeconfig, context, region are preserved
dc_yaml cluster --replace-key node_pool <<'YAML'
node_pool:
  min: 1
  max: 3
YAML
# node_pool.instance_type is gone — the whole branch was replaced
# cluster.name, cluster.region, etc. — untouched
```

#### `dc_prune NAME [KEY...]` — Delete Named Configs or Branches

Removes entire named configs, or specific branches within a named config.

```bash
# Remove entire named configs — parent defined them, child doesn't need them
dc_prune cluster
dc_prune npl
dc_prune services

# Remove a branch within a named config
dc_prune cloudflare tunnel              # removes cloudflare.tunnel.* subtree

# Remove multiple branches within one config
dc_prune cloudflare tunnel access       # removes both subtrees
```

Under the hood, `dc_prune` writes a **tombstone marker** to the child's layer file. During merge resolution, tombstoned configs/branches are excluded from the final `.active`.

#### `dc_set NAME KEY VALUE` — Set Individual Keys

Surgical single-key updates without a full YAML block. Writes to `local.yaml` by default (runtime/IPC layer).

```bash
dc_set tab status "deploying"
dc_set tab theme danger
dc_set tab urgency 2
dc_set --layer base cluster name "noizu"
dc_set --layer secrets cloudflare api_token "wuDcz..."
```

#### `dc_unset NAME KEY [KEY...]` — Remove Individual Keys

Removes specific keys (not branches — use `dc_prune` for subtrees).

```bash
dc_unset cloudflare zone_id_trl
dc_unset --layer base cluster context
```

#### `dc_yaml NAME --layer` — Target a Specific Layer

All functions default to `base` layer. Override with `--layer`:

```bash
dc_yaml cluster --layer dev <<'YAML'
context: noizu-dev
YAML

dc_yaml cloudflare --layer secrets --if-missing <<'YAML'
api_token: ""
access:
  client_secret: ""
YAML
```

`--if-missing` writes only when the layer file doesn't exist — it won't clobber values already filled in.

#### `dc_bump` — Finalize After Batched Writes

When making multiple changes, suppress individual version bumps and finalize once:

```bash
dc_yaml --no-bump cluster <<'YAML'
name: noizu
YAML
dc_prune --no-bump services
dc_set --no-bump tab theme kanagawa
dc_bump   # single version bump + .active regeneration
```

### Function Reference

| Function | Operation | Default Layer | Description |
|----------|-----------|---------------|-------------|
| `dc_get NAME PATH` | read | — | Read a value using path expression (dot, bracket, length) |
| `dc_yaml NAME <<'YAML'` | deep merge | `base` | Merge heredoc into named config, preserving siblings |
| `dc_yaml NAME --replace <<'YAML'` | overwrite | `base` | Replace named config's layer entirely |
| `dc_yaml NAME --replace-key KEY <<'YAML'` | overwrite branch | `base` | Replace one branch, preserve siblings |
| `dc_prune NAME [KEY...]` | delete | `base` | Remove named config or branches within it |
| `dc_set NAME KEY VALUE` | set scalar | `local` | Set one key in named config |
| `dc_unset NAME KEY [KEY...]` | delete key | `local` | Remove keys from named config |
| `dc_bump` | finalize | — | Bump version + regenerate all `.active` files |

**Common flags** (available on all mutating functions):

| Flag | Description |
|------|-------------|
| `--layer NAME` | Target layer: `base`, `dev`, `prod`, `local`, `secrets`, or custom |
| `--if-missing` | Only write if the target layer file doesn't exist |
| `--no-bump` | Suppress version bump (batch with `dc_bump`) |

---

### `.envrc` Examples

#### Root Config — No Parent, Cold Start

The top of the chain. No `source_up`, no pre-existing store. Each concern gets its own named config.

```bash
# k8/.envrc — root of the infra repo
dc_yaml cluster <<'YAML'
name: noizu
kubeconfig: ~/.kube/noizu/config
context: noizu
region: us-east-1
node_pool:
  min: 2
  max: 8
  instance_type: m5.xlarge
YAML

dc_yaml cloudflare <<'YAML'
account_id: a75e7459...
zone_id: 46014d24...
zone_id_trl: 9793b993...
access:
  client_id: 7ebfc690...access
tunnel:
  enabled: true
  name: noizu-tunnel
YAML

dc_yaml tab <<'YAML'
theme: kanagawa
status: idle
YAML

dc_yaml build <<'YAML'
env: prod
registry: ghcr.io/noizu
push_on_build: false
YAML

dc_yaml npl <<'YAML'
project: noizu-infra
YAML

# Secrets — seed empty placeholders if not yet populated
dc_yaml cloudflare --layer secrets --if-missing <<'YAML'
api_token: ""
access:
  client_secret: ""
YAML

# Flattening rules — how named config keys become env vars
dc_yaml _dc <<'YAML'
flatten:
  cluster.kubeconfig: KUBECONFIG
  cluster.context: KUBECTX_CURRENT_CONTEXT
  cluster.name: CLUSTER_NAME
  cloudflare.account_id: CF_ACCOUNT_ID
  cloudflare.zone_id: CF_ZONE_ID
  cloudflare.zone_id_trl: CF_ZONE_ID_THEROBOTLIVES
  cloudflare.api_token: CF_API_TOKEN
  cloudflare.access.client_id: CF_ACCESS_CLIENT_ID
  cloudflare.access.client_secret: CF_ACCESS_CLIENT_SECRET
  build.env: BUILD_ENV
  build.registry: DOCKER_REGISTRY
  npl.project: NPL_PROJECT
  tab.*: TAB_*
YAML

dc_export
```

#### Child — Inherit + Deep Merge

Inherits all parent named configs. Merges into `tab` (overwrite theme, add status). Adds a new `services` config.

```bash
# projects/.envrc — child of k8/.envrc
source_up

dc_yaml tab <<'YAML'
theme: catppuccin
status: projects
YAML

dc_yaml services <<'YAML'
postgres:
  host: postgres.default.svc
  port: 5432
  pool_size: 10
redis:
  host: redis.default.svc
  port: 6379
YAML

dc_yaml _dc <<'YAML'
flatten:
  services.postgres.host: POSTGRES_HOST
  services.postgres.port: POSTGRES_PORT
  services.redis.host: REDIS_HOST
  services.redis.port: REDIS_PORT
YAML

dc_export
```

**Result:** parent's `cluster`, `cloudflare`, `build`, `npl` inherited unchanged. `tab.theme` overwritten to `catppuccin`. `services` is new.

#### Child — Prune Entire Named Configs + Branches

Terraform doesn't need cluster, services, npl, or build. Keeps cloudflare (for the CF provider) but prunes its tunnel branch and a single key.

```bash
# terraform/.envrc
source_up

dc_prune --no-bump cluster
dc_prune --no-bump services
dc_prune --no-bump npl
dc_prune --no-bump build
dc_prune --no-bump cloudflare tunnel
dc_unset --no-bump cloudflare zone_id_trl

dc_yaml --no-bump tab <<'YAML'
theme: nord
status: terraform
emoji: wrench
YAML

dc_yaml --no-bump terraform <<'YAML'
workspace: production
backend:
  type: s3
  bucket: noizu-tf-state
  region: us-east-1
  lock_table: noizu-tf-locks
  encrypt: true
YAML

dc_yaml --no-bump _dc <<'YAML'
flatten:
  terraform.workspace: TF_WORKSPACE
  terraform.backend.bucket: TF_STATE_BUCKET
  cloudflare.account_id: CF_ACCOUNT_ID
  cloudflare.zone_id: CF_ZONE_ID
  cloudflare.api_token: CF_API_TOKEN
YAML

dc_bump
dc_export
```

**Result:** only `cloudflare` (minus tunnel + zone_id_trl), `tab`, and `terraform` survive. Env var set shrinks from ~15 to ~8.

#### Child — Replace an Entire Named Config

Staging needs completely different cloudflare credentials — not a merge, a full replacement.

```bash
# staging/.envrc
source_up

# Wipe parent's cloudflare config, write fresh
dc_yaml cloudflare --replace <<'YAML'
account_id: staging-cf-account
zone_id: staging-zone-id
tunnel:
  enabled: false
YAML

dc_yaml cloudflare --layer secrets --replace <<'YAML'
api_token: staging-api-token
YAML

# Replace just the node_pool branch in cluster — siblings (name, kubeconfig, etc.) preserved
dc_yaml cluster --replace-key node_pool <<'YAML'
node_pool:
  min: 1
  max: 3
YAML

dc_yaml tab <<'YAML'
theme: safe
status: staging
emoji: construction
YAML

dc_yaml build <<'YAML'
env: staging
push_on_build: true
YAML

dc_export
```

**Result:** `cloudflare` is entirely new (parent's `access`, `zone_id_trl` gone). `cluster.node_pool` replaced (no more `instance_type`), but `cluster.name`, `.kubeconfig`, `.region` inherited.

#### Multiple Per-App Named Configs

Each app in the incubator gets its own named config with its own secrets scaffold.

```bash
# apps/.envrc
source_up

dc_yaml build <<'YAML'
env: production
registry: ghcr.io/the-robot-lives
push_on_build: true
platforms:
  - linux/amd64
  - linux/arm64
YAML

dc_yaml tab <<'YAML'
theme: tokyo-night
status: apps
YAML

# Each app is a separate named config
dc_yaml app-codefresh <<'YAML'
domain: codefre.sh
namespace: apps-ns
port: 4001
features:
  auth: github
  billing: stripe
YAML

dc_yaml app-therobotlives <<'YAML'
domain: therobotlives.com
namespace: apps-ns
port: 4002
features:
  auth: magic-link
  cms: true
YAML

dc_yaml app-noizurpg <<'YAML'
domain: noizurpg.com
namespace: apps-ns
port: 4003
features:
  auth: github
  multiplayer: true
  websockets: true
YAML

# Per-app secrets — only seed if not yet populated
dc_yaml app-codefresh --layer secrets --if-missing <<'YAML'
stripe_key: ""
github_client_id: ""
YAML

dc_yaml app-noizurpg --layer secrets --if-missing <<'YAML'
github_client_id: ""
session_secret: ""
YAML

dc_yaml _dc <<'YAML'
flatten:
  app-codefresh.domain: CODEFRESH_DOMAIN
  app-codefresh.port: CODEFRESH_PORT
  app-therobotlives.domain: TRL_DOMAIN
  app-noizurpg.domain: NOIZURPG_DOMAIN
  build.registry: DOCKER_REGISTRY
YAML

dc_export
```

#### Runtime IPC — Child Process Updating Named Config

This isn't an `.envrc` — it's a deploy script updating the `tab` named config so the parent shell's title updates live.

```bash
#!/bin/bash
# deploy.sh <app-name> <image:tag>
APP="$1"; IMAGE="$2"

dc_set tab status "building $APP"
dc_set tab emoji rocket
dc_set tab urgency 2
make build

dc_set tab status "pushing $APP"
dc_set tab emoji ship
docker push "$IMAGE"

dc_set tab status "deploying $APP"
dc_set tab emoji construction
helm upgrade --install ...

# Update the app's own named config with deploy metadata
dc_set "app-${APP}" last_deploy "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
dc_set "app-${APP}" last_image "$IMAGE"
dc_set "app-${APP}" deploy_status "healthy"

dc_set tab status "deployed $APP"
dc_set tab emoji check
dc_set tab urgency 5
```

Each `dc_set` bumps `.version`. The parent shell's `precmd` hook detects the bump and calls `tabbing-status` automatically.

#### Minimal — One-Liner for Simple Projects

Not every project needs multiple configs. For directories that just want a tab theme:

```bash
# some-tool/.envrc
eval "$(dc-init)"
dc_yaml tab <<'YAML'
theme: nord
YAML
dc_export
```

### Config Layering (Elixir-style)

Files are deep-merged in order. Later files override earlier ones. Missing files are skipped.

```
base.yaml  →  ${DC_ENV}.yaml  →  local.yaml  →  secrets.yaml
```

**Example:**

```yaml
# base.yaml
cluster:
  name: noizu
  kubeconfig: ~/.kube/noizu/config
cloudflare:
  account_id: a75e7459...
tab:
  theme: kanagawa
```

```yaml
# dev.yaml — overrides for development
cluster:
  context: noizu-dev
tab:
  theme: safe
```

```yaml
# secrets.yaml — gitignored, never committed
cloudflare:
  api_token: wuDczIM28S...
  access_client_secret: 99491...
```

**Resolved (deep merge):**
```yaml
cluster:
  name: noizu
  kubeconfig: ~/.kube/noizu/config
  context: noizu-dev
cloudflare:
  account_id: a75e7459...
  api_token: wuDczIM28S...
  access_client_secret: 99491...
tab:
  theme: safe
```

### Flattening to Env Vars

YAML keys are flattened to env vars using configurable rules:

```yaml
# Flattening config (in base.yaml under _dc meta key)
_dc:
  flatten:
    cluster.kubeconfig: KUBECONFIG          # explicit mapping
    cluster.context: KUBECTX_CURRENT_CONTEXT
    cloudflare.api_token: CF_API_TOKEN
    cloudflare.account_id: CF_ACCOUNT_ID
    tab.*: TAB_*                            # wildcard: tab.theme → TAB_THEME
  prefix: ""                                # default prefix for unmapped keys
  export: [cluster, cloudflare, tab]        # which top-level keys to export
```

Keys not in `flatten` are exported as `PREFIX_PATH_TO_KEY` (uppercase, dots→underscores).

#### Auto-Derive Convention

When a named config's name matches the env var prefix, no flatten rule is needed. The default export behavior is:

```
{CONFIG_NAME}_{KEY_PATH} → uppercase, dots/nested keys joined with underscores
```

Examples (no flatten rules required):
```
infisical.host              → INFISICAL_HOST
livebook.postgres_password  → LIVEBOOK_POSTGRES_PASSWORD
telemetry.namespace         → TELEMETRY_NAMESPACE
bob.redis_password          → BOB_REDIS_PASSWORD
```

Only write explicit flatten rules for exceptions:
```yaml
flatten:
  cluster.kubeconfig: KUBECONFIG              # want KUBECONFIG, not CLUSTER_KUBECONFIG
  cluster.context: KUBECTX_CURRENT_CONTEXT    # non-obvious name
  cf.zone_id_trl: CF_ZONE_ID_THEROBOTLIVES   # key name doesn't match env var suffix
```

#### Wildcard Flatten Rules

Wildcards remap an entire sub-tree's prefix. The `*` matches all remaining path segments, joined with underscores:

```yaml
flatten:
  tab.*: TAB_*                    # tab.theme → TAB_THEME
  secrets.infisical.*: INFISICAL_*  # secrets.infisical.host → INFISICAL_HOST
  secrets.smtp.*: SMTP_*           # secrets.smtp.host → SMTP_HOST
```

For nested paths, the wildcard expands through all levels:
```
secrets.infisical.postgres_password  →  INFISICAL_POSTGRES_PASSWORD
                   ^^^^^^^^^^^^^^^^      ^^^^^^^^^^^^^^^^^^^^^^^^
                   matched by *          expanded into INFISICAL_*
```

#### Prefix-Stripping Wildcard

To export keys without any config-name prefix, use an empty target:

```yaml
flatten:
  auto.*: "*"       # auto.erpnext_db_password → ERPNEXT_DB_PASSWORD (no AUTO_ prefix)
```

Alternatively, use the structured `export` list with a per-config prefix override:

```yaml
export:
  - infra
  - cluster
  - cf
  - secrets
  - { name: auto, prefix: "" }    # strip the auto_ prefix entirely
  - tab
```

#### Aliases

Aliases create env vars whose values mirror another env var. They are processed **after** flatten rules resolve, so they reference final env var names — not YAML paths.

```yaml
# _dc/base.yaml
aliases:
  SMTP_PASSWORD: SENDGRID_API_KEY                # SMTP_PASSWORD gets same value as SENDGRID_API_KEY
  K8_INFISICAL_HOST: INFISICAL_HOST              # alias for backward compat
  K8_INFISICAL_CLIENT_ID: OPERATOR_CLIENT_ID
  K8_INFISICAL_CLIENT_SECRET: OPERATOR_CLIENT_SECRET
  HF_TOKEN: HF_READ_TOKEN                        # dual-name token
  GITHUB_CLIENT_SECRET: GITHUB_TOKEN             # three names, one value
  GITHUB_API_KEY: GITHUB_TOKEN
  DOCKER_USER: DOCKERHUB_USER
  DOCKER_PASSWORD: DOCKERHUB_PASSWORD
```

**Resolution order:**
1. Flatten rules resolve YAML paths → env var names + values
2. Aliases copy values from resolved env vars to new names
3. `dc env` emits all resolved vars + aliases as `export` lines

Aliases are the correct mechanism for cross-references that span named configs (where YAML anchors don't work) and for backward-compatible env var names.

**Child override:** A child `.envrc` can add aliases in its own `_dc` config. Child aliases are deep-merged with parent aliases — a child can shadow a parent's alias by redefining it, or add new ones.

## Secret Management

`dc` distinguishes **secrets** from settings, encrypts them at rest, redacts them
by default, and audits every reveal. Secrets are stored as opaque self-describing
scalars (`dcenc:v1:t<tier>:<base64url>`) — every language SDK passes them through
untouched; only `dc` (holding the key) can decrypt.

### Setup

Put a 32-byte AEAD key in `~/.config/direnv-config/settings.yaml`:

```yaml
# generate with: openssl rand -base64 32
key: "Q2hhbmdlTWVUb0EzMkJ5dGVSYW5kb21LZXkhIQ=="
# audit_log: /custom/path/audit.log   # optional; defaults to state dir
```

> ⚠️ Rotating this key orphans all existing `dcenc:` tokens — `dc` fails loudly
> rather than silently re-encrypting.

### Tagging secrets in `.envrc`

Prefix a value with `🔒` to mark it a secret. An optional run of `❗` sets the
sensitivity tier (low/med/high). Parsing: trim → strip `🔒` → count `❗` → trim
the body (interior whitespace preserved).

```bash
dc_yaml --no-bump cf <<'YAML'
account_id: a75e745949fc104          # plain setting → base.yaml
access:
  client_id: 7ebfc690af.access       # plain setting → base.yaml
  client_secret: "🔒❗❗ <the-secret>" # secret → encrypted → secrets.yaml
api_token: |
  🔒 <the-secret>                     # block scalars work too
YAML
```

A single heredoc fans out: plain keys go to the requested layer, `🔒` values are
encrypted and routed to `secrets.yaml` **regardless of `--layer`**. A value that
is already a `dcenc:` token (e.g. encrypted-at-rest inline) is stored verbatim,
never double-encrypted.

### Reading secrets

```bash
dc get cf access.client_secret                 # 🔒❗❗ **redacted** (default — key untouched)
dc get cf access.client_secret --reveal        # decrypt to stdout (audited)
dc get cf access.client_secret --clippy        # decrypt to clipboard, no stdout (audited, macOS)
```

Every reveal appends a JSONL record (user, euid, subject, path, tier, method, ts)
to the audit log (mode 0600).

### Browsing

```bash
dc bat                       # not a command — use a subject or --all
dc bat --all                 # every config, secrets masked
dc bat cf                    # one subject
dc bat cf access             # a scope within a subject
dc bat cf --reveal           # unmask (audited)
dc bat cf --filter-key 'secret' --exclude-value 'redacted'
```

Filters are regexes; `--filter-key`/`--exclude-key` match the full concatenated
path (e.g. `cf.access.client_secret`). Output pipes through `bat` when present.

### Editing `.envrc` source in place

`dc config` edits the literal hand-authored `.envrc*` heredocs (not the store),
preserving comments and formatting, and encrypts the new value inline:

```bash
dc config get cf access.client_secret                       # show file:line + redacted preview
dc config set cf access.client_secret --value "$NEW"        # preview → confirm → encrypt → splice
dc config set cf access.api_key --from ./key.txt            # inserts under existing parent (errata)
echo "$NEW" | dc config set cf db.password --stdin          # value via stdin (implies --yes)
dc config set cf x --value "$TOKEN" --encrypted             # value is already a dcenc token
dc config setall cf --below account_id <<'YAML'             # insert a YAML section by anchor
new_group:
  key: value
YAML
```

### Extra lockdown (shadow store)

`dc config secure` moves a secret into `<project>/.secrets/restricted.config.yaml`
and leaves a `⛔` sentinel in both the store and `.envrc`. Plain `--reveal` will
**not** expose a `⛔` value — only the stricter `--reveal-restricted` does, and it
is always audited.

```bash
dc config secure cf access.client_secret --note "rotate quarterly"
dc get cf access.client_secret                    # ⛔ **restricted**
dc get cf access.client_secret --reveal           # still ⛔ **restricted**
dc get cf access.client_secret --reveal-restricted  # decrypts from shadow (audited)
```

### Compare / push / Infisical roundtrip

Compare a local secret against remote copies **without printing any value**:

```bash
dc compare cf access.client_secret \
  --to infisical://cf/CF_API_TOKEN \
  --to k8://apps-ns/cf-secrets/CF_API_TOKEN
# DC == infisical  /cf/CF_API_TOKEN
# DC != k8  apps-ns/cf-secrets/CF_API_TOKEN
```

Force-push (dry-run by default), driven by your decrypted local values:

```bash
dc push cf access --to infisical://cf --dry-run     # plan only, no values shown
dc push cf access --to kubernetes://apps-ns/cf-secrets --yes
```

Roundtrip against the `.infisical-secrets.yaml` mapping:

```bash
dc infisical compare /data/postgres/POSTGRES_PASSWORD --to k8://data/shared-postgres/POSTGRES_PASSWORD
dc infisical get POSTGRES_PASSWORD                  # live Infisical vs dc source, redacted
dc infisical get POSTGRES_PASSWORD --reveal         # both plaintext (audited)
dc infisical set POSTGRES_PASSWORD --value "$NEW"   # locates dc source, edits .envrc in place
```

Infisical/Kubernetes access is native (no shell-out). Connection settings resolve
from env vars then `dc get secrets infisical.*` / `dc get cf access.*`; `compare`
and `push` exit non-zero on any mismatch and never leak plaintext to stdout or the
audit log (the push payload is the sole intended egress).

## Install

Three things need to happen, each serving a different purpose:

### 1. direnv stdlib extension (makes `dc_yaml` etc. available in `.envrc` files)

direnv runs `.envrc` in a bash subshell. For `dc_yaml`, `dc_set`, etc. to work inside `.envrc`, they need to be in direnv's function library.

```bash
# Create direnv's lib directory if it doesn't exist
mkdir -p ~/.config/direnv/lib

# Symlink the direnv-config library into it
ln -sf /path/to/direnv-config/lib/direnv-stdlib.sh ~/.config/direnv/lib/dc.sh
```

direnv auto-sources every `*.sh` in `~/.config/direnv/lib/` before evaluating `.envrc`. This is the idiomatic direnv extension mechanism — no eval hacks needed.

After this, every `.envrc` file can call `dc_yaml`, `dc_set`, `dc_prune`, `dc_unset`, `dc_bump`, and `dc env` without any preamble.

### 2. Shell hook (enables IPC — parent shell detects child writes)

The precmd/PROMPT_COMMAND hook watches `.version` and re-exports env vars when a child process bumps it. This is what makes the tabbing-on integration work.

```bash
# Zsh — add to .zshrc
eval "$(path/to/direnv-config/bin/dc-init zsh)"

# Bash — add to .bashrc
eval "$(path/to/direnv-config/bin/dc-init bash)"
```

`dc-init` outputs a small shell snippet that:
- Registers a `precmd` hook (zsh) or `PROMPT_COMMAND` entry (bash)
- On each prompt, checks if `$DC_ROOT/.version` changed
- If bumped, re-reads the relevant `.active` files and re-exports env vars
- If tabbing-on is loaded, calls `tabbing-status` / `tabbing-style` for `tab.*` changes

**Without this step**, direnv-config still works for `.envrc` loading — you just won't get live IPC from child processes.

### 3. CLI on PATH (optional — for `dc status`, `dc history`, `dc edit`)

```bash
# Option A: add bin/ to PATH (in .zshrc or .envrc)
export PATH="/path/to/direnv-config/bin:$PATH"

# Option B: symlink into an existing PATH directory
ln -sf /path/to/direnv-config/bin/dc ~/.local/bin/dc
```

This gives you the `dc` CLI for interactive commands (`dc status`, `dc history`, `dc edit`, `dc get`, `dc list`). Not needed for `.envrc` operation — that's all handled by step 1.

### Quick Setup (all three at once)

```bash
DC_HOME="/path/to/direnv-config"

# 1. direnv stdlib
mkdir -p ~/.config/direnv/lib
ln -sf "$DC_HOME/lib/direnv-stdlib.sh" ~/.config/direnv/lib/dc.sh

# 2. Shell hook + 3. CLI on PATH — add both to .zshrc:
cat >> ~/.zshrc << EOF
eval "\$($DC_HOME/bin/dc-init zsh)"
export PATH="$DC_HOME/bin:\$PATH"
EOF
```

Then restart your shell or `source ~/.zshrc`.

### How `.envrc` Files Change

**Before (step 1 required `eval`):**
```bash
eval "$(dc-init)"           # ← no longer needed
dc_yaml tab <<'YAML'
theme: kanagawa
YAML
dc_export
```

**After (direnv stdlib handles it):**
```bash
dc_yaml tab <<'YAML'
theme: kanagawa
YAML
dc_export
```

Since `dc_yaml` and friends are loaded by direnv's stdlib mechanism, no `eval "$(dc-init)"` is needed at the top of `.envrc`. The `dc_export` function (alias for `eval "$(dc env)"`) is provided for convenience.

### Dependencies

**Runtime:**
- [direnv](https://direnv.net/) — the `.envrc` loader
- `dc` binary — compiled from this repo's Rust source (`make compile`)
- POSIX shell (`/bin/sh`) — for `dc-init` bootstrap only

**Build (compile from source):**
- Rust toolchain (`rustc` + `cargo`) — install via [rustup](https://rustup.rs/)

**Optional:**
- [tabbing-on](../tabbing-on/) — tab title integration (auto-detected)

## Commands

### `dc init`

Initialize a config store for the current directory. Creates the storage directory and starter `base.yaml`. Usually you don't call this directly — `dc_yaml` in your `.envrc` handles init automatically.

```bash
cd ~/Github/infra/k8
dc init                        # create config store
dc init --env dev              # also create dev.yaml
dc init --from-envrc           # import existing .envrc exports into base.yaml
```

### `dc_yaml`, `dc_prune`, `dc_set`, `dc_unset`, `dc_bump`

Shell functions for `.envrc` files. See [.envrc Functions](#envrc-functions) above for the full API, flag reference, and examples.

### `dc get`

Read config values. Returns the resolved (merged) value.

```bash
dc get cluster name              # → "noizu"
dc get cloudflare                # → full YAML subtree
dc get tab theme                 # → "safe" (from dev.yaml overlay)
dc get --raw cluster             # raw YAML output (all keys)
dc get --env prod cluster name   # resolve using prod.yaml instead of $DC_ENV
```

#### Path Expressions

Paths support dot-notation for nested maps, bracket indexing for arrays, and combinations:

```bash
# Simple key
dc get cluster name                          # → "noizu"

# Nested key (dots within the path arg)
dc get cluster node_pool.min                 # → 2

# Array index
dc get build platforms[0]                    # → "linux/amd64"
dc get build platforms[1]                    # → "linux/arm64"

# Deep path through arrays
dc get app-codefresh features.auth           # → "github"
dc get services endpoints[2].host            # → "redis.default.svc"
dc get services endpoints[2].ports[0]        # → 6379

# Negative indexing (from end)
dc get build platforms[-1]                   # → "linux/arm64"

# Length
dc get build platforms.length                # → 2
dc get services endpoints.length             # → 3

# Wildcards (returns newline-separated values)
dc get services endpoints[*].host            # → "postgres.default.svc\nredis.default.svc\n..."
```

The `.envrc` function equivalent is `dc_get`:

```bash
port=$(dc_get app-codefresh port)
first_platform=$(dc_get build platforms[0])
mobile=$(dc_get contacts people[5].phone.mobile)
```

#### Parser Tiers

Not all path expressions work with the built-in awk parser. Complex paths automatically delegate to `yq` when available:

| Expression | Built-in (awk) | Requires yq |
|------------|:-:|:-:|
| `key` | ✓ | |
| `key.nested.deep` | ✓ | |
| `key[0]` | ✓ | |
| `key[-1]` | ✓ | |
| `key.nested[0].leaf` | ✓ | |
| `key.length` | ✓ | |
| `key[*].field` | | ✓ |
| `key[*].nested[*]` | | ✓ |
| `key[?(.field=="x")]` | | ✓ |

When a path requires `yq` and it's not installed, `dc_get` exits with an error and a message:

```
dc: path 'endpoints[*].host' requires yq — install with: brew install yq
```

### `dc set`

Write config values. Writes to `local.yaml` by default (personal overrides / IPC). Bumps the version counter and updates the active snapshot. Takes a named config, path, and value.

```bash
dc set tab status "deploying"                        # write to tab/local.yaml
dc set --layer base cluster name "noizu"             # write to cluster/base.yaml
dc set --layer secrets cloudflare api_token "abc123"  # write to cloudflare/secrets.yaml

# Path expressions work for set too:
dc set cluster node_pool.min 4
dc set build platforms[0] "linux/arm64"
dc set services endpoints[2].port 6380
```

**This is the IPC mechanism.** A child process (build script, Claude Code, background job) can call `dc set` to update shared config, and any process reading the YAML sees the change immediately.

### `dc env` / `dc_export`

Export resolved config as shell env vars. `dc_export` is a convenience function (provided by the direnv stdlib extension) that wraps `eval "$(dc env)"`.

```bash
dc_export                       # in .envrc — export all mapped vars
eval "$(dc env)"                # equivalent long form
dc env --list                   # show what would be exported (dry run)
dc env --diff                   # show what changed since last export
```

### `dc edit`

Interactive config editor. Opens a TUI (gum-based) for browsing and editing config values.

```bash
dc edit                         # interactive browser/editor
dc edit --layer secrets         # edit secrets.yaml specifically
dc edit cluster                 # jump to cluster section
```

### `dc merge`

Preview or apply layer merges manually.

```bash
dc merge --preview              # show resolved config (all layers)
dc merge --apply                # write resolved snapshot to .active
dc merge --diff base dev        # show what dev.yaml changes vs base
```

### `dc history`

Browse config version history.

```bash
dc history                      # list snapshots with timestamps
dc history --diff 15 17         # diff between versions 15 and 17
dc history --restore 12         # restore version 12 as current
```

### `dc prune`

Remove stale or unused keys.

```bash
dc prune --dry-run              # show what would be removed
dc prune --unused               # remove keys not referenced by flatten rules
dc prune --layer local          # prune only local.yaml overrides
```

### `dc import`

Import configuration from existing sources.

```bash
dc import --envrc .envrc                    # parse export lines into YAML
dc import --yaml external-config.yaml       # merge external YAML
dc import --env KEY=VALUE KEY2=VALUE2       # import specific env vars
```

### `dc status`

Show current config state: active environment, version, layers, and integration status.

```bash
dc status
# Environment: dev
# Version: 17
# Layers: base.yaml ✓  dev.yaml ✓  local.yaml ✓  secrets.yaml ✓
# Store: ~/.local/state/direnv-config/a8f3c2d1/
# Tabbing: active (theme=safe, status=idle)
# Last modified: 2026-05-12 14:03:22
```

### `dc watch`

Watch for config file changes (useful for debugging IPC).

```bash
dc watch                        # tail changes to .active
dc watch --key tab.status       # watch a specific key
dc watch --exec "tabbing-status \$(dc get tab.status)"  # run command on change
```

## Tabbing-On Integration

`direnv-config` and `tabbing-on` are designed to work together. Any process can update tab state via the config file:

```bash
# In a build script, CI hook, or Claude Code session:
dc_set tab status "building"
dc_set tab theme danger
dc_set tab emoji rocket

# The parent shell's precmd hook picks up the change from the tab/ YAML
# and calls tabbing-status/tabbing-style automatically
```

### How It Works

1. `.envrc` runs `dc_yaml tab <<'YAML'` + `eval "$(dc env)"` → exports `TAB_THEME`, `TAB_STATUS`, etc.
2. A `precmd` hook (registered by `dc-init`) checks `.version` file for changes
3. If version bumped, re-reads `tab/.active` and updates env + calls tabbing-on
4. Child processes call `dc_set tab status "done"` → bumps version → parent picks up on next prompt

```
┌─────────────┐   dc_set tab status "done"   ┌────────────────┐
│ Claude Code  │ ───────────────────────────▶ │ tab/local.yaml │
│ (child proc) │                              │ .version++     │
└─────────────┘                               └───────┬────────┘
                                                      │
                           precmd hook detects        │
                           version bump               │
                                                      ▼
┌─────────────┐   re-read + tabbing-status    ┌──────────────┐
│  Tab Title   │ ◀─────────────────────────── │ Parent Shell │
│  updates!    │                              │              │
└─────────────┘                               └──────────────┘
```

### .envrc Setup

After `dc init --from-envrc`, your `.envrc` becomes:

```bash
# Before: 50 lines of exports
# After:
dc_export
```

## Data Storage

### Where YAML Lives

All config stores live under `~/.local/state/direnv-config/` (respects `$XDG_STATE_HOME`).

Each directory that has an `.envrc` using direnv-config gets its own store, identified by a **path hash** — a stable, filesystem-safe encoding of the source directory's absolute path.

### Path → Hash Mapping

The path hash is derived from the absolute directory path using a deterministic, reversible scheme:

```
Source directory                              Path hash (store name)
─────────────────────────────────────────     ──────────────────────────────────
/Users/keith/Github/infra/k8                  Users-keith-Github-infra-k8
/Users/keith/Github/infra/k8/projects         Users-keith-Github-infra-k8-projects
/Users/keith/Github/infra/k8/projects/design  Users-keith-Github-infra-k8-projects-design
/Users/keith/Github/infra/k8/terraform        Users-keith-Github-infra-k8-terraform
```

The scheme: strip the leading `/`, replace `/` with `-`. This is:
- **Reversible** — you can read the original path from the hash (no information lost)
- **Filesystem-safe** — no `/`, spaces, or special chars
- **Human-readable** — `ls ~/.local/state/direnv-config/` shows recognizable paths
- **Deterministic** — same directory always maps to the same store

For deeply nested paths that would create very long directory names, a truncated SHA suffix is appended:

```
# If the mapped name exceeds 200 chars:
Users-keith-Github-infra-k8-projects-apps-repos-incubator-...-a8f3c2d1
                                                               ^^^^^^^^
                                                               sha256[:8] of full path
```

The `.meta` file inside each store records the original absolute path, creation timestamp, and the full hash — so `dc list` can always map back even for truncated names.

### Store Layout

```
~/.local/state/direnv-config/
│
├── Users-keith-Github-infra-k8/                  ← store for k8/.envrc
│   ├── .version                                  # monotonic counter (plain integer)
│   ├── .meta                                     # source path + timestamps
│   ├── cluster/                                  # named config: cluster
│   │   ├── base.yaml                             # non-sensitive (committable)
│   │   ├── dev.yaml                              # environment overlay
│   │   ├── local.yaml                            # personal overrides / IPC writes
│   │   ├── secrets.yaml                          # sensitive values
│   │   └── .active                               # resolved merge snapshot
│   ├── cloudflare/                               # named config: cloudflare
│   │   ├── base.yaml
│   │   ├── secrets.yaml
│   │   └── .active
│   ├── tab/                                      # named config: tab
│   │   ├── base.yaml
│   │   ├── local.yaml                            # dc_set writes land here
│   │   └── .active
│   ├── build/
│   │   ├── base.yaml
│   │   └── .active
│   ├── _dc/                                      # special: flattening rules
│   │   └── base.yaml
│   └── history/
│       ├── 001-2026-05-12T14:03:22.yaml
│       └── 017-2026-05-12T16:45:01.yaml
│
├── Users-keith-Github-infra-k8-projects/         ← store for projects/.envrc
│   ├── .version
│   ├── .meta
│   ├── tab/                                      # child's overlay of parent's tab
│   │   ├── base.yaml
│   │   └── .active
│   ├── services/                                 # new config added at this level
│   │   ├── base.yaml
│   │   └── .active
│   └── _dc/
│       └── base.yaml
│
├── Users-keith-Github-infra-k8-projects-design/  ← store for design/.envrc
│   ├── .version
│   ├── .meta
│   ├── tab/
│   │   ├── base.yaml                             # dc_yaml tab writes
│   │   ├── local.yaml                            # dc_set tab writes
│   │   └── .active
│   ├── services/                                 # merge overlay for parent's services
│   │   ├── base.yaml
│   │   └── .active
│   ├── project/                                  # new config
│   │   ├── base.yaml
│   │   └── .active
│   ├── npl/                                      # tombstoned (pruned)
│   │   └── base.yaml                             # contains: _dc_pruned: true
│   └── _dc/
│       └── base.yaml
```

**Key points:**
- Each directory gets its **own** store — child stores contain only the delta (overrides, new configs, tombstones), not a copy of the parent
- **Resolution at `dc env` time** walks up the parent chain: `design/ → projects/ → k8/` — merging each store's named configs in order
- Layer files that don't exist are simply skipped — `tab/` only gets a `secrets.yaml` if you write one
- The `.active` file in each named config is the resolved merge of that config's layers (`base → dev → local → secrets`) — but **not** the parent chain. Parent chain resolution happens in memory at `dc env` time

### The .meta File

```yaml
# ~/.local/state/direnv-config/Users-keith-Github-infra-k8-projects-design/.meta
source: /Users/keith/Github/infra/k8/projects/design
created: 2026-05-12T14:03:22Z
parent: /Users/keith/Github/infra/k8/projects
configs: [tab, services, project, npl, _dc]
```

`dc list` reads all `.meta` files to show known stores:

```
$ dc list
Store                                           Source                                    Configs  Ver
Users-keith-Github-infra-k8                     ~/Github/infra/k8                         5        17
Users-keith-Github-infra-k8-projects            ~/Github/infra/k8/projects                3        4
Users-keith-Github-infra-k8-projects-design     ~/Github/infra/k8/projects/design         5        8
Users-keith-Github-infra-k8-projects-staging    ~/Github/infra/k8/projects/staging        6        3
Users-keith-Github-infra-k8-terraform           ~/Github/infra/k8/terraform               3        2
```

### Parent Chain Resolution

When `dc env` runs (or the precmd hook fires), it resolves the full config by walking the parent chain:

```
1. Find current store:  Users-keith-Github-infra-k8-projects-design
2. Find parent store:   Users-keith-Github-infra-k8-projects
3. Find grandparent:    Users-keith-Github-infra-k8
4. No further parent.

For each named config (e.g., "tab"):
   grandparent/tab/.active  →  parent/tab/.active  →  child/tab/.active
   Deep merge in order. Tombstones at any level suppress the branch.
```

Parent discovery: strip the last path segment from the store name and check if that store exists. `Users-keith-Github-infra-k8-projects-design` → check for `Users-keith-Github-infra-k8-projects` → check for `Users-keith-Github-infra-k8` → check for `Users-keith-Github-infra` (doesn't exist, stop).

### Committable Config

Each named config's `base.yaml` (and optionally env overlays) can be symlinked or copied back to the project:

```bash
dc export --to ./config/direnv/     # copy all named configs' base.yaml to project
dc link --from ./config/direnv/     # symlink project files into store
```

This lets teams share non-sensitive config via git while keeping secrets and personal overrides local.

## Architecture

Hybrid design: a **Rust binary** (`dc`) handles all YAML parsing, deep merge, path expressions, store management, and env export. **Thin shell wrappers** (`dc_yaml`, `dc_set`, etc.) pipe heredocs and args to the binary. A **shell hook** watches for version bumps (IPC).

```
┌──────────────────────────────────────────────────────────────┐
│  Shell Layer (thin wrappers — loaded by direnv stdlib)       │
│                                                              │
│  lib/direnv-stdlib.sh   dc_yaml, dc_get, dc_set, dc_prune,  │
│                         dc_unset, dc_bump, dc_export         │
│                         Each is ~5 lines: parse flags,       │
│                         pipe heredoc to `dc` binary          │
│                                                              │
│  bin/dc-init            POSIX /bin/sh — outputs precmd hook  │
│                         for version watching + tabbing bridge │
│                                                              │
│  shell/dc.zsh           Completions, precmd registration     │
│  shell/dc.bash          Bash equivalent                      │
└──────────────────────────┬───────────────────────────────────┘
                           │  stdin (heredoc yaml)
                           │  args (name, path, flags)
                           ▼
┌──────────────────────────────────────────────────────────────┐
│  Rust Binary: dc  (single static binary)                     │
│                                                              │
│  Subcommands:                                                │
│    dc yaml <name> [--replace|--replace-key K] [--layer L]    │
│       Reads YAML from stdin, merges/replaces into store      │
│    dc get <name> [path]                                      │
│       Path expressions: dot, bracket, negative, length       │
│    dc set <name> <path> <value>                              │
│       Writes to local layer, bumps version                   │
│    dc unset <name> <path>                                    │
│    dc prune <name> [keys...]                                 │
│       Writes tombstone markers                               │
│    dc env                                                    │
│       Walks parent chain, resolves all configs, emits        │
│       export KEY=VALUE lines per _dc flatten rules           │
│    dc init [--from-envrc]                                    │
│    dc status / dc list / dc history / dc doctor              │
│    dc watch [--key path] [--exec cmd]                        │
│    dc edit [name] (Phase 3 — ratatui TUI)                    │
│                                                              │
│  Crates:                                                     │
│    serde + serde_yaml     Full YAML spec parsing             │
│    clap                   CLI arg parsing + completions      │
│    ratatui + crossterm    TUI for dc edit (Phase 3)          │
│    notify                 Filesystem watcher for dc watch    │
│    similar                Diff engine for dc history --diff  │
└──────────────────────────────────────────────────────────────┘
```

### Why Rust

- **Full YAML spec** via `serde_yaml` — no subset parser, no awk edge cases, no `yq` dependency
- **Single static binary** — `cargo build --release` produces one file, zero runtime deps
- **Path expressions natively** — `folder[5].person.mobile` is trivial with `serde_yaml::Value` traversal
- **ratatui** — when `dc edit` lands (Phase 3), the TUI framework is already in the ecosystem
- **Fast** — YAML parse + deep merge + env export in ~2ms vs ~50ms for shell pipeline
- **Cross-compile** — `cross` for linux/arm64 (K8s nodes), `cargo build` for macOS

### Shell Wrappers Are Thin

The entire `dc_yaml` function is ~5 lines:

```bash
dc_yaml() {
  local name="$1"; shift
  dc yaml "$name" "$@" <<< "$(cat)"
}
```

The heredoc streams through stdin to the binary. Flags (`--replace`, `--layer`, `--no-bump`) pass through as-is — `clap` handles parsing. The shell layer does no YAML processing.

`dc_export` is similarly trivial:

```bash
dc_export() {
  eval "$(dc env)"
}
```

### YAML Parsing

Since the Rust binary uses `serde_yaml`, there are **no parsing tiers**. All YAML features work everywhere:

- Scalars, maps, sequences, nested combinations
- Flow syntax (`{a: 1}`, `[1, 2, 3]`)
- Multi-line strings (literal `|`, folded `>`)
- Anchors and aliases (`&anchor`, `*anchor`)
- Merge keys (`<<: *defaults`)
- Comments (preserved on round-trip via `serde_yaml`'s tagged values)

**Path expression engine** (built into the binary):

| Expression | Example | Description |
|------------|---------|-------------|
| Key | `name` | Map lookup |
| Nested dots | `node_pool.min` | Chained map traversal |
| Array index | `platforms[0]` | Integer index |
| Negative index | `platforms[-1]` | From end |
| Mixed traversal | `folder[5].person.mobile` | Map + array + map |
| Length | `platforms.length` | Count elements |
| Wildcard | `endpoints[*].host` | All elements, extract field |
| Filter | `people[?(.role=="admin")]` | Conditional select |
| Slice | `items[2:5]` | Range of elements |

All expressions work against the fully resolved (merged) config — parent chain included.

## Implementation Roadmap

### Phase 1: Core (MVP)

Rust binary + shell wrappers. Enough to replace a single `.envrc`.

| Component | Location | Description |
|-----------|----------|-------------|
| CLI scaffold | `src/main.rs` | clap-based subcommand routing |
| YAML engine | `src/yaml/` | serde_yaml parse, deep merge, path get/set |
| Store manager | `src/store/` | Path hashing, directory layout, `.meta`, `.version` |
| Flatten engine | `src/flatten.rs` | `_dc` rules → `export KEY=VALUE` output |
| `dc yaml` | `src/cmd/yaml.rs` | Stdin YAML → merge/replace into store layer |
| `dc get` | `src/cmd/get.rs` | Path expression → value |
| `dc set` | `src/cmd/set.rs` | Path + value → write to layer |
| `dc env` | `src/cmd/env.rs` | Resolve parent chain → emit exports |
| `dc prune` | `src/cmd/prune.rs` | Tombstone markers |
| `dc init` | `src/cmd/init.rs` | Create store, optional `--from-envrc` import |
| `dc status` | `src/cmd/status.rs` | Show current state |
| Shell wrappers | `lib/direnv-stdlib.sh` | `dc_yaml`, `dc_get`, `dc_set`, `dc_prune`, `dc_export` |
| Bootstrap | `bin/dc-init` | POSIX sh — outputs precmd hook |
| Zsh adapter | `shell/dc.zsh` | Completions (generated by clap) |
| Makefile | `Makefile` | `compile` → `cargo build`, `install` → copy binary + shell files |

**Exit criterion:** `dc_export` in `.envrc` exports the same vars as the original `export`-heavy file.

### Phase 2: IPC + Tabbing Integration

Cross-process communication — child writes, parent sees.

| Component | Location | Description |
|-----------|----------|-------------|
| Precmd hook | `bin/dc-init` | Shell snippet: check `.version`, re-run `dc env` on bump |
| Tabbing bridge | `bin/dc-init` | If `tab.*` changed, call `tabbing-status` / `tabbing-style` |
| `dc watch` | `src/cmd/watch.rs` | `notify` crate — filesystem watcher with `--exec` |
| History | `src/store/history.rs` | Snapshot on write, `dc history`, `--restore`, `--diff` |
| Import | `src/cmd/init.rs` | `--from-envrc` parser (regex on `export` lines) |

**Exit criterion:** Claude Code runs `dc_set tab status "thinking"` and the parent shell's tab title updates.

### Phase 3: TUI

Interactive config browser/editor. This is where ratatui earns its keep.

| Component | Location | Description |
|-----------|----------|-------------|
| `dc edit` | `src/cmd/edit.rs` | ratatui full-screen app |
| Config tree view | `src/tui/tree.rs` | Collapsible tree of named configs → keys → values |
| Inline editor | `src/tui/editor.rs` | Edit values in-place with validation |
| Layer picker | `src/tui/layers.rs` | Switch between base/dev/local/secrets views |
| Diff view | `src/tui/diff.rs` | Side-by-side resolved vs layer view |
| Search / filter | `src/tui/filter.rs` | `/` to filter keys across configs |
| `dc doctor` | `src/cmd/doctor.rs` | Diagnose issues (replaces shell version) |

**TUI layout:**
```
┌─ dc edit ─────────────────────────────────────────────────────┐
│ Configs        │ Keys                    │ Value               │
│                │                         │                     │
│ ▸ cluster      │ name: noizu             │ noizu               │
│   cloudflare   │ kubeconfig: ~/.kube/... │                     │
│ ▸ tab          │ context: noizu          │ [base]              │
│   build        │ region: us-east-1       │                     │
│   npl          │ ▸ node_pool:            │ Layer: base         │
│   services     │     min: 2              │ Parent: (root)      │
│   _dc          │     max: 8              │ Version: 17         │
│                │     instance_type: m5.xl │                     │
├────────────────┴─────────────────────────┴─────────────────────┤
│ [Tab] switch pane  [/] filter  [e] edit  [l] layer  [q] quit  │
└────────────────────────────────────────────────────────────────┘
```

### Phase 4: Multi-Project + Polish

| Component | Location | Description |
|-----------|----------|-------------|
| `dc list` | `src/cmd/list.rs` | Scan all stores, show table |
| `dc sync` | `src/cmd/sync.rs` | Bulk import from `.envrc` files |
| `dc migrate` | `src/cmd/migrate.rs` | Guided `.envrc` → direnv-config migration |
| Bash adapter | `shell/dc.bash` | Bash completions + adapter |
| Shell completions | `build.rs` | clap `generate` for zsh/bash/fish |

## File Structure

```
direnv-config/
├── README.md
├── LICENSE                        # MIT
├── Cargo.toml                     # Rust project manifest
├── Cargo.lock
├── Makefile                       # compile, test, install targets
├── src/
│   ├── main.rs                    # clap CLI entry point
│   ├── cmd/                       # Subcommand handlers
│   │   ├── yaml.rs               # dc yaml — stdin merge/replace
│   │   ├── get.rs                 # dc get — path expression engine
│   │   ├── set.rs                 # dc set — write to layer
│   │   ├── env.rs                 # dc env — resolve + flatten + emit exports
│   │   ├── prune.rs              # dc prune — tombstone writes
│   │   ├── init.rs               # dc init — create store, --from-envrc
│   │   ├── status.rs             # dc status — current state dump
│   │   ├── watch.rs              # dc watch — notify-based file watcher
│   │   ├── history.rs            # dc history — snapshot browser
│   │   ├── list.rs               # dc list — all known stores
│   │   ├── doctor.rs             # dc doctor — diagnostics
│   │   └── edit.rs               # dc edit — ratatui TUI (Phase 3)
│   ├── yaml/                      # YAML engine
│   │   ├── merge.rs              # Deep merge with tombstone support
│   │   ├── path.rs               # Path expression parser + evaluator
│   │   └── flatten.rs            # _dc flatten rules → export lines
│   ├── store/                     # Store management
│   │   ├── layout.rs             # Path hashing, directory structure
│   │   ├── version.rs            # Atomic version bump
│   │   ├── meta.rs               # .meta file read/write
│   │   ├── resolve.rs            # Parent chain walk + merge
│   │   └── history.rs            # Snapshot management
│   └── tui/                       # ratatui components (Phase 3)
│       ├── app.rs                # Main TUI app loop
│       ├── tree.rs               # Config tree widget
│       ├── editor.rs             # Inline value editor
│       ├── layers.rs             # Layer switcher
│       ├── diff.rs               # Diff view
│       └── filter.rs             # Search/filter
├── lib/
│   └── direnv-stdlib.sh           # Shell wrappers (dc_yaml, dc_set, etc.)
├── bin/
│   └── dc-init                    # POSIX sh — precmd hook output
├── shell/
│   ├── dc.zsh                     # Zsh completions + adapter
│   └── dc.bash                    # Bash completions + adapter
├── demo/                          # Nested .envrc examples
├── examples/
│   ├── base.yaml
│   ├── dev.yaml
│   ├── secrets.yaml
│   └── envrc-minimal
├── tests/
│   ├── yaml_merge.rs              # Deep merge unit tests
│   ├── path_expr.rs               # Path expression tests
│   ├── flatten.rs                 # Flattening tests
│   ├── store.rs                   # Store layout + versioning tests
│   ├── resolve.rs                 # Parent chain resolution tests
│   └── integration/
│       ├── envrc_roundtrip.sh     # .envrc → dc → same env vars
│       └── ipc.sh                 # Child writes, parent detects
└── docs/
    ├── migration-guide.md
    └── ipc-protocol.md
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `DC_ROOT` | Path to active config store directory |
| `DC_VERSION` | Current config version (monotonic integer) |
| `DC_ENV` | Active environment name (`dev`, `prod`, etc.) |
| `DC_SOURCE` | Absolute path of the source directory |
| `DC_STORE` | Base storage directory (`~/.local/state/direnv-config`) |

## Design Decisions

### Why Rust?

- **Full YAML** — `serde_yaml` handles the entire spec; no subset parser, no edge cases, no `yq` dependency
- **Single binary** — `cargo build --release` → one static file, zero runtime deps, ~2MB
- **Path expressions** — `folder[5].person.mobile` is native `serde_yaml::Value` traversal, not awk heroics
- **Speed** — YAML parse + deep merge + flatten + export in ~2ms; awk pipeline takes ~50ms
- **ratatui** — `dc edit` TUI is a natural phase 3, same binary
- **Cross-compile** — `cross` for linux/arm64 (K8s nodes), native macOS build

### Why YAML over TOML/JSON?

- Familiar to the K8s/Helm ecosystem this repo lives in
- Comments supported natively
- Human-readable without tooling
- Deep merge semantics are well-understood
- Sequences (arrays) for lists of platforms, endpoints, etc.

### Why Not Just Use `direnv`'s `dotenv` Format?

`dotenv` is flat key=value. No nesting, no layering, no merge semantics. For a repo with 30+ projects each needing cluster config, secrets, feature flags, and tool settings — flat doesn't scale.

### Why a Compiled Binary Instead of Pure Shell?

The YAML operations (parse, merge, path traversal, array indexing) are fundamentally tree-structured. Shell tools (`awk`, `sed`) operate on text lines. Building a subset YAML parser in awk is possible but fragile — arrays, nested maps, multi-line strings, and merge keys each add edge cases that compound. A compiled binary with `serde_yaml` handles 100% of YAML correctly, and the shell wrappers stay under 5 lines each.

### Why Filesystem IPC Instead of Sockets/Pipes?

- Zero coordination — `stat` + `cat` work everywhere
- Survives process crashes — state persists on disk
- Multiple readers, multiple writers — no locking needed for reads
- Works across `tmux` panes, SSH sessions, container boundaries
- Debugging is `cat ~/.local/state/direnv-config/{hash}/tab/.active`

### Why a Version Counter?

The precmd hook needs to know "did anything change?" cheaply. Checking file mtimes is unreliable across filesystems. A monotonic integer in a 4-byte file is:
- Atomic to read (single `cat`)
- Cheap to compare (integer equality)
- Monotonic (no clock skew issues)

## License

MIT — Copyright 2026 Keith Brings
