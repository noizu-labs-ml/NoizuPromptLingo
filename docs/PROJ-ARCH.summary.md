# Project Architecture Summary

## Overview
NPL MCP is a Model Context Protocol server built on FastMCP 3.x (`>=3.0.0,<4.0.0`) using a three-tier tool pattern: 11 MCP-visible tools at startup (5 discovery + 1 NPL spec + 2 session + 3 instruction), 22 hidden tools callable via ToolCall, 92 stub tools for planned features. Unified catalog of 125 tools. Every MCP-registered tool carries hierarchical `tags` and NPL-specific `meta` (`npl_category`, `npl_discoverable`) so 3.x-native clients can filter/group natively. FastAPI for routing with a pure-ASGI fallback middleware (SSE-safe), Next.js frontend, LiteLLM proxy for LLM-powered features, PostgreSQL for persistent storage.

## Components
- **Launcher** (`launcher.py`): create_app() + create_asgi_app(), CLI, Uvicorn, pure-ASGI `FrontendFallbackMiddleware`
- **REST API Router** (`api/router.py`): All `/api/*` HTTP endpoints — CRUD for tasks, artifacts, chat, sessions, instructions, projects, metrics, orchestration trigger
- **Meta Tools** (`meta_tools/`): ToolSummary, ToolSearch, ToolDefinition, ToolHelp, ToolCall — discovery layer, catalog builder, stub catalog, `mcp_discoverable` helper decorator
- **NPL Spec** (`convention_formatter.py`): NPLSpec tool — NPL definition generation from convention YAMLs
- **Markdown** (`markdown/`): Converter, viewer, CSS/heading/xpath filters, image descriptions
- **NPL Parser** (`npl/`): YAML loader, syntax parser, reference resolver
- **PM Tools** (`pm_tools/`): PRD/story/persona access — DB-backed CRUD (13 hidden) + file-based stubs (8)
- **Instructions** (`instructions/`): Versioned instruction CRUD + embeddings (3 registered + 3 hidden + POST /api/instructions)
- **Tool Sessions** (`tool_sessions/`): Session tracking by (project, agent, task) triple (2 registered)
- **Artifacts** (`artifacts/`): Versioned artifact CRUD + revision history (GET/POST /api/artifacts*)
- **Chat** (`chat/`): Chat rooms + messages REST CRUD (GET/POST /api/chat/rooms*)
- **Work Sessions** (`sessions/`): Generic work-session lifecycle (GET/POST /api/work-sessions*)
- **Tasks** (`tasks/`): Task CRUD + status transitions (GET/POST/PATCH /api/tasks*)
- **Browser** (`browser/`): ToMarkdown, Ping, Download, Screenshot, Rest, Secret (6 hidden + 32 stubs)
- **Storage** (`storage/`): PostgreSQL async connection pool (asyncpg)
- **Frontend** (`frontend/`): Next.js + Tailwind, static export to `web/static/`, hybrid REST/mock API facade (`lib/api/client.ts`)
- Remaining stubs: executors, scripts

## Stack
MCP protocol, FastMCP 3.x, FastAPI, Uvicorn, pure-ASGI middleware, SSE transport, PostgreSQL (asyncpg, port 5111), Liquibase migrations (13 changesets), LiteLLM proxy (port 4111), Next.js + Tailwind frontend

## Infrastructure
- NPL MCP Server: port 8765 (MCP SSE + web UI)
- LiteLLM Proxy: port 4111 (LLM routing)
- PostgreSQL: port 5111 (database `npl`)
- Docker Compose for PostgreSQL, Liquibase for schema

## Key Design Decisions
- FastMCP 3.x with custom catalog retained (hidden-but-callable has no native equivalent; `AggregateProvider` merge semantics don't match our three-tier pattern)
- `mcp_discoverable` helper combines `@mcp.tool` + `@discoverable` and auto-populates 3.x `tags` + `meta` from NPL category
- `ToolCall` distinguishes 4 statuses: dispatched result / `"mcp"` / `"stub"` / `"error"`
- Pure-ASGI fallback middleware replaces `BaseHTTPMiddleware` which broke SSE
- REST API (`/api/*`) runs parallel to MCP SSE — same DB, different access paths (web UI vs AI clients)
- Frontend API facade (`lib/api/client.ts`): pluggable hybrid/rest/mock impls; single import swap to go fully live
- Liquibase manages all 20 DB tables across 13 changesets (YAML format, TimescaleDB/PostgreSQL)

## Agent Orchestration
TDD pipeline: npl-idea-to-spec → npl-prd-editor → npl-tdd-tester → npl-tdd-coder → npl-tdd-debugger (on failure). Plus npl-winnower (quality filtering) and npl-tasker-* (task execution agents).
