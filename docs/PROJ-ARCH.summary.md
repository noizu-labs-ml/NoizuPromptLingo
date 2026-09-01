# Architecture Summary — NoizuPromptLingo

Condensed companion to [PROJ-ARCH.md](PROJ-ARCH.md).

## Overview

Multi-tenant platform for AI agent harnesses + human supervisors ("tobor"). Three runtime containers: nginx → Phoenix backend (:4000) + Next.js frontend (:3000), sharing Postgres (PostGIS + pgvector) and Redis. Backend exposes 20+ MCP servers on host-scoped paths plus a root aggregator at `/mcp`; every server implements the five discovery tools. Weaviate backs semantic search. A legacy Python MCP fleet (`src/npl_mcp`) remains for tooling (persona CLI, orchestration, browser tools).

## Tenancy & auth

Spine: Organization → Project → Session. Coarse membership (owner/admin/lead/member/viewer) + PBAC v2 (groups, JSON policies, scoped memberships, custom roles, simulator). Humans: Authentik OIDC → SSO code → Guardian JWT (invite-gated registration). Agents: minted `McpApiKey` → short-lived MCP JWT; identity resolved server-side via `ToolGuard`/`MCP.Resolve`, never caller args.

## Core components

nginx (reverse proxy) · Phoenix backend (domain contexts, MCP fleet, channels, Oban) · Next.js frontend (public / app / org / admin surfaces) · Liquibase (canonical schema 000–082) · MCP catalog (server routing + scope packaging) · PBAC/Authz · NPL convention engine (YAML → NPLSpec/NPLLoad) · TRP client (PM source) · Python MCP fleet (FastMCP+FastAPI) · local-mcp (stdio, local-only tools) · browser-controller (Playwright relay) · remote-access-client (frpc tunnels) · helm charts (start-app scaffold, npl-mcp production) · agents//commands//design/ (non-runtime assets)

## MCP servers

Required: root, sessions, organizations. Optional subdomains: projects, tickets, assets, artifacts, chat, review, wiki, github, personas, instructions, memory, markdown, notifications, pubsub, browser, customers, market, campaigns, unicode. Custom scopes at `/custom/:slug/mcp`; packaging modes default | core_custom | all_in_one.

## Key decisions

Elixir/Phoenix platform core with per-domain contexts · multi-server MCP on host paths from one catalog · Liquibase owns DDL (Ecto migrations minimal) · separate human (OIDC+Guardian) vs agent (key→JWT) auth · PBAC v2 with ToolGuard shadow mode · frontend API facade (mock/REST/hybrid swap) · NPL YAML conventions with layered pipeline + DSL · Python fleet kept for pipes/orchestration/persona tooling · TRP as PM source (cross-DB FKs dropped, changeset 078)

## Stack

Next.js 16/React 19/Tailwind v4 · Phoenix 1.8/Elixir/Bandit/Guardian/Oban · FastMCP 3.x/FastAPI/asyncpg/uv · PostgreSQL/Redis/Weaviate · Liquibase + minimal Ecto · OpenTelemetry · nginx/Docker Compose/Helm/Infisical · Node companions (local-mcp, browser-controller, remote-access-client)

## Running

`make init` → `make build` → `make run` (prod-like, nginx 8080/8095) · `make run-dev` (hot reload) · `uv run npl-mcp` (Python server :8765, LiteLLM :4111) · sandbox image · `helm/npl-mcp` (tobor.locker) · Postgres :5111

→ Detail: [arch/mcp-tools.md](arch/mcp-tools.md) · [arch/rest-api.md](arch/rest-api.md) · [arch/agent-orchestration.md](arch/agent-orchestration.md) · [arch/agent-pipes.md](arch/agent-pipes.md) · [arch/npl-conventions.md](arch/npl-conventions.md) · [PROJ-SCHEMA.md](PROJ-SCHEMA.md) · [PROJ-LAYOUT.md](PROJ-LAYOUT.md)
