---
id: US-042
title: "Copy Generated MCP Setup Commands (Claude / Codex / Grok)"
slug: "copy-claude-mcp-add-setup-command"
personas: [P-001]
epic: "Onboarding & Auth"
priority: "must-have"
complexity: "S"
tags: [mcp, setup-command, harness-operator, clipboard]
---

# US-042: Copy Generated MCP Setup Commands (Claude / Codex / Grok)

## User Story

**As the** Harness Operator (P-001),
**I want to** get ready-to-paste MCP setup commands for Claude Code, Codex, or Grok right after minting a key,
**So that** I can wire up my harness MCP connection in one copy-paste instead of hand-assembling flags and URLs.

## Acceptance Criteria

- [ ] Given I have just minted a new MCP API key, when the setup panel renders, then I can choose client **Claude Code**, **Codex**, or **Grok** and see the matching add commands with correct server URLs and my token substituted in.
- [ ] Given Claude is selected, commands use `claude mcp add --transport http ... --header "Authorization: Bearer $AUTH_TOKEN"`.
- [ ] Given Codex is selected, commands use `codex mcp add ... --url ... --bearer-token-env-var AUTH_TOKEN`.
- [ ] Given Grok is selected, commands use `grok mcp add --transport http ... --header "Authorization: Bearer $AUTH_TOKEN"`.
- [ ] Given the setup command is displayed, when I select the "copy" control, then the exact command text is placed on my clipboard unmodified.
- [ ] Given I navigate away from the key-created view, when I return to `/app/mcp-keys` later, then the full setup command with the raw token is no longer displayed anywhere, consistent with the key being shown only once.

## Notes

Directly follows key minting in US-041. The one-time-display constraint mirrors the raw key's own one-time display.
