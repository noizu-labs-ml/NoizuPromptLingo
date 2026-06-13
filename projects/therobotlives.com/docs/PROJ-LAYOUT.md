# Project Layout

```
therobotlives.com/
├── design/                         # Visual direction and brand assets
│   ├── direction-a-minimal-tech.*  #   Design direction: Minimal Tech
│   ├── direction-b-social-warmth.* #   Design direction: Social Warmth
│   ├── direction-c-the-machine-aesthetic.*  # Design direction: Machine Aesthetic
│   ├── direction-d-living-network.*        # Design direction: Living Network
│   ├── logos/                      #   Logo and mark assets (SVG)
│   │   ├── concepts/              #     Logo concept explorations (6 SVGs + preview)
│   │   ├── logo.svg               #     Primary logo
│   │   ├── logo-reversed.svg      #     Reversed variant
│   │   ├── mark.svg               #     Standalone mark
│   │   ├── mark-reversed.svg      #     Reversed mark
│   │   ├── mark-mono.svg          #     Monochrome mark
│   │   └── favicon.svg            #     Favicon source
│   └── README.md                  #   Design direction overview
├── docs/                           # Project documentation
│   ├── PROJ-LAYOUT.md             #   This file
│   └── PROJ-LAYOUT.summary.md    #   Condensed tree for tooling
├── helm/                           # Kubernetes deployment
│   └── therobotlives/             #   Helm chart (v0.1.0)
│       ├── Chart.yaml             #     Chart metadata
│       ├── values.yaml            #     Default configuration
│       └── templates/             #     K8s manifest templates
│           ├── _helpers.tpl       #       Template helpers
│           ├── deployment.yaml    #       Deployment resource
│           ├── ingress.yaml       #       Ingress resource
│           ├── service.yaml       #       Service resource
│           └── tls-secret.yaml    #       TLS secret for Cloudflare
├── web/                            # Next.js application
│   ├── src/                       #   Application source
│   │   └── app/                   #     App Router pages
│   │       ├── layout.tsx         #       Root layout
│   │       ├── page.tsx           #       Landing page
│   │       ├── globals.css        #       Global styles
│   │       └── waitlist-form.tsx  #       Waitlist signup component
│   ├── public/                    #   Static assets
│   │   └── favicon.svg            #     Favicon
│   ├── build.sh                   #   Docker build script
│   ├── Dockerfile                 #   Multi-stage build (Next.js + nginx)
│   ├── nginx.conf                 #   Production nginx config
│   ├── next.config.ts             #   Next.js configuration
│   ├── package.json               #   Dependencies and scripts
│   ├── postcss.config.mjs         #   PostCSS / Tailwind config
│   ├── tsconfig.json              #   TypeScript configuration
│   ├── .tool-versions             #   asdf/mise runtime versions
│   ├── .dockerignore              #   Docker build exclusions
│   └── .gitignore                 #   Git exclusions for web/
├── .gemini/                        # Gemini Code Assist configuration
│   ├── config.yaml                #   Review settings
│   └── styleguide.md              #   Code style guide for reviews
├── .gitignore                      # Root git exclusions
└── README.md                       # Project overview and product spec
```

## Key Files Requiring Setup

| File | Action |
|------|--------|
| `web/.tool-versions` | Ensure Node.js version is installed via asdf/mise |
| `helm/therobotlives/values.yaml` | Configure image tag, domain, and resource limits before deploy |
