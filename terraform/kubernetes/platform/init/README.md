# `platform/init` — platform-tier shared data services

Deploys the platform tier's shared **Valkey** (`platform-valkey`) and
**TimescaleDB** (`platform-timescaledb`) into the `platform` namespace, using the
reusable `../../modules/{valkey,timescaledb}` modules.

## Secret management — Infisical

Unlike the `infra`/`infra-services` modules (sealed secrets), these workloads get
their credentials from **Infisical** via the operator: each module creates an
`InfisicalSecret` CR that syncs `/platform/valkey` and `/platform/postgres` from
the `k8-infra` project (env `prod`) into the managed Secrets
(`platform-valkey-secrets`, `platform-timescaledb-secrets`).

Prerequisites (from `infra-services`): the Infisical operator + the
`universal-auth-credentials` machine-identity secret in `infra`.

## State

MinIO s3 backend, key `platform/init/terraform.tfstate`. Storage class is read
from the root `init` state.

```sh
export AWS_ACCESS_KEY_ID="$(terraform -chdir=../../init output -raw minio_root_user)"
export AWS_SECRET_ACCESS_KEY="$(terraform -chdir=../../init output -raw minio_root_password)"
terraform init && terraform plan
```
