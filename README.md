# NoizuPromptLingo (NPL)

**Repo:** https://github.com/noizu-labs-ml/NoizuPromptLingo

The NPL structured prompt-engineering syntax — placeholders, intuition pumps, directives, prefixes, and tagged prompt sections — plus a public MCP that serves that corpus. This repo publishes the *language* agents load; the agent work platform (sessions, tickets, chat, wiki, memory, tobor MCP fleet) lives separately in [agent-kit-mcp](https://github.com/the-robot-lives/agent-kit-mcp).

## What

- **Convention YAML** in `conventions/` — single source of truth for the NPL syntax sections (syntax, declarations, pumps, directives, prefixes, prompt-sections, special-sections, fences).
- **MCP** at `/mcp` — two tools only: `NPLLoad` (expression DSL) and `NPLSpec` (versioned spec generation). **No authentication required.**
- **OAuth** is optional. Clients that insist on OAuth (Claude Code, Cursor, …) complete PKCE and receive a **site-approval** token (`sub=site:npl`). The token does not identify a user; it only means "approved for this site."
- **REST** at `/api/v1/npl/*` (public) for browsing sections and generating the same spec the admin panel produces.
- **Admin / conventions browser** (signed-in) to inspect components and generate NPLSpec blocks.

Hook it up:

```bash
claude mcp add --transport http npl https://promptlingo.dev/mcp
```

Browse as files (VFS — mount the syntax as markdown, no token):

```bash
mcp-mount --url wss://promptlingo.dev/vfs --mount ~/npl --ro
# then open ~/npl/tobor/_npl/sections/syntax.md
```

Kernel FUSE (`mcp-fuse`) is for a **local** unix-socket VFS. Setup, binaries (macOS arm, Linux amd64/arm64, Windows amd64/arm64), and WinFsp notes: [docs/howto/vfs.md](docs/howto/vfs.md).

## Why

Prompt conventions scattered across ad-hoc markdown drift and can't be loaded selectively. NPL keeps one versioned YAML source and serves it on demand: agents pull exactly the syntax sections they need (`NPLLoad(expression="syntax#placeholder:+2 directives -pumps")`), editors curate the corpus through an admin UI, and every consumer sees the same spec. It is the shared vocabulary underneath the Noizu agent fleet.

## Getting Started

Prerequisites: Docker + Docker Compose; Make.

```bash
make init          # Generate .env files with secrets
make build         # Build backend + frontend + nginx images
make run           # Start the stack (nginx on :8080)
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

Deployment is CI-driven to Kubernetes via the Helm chart in `helm/` (registry `ops.noizu.com`, secrets via Infisical).

## How It Works

- Three-container stack — **Next.js 15** frontend, **Phoenix 1.8** (Elixir) API backend, nginx reverse proxy — sharing **Postgres** (PostGIS, pgvector) and **Redis**. Schema is Liquibase-canonical + Ecto app-level; Weaviate powers semantic MCP tool search (intent mode).
- `conventions/*.yaml` is rendered on request: `NPLLoad` for quick agent-facing snippets via expression DSL, `NPLSpec` for full `⌜NPL@1.0⌝`-wrapped spec blocks with dependency resolution. `npl/npl-full.md` is a generated artifact of that pipeline.
- Human sign-in (Authentik OIDC) is only for the conventions admin UI; the MCP endpoint itself is open.

## Repo Layout

```
NoizuPromptLingo/
├── conventions/ # YAML source of truth for NPL syntax sections
├── frontend/    # Next.js 15 — public landing + conventions admin
├── backend/     # Phoenix 1.8 — NPLLoad/NPLSpec MCP at /mcp, REST /api/v1/npl
├── src/         # Python npl_mcp tooling (npl-docs-regen, local tooling)
├── nginx/       # Reverse proxy
├── helm/        # Kubernetes Helm chart
├── liquibase/   # Canonical schema changelogs
├── design/      # Theme YAML (npl-brutalist, npl-editorial, npl-minimal, npl-nocturne)
├── docs/        # Architecture and convention pipeline (PROJ-ARCH / LAYOUT / SCHEMA + summaries)
└── Makefile     # Build/run/deploy targets
```

`project-management/` holds UX-research personas, user stories, screens, and components generated as design/planning input — distinct from the product's own "Agent Persona" and "Customer Persona" domain entities.

License: see [LICENSE](LICENSE).
