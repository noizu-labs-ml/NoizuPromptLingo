# Architecture Summary — NoizuPromptLingo

Condensed companion to [PROJ-ARCH.md](PROJ-ARCH.md).

## Overview

Multi-tenant platform for AI agent harnesses + human supervisors ("tobor"). Three runtime containers: nginx → Phoenix backend (:4000) + Next.js frontend (:3000), sharing Postgres (PostGIS + pgvector) and Redis. Backend exposes a public NPL syntax MCP at `/mcp` (`NPLLoad`, `NPLSpec`, no auth). Agent-kit work servers live in a separate repo. Weaviate backs semantic search. A legacy Python MCP fleet (`src/npl_mcp`) remains for tooling (persona CLI, orchestration, browser tools).

## Tenancy & auth

Public MCP: no auth. Optional OAuth issues a site-approval token (`sub=site:npl`). Humans (conventions admin): Authentik OIDC → Guardian JWT.

## Core components

nginx (reverse proxy) · Phoenix backend (domain contexts, MCP fleet, channels, Oban) · Next.js frontend (public / app / org / admin surfaces) · Liquibase (canonical schema 000–084) · MCP catalog (server routing + scope packaging) · MCP toolsets/VFS (custom tool sets with profiles + consent elevation; `/tobor/{org}/…` VFS mount) · PBAC/Authz · NPL convention engine (YAML → NPLSpec/NPLLoad) · TRP client (PM source) · Python MCP fleet (FastMCP+FastAPI) · local-mcp (stdio, local-only tools) · browser-controller (Playwright relay) · remote-access-client (frpc tunnels) · helm charts (start-app scaffold, npl-mcp production) · agents//commands//design/ (non-runtime assets)

## MCP servers

Public root `/mcp` serves `NPLLoad` and `NPLSpec` only (no bearer required; optional OAuth site-approval token). Per-domain subdomains moved to agent-kit-mcp. Custom/set/mock gateways remain as leftover admin surfaces.

## Key decisions

Elixir/Phoenix platform core with per-domain contexts · multi-server MCP on host paths from one catalog · DB-backed custom tool sets + VFS over the same domain contexts · Liquibase owns DDL (Ecto migrations minimal) · separate human (OIDC+Guardian) vs agent (key→JWT) auth · PBAC v2 with ToolGuard shadow mode · frontend API facade (mock/REST/hybrid swap) · NPL YAML conventions with layered pipeline + DSL · Python fleet kept for pipes/orchestration/persona tooling · TRP as PM source (cross-DB FKs dropped, changeset 078)

## Stack

Next.js 16/React 19/Tailwind v4 · Phoenix 1.8/Elixir/Bandit/Guardian/Oban · FastMCP 3.x/FastAPI/asyncpg/uv · PostgreSQL/Redis/Weaviate · Liquibase + minimal Ecto · OpenTelemetry · nginx/Docker Compose/Helm/Infisical · Node companions (local-mcp, browser-controller, remote-access-client)

## Running

`make init` → `make build` → `make run` (prod-like, nginx 8080/8095) · `make run-dev` (hot reload) · `uv run npl-mcp` (Python server :8765, LiteLLM :4111) · sandbox image · `helm/npl-mcp` (tobor.locker) · Postgres :5111

→ Detail: [arch/mcp-tools.md](arch/mcp-tools.md) · [arch/rest-api.md](arch/rest-api.md) · [arch/agent-orchestration.md](arch/agent-orchestration.md) · [arch/agent-pipes.md](arch/agent-pipes.md) · [arch/npl-conventions.md](arch/npl-conventions.md) · [PROJ-SCHEMA.md](PROJ-SCHEMA.md) · [PROJ-LAYOUT.md](PROJ-LAYOUT.md)
