# Build & Deploy Pipeline

## Build Process

1. **Static Export**: `next build` with `output: "export"` generates flat HTML/CSS/JS into `web/out/`
2. **Docker Build**: Multi-stage Dockerfile
   - Stage 1 (`node:22-alpine`): `npm ci` → `npm run build` → produces `out/`
   - Stage 2 (`nginx:alpine`): Copies `out/` to `/usr/share/nginx/html`, injects `nginx.conf`
3. **Push**: Image tagged and pushed to `ops.noizu.com/app-jailbreakingsite`

## Build Script

`web/build.sh` wraps the full pipeline:
```
npm run build → docker build --platform linux/amd64 → docker push
```

Accepts optional tag argument (defaults to `latest`).

## nginx Configuration

- Gzip compression for text/CSS/JSON/JS
- 1-year cache with `immutable` for `/_next/static/`
- SPA fallback: `try_files $uri $uri.html $uri/index.html /index.html`
- Security headers: `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`

## Container

- **Base**: `nginx:alpine`
- **Port**: 80
- **Image**: `ops.noizu.com/app-jailbreakingsite:{tag}`
- **Platform**: `linux/amd64`

## Deployment Target

Kubernetes cluster via the parent incubator infrastructure. Cloudflare handles TLS termination and origin pull to the nginx container.
