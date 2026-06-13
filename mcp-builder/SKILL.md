---
name: trl-mcp-builder
description: >
  Parent coordinator for designing, building, and deploying MCP (Model Context
  Protocol) servers across three phases: rapid prototype, production hardening,
  and virtual MCP composition. Use this skill when the user wants to build an
  MCP server, design MCP tool interfaces, scaffold an MCP project, understand
  MCP transports or SDKs, create a virtual MCP from existing tools, compare
  MCP implementation options, or plan an MCP server architecture -- even if
  they don't say "MCP builder." Also trigger when users mention tool servers,
  Claude Desktop integrations, AI tool APIs, context protocol, MCP tool
  registration, or building plugins for LLM clients like Cursor, Cline, or
  Windsurf.
---

# MCP Builder

Coordinator for three-phase MCP server development: prototype, production, and virtual composition.

## Overview

This skill orchestrates the full lifecycle of MCP server creation. It routes to two sub-skills for execution and maintains the ecosystem reference material that both depend on.

- **trl-mcp-architect** -- specification design, interface contracts, threat modeling, checklist-driven review
- **trl-mcp-forge** -- scaffolding, implementation, testing, packaging, deployment

This coordinator handles **phase routing, ecosystem orientation, SDK selection, and cross-cutting concerns** (security, transport, discovery). The sub-skills handle the actual design and build work.

> For monetizing MCP servers as digital products, see **trl-ai-templates** (`references/templates-reference.md`).

## Core Philosophy

1. **Prototype first.** Ship a working stdio server in under 2 hours. Validate the tool interface with a real client before investing in production infrastructure.
2. **Checklist-driven.** Every phase has an explicit checklist. Skip nothing silently -- mark items as intentionally deferred with rationale.
3. **SDK-native.** Use official SDKs (`@modelcontextprotocol/sdk` for TypeScript, `fastmcp` for Python) rather than hand-rolling JSON-RPC. The protocol has sharp edges that SDKs handle correctly.
4. **Security by default.** Input validation, secrets management, rate limiting, and audit logging are not optional extras. They ship with the first production deploy.
5. **Versioned contracts.** Tool interfaces are contracts with consumers. Version them explicitly. Breaking changes get a major version bump and a deprecation window.

## When to Use This Skill

| User Intent | Route To | Key Reference |
|---|---|---|
| "I want to build an MCP server" | Phase routing (below) | This file |
| "Design the interface for my MCP server" | **trl-mcp-architect** | `mcp-architect/references/specification-checklist.md` |
| "Scaffold / implement my MCP server" | **trl-mcp-forge** | `mcp-forge/references/scaffold-guide.md` |
| "What SDK should I use?" | SDK comparison | `references/sdk-reference-nodejs.md`, `references/sdk-reference-python.md` |
| "How do MCP transports work?" | Transport guide | `references/transport-guide.md` |
| "How do clients discover MCP servers?" | Discovery guide | `references/discovery-mechanisms.md` |
| "Build a virtual MCP from existing tools" | Phase 3 | `references/virtual-mcp-architecture.md` |
| "Security review my MCP server" | Security checklist | `references/security-checklist.md` |
| "What is MCP / how does the ecosystem work?" | Ecosystem overview | `references/mcp-ecosystem-overview.md` |
| "Walk me through a full example" | Worked examples | `references/worked-example-github-status.md` |

## MCP Ecosystem Quick Reference

| Aspect | Options | Recommendation |
|---|---|---|
| **Transport** | stdio, Streamable HTTP, SSE (deprecated) | stdio for local/dev; Streamable HTTP for production remote |
| **TypeScript SDK** | `@modelcontextprotocol/sdk` v1.29.0 | Official. Use `McpServer` high-level API |
| **Python SDK** | `fastmcp` v3.2.4 (wraps `modelcontextprotocol` v1.26.0) | FastMCP for most projects; raw SDK for edge cases |
| **Discovery** | Manual config, registries (Smithery, mcp.run), DNS-SD (draft) | Manual config today; registries for distribution |
| **Protocol version** | 2025-03-26 | Current stable spec |
| **Clients** | Claude Desktop, VS Code (Copilot), Cursor, Continue, Cline, Windsurf | Claude Desktop for testing; target multiple for distribution |

## Three-Phase Workflow

| Phase | Goal | Time | Output | Skill |
|---|---|---|---|---|
| **1. Prototype** | Validate tool interface with a real client | 1-2 hours | Working stdio server, 2-5 tools, manual testing | trl-mcp-architect (light) + trl-mcp-forge |
| **2. Production** | Hardened, deployable, documented server | 1-2 days | Streamable HTTP transport, Docker image, tests, CI/CD | trl-mcp-architect (full) + trl-mcp-forge |
| **3. Virtual MCP** | Agent-composed tool facade over existing servers | Variable | Published tool catalog, version contracts, self-audit | trl-mcp-architect + this skill |

## Phase Routing Logic

**Start here when a user says "build an MCP server":**

1. Do they have a clear specification? If no --> Phase 1 (prototype to discover the interface).
2. Do they have a working prototype? If no --> Phase 1.
3. Is the prototype validated and the interface stable? If yes --> Phase 2 (production hardening).
4. Are they composing multiple existing MCP servers into a unified interface? --> Phase 3 (Virtual MCP).
5. Are they re-entering after finding gaps in production? --> Back to trl-mcp-architect for spec revision, then trl-mcp-forge.

> For the full decision tree with edge cases, see [references/phase-routing-logic.md](references/phase-routing-logic.md).

## Quick Start Guides

### Path A: Idea to Full Workflow

1. Fill out the [MCP Server Brief Worksheet](assets/mcp-server-brief-worksheet.md)
2. Run Phase 1 prototype via **trl-mcp-forge** (stdio, minimal tools)
3. Test with Claude Desktop or your target client
4. If interface works --> run **trl-mcp-architect** full specification checklist
5. Run Phase 2 production build via **trl-mcp-forge**
6. Deploy and distribute

### Path B: Specification to Forge

You already have a spec or know exactly what tools you want.

1. Run **trl-mcp-architect** specification checklist to formalize the interface
2. Run **trl-mcp-forge** scaffold generation
3. Implement tool handlers
4. Test, package, deploy

### Path C: Understand MCP First

You want to learn before building.

1. Read [references/mcp-ecosystem-overview.md](references/mcp-ecosystem-overview.md)
2. Read the SDK reference for your language ([Node.js](references/sdk-reference-nodejs.md) or [Python](references/sdk-reference-python.md))
3. Read [references/transport-guide.md](references/transport-guide.md)
4. Walk through [references/worked-example-github-status.md](references/worked-example-github-status.md)
5. When ready, start Path A

## Reference Guide

| Task | File | Skill |
|---|---|---|
| Coordinate phases, route intent | `mcp-builder/SKILL.md` | trl-mcp-builder |
| Agent workflows for coordinator | `mcp-builder/references/agent-playbook.claude-code.md` | trl-mcp-builder |
| Phase routing decision tree | `mcp-builder/references/phase-routing-logic.md` | trl-mcp-builder |
| MCP ecosystem overview | `mcp-builder/references/mcp-ecosystem-overview.md` | trl-mcp-builder |
| TypeScript SDK reference | `mcp-builder/references/sdk-reference-nodejs.md` | trl-mcp-builder |
| Python SDK reference | `mcp-builder/references/sdk-reference-python.md` | trl-mcp-builder |
| Transport comparison | `mcp-builder/references/transport-guide.md` | trl-mcp-builder |
| Security checklist | `mcp-builder/references/security-checklist.md` | trl-mcp-builder |
| Discovery mechanisms | `mcp-builder/references/discovery-mechanisms.md` | trl-mcp-builder |
| Virtual MCP architecture | `mcp-builder/references/virtual-mcp-architecture.md` | trl-mcp-builder |
| GitHub Status worked example | `mcp-builder/references/worked-example-github-status.md` | trl-mcp-builder |
| Virtual MCP worked example | `mcp-builder/references/worked-example-virtual-mcp.md` | trl-mcp-builder |
| Specification design checklist | `mcp-architect/references/specification-checklist.md` | trl-mcp-architect |
| Threat model template | `mcp-architect/assets/threat-model-template.md` | trl-mcp-architect |
| Scaffold generation | `mcp-forge/references/scaffold-guide.md` | trl-mcp-forge |
| Testing patterns | `mcp-forge/references/testing-patterns.md` | trl-mcp-forge |
| Deployment guide | `mcp-forge/references/deployment-guide.md` | trl-mcp-forge |

## Related Skills

| Skill | When to Invoke | Key File |
|---|---|---|
| **trl-ai-templates** | When packaging an MCP server as a sellable digital product | `references/templates-reference.md` |
| **trl-user-experience-engineer** | When designing a landing page or docs site for an MCP server | `references/outputs/landing-pages.md` |
| **trl-seo-guru** | When optimizing an MCP server listing for discovery in registries | `SKILL.md` |
| **trl-skill-engineer** | When building a Claude Code skill that wraps or invokes MCP tools | `references/mcp-tool-catalog.md` |

## Bundled Resources

### References

- [agent-playbook.claude-code.md](references/agent-playbook.claude-code.md) -- Agent role definition and coordinator workflows for Claude Code. Read when operating as the trl-mcp-builder agent.
- [phase-routing-logic.md](references/phase-routing-logic.md) -- Detailed decision tree for routing users to the correct phase and sub-skill. Read when triaging a new MCP server request.
- [mcp-ecosystem-overview.md](references/mcp-ecosystem-overview.md) -- Comprehensive MCP protocol, SDK, client, and registry reference. Read when answering "what is MCP" or comparing implementation options.
- [sdk-reference-nodejs.md](references/sdk-reference-nodejs.md) -- Version-pinned TypeScript SDK reference with code examples. Read when building with `@modelcontextprotocol/sdk` v1.29.0.
- [sdk-reference-python.md](references/sdk-reference-python.md) -- Version-pinned Python/FastMCP SDK reference with code examples. Read when building with `fastmcp` v3.2.4.
- [transport-guide.md](references/transport-guide.md) -- Transport protocol comparison (stdio, Streamable HTTP, SSE). Read when choosing or configuring a transport.
- [security-checklist.md](references/security-checklist.md) -- MCP-specific security checklist covering input validation, secrets, auth, rate limiting, and common vulnerabilities. Read during Phase 2 hardening.
- [discovery-mechanisms.md](references/discovery-mechanisms.md) -- How MCP clients discover and connect to servers. Read when planning distribution or multi-server orchestration.
- [virtual-mcp-architecture.md](references/virtual-mcp-architecture.md) -- Theory and design for Phase 3 Virtual MCP servers. Read when composing multiple tool sources into a unified interface.
- [worked-example-github-status.md](references/worked-example-github-status.md) -- End-to-end walkthrough building a GitHub Status MCP server from prototype to production.
- [worked-example-virtual-mcp.md](references/worked-example-virtual-mcp.md) -- End-to-end walkthrough building a Virtual MCP composing GitHub, Slack, and PagerDuty.

### Assets

- [project-tracker.md](assets/project-tracker.md) -- MCP server project dashboard template for tracking active builds, ideas, and completed servers.
- [mcp-server-brief-worksheet.md](assets/mcp-server-brief-worksheet.md) -- Intake form for scoping a new MCP server project before entering the build workflow.
