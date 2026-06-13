# Deployment

## Container Architecture

Multi-stage Docker build producing an nginx:alpine image serving a Next.js static export.

```
Stage 1 — Builder (node:22-alpine)
  └── npm ci → npm run build → /app/out/

Stage 2 — Runtime (nginx:alpine)
  └── COPY /app/out → /usr/share/nginx/html
  └── COPY nginx.conf → /etc/nginx/conf.d/default.conf
  └── EXPOSE 80
```

## nginx Configuration

- Gzip compression for text/CSS/JSON/JS/XML (min 256 bytes)
- Immutable cache headers (1 year) for `/_next/static/`
- SPA fallback: `try_files $uri $uri.html $uri/index.html /index.html`
- Security headers: `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`

## Build Pipeline

```bash
cd web
./build.sh          # Wraps: docker build -t therobotknows-web .
```

## Planned Infrastructure

When this project moves beyond prototype:

- Container deployed to the k8 cluster via Helm chart (Pattern A — local chart)
- Ingress via Cloudflare-only access (shared `cloudflare-lib`)
- Domain: `therobotknows.com` or subdomain of `noizu.com`
- Backend API server (TBD: Phoenix or Node) with PostgreSQL + vector store
- Secrets via Infisical operator
