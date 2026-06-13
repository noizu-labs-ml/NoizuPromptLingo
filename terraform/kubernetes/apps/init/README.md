# `apps/init` — apps-tier shared data services and app publishing

Deploys the apps tier's shared **Valkey** (`app-valkey`) and **TimescaleDB**
(`app-timescaledb`) into the `apps` namespace, via the reusable
`../../modules/{valkey,timescaledb}` modules.

Also publishes static websites through local Helm charts:

- `noizu.com` from `../../../../projects/noizu.com/helm/noizu-site`
- `aifighter.com` from `../../../../projects/aifighter.com/helm/aifighter`

## Secret management — Infisical

Credentials come from **Infisical** via the operator: each module creates an
`InfisicalSecret` CR syncing `/apps/valkey`, `/apps/postgres`, `/shared/tls`,
and `/shared/registry` from the `k8-infra` project (env `prod`) into the
managed Secrets (`app-valkey-secrets`, `app-timescaledb-secrets`,
`noizu-com-tls`, `aifighter-com-tls`, and `ops-registry-secret`).

Prerequisites (from `infra-services`): the Infisical operator + the
`universal-auth-credentials` secret in `infra`.

## State

MinIO s3 backend, key `apps/init/terraform.tfstate`. Storage class is read from
the root `init` state.

```sh
export AWS_ACCESS_KEY_ID="$(terraform -chdir=../../init output -raw minio_root_user)"
export AWS_SECRET_ACCESS_KEY="$(terraform -chdir=../../init output -raw minio_root_password)"
terraform init && terraform plan
```

## Terragrunt

This unit is wired for `terragrunt run --all` through `terragrunt.hcl`. It runs
after `../../init` and `../../infra-services`, copies from the
`terraform/kubernetes` root so `../../modules` is available in the Terragrunt
cache, and passes absolute paths for the root init local state and the local
static-site Helm charts.
