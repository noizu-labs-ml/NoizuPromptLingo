# platform/creative

Diagram + design tools in the `platform-creative` namespace.

| Service    | Image                                   | Data                         | Host                |
|------------|-----------------------------------------|------------------------------|---------------------|
| chartdb    | `ops.noizu.com/chartdb/chartdb`         | stateless                    | chartdb.noizu.com   |
| drawio     | `jgraph/drawio`                         | stateless                    | drawio.noizu.com    |
| plantuml   | `plantuml/plantuml-server:jetty`        | stateless                    | plantuml.noizu.com  |
| kroki      | `yuzutech/kroki` + 4 companions         | stateless                    | kroki.noizu.com     |
| mydraft    | `ops.noizu.com/noizu/mydraft-server`    | PVC (5Gi)                    | mydraft.noizu.com   |
| excalidraw | `excalidraw/excalidraw` + room          | shared Valkey (db 1)         | excalidraw.noizu.com|
| mermaid    | `ops.noizu.com/mermaid-live-editor`     | shared Postgres + Authentik OIDC + OTEL | mermaid.noizu.com |
| penpot     | `penpotapp/{frontend,backend,exporter}` | shared Postgres + Valkey + embedded MinIO (PVC) | penpot.noizu.com |
| webstudio  | `ops.noizu.com/webstudio/builder` + PostgREST | shared Postgres        | webstudio.noizu.com |

## Data tier (platform/init)
- Postgres (`platform-timescaledb`): mermaid, penpot, webstudio — DBs provisioned by
  `files/postgres/initdb.d/{mermaid,penpot,webstudio}`.
- Valkey (`platform-valkey`): excalidraw (db 1), penpot (db 0).
- penpot also runs its own embedded MinIO (`penpot-minio`) for asset storage.

## Secrets (Infisical, project `k8-infra`, env `prod`)
Per-app paths → `<app>-secrets` (created in `secrets.tf` via for_each over
`app_secret_names = [excalidraw, mermaid, penpot, webstudio]`):
- `/creative/excalidraw`: `EXCALIDRAW_REDIS_PASSWORD`
- `/creative/mermaid`: DB DSN/creds, Authentik OIDC client, `SENDGRID_API_KEY`, `BETTER_AUTH_SECRET` (consumed via `envFrom`)
- `/creative/penpot`: `PENPOT_SECRET_KEY`, `PENPOT_DATABASE_URI/USERNAME/PASSWORD`, `PENPOT_REDIS_URI`,
  `PENPOT_GOOGLE_CLIENT_ID/SECRET`, `MINIO_ROOT_USER/PASSWORD`
- `/creative/webstudio`: `WEBSTUDIO_DB_USER/PASSWORD`, `WEBSTUDIO_AUTH_SECRET`,
  `WEBSTUDIO_POSTGREST_JWT_SECRET`, `WEBSTUDIO_GOOGLE_CLIENT_ID/SECRET`, `WEBSTUDIO_DEV_LOGIN`

chartdb/drawio/kroki/mydraft/plantuml need no app secret. Shared: `/shared/tls`
→ `cloudflare-tls-synced`, `/shared/registry` → `ops-registry-secret`.

> Notes: penpot's `PENPOT_INTERNAL_RESOLVER` is set to `10.0.0.254` (the legacy
> cluster's DNS ClusterIP) — verify it matches this cluster's kube-dns/CoreDNS.
> DB/Redis full DSNs in Infisical must point at the platform-tier services and
> match the roles created by `platform/init`.

```sh
export AWS_ACCESS_KEY_ID=$(terraform -chdir=../../init output -raw minio_root_user)
export AWS_SECRET_ACCESS_KEY=$(terraform -chdir=../../init output -raw minio_root_password)
terragrunt apply
```
