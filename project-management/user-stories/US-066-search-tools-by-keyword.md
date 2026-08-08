---
id: US-066
title: "Search Tools by Keyword"
slug: "search-tools-by-keyword"
personas: [P-001, P-002]
epic: "Search & Discovery"
priority: "must-have"
complexity: "S"
tags: [mcp, discovery, tool-search, keyword]
---

# US-066: Search Tools by Keyword

## User Story

**As a** Harness Operator (Jordan Vance, P-001) or Autonomous Coding Agent (Sable, P-002),
**I want to** run ToolSearch in text mode with a plain keyword or substring,
**So that** I can quickly find the right tool on a large server without scanning the full ToolSummary list.

## Acceptance Criteria

- [ ] Given a server with 20+ tools, when ToolSearch is called with mode=text and a substring matching a tool name or description, then only matching tools are returned, ranked with exact name matches first.
- [ ] Given a keyword that matches no tool name or description, when ToolSearch is called in text mode, then an empty result set is returned rather than an error.
- [ ] Given a keyword typed in mixed case, when ToolSearch is called in text mode, then matching is case-insensitive and returns the same results as the lowercase equivalent.

## Notes

Text mode is the fast-path sibling of semantic-intent search (US-067); both are reached through the same ToolSearch tool via a `mode` parameter.
