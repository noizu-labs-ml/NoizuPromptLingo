---
name: trl-mcp-forge
description: >
  Implementation engineer for MCP servers. Scaffolds runnable projects across
  three phases: quick prototype (stdio, minimal), production build (Docker,
  tests, CI/CD, monitoring), and Virtual MCP agent (tool composition layer
  with version contracts and self-audit). Use this skill when the user wants
  to scaffold an MCP server, generate boilerplate, implement tools from a
  spec, add MCP tests, containerize an MCP server, or build a virtual MCP
  agent -- even if they don't say "forge." Also trigger when users mention
  MCP testing, MCP Docker, MCP CI/CD, MCP scaffold, or virtual MCP
  implementation.
---

# MCP Forge

Implementation and scaffolding engine for MCP servers. Takes specifications (from **trl-mcp-architect** or ad-hoc requirements) and produces runnable code.

## Overview

MCP Forge generates complete, runnable project scaffolds across three tiers of maturity:

- **Phase 1 -- Quick Scaffold.** A working MCP server in under 30 minutes. Stdio transport, 2-5 tools, smoke tests, zero infrastructure. Good enough to test with Claude Desktop.
- **Phase 2 -- Production Scaffold.** Hardened server with Streamable HTTP transport, structured logging, rate limiting, Docker packaging, CI/CD pipeline, unit and integration tests. Ready for deployment.
- **Phase 3 -- Virtual MCP.** An agent-based composition layer that presents a unified tool interface over multiple backing MCP servers. Includes version contracts, self-audit, and the NPL three-tier discovery pattern.

> For spec design before scaffolding, see **trl-mcp-architect** (`references/specification-checklist.md`).

## Core Philosophy

1. **Runnable output only.** Every scaffold must work out of the box. No placeholder TODOs in critical paths. If a tool handler needs real API logic, the scaffold includes a working mock that returns realistic data.
2. **SDK conventions.** Use official SDK patterns (`McpServer` in TypeScript, `@mcp.tool()` in FastMCP) rather than raw JSON-RPC. SDKs handle protocol edge cases correctly.
3. **Test from the start.** Phase 1 includes a smoke test. Phase 2 includes unit, integration, and contract tests. Testing is not a follow-up task.
4. **Config over hardcoding.** Server name, version, transport, auth, and feature flags come from environment variables or config files. No magic strings buried in source code.
5. **Virtual MCP is an agent, not a server.** Phase 3 does not generate a traditional server. It produces an agent definition that composes existing tools through LLM-mediated dispatch.

## When to Use

| Situation | Phase | Start Here |
|---|---|---|
| "Scaffold a quick MCP server" | 1 | `references/scaffold-nodejs-quick.md` or `references/scaffold-python-quick.md` |
| "Implement tools from this spec" | 1 or 2 | Match phase to spec maturity |
| "Add tests to my MCP server" | 2 | `references/testing-patterns.md` |
| "Containerize my MCP server" | 2 | `references/docker-patterns.md` |
| "Add CI/CD to my MCP server" | 2 | `references/ci-cd-patterns.md` |
| "Add monitoring/observability" | 2 | `references/monitoring-and-observability.md` |
| "Build a virtual MCP over existing tools" | 3 | `references/virtual-mcp-implementation.md` |
| "Version my virtual MCP interface" | 3 | `references/virtual-mcp-versioning.md` |
| "Audit my virtual MCP for drift" | 3 | `references/virtual-mcp-self-audit.md` |

## Phase 1: Quick Scaffold

**What you get:** A single-command runnable MCP server with stdio transport, 2 example tools, Zod/type-hint validated parameters, a smoke test, and a README.

**Node.js path:** TypeScript project with `@modelcontextprotocol/sdk` v1.29.0. Build with `npm run build`, run with `npm start`, test with `npm test`. Full scaffold in `references/scaffold-nodejs-quick.md`.

**Python path:** FastMCP v3.2.4 project. Run with `python server.py`, test with `pytest`. Full scaffold in `references/scaffold-python-quick.md`.

Both scaffolds are complete -- copy the files, install dependencies, run.

## Phase 2: Production Scaffold

**What you get:** Multi-file project structure with:

- Separated server initialization, tool registry, and tool implementations
- Rate limiting and structured logging middleware
- Unit and integration test suites
- Docker multi-stage build with non-root user
- Docker Compose for local development
- GitHub Actions CI/CD pipeline (lint, test, build, Docker push)
- Environment-based configuration with sensible defaults

**Node.js:** `references/scaffold-nodejs-production.md`
**Python:** `references/scaffold-python-production.md`

Supporting patterns: `references/testing-patterns.md`, `references/docker-patterns.md`, `references/ci-cd-patterns.md`, `references/monitoring-and-observability.md`.

## Phase 3: Virtual MCP

A Virtual MCP is not a traditional server. It is an **agent** that:

1. Reads a version contract defining its published tool interface
2. Maps each published tool to a sequence of calls against backing MCP servers or CLI tools
3. Exposes meta-tools (ToolSummary, ToolSearch, ToolDefinition, ToolHelp, ToolCall) for discovery
4. Runs self-audit prompts to detect drift between published interface and backing tool behavior

Implementation details: `references/virtual-mcp-implementation.md`
Versioning: `references/virtual-mcp-versioning.md`
Self-audit: `references/virtual-mcp-self-audit.md`
NPL three-tier pattern: `references/npl-three-tier-integration.md`

## Language Selection Matrix

| Factor | Node.js / TypeScript | Python |
|---|---|---|
| **SDK maturity** | `@modelcontextprotocol/sdk` v1.29.0 -- comprehensive | `fastmcp` v3.2.4 -- ergonomic, slightly behind on edge features |
| **Best for** | Web APIs, JSON-heavy tools, existing Node ecosystem | Data science, ML tools, scripting, existing Python ecosystem |
| **Type safety** | Zod schemas for tool parameters | Python type hints + Pydantic |
| **Transport support** | stdio + Streamable HTTP | stdio + Streamable HTTP |
| **Docker image size** | ~150MB (node:slim) | ~120MB (python:slim) |
| **Startup time** | Fast (V8) | Fast (CPython) |
| **Recommendation** | Default choice for web-oriented tools | Choose when Python libs are needed or team prefers Python |

## Quick Start Guides

### Path A: Quick Prototype

1. Choose language (TypeScript or Python)
2. Copy scaffold from `references/scaffold-{lang}-quick.md`
3. Replace example tools with your tools
4. Test with `npm test` / `pytest`
5. Connect to Claude Desktop and validate

### Path B: Production Build

1. Start from Phase 1 or copy `references/scaffold-{lang}-production.md`
2. Implement tool handlers with real logic
3. Configure auth, rate limiting, logging via `config.ts` / `config.py`
4. Run full test suite
5. Build Docker image, deploy

### Path C: Virtual MCP

1. Identify backing MCP servers or CLI tools to compose
2. Define published tool interface (use **trl-mcp-architect** for spec)
3. Write version contract from `assets/version-contract-template.md`
4. Implement agent definition per `references/virtual-mcp-implementation.md`
5. Run self-audit per `references/virtual-mcp-self-audit.md`

## Reference Guide

| Task | File |
|---|---|
| Agent workflows | `references/agent-playbook.claude-code.md` |
| Phase 1 Node.js scaffold | `references/scaffold-nodejs-quick.md` |
| Phase 1 Python scaffold | `references/scaffold-python-quick.md` |
| Phase 2 Node.js scaffold | `references/scaffold-nodejs-production.md` |
| Phase 2 Python scaffold | `references/scaffold-python-production.md` |
| Testing patterns | `references/testing-patterns.md` |
| CI/CD patterns | `references/ci-cd-patterns.md` |
| Docker patterns | `references/docker-patterns.md` |
| Monitoring and observability | `references/monitoring-and-observability.md` |
| Virtual MCP implementation | `references/virtual-mcp-implementation.md` |
| Virtual MCP self-audit | `references/virtual-mcp-self-audit.md` |
| Virtual MCP versioning | `references/virtual-mcp-versioning.md` |
| NPL three-tier integration | `references/npl-three-tier-integration.md` |
| Worked example: Stripe MCP | `references/worked-example-stripe-mcp.md` |
| Worked example: Virtual DevOps | `references/worked-example-virtual-devops.md` |

## Related Skills

| Skill | Relationship | Key File |
|---|---|---|
| **trl-mcp-builder** | Parent coordinator -- routes users here | `mcp-builder/SKILL.md` |
| **trl-mcp-architect** | Provides spec input consumed by forge | `mcp-architect/references/specification-checklist.md` |
| **trl-ai-templates** | Package MCP servers as sellable products | `ai-templates/references/templates-reference.md` |
| **trl-skill-engineer** | Build Claude Code skills that invoke MCP tools | `skill-engineer/references/mcp-tool-catalog.md` |

## Bundled Resources

### References

- [agent-playbook.claude-code.md](references/agent-playbook.claude-code.md) -- Agent role definition and implementation workflows. Read when operating as the trl-mcp-forge agent.
- [scaffold-nodejs-quick.md](references/scaffold-nodejs-quick.md) -- Phase 1 TypeScript scaffold with complete runnable files. Read when generating a quick Node.js prototype.
- [scaffold-nodejs-production.md](references/scaffold-nodejs-production.md) -- Phase 2 TypeScript scaffold with tests, Docker, CI/CD. Read when generating a production Node.js server.
- [scaffold-python-quick.md](references/scaffold-python-quick.md) -- Phase 1 Python/FastMCP scaffold with complete runnable files. Read when generating a quick Python prototype.
- [scaffold-python-production.md](references/scaffold-python-production.md) -- Phase 2 Python/FastMCP scaffold with tests, Docker, CI/CD. Read when generating a production Python server.
- [testing-patterns.md](references/testing-patterns.md) -- MCP server testing strategies: unit, integration, smoke, contract. Read when adding tests.
- [ci-cd-patterns.md](references/ci-cd-patterns.md) -- CI/CD pipeline patterns for MCP servers. Read when setting up GitHub Actions.
- [docker-patterns.md](references/docker-patterns.md) -- Docker patterns for MCP servers. Read when containerizing.
- [monitoring-and-observability.md](references/monitoring-and-observability.md) -- Structured logging, metrics, tracing, alerting. Read when adding observability.
- [virtual-mcp-implementation.md](references/virtual-mcp-implementation.md) -- Phase 3 Virtual MCP implementation guide. Read when building agent-based tool composition.
- [virtual-mcp-self-audit.md](references/virtual-mcp-self-audit.md) -- Self-audit system for Virtual MCP drift detection. Read when setting up automated verification.
- [virtual-mcp-versioning.md](references/virtual-mcp-versioning.md) -- Semantic versioning and contracts for Virtual MCP interfaces. Read when managing tool interface evolution.
- [npl-three-tier-integration.md](references/npl-three-tier-integration.md) -- NPL three-tier tool discovery architecture. Read when implementing tiered tool visibility.
- [worked-example-stripe-mcp.md](references/worked-example-stripe-mcp.md) -- End-to-end Stripe payments MCP server from spec to production.
- [worked-example-virtual-devops.md](references/worked-example-virtual-devops.md) -- End-to-end Virtual MCP composing kubectl, Docker, and GitHub Actions.

### Assets

- [project-tracker.md](assets/project-tracker.md) -- Implementation tracking template for active MCP server builds.
- [scaffold-config.yaml](assets/scaffold-config.yaml) -- Configuration file driving scaffold generation.
- [self-audit-prompt-template.md](assets/self-audit-prompt-template.md) -- Fillable template for Virtual MCP self-audit prompts.
- [version-contract-template.md](assets/version-contract-template.md) -- Template for Virtual MCP version contracts.
