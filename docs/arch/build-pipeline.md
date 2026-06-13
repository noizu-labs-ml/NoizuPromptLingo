# Build & Deploy Pipeline

## Docker Build

Two-stage Dockerfile in `web/`:

1. **Builder stage** (`node:22-alpine`): `npm ci` → `npm run build` → static export to `out/`
2. **Runtime stage** (`nginx:alpine`): copies `out/` to nginx html root, applies custom `nginx.conf`

Build command: `./build.sh` from `web/`

## nginx Configuration

- Listens on port 80
- Gzip enabled for text, CSS, JSON, JS, XML (min 256 bytes)
- Static asset caching: `/_next/static/` gets 1-year `immutable` cache headers
- SPA fallback: `try_files $uri $uri.html $uri/index.html /index.html`
- Security headers: `X-Content-Type-Options: nosniff`, `X-Frame-Options: SAMEORIGIN`, `Referrer-Policy: strict-origin-when-cross-origin`

## DNS & TLS

Served at `robots-unite.com` behind Cloudflare. TLS termination at Cloudflare edge. Origin uses Cloudflare-authenticated origin pull (standard across the `*.noizu.com` infrastructure).

## Deployment

Currently manual Docker build and push. Future: integrated with the k8 incubator's `docker-build` / `docker-push` tooling and Helm chart deployment via `project.yaml` metadata.
