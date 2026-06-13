# platform/analytics

| Service    | Image                     | Data                  | Host                 |
|------------|---------------------------|-----------------------|----------------------|
| matomo     | `matomo:5-apache`         | shared MariaDB + PVC  | matomo.noizu.com     |
| growthbook | `growthbook/growthbook`   | shared MongoDB        | growthbook.noizu.com |

## Data tier (platform/init)
- matomo → **platform-mariadb** (db `matomo`, `files/mariadb/initdb.d/matomo`)
- growthbook → **platform-mongodb** (db `growthbook`, `files/mongodb/initdb.d/growthbook`)

## Secrets (`/analytics` → `analytics-app-secrets`)
- `MATOMO_DB_PASSWORD` (must match `/platform/mariadb`)
- `GROWTHBOOK_MONGODB_URI` (full `mongodb://growthbook:<pass>@platform-mongodb.platform:27017/growthbook?authSource=growthbook`),
  `GROWTHBOOK_JWT_SECRET`, `GROWTHBOOK_ENCRYPTION_KEY`

`GROWTHBOOK_DB_USER`/`GROWTHBOOK_DB_PASSWORD` live in `/platform/mongodb` (for the
init script); the URI password must match. Plus `/shared/tls`, `/shared/registry`.

```sh
export AWS_ACCESS_KEY_ID=$(terraform -chdir=../../init output -raw minio_root_user)
export AWS_SECRET_ACCESS_KEY=$(terraform -chdir=../../init output -raw minio_root_password)
terragrunt apply
```
