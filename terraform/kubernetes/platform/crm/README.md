# platform/crm

Self-hosted CRM apps in the `platform-crm` namespace:

| Service   | Image                          | Data                              | Host                |
|-----------|--------------------------------|-----------------------------------|---------------------|
| espocrm   | `espocrm/espocrm`              | shared MariaDB (`espocrm` db) + PVC | espocrm.noizu.com  |
| bottlecrm | `ops.noizu.com/bottlecrm`(+fe) | shared Postgres + Valkey          | bottlecrm.noizu.com |

bottlecrm runs backend (gunicorn) + celery worker + celery beat + SvelteKit
frontend in one pod; ingress routes `/api` and `/admin` to the backend (8000) and
everything else to the frontend (3000).

## Data tier (platform/init)

- espocrm → **platform-mariadb**, DB provisioned by `files/mariadb/initdb.d/espocrm`.
- bottlecrm → **platform-timescaledb** (db `bottlecrm`, see `files/postgres/initdb.d/bottlecrm`) + **platform-valkey**.

## Secrets (Infisical, project `k8-infra`, env `prod`)

`/crm` → `crm-app-secrets`:
- espocrm: `ESPOCRM_DB_PASSWORD`, `ESPOCRM_ADMIN_USERNAME`, `ESPOCRM_ADMIN_PASSWORD`
- bottlecrm: `BOTTLECRM_SECRET_KEY`, `BOTTLECRM_DB_PASSWORD`, `BOTTLECRM_REDIS_URL`
  (full `redis://:<valkey-pass>@platform-valkey.platform:6379/1`),
  `BOTTLECRM_GOOGLE_CLIENT_ID`, `BOTTLECRM_GOOGLE_CLIENT_SECRET`, `SENDGRID_API_KEY`

Also: `/shared/tls` → `cloudflare-tls-synced`, `/shared/registry` → `ops-registry-secret`.

> The `<APP>_DB_PASSWORD` value must match the copy in `/platform/mariadb`
> (espocrm) / `/platform/postgres` (bottlecrm) used to create the shared DB role.

## Apply

```sh
export AWS_ACCESS_KEY_ID=$(terraform -chdir=../../init output -raw minio_root_user)
export AWS_SECRET_ACCESS_KEY=$(terraform -chdir=../../init output -raw minio_root_password)
terragrunt apply
```
