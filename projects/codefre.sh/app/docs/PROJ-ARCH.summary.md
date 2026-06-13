# Architecture Summary — start-app

Three-container Docker stack: Next.js frontend, Phoenix API backend, nginx reverse proxy. Shares Postgres/Redis on the external `lets-go_default` network. Scaffolded into `projects/{domain}/app/` — design artifacts live at the project root.

## Components

- **nginx** — reverse proxy routing `/api/*` to backend, `/*` to frontend
- **backend** — Phoenix 1.8 JSON API with JWT auth, Postgres (PostGIS/pgvector), Redis
- **frontend** — Next.js 15 with YAML-driven design system and auth UI
- **Makefile** — build orchestration and project identity derivation
- **docker-compose.yaml** — service definitions on shared Docker network
- **scripts/gen-env.sh** — generates `.env` files with secrets

## Identity System

Makefile derives slug, DB name, Redis DB number, and image tags from the parent directory name when inside `app/`. Scaffolding to `projects/{domain}/app/` auto-configures everything.

## Auth

JWT (Guardian) — backend issues tokens, frontend stores in localStorage and attaches Bearer header.

## Design System

YAML themes → `@the-robot-lives/styleguide` → generated CSS → Tailwind v4 `@theme` bridge.

## Deployment

Multi-stage Docker builds. `make build-push` produces multi-arch images for `ops.noizu.com` registry.

## Scaffold Flow

`init-proj-scaffold <domain> <slug> <Module>` automates project creation:

1. **Tarball** — builds/caches `start-app.tar.gz` (excludes build artifacts, .env, deps)
2. **Extract** — unpacks to `projects/<domain>/app/`
3. **Hydrate** — sed replaces `Starter`→`Module`, `:starter`→`:otp_app`, renames `lib/starter/`→`lib/otp_app/`
4. **Register** — creates DB user + databases in Postgres, appends to `init-databases.sh` and `users.acl`

## Agent Workflow (Post-Scaffold)

```
init-proj-scaffold → cd app/ → make init → Design (theme YAML → make regen → serve-project.sh)
  → Backend (contexts, migrations, controllers) → Frontend (pages, API wiring)
  → make build → make run → verify at :8080
```

Design iterates via the styleguide-engine preview. Backend extends the auth scaffold with project-specific contexts. Frontend wires API calls and customizes pages.

## Key Decisions

- Three-container split for independent deployment
- External shared network — projects share infra, isolated by DB/Redis DB number
- Parent-directory-driven identity — Makefile in `app/` reads domain from parent dir, no config edits needed
- Compose runs pre-built images only (no compose build)
- Secrets generated at `make init` time
- Single-command scaffolding with `init-proj-scaffold` — tarball, hydration, DB/Redis registration
- Idempotent registration — safe to re-run
