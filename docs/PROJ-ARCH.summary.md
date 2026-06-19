# Architecture Summary

## Overview
Two-tier MCP collaboration platform: Elixir/Phoenix API backend with 8 domain-specific MCP servers (subdomain-routed), Next.js 15 dashboard frontend with OIDC auth. PostgreSQL persistence, Kubernetes deployment via Helm.

## Core Components
- **Root MCP Server**: Discovery tools, NPL spec loading, agent orchestration
- **8 Domain MCP Servers**: Sessions, Tickets, Chat, Review, Wiki, Projects, Artifacts, Assets — each on its own subdomain
- **Phoenix Router**: Subdomain dispatch to MCP servers + REST API for dashboard
- **Next.js Dashboard**: Web UI with Authentik OIDC, project-scoped CRUD pages
- **Mock MCP Gateway**: Dynamic MCP server generation from YAML specs
- **Liquibase**: Database migrations (not Ecto migrations)

## Domain Architecture
Each domain: supervised GenServer MCP server, tool catalog (hidden CRUD + visible Overview), Ecto schemas. Consistent layout: `mcp.ex`, `{domain}.ex`, `tools/*.ex`. Cross-domain: Sessions group items, Tickets/Artifacts/Assets are project-scoped, Comments/Reactions/Watches are polymorphic.

## Authentication
Authentik OIDC via NextAuth v5. JWT tokens carry `oidc_sub`. User sync on sign-in via `/api/auth/sync`. MCP API keys (bcrypt-hashed) for programmatic agent access.

## Data Layer
PostgreSQL, Ecto 3.13, 35+ schema modules. Liquibase changelogs in `db/changelog/`. Project-scoped entities use `project_id` FK. Polymorphic associations for comments, reactions, watches, attachments.

## Deployment
Two Alpine Docker images (Elixir :4040, Next.js :3000). Single Helm chart `npl-mcp`. Wildcard DNS `*.tobor.locker` for subdomain routing. Secrets via Infisical operator.

## Tech Stack
Elixir 1.18+, Phoenix 1.7, OTP 29, noizu_mcp ~> 0.1.3, Next.js 15.3, React 19, NextAuth v5, PostgreSQL, Liquibase, Helm, Kubernetes.
