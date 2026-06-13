# `infra` — platform workloads (MinIO-backed remote state)

The main platform module. Unlike `../init` (which uses **local** state because it
bootstraps the cluster from nothing), this module keeps its state in **MinIO**,
the S3-compatible object store that `init` stands up.

## Workloads (namespace `infra`, storage `longhorn`)

Modeled on the live cluster (`data-ns/shared-*`, `platform-ns/registry`,
`observability-ns/signoz`), consolidated into the `infra` namespace:

| Workload | File | Notes |
|---|---|---|
| Valkey | `valkey.tf` | `infra-valkey`, cache/queue |
| PostgreSQL | `postgres.tf` | `noizu/timescaledb-ha-with-age` (uid 1000, `/home/postgres/pgdata`); multi-tenant DB users via `init-db.sh` |
| ZooKeeper | `zookeeper.tf` | coordination for ClickHouse |
| ClickHouse | `clickhouse.tf` | config in `files/clickhouse/*`; waits on ZooKeeper |
| SigNoz | `signoz.tf` | `apm.noizu.com`; talks to ClickHouse |
| Docker registry | `registry.tf` | `ops.noizu.com`; basic-auth + `ops-noizu-com-tls` |

Secrets are **sealed secrets** (`secrets.tf` + `seal-secrets.sh`), unsealed by the
controller `init` installs. Config blobs live as real files under `files/`.

```
init/   →  local state  →  deploys MinIO + creates the `tfstate` bucket
infra/  →  state in MinIO (s3 backend) → everything else
```

## Bootstrap order

```sh
# 1. Bring up the cluster prerequisites + MinIO + the state bucket (local state)
cd ../init
terraform apply

# 2. Point this module's backend at MinIO. Credentials come from env, never code.
cd ../infra
export AWS_ACCESS_KEY_ID="$(terraform -chdir=../init output -raw minio_root_user)"
export AWS_SECRET_ACCESS_KEY="$(terraform -chdir=../init output -raw minio_root_password)"
terraform init      # creates infra/terraform.tfstate in the bucket
terraform plan
```

> `namespace` and `storage_class` are read from `init`'s state automatically
> (see `remote-state.tf`); you don't pass them. Only the backend creds (above)
> are supplied manually, since a backend block can't reference data sources.

## Backend details (see `provider.tf`)

- **Endpoint:** `https://minio.noizu.com` (the MinIO S3 API ingress).
- **Bucket / key:** `tfstate` / `infra/terraform.tfstate`.
- **`use_path_style = true`** — MinIO uses path-style addressing.
- **`use_lockfile = true`** — S3-native state locking (Terraform ≥ 1.10); no
  DynamoDB table required.
- **`skip_*` flags** — MinIO has no STS/IAM/EC2-metadata, so those AWS checks are
  disabled. `region` is a required placeholder MinIO ignores.

Credentials are the MinIO root (or a dedicated state user) access/secret key,
supplied via `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`. Nothing secret is
stored in this directory.

## Target cluster

`provider.tf` selects the cluster via `var.kube_context` (default `noizu` — the
colo server + VM members). Override with `-var kube_context=<ctx>` if needed.
