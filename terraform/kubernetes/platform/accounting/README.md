# `platform/accounting` — accounting stack (ERPNext + Kimai)

Terraform translation of the `accounting-infra` Helm umbrella chart. Deploys into
the **`platform-accounting`** namespace (created by this module).

## Components

- **ERPNext** — upstream `erpnext` subchart (`https://helm.erpnext.com`,
  v8.0.53) via a `helm_release`. Brings up nginx, gunicorn, the default/short/long
  workers, scheduler, socketio, the built-in MariaDB StatefulSet, the
  cache/queue Valkey instances, and the configure + createSite jobs. The shared
  "sites" PVC (`erpnext-sites`, RWX) is created by this module and passed to the
  subchart as `persistence.worker.existingClaim`.
- **Kimai** — `kubernetes_deployment_v1` + Service (port 8001) with a data PVC.
- **Kimai MariaDB** — `kubernetes_deployment_v1` + Service (port 3306) with a
  data PVC.
- **Ingresses** — `erpnext-ingress` (accounting.noizu.com → `<release>-erpnext`
  :8080) and `kimai-ingress` (kimai.noizu.com → `kimai` :8001), class `nginx`,
  TLS via `cloudflare-tls-synced`.

## Secret management — Infisical

Two `InfisicalSecret` CRs (applied with the kubectl provider):

- `infisical-accounting-secrets`: path `/accounting` → managed Secret
  `accounting-app-secrets`. `includeAllSecrets` plus a template that builds
  `KIMAI_DATABASE_URL` from `KIMAI_DATABASE_PASSWORD`. Consumed by Kimai and its
  MariaDB.
- `infisical-tls-sync`: path `/shared/tls` → managed Secret
  `cloudflare-tls-synced` (`kubernetes.io/tls`), consumed by both ingresses.

Both read universal-auth creds from `universal-auth-credentials` in
`infisical-operator-system` (project `k8-infra`, env `prod`). Prerequisite: the
Infisical operator + that credentials secret (from `infra-services`).

## Storage

All PVCs use `local.storage_class`, read from the root `init` remote state
(`../../init/terraform.tfstate`), falling back to `var.storage_class`
(`longhorn`). The original chart bound `erpnext-sites` to a hostPath PV; this
module instead provisions it on the cluster storage class as RWX.

## State

MinIO s3 backend, key `platform/accounting/terraform.tfstate`.

```sh
export AWS_ACCESS_KEY_ID="$(terraform -chdir=../../init output -raw minio_root_user)"
export AWS_SECRET_ACCESS_KEY="$(terraform -chdir=../../init output -raw minio_root_password)"
terraform init && terraform plan
```
