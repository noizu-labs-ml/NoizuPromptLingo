# platform/seo

Self-hosted SEO tools in the `platform-seo` namespace:

| Service  | Image                        | Data                         | Host                 |
|----------|------------------------------|------------------------------|----------------------|
| seonaut  | `ops.noizu.com/seonaut`      | shared MariaDB (`seonaut` db)| seonaut.noizu.com    |
| serpbear | `towfiqi/serpbear`           | PVC (embedded SQLite)        | serpbear.noizu.com   |

## Data tier

`seonaut` uses the shared **platform-mariadb** (`platform/init`). Its DB + login
user are provisioned by `platform/init/files/mariadb/initdb.d/seonaut/init-db.sh`.

## Secrets (Infisical, project `k8-infra`, env `prod`)

`/seo` → `seo-app-secrets`:
- `SEONAUT_DB_PASSWORD`
- `SERPBEAR_USER`, `SERPBEAR_PASSWORD`, `SERPBEAR_SECRET`, `SERPBEAR_API_TOKEN`

`/platform/mariadb` (for the shared DB): `SEONAUT_DB_USER`, `SEONAUT_DB_PASSWORD`.
`/shared/tls` → `cloudflare-tls-synced`. `/shared/registry` → `ops-registry-secret`.

## Apply

```sh
export AWS_ACCESS_KEY_ID=$(terraform -chdir=../../init output -raw minio_root_user)
export AWS_SECRET_ACCESS_KEY=$(terraform -chdir=../../init output -raw minio_root_password)
terragrunt apply
```

> Note: legacy PVCs pinned a specific `volumeName` / `openebs-lvmpv`. This stack
> uses the cluster default storage class; restore serpbear's SQLite data
> separately if migrating existing content.
