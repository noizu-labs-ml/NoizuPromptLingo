# platform/devtools

| Service     | Image                              | Data                   | Host                |
|-------------|------------------------------------|------------------------|---------------------|
| code-server | `lscr.io/linuxserver/code-server`  | PVC `/config` (50Gi)   | code.noizu.com      |
| livecodes   | `ops.noizu.com/livecodes`          | shared Valkey (db 2)   | livecodes.noizu.com |

## Secrets (`/devtools` → `devtools-app-secrets`)
- `CODE_SERVER_PASSWORD`
- `LIVECODES_REDIS_URL` — full `redis://:<valkey-pass>@platform-valkey.platform:6379/2`

Plus `/shared/tls` → `cloudflare-tls-synced`, `/shared/registry` → `ops-registry-secret`.

```sh
export AWS_ACCESS_KEY_ID=$(terraform -chdir=../../init output -raw minio_root_user)
export AWS_SECRET_ACCESS_KEY=$(terraform -chdir=../../init output -raw minio_root_password)
terragrunt apply
```
