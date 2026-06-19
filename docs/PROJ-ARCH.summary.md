# Architecture Summary — start-app

Three-container Docker stack: Next.js frontend, Phoenix API backend, nginx reverse proxy. Shares Postgres/Redis on the external `lets-go_default` network. Scaffolded into `projects/{domain}/app/` — design artifacts live at the project root. Deployable via Docker Compose (local) or Helm chart (Kubernetes).

## Components

- **nginx** — reverse proxy routing `/api/*` to backend, `/*` to frontend
- **backend** — Phoenix 1.8 JSON API with JWT auth, SSO (OIDC/SAML/OAuth), Postgres (PostGIS/pgvector), Redis
- **frontend** — Next.js 15 with YAML-driven design system, auth UI, SSO callback, analytics
- **Makefile** — build orchestration and project identity derivation
- **docker-compose.yaml** — production service definitions on shared Docker network
- **docker-compose.dev.yaml** — dev overrides with volume mounts, hot reload, Liquibase migrations
- **helm/start-app/** — publishable Helm chart for Kubernetes deployment
- **scripts/gen-env.sh** — generates `.env` files with secrets

## Identity System

Makefile derives slug, DB name, Redis DB number, and image tags from the parent directory name when inside `app/`. Scaffolding to `projects/{domain}/app/` auto-configures everything.

## Auth & SSO

JWT (Guardian) — backend issues tokens, frontend stores in localStorage and attaches Bearer header. SSO via Ueberauth: OIDC, SAML, Google, Facebook, GitHub, LinkedIn. Provider discovery endpoint. Configurable invite-only mode.

## Analytics

Pluggable provider pattern (Google Analytics, PostHog). Runtime config injection via `docker-entrypoint.sh` → `window.__ENV` — no rebuild needed for config changes. Category-level cookie consent gates GA/PostHog scripts and events until analytics is approved.

## Schema Management

Dual-track: Liquibase YAML changelogs (000–010) for canonical schema, Ecto migrations for app-level changes. Liquibase runs first as a separate container.

## Design System

YAML themes → `@noizu/styleguide` → generated CSS → Tailwind v4 `@theme` bridge.

## Deployment

### Docker
Multi-stage Docker builds. `make build-push` produces multi-arch images for `ops.noizu.com` registry. Dev mode mounts source volumes with hot reload.

### Kubernetes
Helm chart with deployment, service, ingress (Cloudflare-only), TLS from Infisical, pre-install migration Job, ConfigMap for runtime config. Supports SSO, analytics, and mail via values.yaml.

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

## Technology Stack

Frontend: Next.js 15, React 19, Tailwind v4 | Backend: Elixir 1.19, Phoenix 1.8, Bandit | DB: PostgreSQL (PostGIS, pgvector) | Cache: Redis | Auth: Guardian JWT + Ueberauth SSO | Analytics: GA + PostHog | Schema: Liquibase + Ecto | Proxy: Nginx | Container: Docker + docker-compose | Orchestration: Kubernetes (Helm) | Registry: ops.noizu.com | Secrets: Infisical | Build: Make + shell

## Key Decisions

- Three-container split for independent deployment
- External shared network — projects share infra, isolated by DB/Redis DB number
- Parent-directory-driven identity — Makefile in `app/` reads domain from parent dir, no config edits needed
- Compose runs pre-built images only (no compose build)
- Secrets generated at `make init` time
- Single-command scaffolding with `init-proj-scaffold` — tarball, hydration, DB/Redis registration
- Idempotent registration — safe to re-run
- Dual-track schema management — Liquibase for canonical schema, Ecto for app-level
- Publishable Helm chart — generic chart + env-specific wrapper pattern
- Runtime config injection — one image, all environments
- Pluggable SSO — env-var-driven provider configuration
