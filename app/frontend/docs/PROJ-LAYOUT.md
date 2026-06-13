# Project Layout — start-app/frontend

Next.js 15 starter frontend with YAML-driven design system, auth scaffolding, and styleguide viewer.

```
frontend/
├── src/                                # Application source → [layout/src.md](layout/src.md)
│   ├── app/                            #   Next.js App Router pages + global styles
│   ├── components/                     #   Shared React components
│   ├── config/                         #   Theme YAML definitions (design system input)
│   ├── context/                        #   React context providers
│   ├── lib/                            #   Shared utilities and API client
│   └── scripts/                        #   Build-time code generation
├── public/                             # Static assets (empty, .gitkeep)
├── docs/                               # Project documentation
│   ├── PROJ-LAYOUT.md                  #   This file
│   └── layout/                         #   Detailed directory breakdowns
├── .claude/                            # Claude Code local settings
│   └── settings.local.json
├── .env                                # Environment variables (API URLs, secrets)
├── .npmrc.template                     # Copy to .npmrc — configures GitHub Packages auth
├── .dockerignore                       # Docker build exclusions
├── .gitignore                          # Git exclusions
├── Dockerfile                          # Container build definition
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
