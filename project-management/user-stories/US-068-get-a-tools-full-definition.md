---
id: US-068
title: "Get a Tool's Full Definition"
slug: "get-a-tools-full-definition"
personas: [P-002]
epic: "Search & Discovery"
priority: "should-have"
complexity: "S"
tags: [mcp, discovery, tool-definition, schema]
---

# US-068: Get a Tool's Full Definition

## User Story

**As an** Autonomous Coding Agent (Sable, P-002),
**I want to** call ToolDefinition for one specific tool name,
**So that** I can retrieve its complete input/output schema before constructing a ToolCall.

## Acceptance Criteria

- [ ] Given a valid tool name returned by ToolSummary or ToolSearch, when ToolDefinition is called with that name, then the full parameter schema (types, required/optional, descriptions) and the return-shape schema are returned.
- [ ] Given a tool name that does not exist on the target server, when ToolDefinition is called with that name, then a clear not-found error is returned rather than a partial or empty schema.
- [ ] Given a tool with nested object or array parameters, when ToolDefinition is called, then the nested structure is fully expanded in the response rather than summarized or truncated.

## Notes

Mirrors the deferred-tool-loading pattern used by discovery tooling generally: schemas are fetched on demand via ToolDefinition rather than preloaded into every session.
