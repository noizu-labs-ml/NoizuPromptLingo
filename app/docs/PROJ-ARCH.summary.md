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

## Kubernetes Deployment

Helm chart at `helm/derobotis/` deploys the stack to K8s with deployment, service, ingress, TLS, and migrate job.

## Scaffold Flow

`init-proj-scaffold <domain> <slug> <Module>` automates project creation: tarballs the template, extracts, hydrates names, and registers DB + Redis entries. Details in `arch/scaffold-flow.md`.

## Agent Workflow (Post-Scaffold)

Four-phase sequence: Design (theme YAML iteration) → Backend (contexts, migrations, controllers) → Frontend (pages, API wiring) → Deploy (`make build && make run`). Details in `arch/agent-workflow.md`.

## Key Decisions

- Three-container split for independent deployment
- External shared network — projects share infra, isolated by DB/Redis DB number
- Parent-directory-driven identity — Makefile in `app/` reads domain from parent dir, no config edits needed
- Compose runs pre-built images only (no compose build)
- Secrets generated at `make init` time
- Single-command scaffolding with `init-proj-scaffold` — tarball, hydration, DB/Redis registration
- Idempotent registration — safe to re-run
