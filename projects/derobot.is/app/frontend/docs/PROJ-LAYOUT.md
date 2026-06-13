# Project Layout — derobot.is/frontend

Next.js 15 frontend with YAML-driven design system, auth scaffolding, and styleguide viewer.

```
frontend/
├── src/                                # Application source → [layout/src.md](layout/src.md)
│   ├── app/                            #   Next.js App Router pages + global styles
│   ├── components/                     #   Shared React components (11 + generated/)
│   ├── config/                         #   Theme YAML definitions (design system input)
│   ├── context/                        #   React context providers
│   ├── lib/                            #   API client + product data
│   └── scripts/                        #   Build-time code generation
├── public/                             # Static assets
│   ├── icon.svg                        #   Favicon
│   ├── logo-b.svg                      #   Brand logo
│   └── themes/derobot.css              #   Generated theme CSS
├── docs/                               # Project documentation
│   ├── PROJ-ARCH.md                    #   Architecture document
│   ├── PROJ-ARCH.summary.md            #   Architecture summary
│   ├── PROJ-LAYOUT.md                  #   This file
│   ├── PROJ-LAYOUT.summary.md          #   Tree-only quick reference
│   ├── arch/                           #   Detailed architecture docs
│   │   ├── auth.md                     #     Auth flow
│   │   ├── deployment.md               #     Deployment strategy
│   │   └── design-system.md            #     Design system architecture
│   └── layout/                         #   Detailed directory breakdowns
│       └── src.md                      #     src/ tree + descriptions
├── .npmrc.template                     # Copy to .npmrc — configures GitHub Packages auth
├── .tool-versions                      # asdf node version
├── .dockerignore                       # Docker build exclusions
├── .gitignore                          # Git exclusions
├── Dockerfile                          # Production container build
├── Dockerfile.dev                      # Development container build
├── next.config.ts                      # Next.js configuration
├── package.json                        # Dependencies and scripts
├── postcss.config.mjs                  # PostCSS / Tailwind v4 config
└── tsconfig.json                       # TypeScript configuration
```

## Key Files Requiring Setup

| File | Action |
|------|--------|
| `.env` | Configure `NEXT_PUBLIC_API_URL` and other env vars |
| `.npmrc` | Copy from `.npmrc.template`, add GitHub Packages token |

## Scripts

| Command | Purpose |
|---------|---------|
| `npm run dev` | Start Next.js dev server |
| `npm run regen` | Clear cache + regenerate CSS from YAML themes |
| `npm run generate-css` | Generate CSS from YAML (no cache clear) |
| `npm run build` | Generate CSS then build for production |
