---
id: US-069
title: "Get Contextual Help for a Tool"
slug: "get-contextual-help-for-a-tool"
personas: [P-002, P-008]
epic: "Search & Discovery"
priority: "could-have"
complexity: "S"
tags: [mcp, discovery, tool-help, onboarding]
---

# US-069: Get Contextual Help for a Tool

## User Story

**As an** Autonomous Coding Agent (Sable, P-002) or Evaluating Newcomer (Tomás Lindqvist, P-008),
**I want to** call ToolHelp on a tool and get usage guidance and examples rather than just a raw schema,
**So that** I understand how and when to use the tool correctly, especially when I'm unfamiliar with the MCP surface.

## Acceptance Criteria

- [ ] Given a valid tool name, when ToolHelp is called, then the response includes a plain-language description of the tool's purpose, at least one example call, and common pitfalls or preconditions.
- [ ] Given a tool with confusable siblings (e.g. ToolSearch vs ToolSummary), when ToolHelp is called on it, then the help text explicitly distinguishes it from those siblings.
- [ ] Given a tool that requires a prior step (e.g. Session.Create must precede Session.Update), when ToolHelp is called on it, then that prerequisite is stated in the response.

## Notes

Complements ToolDefinition (US-068): ToolDefinition answers "what are the parameters," ToolHelp answers "how do I actually use this" — the latter matters most for low-MCP-familiarity users like P-008.
