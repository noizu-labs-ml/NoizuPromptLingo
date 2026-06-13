---
id: P-001
name: "Alex Chen"
slug: "mcp-tool-developer"
archetype: "The Builder"
segment: "primary"
tags: [developer, mcp-server, justmcp, mcp-jumpstart, deployment, testing]
---

# Alex Chen — The Builder

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 25-34 |
| **Role** | Senior Software Engineer |
| **Technical Level** | Advanced |
| **Industry** | Developer Tools / AI Infrastructure |
| **Location** | Remote-first, based in San Francisco |

## Bio

Alex has been building developer tools for four years and caught the MCP wave early. They maintain two open-source MCP servers — one for Postgres schema introspection and one for GitHub PR automation — and spend weekends prototyping new tool ideas. They have shipped MCP servers manually before: Dockerfiles, reverse proxies, SSL certs, monitoring glue. It works, but it is tedious and distracts from the actual tool logic.

## Goals

1. Deploy MCP servers to a public endpoint in under five minutes without touching infrastructure
2. Get production-grade observability (logs, metrics, usage breakdown) out of the box for every tool they ship
3. Publish tools to a discoverable registry so other developers can find and integrate them

## Frustrations

1. Every MCP server deployment is a bespoke DevOps project — container, networking, TLS, health checks, repeat
2. No standard way to expose an MCP server publicly with auth and rate limiting without writing glue code
3. Local testing is easy but there is a cliff between "works on my machine" and "someone else can call this tool reliably"

## Behaviors

- Writes MCP servers in TypeScript and Python using the official SDKs
- Tests locally with Claude Desktop or a custom stdio harness before deploying
- Shares work-in-progress tools as GitHub repos but has no good answer when people ask "can I try it live?"
- Tracks GitHub stars and npm downloads as a proxy for adoption but wants actual invocation metrics

## Job to Be Done

> "When I finish building an MCP tool, I want to push it to a hosted endpoint with one command, so I can share a live URL with collaborators and start collecting real usage data immediately."

## Relationship to Product

Alex discovers MCP Host through the MCP community (Discord, GitHub discussions). JustMCP.it is the entry point — they try the free tier to deploy a tool, and if the DX is smooth, they stay. MCP Jumpstart accelerates new projects by generating boilerplate they would otherwise copy-paste from docs. SafeMCP is background infrastructure they appreciate but do not configure directly. Alex would churn if the deployment flow becomes slow, opaque, or adds friction they did not have self-hosting.

## Scenarios

1. **One-Click Deploy** — Alex finishes a new MCP tool locally, runs a single CLI command or uploads through the JustMCP.it dashboard, and gets a live HTTPS endpoint with API key auth in under two minutes.
2. **Registry Publishing** — Alex publishes a tool to the public MCP registry, sets visibility to "listed," and within a day sees the first external invocations appear in the analytics dashboard.
3. **Template Scaffolding** — Alex starts a new project using MCP Jumpstart, selects "TypeScript / Database tool," and gets a working project with transport config, tool definition stubs, example handlers, and a Dockerfile — ready to customize.
