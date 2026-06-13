---
id: P-004
name: "Jordan Rivera"
slug: "ai-ml-engineer"
archetype: "The Integrator"
segment: "primary"
tags: [ai-engineer, mcp-client, tool-discovery, auth-flow, agent-integration, performance]
---

# Jordan Rivera — The Integrator

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 25-34 |
| **Role** | AI/ML Engineer |
| **Technical Level** | Advanced |
| **Industry** | AI / Machine Learning |
| **Location** | Austin, Texas |

## Bio

Jordan builds AI agent systems that automate customer support workflows. Their agents need to call tools — look up orders, query knowledge bases, file tickets — and they chose MCP as the tool protocol because it is emerging as the standard. Jordan spends more time on auth flows, token scoping, and tool discovery than on the actual agent logic. They want MCP tools to be as easy to integrate as REST APIs: discover the endpoint, authenticate, call it, handle errors.

## Goals

1. Discover available MCP tools through a searchable registry with quality signals (health, latency, trust level) instead of word-of-mouth and GitHub spelunking
2. Integrate MCP tools into agent workflows with minimal auth ceremony — scoped tokens, automatic refresh, clear permission boundaries
3. Monitor tool invocation performance in real time — latency, error rates, timeouts — so agent behavior remains reliable under load

## Frustrations

1. Finding MCP tools requires searching GitHub repos, reading READMEs, and hoping the server is actually running and maintained
2. Auth for MCP tools is inconsistent — some use API keys, some use OAuth, some have no auth at all — and there is no standard handshake
3. When an agent's tool call fails, the error message is often opaque (connection refused, timeout, "internal error") with no structured way to debug

## Behaviors

- Uses Claude API or OpenAI function calling as the agent runtime, with MCP as the tool layer
- Maintains a local catalog of MCP tool endpoints, manually curated, that breaks every time a server goes down or changes its schema
- Writes retry logic and fallback handling for every tool integration because reliability is unpredictable
- Profiles agent pipelines end-to-end and tools are consistently the latency bottleneck

## Job to Be Done

> "When I am building an agent that needs external capabilities, I want to browse a verified catalog of MCP tools, authenticate once with a scoped token, and invoke tools with predictable latency and structured error responses, so I can ship reliable agent workflows without spending days on integration plumbing."

## Relationship to Product

Jordan encounters MCP Host through the registry — they search for a tool they need and find it listed with health scores and latency data. They sign up for an API key, configure their agent to route MCP calls through MCP Host, and get immediate value from the standardized auth flow and monitoring. JustMCP.it is useful when Jordan wants to host their own internal tools. SafeMCP matters for production deployments where policy compliance is required. Jordan would churn if the registry has poor coverage, if latency overhead is noticeable, or if the auth flow adds more friction than direct API key usage.

## Scenarios

1. **Tool Discovery and Integration** — Jordan searches the MCP registry for a "ticket management" tool, finds one with 99.5% uptime and 45ms median latency, reads the schema, generates a scoped API token, and has it integrated into their agent within an hour.
2. **Real-Time Performance Monitoring** — Jordan opens the MCP Host dashboard during a load test and watches tool invocation latency, error rates, and throughput in real time, identifying a timeout issue with one tool before it impacts production agents.
3. **Scoped Auth for Multi-Agent System** — Jordan deploys five agents, each with a different scoped token that limits which tools they can call. When one agent tries to access an unauthorized tool, the request is denied with a clear structured error indicating the missing permission scope.
