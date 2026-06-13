# platform/content

| Service   | Image                | Data                                  | Host                |
|-----------|----------------------|---------------------------------------|---------------------|
| docmost   | `docmost/docmost`    | shared Postgres + Valkey + PVC (50Gi) | docmost.noizu.com   |
| ghost     | `ghost:5.109-alpine` | shared MariaDB + PVC (10Gi)           | ghost.noizu.com     |
| nextcloud | `nextcloud:29-apache`| shared Postgres + Valkey + PVC (100Gi)| nextcloud.noizu.com |

## Data tier (platform/init)
- docmost → **platform-timescaledb** (`files/postgres/initdb.d/docmost`) + **platform-valkey**
- ghost → **platform-mariadb** (`files/mariadb/initdb.d/ghost`)
- nextcloud → **platform-timescaledb** (`files/postgres/initdb.d/nextcloud`) + **platform-valkey**

## Secrets (`/content` → `content-app-secrets`)
- docmost: `DOCMOST_DATABASE_URL`, `DOCMOST_REDIS_URL`, `DOCMOST_JWT_SECRET`, `SMTP_HOST/PORT/USER/PASSWORD/FROM`
- ghost: `GHOST_DB_PASSWORD`
- nextcloud: `NEXTCLOUD_DB_USER`, `NEXTCLOUD_DB_PASSWORD`, `NEXTCLOUD_REDIS_PASSWORD`
  (= Valkey password), `NEXTCLOUD_ADMIN_USER`, `NEXTCLOUD_ADMIN_PASSWORD`, `SMTP_*`

`docmost`'s full DSNs and `nextcloud`'s discrete creds/redis-password must match
the shared DB roles in `/platform/postgres`, `/platform/mariadb`, `/platform/valkey`.
Plus `/shared/tls`, `/shared/registry`.

```sh
export AWS_ACCESS_KEY_ID=$(terraform -chdir=../../init output -raw minio_root_user)
export AWS_SECRET_ACCESS_KEY=$(terraform -chdir=../../init output -raw minio_root_password)
terragrunt apply
```
