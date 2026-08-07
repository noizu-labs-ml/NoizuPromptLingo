# Architecture Summary — NoizuPromptLingo (NPL / tobor)

Multi-tenant agent + human collaboration platform. Phoenix API/MCP backend + Next.js web app + nginx. Agents use MCP (`tobor-*`); humans use the web UI. This project *is* tobor for the monorepo’s work-session MCP.

## Overview

- Tenancy: Organization → Project → Session
- Domains: tickets/boards, chat, wiki, artifacts, review, personas, memory, instructions, assets, GitHub, marketing suite, browser relay, remote tunnels, mock MCP, NPL conventions, unicode codex
- Dual auth: humans = Authentik OIDC → Guardian JWT; agents = McpApiKey → short-lived MCP JWT
- MCP: 20+ subdomain servers + root `/mcp` + `/custom/:slug/mcp`; shared discovery tools; Weaviate semantic search
- Identity on tools: server-side from JWT (`ToolGuard`), not caller args

## Components

| Piece | One-liner |
|-------|-----------|
| nginx | Routes API/auth/socket vs SPA |
| backend | Phoenix domains, MCP fleet, channels, Oban |
| frontend | Next.js org/admin/dashboard surfaces |
| Liquibase | Canonical schema 000–073+ |
| MCPServers catalog | Subdomain list + custom scope packaging |
| PBAC + membership | Coarse roles + policy documents |
| local-mcp / browser-controller / remote-access-client | Local-only sidecars |
| helm/npl-mcp | Prod tobor.locker chart |
| agents/commands | Harness prompt assets (not runtime) |

## Diagrams (essence)

```
Browser ──► nginx ──► frontend | backend
Harness ──► ingress host/path ──► backend /mcp
backend ──► Postgres, Redis, Weaviate, S3
```

Org → projects/sessions → tickets, chat, wiki, memory, personas, …

## Auth

- Human: OIDC only (invite-gated); SPA at `/auth/sso-callback`
- Agent: mint key in UI → token endpoint → Bearer MCP JWT
- Routes gated by membership ladder; MCP by ToolGuard (shadow/enforce)

## Schema & data

Liquibase first; Ecto schemas mirror tables. Redis presence/cache; Oban for memory/jobs; Weaviate for tool search; S3 for media.

## Deploy

- Local: `make init|build|run` or `run-dev` (port map NPL=8095, Redis DB 15, slug `npl`)
- Shared docker network `lets-go_default` for PG/Redis
- K8s: `helm/npl-mcp`, images `ops.noizu.com/npl-mcp/*`, Infisical secrets

## Stack

Next.js 16 / React 19 / Tailwind v4 · Elixir / Phoenix 1.8 / Bandit · Guardian + OIDC · Postgres+PostGIS+pgvector · Redis · Weaviate · noizu_mcp · GenAI · Oban · OTel · Docker/Helm

## Key decisions

1. MCP-first dual surface (REST + tools)  
2. Subdomain MCP + custom scopes for least privilege  
3. Server-side actor resolution  
4. Layered membership + PBAC  
5. Separate human vs agent auth  
6. Liquibase canonical schema  
7. Local sidecars for browser/tunnels  
8. Scaffold heritage; product docs live here (not nested start-app arch stubs)

## Related

README · FEATURE-PARITY-AUDIT · PROJ-LAYOUT · PROJ-SCHEMA · REMOTE-ACCESS-TUNNEL-DESIGN · `mcp_servers.ex` · `router.ex`
