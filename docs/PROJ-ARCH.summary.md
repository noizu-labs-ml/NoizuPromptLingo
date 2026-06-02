# Project Architecture Summary

## Overview
NPL MCP is a Model Context Protocol server built on FastMCP 3.x (`>=3.0.0,<4.0.0`) using a two-tier tool pattern: 58 MCP-visible tools across 16 categories, 22 hidden tools callable via ToolCall, ~45 stubs. 80 total implemented tools. Every MCP-registered tool carries hierarchical `tags` and NPL-specific `meta` (`npl_category`, `npl_discoverable`) so 3.x-native clients can filter/group natively. FastAPI for routing (~105 REST endpoints) with a pure-ASGI fallback middleware (SSE-safe), Next.js frontend with Cypress E2E, LiteLLM proxy for LLM-powered features, PostgreSQL for persistent storage, `orchestration/` module for pipeline execution. Companion `npl_persona` CLI package for offline persona simulation.

## Components
- **Launcher** (`launcher.py`): create_app() + create_asgi_app(), CLI, Uvicorn, pure-ASGI `FrontendFallbackMiddleware`
- **REST API Router** (`api/router.py`): All `/api/*` HTTP endpoints (~105 routes) — CRUD for tasks, artifacts, chat, sessions, instructions, projects, pipes, agents, skills, metrics, orchestration
- **Meta Tools** (`meta_tools/`): ToolSummary, ToolSearch, ToolDefinition, ToolHelp, ToolCall — discovery layer, catalog builder, stub catalog, `mcp_discoverable` helper decorator
- **NPL Spec** (`convention_formatter.py`): NPLSpec tool — NPL definition generation from convention YAMLs
- **Markdown** (`markdown/`): Converter, viewer, CSS/heading/xpath filters, image descriptions
- **NPL Parser** (`npl/`): YAML loader, syntax parser, reference resolver
- **PM Tools** (`pm_tools/`): PRD/story/persona access — DB-backed CRUD (13 hidden) + file-based stubs (8)
- **Instructions** (`instructions/`): Versioned instruction CRUD + embeddings (3 registered + 3 hidden + POST /api/instructions)
- **Tool Sessions** (`tool_sessions/`): Session tracking by (project, agent, task) triple (2 registered)
- **Artifacts** (`artifacts/`): Versioned artifact CRUD + revision history + binary upload (GET/POST /api/artifacts*)
- **Chat** (`chat/`): Chat rooms + messages REST CRUD (GET/POST /api/chat/rooms*)
- **Work Sessions** (`sessions/`): Generic work-session lifecycle (GET/POST /api/work-sessions*)
- **Tasks** (`tasks/`): Task CRUD + status transitions (GET/POST/PATCH /api/tasks*)
- **Browser** (`browser/`): ToMarkdown, Ping, Download, Screenshot, Rest, Secret, Capture, Checkpoint, Diff, Interact, Report (6 hidden + 32 stubs)
- **Agents** (`agents/`): Agent catalog — parses agent markdown frontmatter, list/get API
- **Pipes** (`pipes/`): Inter-agent structured YAML messaging (input/output pipes, DB-backed)
- **Skills** (`skills/`): Skill file validation + quality scoring
- **Orchestration** (`orchestration/`): Pattern registry, sequential pipeline with quality gates, TDD pipeline integration. REST: GET/POST /api/orchestration/{agents,runs,trigger,patterns}
- **Structured Logging** (`structured_logging.py`): JSONL logging with severity numbers and extra attribute pass-through
- **NPL Docs Regen** (`docs_regen.py`): Regenerate `npl/npl-full.md` from `conventions/` (CLI: `npl-docs-regen`)
- **Storage** (`storage/`): PostgreSQL async connection pool (asyncpg)
- **Frontend** (`frontend/`): Next.js + Tailwind, static export to `web/static/`, hybrid REST/mock API facade (`lib/api/client.ts`); Cypress E2E in `frontend/cypress/`
- **Persona CLI** (`npl_persona/`): Offline persona simulation, journal, knowledge, teams, templates (separate package)
- Remaining stubs: executors, scripts

## Stack
MCP protocol, FastMCP 3.x, FastAPI, Uvicorn, pure-ASGI middleware, SSE transport, PostgreSQL (asyncpg, port 5111), Liquibase migrations (18 changesets), LiteLLM proxy (port 4111), Next.js + Tailwind + Cypress frontend

## Infrastructure
- NPL MCP Server: port 8765 (MCP SSE + web UI)
- LiteLLM Proxy: port 4111 (LLM routing)
- PostgreSQL: port 5111 (database `npl`)
- Docker Compose for PostgreSQL, Liquibase for schema (18 changesets)
- Multi-stage `Dockerfile` (Node 22 frontend build → python:3.13-slim runtime)
- Helm chart at `charts/npl-mcp/` for Kubernetes deployment
- `Makefile` targets: install, serve, serve-dev, test, lint, fmt, docs-regen, fe-build, cy-open, cy-run

## Console Scripts
- `npl-mcp` — full server (`npl_mcp.launcher:main`)
- `npl-docs-regen` — regenerate npl-full.md (`npl_mcp.docs_regen:main`)
- `npl-tmlanguage` — generate NPL TextMate grammar
- `git-dump`, `git-tree` — repo dump/tree utilities
- `2md`, `md-view`, `view-md` — markdown conversion/viewing CLIs

## Key Design Decisions
- FastMCP 3.x with custom catalog (hidden-but-callable has no native equivalent)
- `mcp_discoverable` helper combines `@mcp.tool` + `@discoverable` with auto-populated tags/meta
- Pure-ASGI fallback middleware (SSE-safe, replaces BaseHTTPMiddleware)
- REST API (~105 endpoints) parallel to MCP SSE — same DB, different access paths
- Frontend API facade: pluggable hybrid/rest/mock impls; Cypress for E2E
- Agent pipes: inter-agent structured YAML messaging with upsert semantics and group targeting
- NPL convention system: YAML source of truth → parse → resolve → layout pipeline with expression DSL
- Liquibase manages all DB tables across 18 changesets
- Orchestration: `PipelinePattern` with `QualityGate` retry logic; pattern registry extensible to consensus/hierarchical/iterative patterns
- Structured JSONL logging via `JsonFormatter` for service diagnostics

## Detailed References
- `arch/rest-api.md` — Full REST endpoint reference (~105 endpoints)
- `arch/mcp-tools.md` — Complete per-tool reference (58 visible + 22 hidden)
- `arch/npl-conventions.md` — Convention system architecture and expression DSL
- `arch/agent-pipes.md` — Pipe messaging schema, targeting, and lifecycle
- `reference/persona-cli.md` — Persona CLI package documentation
- `arch/meta-tools.md` — Catalog architecture and LLM configuration
- `arch/agent-orchestration.md` — TDD pipeline workflow details

## Agent Orchestration
30+ primary agents organized by role: TDD pipeline (idea-to-spec → prd-editor → tdd-tester → tdd-coder → tdd-debugger), taskers (haiku/fast/sonnet/opus/ultra), authoring (author, marketing-writer, technical-writer), analysis (winnower, gopher-scout, thinker, grader), persona (persona, persona-manager), coordination (project-coordinator, prd-manager), domain specialists (sql-architect, build-master, cpp-modernizer, perf-profiler, threat-modeler), and utilities (fim, templater, nimps, nb). 24+ additional specialist agents in `agents/additional-agents/`. Inter-agent communication via pipes module. `orchestration/` module provides pipeline execution and TDD workflow automation. Companion `npl_persona` CLI for offline persona simulation.
