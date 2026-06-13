# Build & Deployment Pipeline

## Docker Build (Multi-Stage)

**Stage 1 — Builder** (`node:22-alpine`):
1. Install dependencies via `npm ci`
2. Run `next build` which produces a static export to `out/`

**Stage 2 — Runtime** (`nginx:alpine`):
1. Copy `out/` directory to nginx html root
2. Apply custom `nginx.conf` for SPA routing
3. Expose port 80, run nginx in foreground

## Helm Deployment

The Helm chart (`helm/therobotlives/`, Chart v0.1.0) produces four resources:

| Resource | Template | Purpose |
|----------|----------|---------|
| Deployment | `deployment.yaml` | Single replica running the nginx container on port 3000 |
| Service | `service.yaml` | ClusterIP service exposing the deployment |
| Ingress | `ingress.yaml` | NGINX Ingress with Cloudflare IP whitelist + TLS termination |
| InfisicalSecret | `tls-secret.yaml` | Syncs TLS cert/key from Infisical to a K8s TLS Secret |

## Resource Allocation

| Resource | Request | Limit |
|----------|---------|-------|
| CPU | 50m | 200m |
| Memory | 128Mi | 256Mi |

## Health Checks

- **Liveness**: `GET /` on port 3000, initial delay 10s, period 30s
- **Readiness**: `GET /` on port 3000, initial delay 5s, period 10s

## Image Registry

Images are pushed to `ops.noizu.com/therobotlives.com/web` and pulled via `ops-registry-secret` imagePullSecret.
