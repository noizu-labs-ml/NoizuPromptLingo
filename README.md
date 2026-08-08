# NoizuPromptLingo (NPL)

Multi-tenant backend and MCP tool fleet ("tobor") that gives AI coding-agent harnesses — Claude Code, Codex CLI, and similar — durable, organization- and project-scoped infrastructure to coordinate real work: tickets and sprint boards, chat rooms, a wiki, code review, versioned reusable prompts, persistent agent identities with long-term memory, and a companion Next.js web app for the humans supervising them.

This is an Elixir/Next.js rewrite of a deprecated Python build of NoizuPromptLingo (see `docs/FEATURE-PARITY-AUDIT.md`), audited feature-for-feature against that predecessor's PRDs and user stories. The "Prompt Lingua" name refers specifically to the NPL convention/spec-generation engine (`/api/v1/npl/*`, backed by `priv/conventions/npl.yaml`) — one domain among many, rather than the whole product's identity; most of the surface area is general-purpose agent/human collaboration tooling.

If you're reading this inside the Noizu Infra monorepo: the `tobor-organizations`, `tobor-root`, and `tobor-sessions` MCP servers this very Claude Code session uses for work-session tracking (see the repo's root `CLAUDE.md`) are served by this project. NoizuPromptLingo is not a downstream consumer of tobor — it *is* tobor.

## Who it's for

- **Developers running coding-agent harnesses** — mint an MCP API key, run the generated `claude mcp add` command, and get a durable session/ticket/chat backend for agent-driven work instead of losing context between runs.
- **Engineering leads** — track work as tickets (including `user_story` and `prd` ticket types) on kanban boards with sprints/iterations, across both human and agent contributors.
- **Org owners/admins** — provision an organization, invite members via token, and scope exactly which MCP tools different teams or agents can reach.
- **Marketing/growth operators** — a separate creative suite (campaigns, ad copy, landing pages, competitor/keyword research) generated and reviewed through the same MCP/web surface.
- **Platform administrators** — a global admin panel for user/org oversight, LLM provider catalog and connectivity testing, GitHub token grants, and MCP custom-scope curation.
- **Reviewers** — pixel-anchored visual review (screenshot overlays) and GitHub PR/issue review, without leaving the platform.

## Key features

**Work coordination**
- **Organizations → Projects → Sessions** — the tenancy spine every other domain hangs off of. A Session is the unit of "grouped work" (rooms, artifacts, tickets) an agent or human opens for a task.
- **Tickets & Boards** — org-scoped tickets with custom fields/types (tri-scoped global/org/project), kanban boards with stages and sprint iterations, polymorphic ticket↔ticket and ticket↔any-entity links. `user_story` and `prd` are ticket *types*, not separate schemas.
- **Chat Rooms** — persistent rooms with threaded replies, pin/highlight/schedule-send, typed system events, and per-room notifications.
- **Wiki** — spaces → pages, with comments, attachments, and reactions.
- **Code Review** — reviews with pixel-anchored overlay comments (x/y/width/height on a screenshot) plus a verdict/compile/attach workflow.
- **Artifacts** — versioned typed content objects with revision history.

**Agent-specific infrastructure**
- **Agent Personas** — named agent identities with a bio, a work-log journal, and a private knowledge base. Distinct from the "Customer Persona" (marketing ICP) and the UX-research personas described below — three unrelated meanings of "persona" coexist in this codebase.
- **Associative Memory** — episodic/semantic/procedural memories with an emotional vector (valence/arousal/dominance + cortisol/dopamine/oxytocin/serotonin), weighted association edges, access-controlled compartments, and a quarantine mechanism for flagged content.
- **Instructions** — versioned, slug-addressable prompt templates rendered with per-task parameters to spawn sub-agents.
- **Mock MCP Builder** — describe a fake MCP server in prose; an LLM generates its tool definitions (and optionally real Elixir modules) and serves it live for testing/prototyping, fully separate from the production tool catalog.
- **Browser Relay** — MCP tools that drive a local Playwright browser over a websocket (navigate/screenshot/click/fill/record).
- **Remote Access Tunnels** — named reverse tunnels (frpc/frps) exposing a local dev server at `<name>.remote-access.noizu.com`.

**Creative / marketing suite** (its own mini-product, sharing the tenancy spine)
- Campaigns → ad groups → LLM-generated ad copy with an approve/reject workflow.
- LLM-generated landing pages, domain-name tracking, competitor/keyword/market research.
- A general creative-asset pipeline (prompt → generate/regenerate → accept/reject → publish) shared with the marketing suite.

**Reference data**
- **NPL Convention Engine** — the namesake feature: `npl_load`/`npl_spec` and a ~317-component YAML corpus of NPL syntax conventions, exposed at `/api/v1/npl/*`.
- **Unicode/NPL Glyph Codex** — layered global/org/project reference data for the special characters used in NPL syntax.

**Platform & security**
- **Two role systems, deliberately layered**: a simple `owner|admin|editor|viewer` membership ladder for coarse route gating, plus a full PBAC v2 system (groups, JSON policy documents, scoped memberships, org-defined custom roles/permissions) for fine-grained authorization — including a policy simulator (`/policies/check`, `/policies/explain`).
- **MCP Custom Scopes** — per-org/project (or global preset) filtering of which MCP tool groups/tools are exposed, served at a dedicated `/custom/:slug/mcp` gateway.
- **Server-side identity resolution** (`mcp/tool_guard.ex`) — MCP tool calls resolve the caller's identity from the JWT, never from a caller-supplied argument, specifically to close a spoofing hole present in an earlier design. Currently rolling out in shadow (log-only) mode.

## Architecture at a glance

Three-container stack (Next.js frontend, Phoenix API backend, nginx reverse proxy) sharing Postgres (PostGIS + pgvector) and Redis. The backend exposes **20+ per-domain MCP servers** on distinct subdomains (`sessions.`, `tickets.`, `chat.`, `personas.`, `memory.`, `campaigns.`, …), each with the same five discovery tools (`ToolSummary`, `ToolSearch`, `ToolDefinition`, `ToolCall`, `ToolHelp`) so a client can find tools by keyword or semantic intent (Weaviate-backed) without hard-coding a tool list. A host-less root `/mcp` aggregates every domain.

**Two independent auth flows:**
- **Humans** authenticate exclusively via Authentik OIDC (`/auth/oidc` → callback → SSO code exchange → Guardian JWT pair). Password/magic-link/OTP routes exist in the frontend but are intentionally disabled server-side — registration is invite-token gated.
- **Agents/MCP clients** never touch human login. A user self-mints a long-lived `McpApiKey` (shown once) at `/app/mcp-keys`, which any harness exchanges for a short-lived MCP JWT (`POST /api/mcp/token`) to present as a Bearer token to the MCP endpoints — this is what the `claude mcp add --transport streamable-http ... --header "Authorization: Bearer $AUTH_TOKEN"` setup command on that page wires up.

See `docs/FEATURE-PARITY-AUDIT.md` for the fullest single grounding document (predecessor-parity audit, what's new vs. the deprecated Python build, what was deliberately not ported). `docs/PROJ-ARCH.md`, `docs/PROJ-LAYOUT.md`, and `docs/PROJ-SCHEMA.md` describe the generic `start-app` scaffold this project was hydrated from (container topology, migrations, the 12-table auth/org base schema) rather than NPL-specific domains — useful for the deploy mechanics below, not for the product surface above. `frontend/docs/arch/auth.md` is stale (it documents a password-login flow that is disabled server-side; the OIDC-only behavior in `router.ex` is authoritative).

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
├── frontend/    # Next.js 15 — 40+ routes across public, dashboard, per-org, and admin surfaces
├── backend/     # Phoenix 1.8 API — ~20 domain contexts under lib/noizu_prompt_lingua/domains/,
│                #   20+ MCP servers under lib/noizu_prompt_lingua/mcp/ + domains/*/mcp.ex
├── nginx/       # Reverse proxy
├── design/      # Theme YAML (4 active themes) + design system docs
├── docs/        # Scaffold-mechanics docs (see note above) + docs/FEATURE-PARITY-AUDIT.md
├── helm/        # Kubernetes Helm chart
├── local-mcp/, browser-controller/, remote-access-client/  # Downloadable dev-tool packages
└── Makefile     # Build/run/deploy targets
```

## Project management artifacts

`project-management/` holds UX-research personas, user stories, screens, and components for this product — generated as design/planning input, distinct from the product's own "Agent Persona" and "Customer Persona" domain entities described above.
