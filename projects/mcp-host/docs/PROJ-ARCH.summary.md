# Architecture Summary

> MCP Host — unified MCP hosting platform (justmcp.it | mcpjumpst.art | safemcp.com)

## Overview

Multi-surface platform for deploying, scaffolding, and securing MCP servers. Dual-principal authorization model ensures tool permissions are the intersection of caller and user grants. Pre-development stage with frontend scaffold in place.

## Product Surfaces

- **JustMCP.it** — One-click MCP deployment with monitoring and analytics
- **MCP Jumpstart** — Project scaffolding across 5 languages and multiple use-case templates
- **SafeMCP** — Security control plane with policy management, audit logs, and simulation

## Core Components

- **Auth Gateway** — Caller + user identity resolution, scoped session issuance
- **Policy Engine** — Six-level hierarchical policy evaluation (OPA/Cedar, under evaluation)
- **Execution Sandbox** — Isolated runtimes with network/resource/filesystem constraints (Firecracker/gVisor)
- **Registry** — Searchable MCP server catalog with health scoring and trust verification
- **Audit Store** — Immutable append-only invocation log with compliance export

## Security Model

Dual-principal: every request carries caller (AI agent) and user (human). Access = caller_policy AND user_policy. Delegated OAuth for downstream services — MCP Host never stores user credentials. Policies span six scope levels evaluated innermost-first.

## Tech Stack

Next.js 15 frontend, Phoenix 1.8 backend (planned), PostgreSQL + Redis, OPA/Cedar policy engine, Firecracker/gVisor sandboxing, Kubernetes deployment.

## Frontend

YAML-driven design system with four themes (Bold, Enterprise, Minimal, Nocturne) compiled to CSS. Tailwind CSS 4, Headless UI, Monaco Editor. Currently in early scaffold stage.

## Key Decisions

- Dual-principal auth prevents AI agent privilege escalation
- Phoenix/Elixir for concurrency and WebSocket support
- Declarative policy engine (OPA/Cedar) for auditable evaluation
- Firecracker/gVisor for strong tool isolation
- YAML-driven themes for multi-domain visual identity
