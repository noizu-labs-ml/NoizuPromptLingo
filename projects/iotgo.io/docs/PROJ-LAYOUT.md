# Project Layout

```
iotgo.io/
├── design/                     # Visual design → [layout/design.md](layout/design.md)
│   ├── logos/                  #   SVG logo variants (mark, logotype, combo, favicon)
│   ├── direction-a-*.md/.html  #   Style guide: Dark Ops Console
│   ├── direction-b-*.md/.html  #   Style guide: Trust + Precision
│   ├── direction-c-*.md/.html  #   Style guide: Signal Mesh
│   └── README.md               #   Decision framework for choosing direction
├── helm/                       # Kubernetes deployment chart
│   └── iotgo/                  #   Helm chart (v0.1.0)
│       ├── templates/          #     K8s manifests (deployment, ingress, service, tls)
│       ├── Chart.yaml          #     Chart metadata
│       └── values.yaml         #     Configurable values
├── web/                        # Next.js 16 landing page → [layout/web.md](layout/web.md)
│   ├── public/                 #   Static assets (favicon)
│   ├── src/app/                #   App Router pages and components
│   ├── .tool-versions          #   Node.js 22.22.0
│   ├── build.sh                #   Docker build script
│   ├── Dockerfile              #   Container image definition
│   ├── next.config.ts          #   Next.js configuration
│   ├── nginx.conf              #   Reverse proxy config (production)
│   ├── package.json            #   Dependencies (Next 16, React 19, Tailwind 4)
│   ├── postcss.config.mjs      #   PostCSS + Tailwind
│   └── tsconfig.json           #   TypeScript configuration
├── docs/                       # Documentation
│   ├── PROJ-LAYOUT.md          #   This file
│   └── layout/                 #   Detailed directory breakdowns
├── .gemini/                    # Gemini Code Assist configuration
│   ├── config.yaml             #   PR review config
│   └── styleguide.md           #   Style guide for reviews
├── .gitignore                  # Ignores: node_modules, .next, build, .env*, lock files
└── README.md                   # Project overview — concept, architecture, monetization
```

## Key Files Requiring Setup

| File | Action |
|------|--------|
| `web/.tool-versions` | Ensure Node.js 22.22.0 is installed via mise/asdf |
| `helm/iotgo/values.yaml` | Configure image, domain, TLS before deploy |
