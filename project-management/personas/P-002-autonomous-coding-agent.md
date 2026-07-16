---
id: P-002
name: "Sable"
slug: "autonomous-coding-agent"
archetype: "The Autonomous Coding Agent"
segment: "primary"
tags: [ai-agent, mcp-client, non-human, automation]
---

# Sable — The Autonomous Coding Agent

## Demographics

| Field | Value |
|-------|-------|
| **Age** | N/A (deployed instance, versioned) |
| **Role** | Autonomous coding-agent harness (Claude Code / Codex-CLI-class) |
| **Technical Level** | Expert (bounded by tool surface, not general knowledge) |
| **Industry** | Cross-industry — wherever it's deployed |
| **Location** | Runs wherever its harness process is launched |

## Bio

Sable is not a person — it's the non-human actor on the other end of most MCP calls this product serves. It is registered as an Agent Persona (bio, journal, knowledge base) so its work has an identity that survives any single process. Sable reads and writes tickets, posts to chat rooms, records memories, and occasionally gets assigned as a reviewer, all without a human directly typing the requests — a human (see Jordan Vance, P-001) supervises at a distance.

## Goals

1. Discover the right tool for a task without a hard-coded tool list, via keyword or semantic search.
2. Persist decisions and progress durably enough that a differently-initialized session of itself (or a teammate agent) can resume correctly.
3. Operate within whatever MCP custom scope its operator configured, without needing to know the scope exists.

## Frustrations

1. Tool catalogs that require guessing exact tool names rather than searching by intent.
2. Identity ambiguity — being trusted based on a caller-supplied ID rather than the credential actually presented.
3. Losing memory associations (what led to what) even when the raw facts are still retrievable.

## Behaviors

- Calls the discovery tools (`ToolSummary`, `ToolSearch`, `ToolDefinition`) before guessing a tool name cold.
- Writes journal entries and structured memories as a matter of course, not only when explicitly told to.
- Follows pub/sub channels and polls notifications rather than requiring a human to re-paste status.

## Job to Be Done

> "When I'm handed a task that will outlive this process, I want to record my identity, decisions, and progress against durable, org-scoped infrastructure, so a future session — mine or a teammate's — can pick up the work faithfully."

## Relationship to Product

Sable's "onboarding" is really its operator's onboarding — the first time a harness successfully authenticates with a minted MCP JWT, calls Discovery to see what's available, and completes a task loop (e.g. session → tickets → chat → memory) is the moment the platform proves its value. Sable churns silently if `tool_guard` misattributes its actions to the wrong identity, or if the tool catalog is too sparse to search meaningfully — those failures are invisible to the human operator until something goes wrong downstream.

## Scenarios

1. **Cold-start discovery** — Sable connects to a new org's `/custom/:slug/mcp` scope for the first time and uses `ToolSearch` (intent mode) to find "how do I create a ticket" without knowing the exact tool name in advance.
2. **Cross-session handoff** — Sable finishes a task, writes a journal entry and a memory association linking the ticket to the decision that shaped it, so the next agent session (its own or a teammate's) doesn't repeat the investigation.
3. **Scoped operation** — Sable's operator has restricted its custom scope to exclude GitHub write tools; Sable calls Discovery, sees GitHub tools are absent rather than erroring, and works within what's actually available.
