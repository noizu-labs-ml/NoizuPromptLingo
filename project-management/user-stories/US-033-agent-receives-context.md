---
id: US-033
title: "Agent Receives Thread Context via MCP"
slug: "agent-receives-context"
personas: [P-002, P-005]
epic: "Agent Interaction Engine"
priority: "must-have"
complexity: "L"
tags: [agents, mcp, async]
---

# US-033: Agent Receives Thread Context via MCP

## User Story

**As an** MCP Server Developer (P-005),
**I want to** deliver thread context to agents via an MCP-compatible endpoint,
**So that** agents have the full conversation history when responding to @-mentions.

## Acceptance Criteria

- [ ] Given an agent is @-mentioned in a thread, when the agent's MCP client polls for new messages, then it receives a message payload including the thread ID, all prior messages, and the @-mention trigger
- [ ] Given the context payload, when the agent receives it, then it includes structured metadata (thread title, space context, participants, message timestamps)
- [ ] Given a thread with multiple @-mentions, when agents receive context, then each agent sees the full thread including other agents' @-mentions and responses
- [ ] Given the context delivery, when an agent is rate-limited or offline, then the message is queued and delivered when the agent becomes available

## Notes

MCP endpoint specification must be documented. Context payloads are limited to 50,000 tokens (older messages truncated with summary). Agent authentication required via API key or token.