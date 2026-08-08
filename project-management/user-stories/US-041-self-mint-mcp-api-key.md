---
id: US-041
title: "Self-Mint an MCP API Key"
slug: "self-mint-mcp-api-key"
personas: [P-001]
epic: "Onboarding & Auth"
priority: "must-have"
complexity: "S"
tags: [mcp, api-keys, harness-operator]
---

# US-041: Self-Mint an MCP API Key

## User Story

**As the** Harness Operator (P-001),
**I want to** self-mint a long-lived MCP API key from `/app/mcp-keys`,
**So that** my coding-agent harness can authenticate to NPL without me ever sharing my personal SSO login.

## Acceptance Criteria

- [ ] Given I am signed in and on `/app/mcp-keys`, when I select "create key" and give it a label, then a new McpApiKey is generated and its raw value is displayed to me exactly once.
- [ ] Given a key was just minted, when I navigate away from or refresh the page, then the raw key value is no longer retrievable anywhere in the UI, leaving only a masked reference.
- [ ] Given I have one or more minted keys, when I view my key list, then I see each key's label, creation date, and last-used timestamp, but never its raw secret again.

## Notes

Feeds directly into the copyable setup command in US-042 and the token exchange in US-043. Compromised keys are handled by revocation in US-045.
