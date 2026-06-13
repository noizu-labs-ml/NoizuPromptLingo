# Web Layer Architecture

## Stack

- **Framework**: Next.js 16.1.6 with App Router, configured for static export (`output: "export"`)
- **UI**: React 19.2.3 + Tailwind CSS 4
- **Build**: Node 22-alpine (multi-stage Docker build)
- **Serving**: nginx:alpine with gzip, SPA fallback, 1-year cache on `/_next/static/`

## Components

| Component | Path | Purpose |
|-----------|------|---------|
| `NeuralCanvas` | `web/src/components/NeuralCanvas.tsx` | Animated neural-network background effect |
| `WaitlistForm` | `web/src/components/WaitlistForm.tsx` | Email capture form for waitlist signups |
| `CounterAnimation` | `web/src/components/CounterAnimation.tsx` | Animated number counter for stats display |

## Build & Deploy Pipeline

```
npm run build          # Next.js static export → out/
docker build ...       # Multi-stage: node:22 build → nginx:alpine serve
docker push            # → ops.noizu.com/app-aifighter:{tag}
```

The `build.sh` script handles compilation, Docker build (linux/amd64), and push to the Noizu registry in one step.

## nginx Configuration

- Gzip enabled for text/CSS/JSON/JS (min 256 bytes)
- SPA fallback: `try_files $uri $uri.html $uri/index.html /index.html`
- Security headers: `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`
- Static asset caching: `/_next/static/` with 1-year expiry and `immutable` directive

## Image Handling

Images are unoptimized (`images.unoptimized: true` in next.config.ts) since the static export can't use Next.js image optimization. Assets served directly by nginx.
