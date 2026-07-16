---
id: US-042
title: "Copy a Generated `claude mcp add` Setup Command"
slug: "copy-claude-mcp-add-setup-command"
personas: [P-001]
epic: "Onboarding & Auth"
priority: "must-have"
complexity: "S"
tags: [mcp, setup-command, harness-operator, clipboard]
---

# US-042: Copy a Generated `claude mcp add` Setup Command

## User Story

**As the** Harness Operator (P-001),
**I want to** get a ready-to-paste `claude mcp add` command right after minting a key,
**So that** I can wire up Claude Code's MCP connection in one copy-paste instead of hand-assembling flags and URLs.

## Acceptance Criteria

- [ ] Given I have just minted a new MCP API key, when the key-created confirmation view renders, then it shows a complete `claude mcp add --transport streamable-http ... --header "Authorization: Bearer $AUTH_TOKEN"` command with the correct server URL and my token substituted in.
- [ ] Given the setup command is displayed, when I select the "copy" control, then the exact command text is placed on my clipboard unmodified.
- [ ] Given I navigate away from the key-created view, when I return to `/app/mcp-keys` later, then the full setup command with the raw token is no longer displayed anywhere, consistent with the key being shown only once.

## Notes

Directly follows key minting in US-041. The one-time-display constraint mirrors the raw key's own one-time display.
