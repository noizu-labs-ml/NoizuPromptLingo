---
id: US-016
title: "Connect MCP server to Claude Code"
slug: "connect-mcp-claude-code"
personas: [P-001]
epic: "Onboarding & Authentication"
priority: "must-have"
complexity: "S"
tags: [mcp, claude-code, integration, setup, connection]
---

# US-016: Connect MCP server to Claude Code

## User Story

**As a** full-stack developer (P-001),
**I want to** follow in-app instructions to add the securamcp.com MCP server to my Claude Code configuration,
**So that** I can call mockup generation tools from Claude Code without looking up documentation.

## Acceptance Criteria

- [ ] Given I am on the Claude Code connection step (in the wizard or settings), when I view the instructions, then I see a pre-filled `claude_desktop_config.json` snippet with my API key already substituted
- [ ] Given I copy the config snippet, when I paste it into `~/.claude/claude_desktop_config.json` and restart Claude Code, then the securamcp tools appear in Claude Code's tool list
- [ ] Given I click "Verify Connection", when Claude Code has the server registered and reachable, then the UI shows a green "Connected" status with the tool count
- [ ] Given I click "Verify Connection" but the server is not detected, then the UI shows a troubleshooting checklist (config path, restart required, network)

## Notes

The config snippet must be valid JSON that users can safely copy-paste without editing. Detection relies on a lightweight `/health` ping to the MCP server using the API key. Related to US-001, US-014, US-015, US-017.
