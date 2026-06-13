---
id: US-017
title: "Connect MCP server to Cursor IDE"
slug: "connect-mcp-cursor-ide"
personas: [P-001, P-006]
epic: "Onboarding & Authentication"
priority: "must-have"
complexity: "S"
tags: [mcp, cursor, integration, setup, connection]
---

# US-017: Connect MCP server to Cursor IDE

## User Story

**As a** freelance consultant (P-006),
**I want to** follow in-app instructions to connect the securamcp.com MCP server to Cursor IDE,
**So that** I can generate mockups for client projects directly from my primary coding environment.

## Acceptance Criteria

- [ ] Given I select "Cursor" in the assistant connection step, when I view the instructions, then I see Cursor-specific setup steps with a pre-filled `.cursor/mcp.json` snippet containing my API key
- [ ] Given I have pasted the config and restarted Cursor, when I open Cursor's MCP panel, then the securamcp server appears with a green status indicator
- [ ] Given I click "Verify Connection" in the securamcp UI, when Cursor has the server registered and reachable, then the UI confirms connection with tool count
- [ ] Given Cursor releases a breaking change to its MCP config format, when that version is detected, then the displayed snippet format automatically adapts (or a migration note is shown)

## Notes

Cursor MCP config path: `.cursor/mcp.json` in the project root or `~/.cursor/mcp.json` globally. Instructions must cover both locations. Windsurf support follows the same pattern but is tracked separately. Related to US-001, US-014, US-015, US-016.
