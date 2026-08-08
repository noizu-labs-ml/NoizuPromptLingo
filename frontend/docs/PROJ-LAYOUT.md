# Project Layout — frontend (npl-frontend)

Next.js App Router console for NoizuPromptLingo: org-scoped work surfaces, admin, MCP key setup, YAML-driven design system.

```
frontend/
├── src/                                # Application source → [layout/src.md](layout/src.md)
│   ├── app/                            #   Routes: public, auth, /app, /app/[orgId], admin
│   ├── components/                     #   Shell, console CRUD, memory, markdown, nav
│   ├── config/theme-style-guide/       #   Design-system YAML (generate-css input)
│   ├── context/                        #   auth, org, sidebar providers
│   ├── hooks/                          #   e.g. use-channel (Phoenix)
│   ├── i18n/                           #   next-intl config + en messages
│   ├── lib/                            #   API client, console registry, analytics, otel
│   ├── scripts/generate-css.ts         #   YAML → design-system.generated.css
│   ├── proxy.ts                        #   Next proxy helpers
│   └── types/phoenix.d.ts
├── public/
│   ├── brand/ · favicon.svg
│   └── themes/style-guide.css
├── e2e/                                # Playwright (auth setup, room, reactions, XSS)
├── docs/
│   ├── PROJ-LAYOUT.md                  #   This file
│   ├── PROJ-LAYOUT.summary.md
│   ├── PROJ-ARCH.md · .summary.md
│   ├── layout/src.md
│   └── arch/                           #   auth, deployment, design-system notes
├── bin/dev-start.sh
├── docker-entrypoint.sh                # Runtime config → window.__ENV
├── Dockerfile · Dockerfile.dev
├── next.config.ts
├── package.json                        # name: npl-frontend
├── playwright.config.ts
├── postcss.config.mjs
├── tsconfig.json
├── .env                                # ⚠ API URLs / public config
└── .npmrc.template                     # GitHub Packages for @noizu/styleguide
```

## Key files requiring setup

| File | Action |
|------|--------|
| `.env` | From root `make init`; set `NEXT_PUBLIC_API_URL` (compose uses `/api`) |
| `.npmrc` | Copy from `.npmrc.template` if private `@noizu/*` packages needed |

## Scripts

| Command | Purpose |
|---------|---------|
| `npm run dev` | Next dev server |
| `npm run regen` | Clear cache + regenerate CSS from YAML |
| `npm run generate-css` | YAML → `design-system.generated.css` |
| `npm run build` | Generate CSS + production build |
| `npm run test:e2e` | Playwright suite |

## Route map (high level)

| Prefix | Purpose |
|--------|---------|
| `/`, `/login`, `/auth/*`, `/styleguide`, `/sitemap` | Public / auth |
| `/app` | Post-login hub (orgs, profile, MCP keys, admin) |
| `/app/[orgId]/*` | Org-scoped: tickets, boards, chat, wiki, sessions, … |
| `/app/admin/*` | Global admin (users, orgs, LLM models, authz, …) |
