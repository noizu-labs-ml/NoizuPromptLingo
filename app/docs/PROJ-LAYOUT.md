# Project Layout — start-app

Starter template for portfolio projects. Three-service Docker stack: **Next.js frontend**, **Phoenix backend**, **nginx reverse proxy** — orchestrated by Make and docker-compose, connecting to shared Postgres/Redis on the `lets-go_default` network.

Scaffolded into `projects/{domain}/app/` via `init-proj-scaffold`. The project root (`projects/{domain}/`) holds design artifacts (README.md, design/, docs/); the `app/` subdirectory holds the runnable code.

```
start-app/
├── frontend/                       # Next.js 15 app → [frontend/docs/PROJ-LAYOUT.md](../frontend/docs/PROJ-LAYOUT.md)
│   ├── src/                        #   App Router pages, components, theme YAML, auth context
│   ├── docs/                       #   Frontend architecture + layout docs
│   └── Dockerfile                  #   Frontend container build
├── backend/                        # Phoenix 1.8 API → [backend/docs/PROJ-LAYOUT.md](../backend/docs/PROJ-LAYOUT.md)
│   ├── lib/                        #   Elixir source (Starter app + StarterWeb)
│   ├── config/                     #   Mix config per environment
│   ├── priv/repo/                  #   Migrations and seeds
│   ├── docs/                       #   Backend architecture + layout docs
│   └── Dockerfile                  #   Backend container build
├── nginx/                          # Reverse proxy
│   ├── nginx.conf                  #   Route: /api/* → backend, /* → frontend
│   └── Dockerfile                  #   Nginx container build
├── scripts/                        # Build utilities
│   └── gen-env.sh                  #   Generates .env files with secrets for all services
├── docs/                           # Root documentation
│   ├── PROJ-LAYOUT.md              #   This file
│   └── PROJ-LAYOUT.summary.md     #   Tree-only quick reference
├── .env.example                    # Environment template — copy and configure
├── .envrc                          # direnv — run `direnv allow`
├── .gitignore                      # Git ignore rules
├── docker-compose.yaml             # Service definitions (nginx, backend, frontend)
└── Makefile                        # Build + lifecycle commands
```

## Key Files Requiring Setup

| File | Action |
|------|--------|
| `.env` | Run `make init` to generate from `.env.example` with real secrets |
| `.envrc` | Run `direnv allow` |
| `frontend/.npmrc` | Copy from `frontend/.npmrc.template`, add GitHub Packages token |
| `backend/.tool-versions` | Run `asdf install` to match Elixir/Erlang versions |

## Make Targets

| Command | Purpose |
|---------|---------|
| `make init` | Generate `.env` + `backend/.env` + `frontend/.env` with secrets |
| `make regen` | Regenerate design system CSS from theme YAML |
| `make build` | Build all Docker images (backend, frontend, nginx) |
| `make run` | Start all containers via docker-compose |
| `make stop` | Stop containers |
| `make restart` | Stop → rebuild → start |
| `make logs` | Tail container logs |
| `make clean` | Remove containers, volumes, and local images |
| `make push` | Push pre-built images to registry |
| `make build-push` | Build multi-arch (amd64+arm64) and push |

## Network Architecture

All services join the external `lets-go_default` Docker network, where shared Postgres and Redis containers run. Nginx listens on `$PORT` (default 8080) and routes:

- `/api/*`, `/health` → backend (Phoenix on :4000)
- `/_next/webpack-hmr` → frontend (WebSocket upgrade for HMR)
- `/*` → frontend (Next.js on :3000)

## Project Identity

The Makefile derives project identity from the parent directory name. When scaffolded to `projects/{domain}/app/`, the Makefile detects it's inside `app/` and resolves `PROJECT_DIR` from the parent — i.e., `derobot.is`. This auto-resolves the correct slug, database name, and Redis DB number from built-in maps.
