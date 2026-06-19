# start-app

Phoenix API + Next.js frontend scaffold. Three-container stack (backend, frontend, nginx) with Postgres/Redis on a shared Docker network. Scaffolded into `projects/{domain}/app/` via `init-proj-scaffold`.

## Quick Start

```bash
make init          # Generate .env files with secrets
make build         # Build all Docker images
make run           # Start containers (nginx on :8080)
```

## Modes

### Production

Pre-built images, nginx reverse proxy, no source mounts.

```bash
make build         # Build backend + frontend + nginx
make run           # Start stack
make stop          # Tear down
```

### Dev (Hot Reload)

Source-mounted volumes with `npm run dev` and `mix phx.server`. Changes rebuild automatically via Next.js HMR and Phoenix code reloading.

```bash
make run-dev       # Foreground with live logs
make run-dev-d     # Detached
make logs-dev      # Tail logs
make stop-dev      # Tear down
```

### Live Sandbox (Remote Dev)

A single container combining Node.js + Elixir + Samba. Exposes the app's `/workspace` directory as an SMB share so you can mount it on your local machine and edit files directly — both Next.js and Elixir watchers auto-rebuild on changes.

#### Local (Docker Compose)

```bash
make sandbox       # Build the sandbox image
make run-sandbox   # Start (foreground)
make run-sandbox-d # Start (detached)
make sandbox-mount # Mount workspace at ~/sandbox-<project> (macOS)
```

The sandbox exposes three ports:

| Port | Service |
|------|---------|
| 445  | Samba share (`//localhost/workspace`, user: `dev`, pass: `dev`) |
| 3000 | Next.js dev server |
| 4000 | Phoenix dev server |

Override ports with env vars: `SANDBOX_SMB_PORT`, `SANDBOX_FRONTEND_PORT`, `SANDBOX_BACKEND_PORT`.

#### Kubernetes (Helm)

Deploy the sandbox as a sidecar deployment alongside (or instead of) the production stack:

```bash
# Build and push the sandbox image
make sandbox
docker tag ops.noizu.com/<project>/sandbox:latest ops.noizu.com/<project>/sandbox:latest
docker push ops.noizu.com/<project>/sandbox:latest

# Deploy with sandbox enabled
helm upgrade <release> helm/start-app \
  --set sandbox.enabled=true \
  --set sandbox.image=ops.noizu.com/<project>/sandbox:latest

# Port-forward to your machine
kubectl port-forward svc/<release>-start-app-sandbox 445:445 3000:3000 4000:4000

# Mount the share (macOS)
mount_smbfs //dev:dev@localhost/workspace ~/sandbox-myapp

# Mount the share (Linux)
sudo mount -t cifs //localhost/workspace ~/sandbox-myapp -o user=dev,password=dev,port=445
```

Sandbox Helm values:

```yaml
sandbox:
  enabled: true
  image: ops.noizu.com/myapp/sandbox:latest
  resources:
    requests:
      cpu: 200m
      memory: 512Mi
    limits:
      cpu: "1"
      memory: 1Gi
  persistence:
    enabled: false      # Set true for a PVC-backed workspace
    size: 5Gi
    storageClass: ""
  service:
    type: ClusterIP     # Use NodePort or LoadBalancer for direct access
```

#### How It Works

1. On first start, source from `frontend/` and `backend/` is seeded into `/workspace/`
2. Samba exposes `/workspace` as a network share
3. Supervisord manages three processes: smbd, `npm run dev`, `mix phx.server`
4. Edit files via the mount — inotify/polling triggers automatic rebuilds
5. Oplocks are disabled in Samba to prevent stale-cache issues with file watchers

## Build & Push

```bash
make build-push    # Multi-arch (amd64+arm64) build and push to registry
make push          # Push pre-built images
```

## Migrations

Liquibase for canonical schema, Ecto for app-level changes.

```bash
make migrate            # Run pending migrations
make migrate-status     # Show pending changesets
make migrate-rollback   # Roll back last changeset
```

## Helm Chart

```bash
make helm-lint          # Lint
make helm-package       # Package .tgz
make helm-publish       # Package + push to OCI registry
make helm-bump-patch    # Bump patch version
```

## Project Identity

When placed at `projects/{domain}/app/`, the Makefile derives the project slug, DB name, Redis DB number, host port, and image tags from the parent directory name. No config edits needed.

## Project Layout

```
start-app/
├── frontend/              # Next.js 15
├── backend/               # Phoenix 1.8 API
├── nginx/                 # Reverse proxy
├── sandbox/               # Live-sandbox configs (smb, supervisor, entrypoint)
├── helm/start-app/        # Helm chart
├── scripts/               # gen-env.sh
├── docs/                  # Architecture + layout docs
├── Dockerfile.sandbox     # Combined sandbox image
├── docker-compose.yaml    # Production
├── docker-compose.dev.yaml      # Dev overrides
├── docker-compose.sandbox.yaml  # Sandbox overrides
└── Makefile               # All build/run/deploy targets
```

## Tech Stack

- **Frontend**: Next.js 15, React 19, Tailwind v4, YAML-driven design system
- **Backend**: Elixir 1.19, Phoenix 1.8, Guardian JWT, Ueberauth SSO
- **Database**: PostgreSQL (PostGIS, pgvector), Redis
- **Proxy**: Nginx
- **Schema**: Liquibase + Ecto
- **Deploy**: Docker Compose (local), Helm (Kubernetes)
- **Registry**: ops.noizu.com
- **Secrets**: Infisical
