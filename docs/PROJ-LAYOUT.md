# Project Layout — NoizuPromptLingo (NPL)

Multi-tenant agent/human collaboration platform (“tobor”): Phoenix API + MCP fleet, Next.js console, nginx proxy. OTP app `:noizu_prompt_lingua`. Product overview: [README.md](../README.md). Architecture detail: [PROJ-ARCH.md](PROJ-ARCH.md).

```
NoizuPromptLingo/
├── frontend/                       # Next.js app → [frontend/docs/PROJ-LAYOUT.md](../frontend/docs/PROJ-LAYOUT.md)
│   ├── src/                        #   App Router (public + /app + /app/[orgId] + admin)
│   ├── e2e/                        #   Playwright specs
│   ├── public/                     #   Static brand/theme assets
│   └── docs/                       #   Frontend layout + arch notes
├── backend/                        # Phoenix 1.8 API → [backend/docs/PROJ-LAYOUT.md](../backend/docs/PROJ-LAYOUT.md)
│   ├── lib/noizu_prompt_lingua/    #   Domains, MCP, entities, Ecto schemas
│   ├── lib/noizu_prompt_lingua_web/ #   Controllers, plugs, channels, router
│   ├── config/                     #   Mix config (dev/test/prod/runtime)
│   ├── db/changelog/               #   Liquibase YAML (000–073 + master)
│   ├── priv/                       #   Conventions, seeds, unicode-codex, downloads
│   └── test/                       #   ExUnit suites
├── nginx/                          # Reverse proxy (/api → backend, /* → frontend)
│   ├── nginx.conf
│   └── Dockerfile
├── helm/
│   ├── start-app/                  #   Main app chart (deploy, migrate-job, sandbox)
│   └── npl-mcp/                    #   MCP-facing chart (ingress per domain host)
├── design/                         # Theme treatises + YAML (8 NPL themes) + asset prompts
│   ├── theme/                      #   theme-npl-*, conformance/*, theme-style-guide/
│   └── asset-prompts/screens/      #   Screen media prompts by theme
├── docs/                           # Root docs (this map, arch, schema, audits)
│   ├── PROJ-LAYOUT.md
│   ├── PROJ-LAYOUT.summary.md
│   ├── PROJ-ARCH.md / .summary.md
│   ├── PROJ-SCHEMA.md / .summary.md
│   ├── FEATURE-PARITY-AUDIT.md
│   └── REMOTE-ACCESS-TUNNEL-DESIGN.md
├── local-mcp/                      # Standalone filesystem MCP (packaged for download)
├── browser-controller/             # Local Playwright browser relay client
├── remote-access-client/           # frpc wrapper for *.remote-access.noizu.com tunnels
├── sandbox/                        # Single-container sandbox (Samba + app entrypoint)
├── agents/                         # Claude/NPL agent prompts (taskers, TDD, PRD, …)
│   ├── additional-agents/          #   Extra specialist agent defs
│   └── skeleton/                   #   Agent templates
├── commands/                       # Slash-command / workflow docs (layout, arch, init, …)
├── project-management/             # UX research: personas, screens, user stories, roadmap
│   ├── personas/                   #   P-001… harness/org/admin personas
│   ├── screens/                    #   Screen specs 01–47
│   ├── user-stories/               #   US-001… (~100)
│   ├── components/                 #   UI component specs
│   └── roadmap/                    #   Milestone notes M0–M5
├── sub-agent-prompts/              # One-shot sub-agent continuation prompts
├── scripts/
│   ├── gen-env.sh                  #   .env generation for make init
│   └── mint-remote-access-origin-cert.sh
├── docker-compose.yaml             # Runtime services (nginx, backend, frontend)
├── docker-compose.dev.yaml         # Dev: hot reload, volume mounts
├── docker-compose.sandbox.yaml     # Sandbox profile
├── docker-compose.ci.yml           # CI compose
├── docker-compose.override.yaml    # Local overrides (gitignored if present)
├── Dockerfile.sandbox              # Combined sandbox image
├── .env.example                    # Env template — copy via make init
├── .envrc                          # direnv (generated/gitignored)
├── Makefile                        # Build, run, migrate, helm, package downloads
└── README.md                       # Product entry point
```

## Nested layout docs

| Area | Path |
|------|------|
| Frontend tree | [frontend/docs/PROJ-LAYOUT.md](../frontend/docs/PROJ-LAYOUT.md) |
| Frontend `src/` | [frontend/docs/layout/src.md](../frontend/docs/layout/src.md) |
| Backend tree | [backend/docs/PROJ-LAYOUT.md](../backend/docs/PROJ-LAYOUT.md) |
| Backend `lib/` | [backend/docs/layout/lib.md](../backend/docs/layout/lib.md) |

## Key files requiring setup

| File | Action |
|------|--------|
| `.env` (+ `backend/.env`, `frontend/.env`) | `make init` from `.env.example` |
| `.envrc` | `direnv allow` after secrets hydrate |
| `frontend/.npmrc` | From `.npmrc.template` if using GitHub Packages (`@noizu/styleguide`) |

## Common Make targets

| Command | Purpose |
|---------|---------|
| `make init` | Generate env files with secrets |
| `make build` / `make run` | Build images / start stack (nginx `:8080`) |
| `make run-dev` / `make stop-dev` | Hot-reload compose |
| `make migrate` | Liquibase changelogs |
| `make regen` | Theme YAML → design-system CSS |
| `make downloads-package` | Bundle local-mcp / browser-controller / remote-access-client into `backend/priv/static/downloads` |
| `make sandbox` / `make run-sandbox` | Combined sandbox image + Samba |

## Network (compose)

External `lets-go_default` (shared Postgres/Redis). Nginx on `$PORT` (default 8080):

- `/api/*`, `/health`, MCP/WebSocket → backend `:4000`
- `/_next/webpack-hmr` → frontend HMR
- `/*` → frontend `:3000`
