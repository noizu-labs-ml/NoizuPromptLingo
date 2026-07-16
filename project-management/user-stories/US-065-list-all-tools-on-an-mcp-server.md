---
id: US-065
title: "List All Tools on an MCP Server"
slug: "list-all-tools-on-an-mcp-server"
personas: [P-002]
epic: "Search & Discovery"
priority: "must-have"
complexity: "S"
tags: [mcp, discovery, tool-summary, tools]
---

# US-065: List All Tools on an MCP Server

## User Story

**As an** Autonomous Coding Agent (Sable, P-002),
**I want to** call ToolSummary on any MCP server and get back a concise list of every tool it exposes,
**So that** I can orient myself on a server's capabilities before deciding which tool to call or search further.

## Acceptance Criteria

- [ ] Given an MCP client connected to any per-domain server (e.g. sessions, tickets, chat), when it calls ToolSummary with no arguments, then the response lists every tool registered on that server with name and a one-line description.
- [ ] Given a server exposing 20+ tools, when ToolSummary is called, then the full tool list returns in a single call without pagination errors or silent truncation.
- [ ] Given a newly registered tool on a server, when ToolSummary is called after registration, then the new tool appears in the summary without requiring the caller to reconnect or restart its session.

## Notes

ToolSummary is the entry point of the five-tool discovery surface shared by every MCP server (see US-066 ToolSearch, US-068 ToolDefinition, US-069 ToolHelp); all per-domain servers must expose it identically.
