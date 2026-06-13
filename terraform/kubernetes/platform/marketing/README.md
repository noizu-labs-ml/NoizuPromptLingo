# platform/marketing

| Service  | Image                  | Data                          | Host               |
|----------|------------------------|-------------------------------|--------------------|
| listmonk | `listmonk/listmonk`    | shared Postgres + PVC uploads | listmonk.noizu.com |
| mautic   | `mautic/mautic:5-apache` | shared MariaDB + PVC        | mautic.noizu.com   |

## Data tier (platform/init)
- listmonk → **platform-timescaledb** (db `listmonk`, `files/postgres/initdb.d/listmonk`)
- mautic → **platform-mariadb** (db `mautic`, `files/mariadb/initdb.d/mautic`)

## Secrets (`/marketing` → `marketing-app-secrets`)
- `LISTMONK_DB_PASSWORD`
- `MAUTIC_DB_PASSWORD`, `MAUTIC_SECRET_KEY`

`<APP>_DB_PASSWORD` must match the copy in `/platform/postgres` (listmonk) /
`/platform/mariadb` (mautic). Plus `/shared/tls`, `/shared/registry`.

```sh
export AWS_ACCESS_KEY_ID=$(terraform -chdir=../../init output -raw minio_root_user)
export AWS_SECRET_ACCESS_KEY=$(terraform -chdir=../../init output -raw minio_root_password)
terragrunt apply
```
