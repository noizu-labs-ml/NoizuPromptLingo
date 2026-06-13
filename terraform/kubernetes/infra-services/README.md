# `infra-services` — platform applications (MinIO-backed remote state)

Application tier, deployed into the `infra` namespace. Sits on top of `init`
(cluster bootstrap + MinIO) and `infra` (shared data tier: postgres, valkey,
clickhouse, zookeeper, registry, minio).

```
init/           local state    bootstrap + MinIO + tfstate bucket
infra/          state in MinIO  shared data tier
infra-services/ state in MinIO  the apps below
```

## Services

| App | File | Host | Notes |
|---|---|---|---|
| Infisical | `infisical.tf` | infisical.noizu.com | shared infra-timescaledb + infra-valkey |
| Infisical operator | `infisical-operator.tf` | — | secrets.infisical.com CRDs, ns `infisical-operator-system` |
| Verdaccio | `verdaccio.tf` | npm.noizu.com | private npm registry |
| Headlamp | `headlamp.tf` | headlamp.noizu.com | k8s dashboard (cluster-admin SA) |
| Authentik | `authentik.tf` | auth.noizu.com | server + worker; config via `envFrom` |
| Phoenix | `phoenix.tf` | eval.noizu.com | uses shared Postgres |
| PostHog | `posthog.tf` | posthog.noizu.com | web/worker/plugins → **shared** clickhouse/postgres/valkey; dedicated Redpanda (kafka) |
| SigNoz | `signoz.tf` | apm.noizu.com | moved from the infra module; uses infra-clickhouse |
| Cockpit | `cockpit.tf` | cockpit.noizu.com | proxy (Service + manual Endpoints) to the host Cockpit at `10.1.0.1:9090` |

## State backend

MinIO s3 backend, key `infra-services/terraform.tfstate`. Bootstrap:

```sh
export AWS_ACCESS_KEY_ID="$(terraform -chdir=../init output -raw minio_root_user)"
export AWS_SECRET_ACCESS_KEY="$(terraform -chdir=../init output -raw minio_root_password)"
terraform init && terraform plan
```

`namespace`, `storage_class` and `node_selector` are read from `init`'s state
(`remote-state.tf` / `locals.tf`). Every workload is pinned to the base node
(`noizu-server`) via `node_selector = local.node_selector`; every PVC uses
`local.storage_class` (longhorn).

## Run order (Terragrunt)

`terragrunt.hcl` declares `dependencies { paths = ["../init", "../infra"] }`, so
this stack runs LAST (init → infra → infra-services). It reads init's outputs
directly and its apps connect to the shared data tier `infra` stands up.

## Secrets (sealed)

All secrets are sealed, unsealed by the controller `init` installs. The old
cluster is gone, so nothing is copied from a live cluster — `./seal-secrets.sh`
**generates once and seals**, sourcing values by kind:

| Source | Examples |
|---|---|
| shared with `infra` (its `values.env`) | Phoenix/PostHog/Authentik DB URLs, `SIGNOZ_TOKENIZER_JWT_SECRET` |
| generated once (this module's `values.env`) | `*_SECRET_KEY`, bootstrap/admin secrets, verdaccio htpasswd |
| external — you fill `overrides.env` | Google OAuth (Phoenix), SendGrid/SMTP |
| recovered from the cluster backup | `cloudflare-tls-synced` (`*.noizu.com` wildcard) |

The per-app Valkey secrets (`authentik-valkey`, `posthog-valkey`) are NOT sealed
here — `valkey-users.tf` materialises them from init's `shared_valkey_users`.

```sh
../infra/seal-managed-secrets.sh   # FIRST — produces the shared DB creds + JWT
./seal-secrets.sh                  # then generate + seal this module's secrets
```

Empty external creds are fine: the app deploys and that integration stays inert
until you fill `<repo>/.secrets/infra-services/overrides.env` and re-run.
