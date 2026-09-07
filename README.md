# NoizuPromptLingo (NPL)

**Noizu Prompt Lingo** is the syntax convention set for structured prompt engineering — placeholders, intuition pumps, directives, prefixes, and tagged prompt sections — plus a public MCP that serves that corpus.

This repo is **not** the agent-harness work platform. Sessions, tickets, chat, wiki, memory, and the tobor MCP fleet now live in [agent-kit-mcp](https://github.com/the-robot-lives/agent-kit-mcp). NPL publishes the language those agents load.

## What it is

- **Convention YAML** in `conventions/` (syntax, declarations, pumps, directives, prefixes, prompt-sections, special-sections, fences).
- **MCP** at `/mcp` — two tools only: `NPLLoad` (expression DSL) and `NPLSpec` (versioned spec generation). **No authentication required.**
- **OAuth** is optional. Clients that insist on OAuth (Claude Code, Cursor, …) complete PKCE and receive a **site-approval** token (`sub=site:npl`). The token does not identify a user; it only means “approved for this site.”
- **REST** at `/api/v1/npl/*` (public) for browsing sections and generating the same spec the admin panel produces.
- **Admin / conventions browser** (signed-in) to inspect components and generate NPLSpec blocks.

```bash
claude mcp add --transport http npl https://promptlingo.dev/mcp
```

### Browse as files (VFS)

Mount the syntax as markdown (no token):

```bash
mcp-mount --url wss://promptlingo.dev/vfs --mount ~/npl --ro
# then open ~/npl/tobor/_npl/sections/syntax.md
```

Kernel FUSE (`mcp-fuse`) is for a **local** unix-socket VFS. Setup, binaries
(macOS arm, Linux amd64/arm64, Windows amd64/arm64), and WinFsp notes:
[docs/howto/vfs.md](docs/howto/vfs.md).

## Who it's for

- **Prompt authors and agent harnesses** that need a stable, loadable syntax vocabulary.
- **Editors** who curate convention YAML and generate spec excerpts from the admin panel.
- **Anyone integrating NPL** into Claude Code, Codex, Cursor, Grok, or a custom MCP client — no API key.

Agent orchestration (tickets, sessions, chat, personas) → [agent-kit-mcp](https://github.com/the-robot-lives/agent-kit-mcp).

## Architecture at a glance

Three-container stack (Next.js frontend, Phoenix API backend, nginx reverse proxy) sharing Postgres and Redis. The public MCP is a single Streamable HTTP endpoint at `/mcp`. Human sign-in (Authentik OIDC) is only for the conventions admin UI.

See `docs/PROJ-ARCH.md`, `docs/PROJ-LAYOUT.md`, and `docs/arch/npl-conventions.md` for the convention pipeline.

## Tech stack

- **Frontend**: Next.js 15, React 19, Tailwind v4, YAML-driven design system (`@noizu/styleguide`) — 40+ routes, four active themes (`npl-brutalist`, `npl-editorial`, `npl-minimal`, `npl-nocturne`) under `design/theme/`
- **Backend**: Elixir 1.19, Phoenix 1.8, Bandit, Guardian JWT, Ueberauth (OIDC/SAML)
- **Database**: PostgreSQL (PostGIS, pgvector), Redis
- **Proxy**: Nginx
- **Schema**: Liquibase (canonical) + Ecto (app-level)
- **Search**: Weaviate (semantic MCP tool search, intent mode)
- **Deploy**: Docker Compose (local), Helm (Kubernetes) — registry `ops.noizu.com`, secrets via Infisical

## Running locally

```bash
make init          # Generate .env files with secrets
make build          # Build backend + frontend + nginx images
make run            # Start the stack (nginx on :8080)
```

Hot-reload dev mode (source-mounted, Next.js HMR + Phoenix code reloading):

```bash
make run-dev         # Foreground with live logs
make run-dev-d       # Detached
make logs-dev        # Tail logs
make stop-dev        # Tear down
```

A live-sandbox mode (single container, Node + Elixir + Samba, mountable as a network share for remote editing) is also available — see `make sandbox` / `make run-sandbox` / `make sandbox-mount`.

Migrations (Liquibase for canonical schema, Ecto for app-level):

```bash
make migrate
make migrate-status
make migrate-rollback
```

## Project layout

```
NoizuPromptLingo/
├── conventions/ # YAML source of truth for NPL syntax sections
├── frontend/    # Next.js 15 — public landing + conventions admin
├── backend/     # Phoenix 1.8 — NPLLoad/NPLSpec MCP at /mcp, REST /api/v1/npl
├── nginx/       # Reverse proxy
├── design/      # Theme YAML
├── docs/        # Architecture and convention pipeline
├── helm/        # Kubernetes Helm chart
└── Makefile     # Build/run/deploy targets
```

## Project management artifacts

`project-management/` holds UX-research personas, user stories, screens, and components for this product — generated as design/planning input, distinct from the product's own "Agent Persona" and "Customer Persona" domain entities described above.
