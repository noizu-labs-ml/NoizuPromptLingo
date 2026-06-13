# direnv-config Demo

A nested directory tree demonstrating every direnv-config operation. Each `.envrc` inherits from its parent and modifies the config using different operations.

## Directory Tree

```
root/                          ← Cold start, defines 5 named configs
├── .envrc                       cluster, cloudflare, tab, build, npl + _dc flatten rules
│
├── projects/                  ← Inherits all, adds services, overrides tab
│   ├── .envrc                   dc_yaml tab (merge), dc_yaml services (new)
│   │
│   ├── design/                ← Merge, prune, set
│   │   └── .envrc               dc_yaml tab (merge), dc_prune npl, dc_set tab status,
│   │                            dc_yaml services (merge into inherited), dc_yaml project (new)
│   │
│   ├── staging/               ← Replace, replace-key
│   │   └── .envrc               dc_yaml cloudflare --replace (wipe + rewrite),
│   │                            dc_yaml cluster --replace-key node_pool (branch swap),
│   │                            dc_yaml build (merge), dc_yaml project (new)
│   │
│   ├── terraform/             ← Heavy pruning, unset, batched writes
│   │   └── .envrc               dc_prune cluster/services/npl/build (4 whole configs),
│   │                            dc_prune cloudflare tunnel (branch), dc_unset cloudflare zone_id_trl,
│   │                            dc_yaml terraform (new), all --no-bump + dc_bump
│   │
│   └── apps/                  ← Multiple per-app named configs, secrets scaffolding
│       └── .envrc               dc_yaml app-codefresh, app-therobotlives, app-noizurpg (3 new),
│                                dc_yaml --layer secrets --if-missing (per-app secret seeds)
│
└── scripts/
    └── deploy.sh              ← Runtime IPC: dc_set from child process
```

## Operations Demonstrated

| Operation | Where | What It Does |
|-----------|-------|-------------|
| `dc_yaml name <<'YAML'` | Every `.envrc` | Deep merge — add/overwrite keys, preserve siblings |
| `dc_yaml name --replace` | staging | Wipe entire named config, write fresh |
| `dc_yaml name --replace-key KEY` | staging | Replace one branch within a named config |
| `dc_yaml name --layer secrets` | root, apps | Write to secrets layer |
| `dc_yaml name --if-missing` | root, apps | Only create layer if it doesn't exist |
| `dc_yaml name --no-bump` | terraform | Suppress version bump for batched writes |
| `dc_prune name` | design, terraform | Remove entire named config |
| `dc_prune name key` | terraform | Remove a branch within a named config |
| `dc_unset name key` | terraform | Remove a single key |
| `dc_set name key value` | design, deploy.sh | Set individual key (default: local layer) |
| `dc_bump` | terraform | Finalize batched `--no-bump` operations |

## Named Configs in This Demo

| Config | Defined At | Inherited By | Purpose |
|--------|-----------|-------------|---------|
| `cluster` | root | projects, design, staging, apps | K8s cluster connection |
| `cloudflare` | root | projects, design, staging, terraform, apps | CF API config |
| `tab` | root | all children | Terminal tab title/theme |
| `build` | root | projects, design, staging, apps | Docker build settings |
| `npl` | root | projects, staging, apps | NPL project ID |
| `services` | projects | design, staging, terraform, apps | Postgres/Redis endpoints |
| `project` | design, staging | — | Per-project metadata |
| `terraform` | terraform | — | IaC-specific config |
| `app-codefresh` | apps | — | Per-app config |
| `app-therobotlives` | apps | — | Per-app config |
| `app-noizurpg` | apps | — | Per-app config |
| `_dc` | every level | merged down chain | Flatten rules (YAML → env vars) |

## Expected State

The `expected-state/` directory contains the fully resolved YAML for each level, showing exactly which keys survive, which are overwritten, and which are pruned. Each file includes comments showing the resulting env vars.

```
expected-state/
├── root.yaml          5 named configs, baseline env vars
├── projects.yaml      tab modified, services added
├── design.yaml        npl pruned, services.postgres merged, tab overridden by local layer
├── staging.yaml       cloudflare replaced, cluster.node_pool replaced, build merged
└── terraform.yaml     4 configs pruned, cloudflare.tunnel pruned, zone_id_trl unset
```

## Config Inheritance Diagram

```
root
├── cluster ─────────┬── projects ──┬── design     (inherited unchanged)
├── cloudflare ──────┤              ├── staging    (--replace: completely new)
├── tab ─────────────┤              ├── terraform  (partial prune: tunnel + zone_id_trl)
├── build ───────────┤              └── apps       (inherited unchanged)
├── npl ─────────────┤
│                    │
│   + services ──────┤
│                    │
│                    ├── design
│                    │   pruned: npl
│                    │   merged: tab (theme+status+emoji), services (pool_size+database)
│                    │   set: tab.status → "ready" (local layer)
│                    │   added: project
│                    │
│                    ├── staging
│                    │   replaced: cloudflare (whole config)
│                    │   replaced-key: cluster.node_pool
│                    │   merged: build (env+push_on_build), tab (theme+status+emoji)
│                    │   added: project
│                    │
│                    ├── terraform
│                    │   pruned: cluster, services, npl, build (entire configs)
│                    │   pruned: cloudflare.tunnel (branch)
│                    │   unset: cloudflare.zone_id_trl (single key)
│                    │   merged: tab (theme+status+emoji)
│                    │   added: terraform
│                    │
│                    └── apps
│                        merged: build (env+registry+push_on_build+platforms)
│                        merged: tab (theme+status)
│                        added: app-codefresh, app-therobotlives, app-noizurpg
│                        secrets: per-app --if-missing scaffolds
```
