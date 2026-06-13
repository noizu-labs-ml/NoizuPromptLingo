---
id: US-001
title: "Register MCP server with AI coding assistant"
slug: "register-mcp-server"
personas: [P-001, P-006]
epic: "MCP Core Service"
priority: "must-have"
complexity: "M"
tags: [mcp, onboarding, integration, setup]
---

# US-001: Register MCP server with AI coding assistant

## User Story

**As a** full-stack developer (P-001),
**I want to** register the securamcp.com MCP server with my AI coding assistant using a config snippet,
**So that** I can invoke mockup generation tools directly from my coding environment without leaving my workflow.

## Acceptance Criteria

- [ ] Given a valid API key, when I add the MCP server config to my assistant's settings, then the server appears in the active tools list within 10 seconds
- [ ] Given the server is registered, when I list available MCP tools, then mockup generation tools appear with their parameter schemas
- [ ] Given an invalid or expired API key, when registration is attempted, then the assistant displays a clear authentication error with a link to regenerate the key
- [ ] Given the MCP server is unreachable, when the assistant attempts to connect, then a graceful timeout error is returned rather than a hang

## Notes

Supports Claude Code (`claude_desktop_config.json`), Cursor (`.cursor/mcp.json`), and Windsurf config formats. Config snippets must be surfaced in the onboarding wizard (US-015). Related to US-016 and US-017.
