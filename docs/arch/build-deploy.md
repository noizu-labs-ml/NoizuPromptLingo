# Build & Deploy

## Static Export

Next.js is configured with `output: "export"` in `next.config.mjs`, producing a fully static site in the `out/` directory. No Node.js server runtime is required at serving time.

## Docker Build

Two-stage Dockerfile:

1. **Build stage** (`node:22-alpine`) — installs dependencies, runs `next build`, produces `out/`
2. **Serve stage** (`nginx:alpine`) — copies `out/` to `/usr/share/nginx/html`, applies custom `nginx.conf`

## build.sh

```bash
./build.sh    # Builds linux/amd64, tags as ops.noizu.com/noizu-website:{tag}, pushes
```

The script handles version tagging and pushes to the private container registry at `ops.noizu.com`.

## nginx Configuration

| Feature | Setting |
|---------|---------|
| Compression | gzip on (text/html, CSS, JS, JSON, SVG, XML) |
| Static cache | `_next/static/` — 1 year, immutable |
| SPA fallback | `try_files $uri $uri/ /index.html` |
| Security headers | X-Frame-Options, X-Content-Type-Options, Referrer-Policy |
| Listen port | 80 |

## K8s Status

This project lives in the incubator (`repos/incubator/projects/noizu.com`), not yet promoted to a first-class K8s project. No `project.yaml` exists in the parent infrastructure. The container image is built and pushed manually via `build.sh`; integration with the `helm-upgrade` orchestrator is pending.

## Environment

| File | Purpose |
|------|---------|
| `envrc.example` | Template for `.envrc` — copy and fill secrets |
| `.tool-versions` | asdf version pinning — Node.js 22.22.0 |
