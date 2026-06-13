---
id: US-014
title: "Generate API key for MCP server authentication"
slug: "generate-api-key"
personas: [P-001, P-004, P-006]
epic: "Onboarding & Authentication"
priority: "must-have"
complexity: "S"
tags: [auth, api-key, mcp, security, credentials]
---

# US-014: Generate API key for MCP server authentication

## User Story

**As a** full-stack developer (P-001),
**I want to** generate a named API key from my account settings,
**So that** I can authenticate the MCP server with my AI coding assistant using a credential I can rotate or revoke independently.

## Acceptance Criteria

- [ ] Given I am logged in, when I navigate to API Keys settings and click "New Key", then a key name prompt is shown and a new key is generated on confirmation
- [ ] Given the key is generated, when the creation dialog is displayed, then the full key value is shown exactly once with a copy button and a warning that it will not be shown again
- [ ] Given I have an existing key, when I click "Revoke", then the key is invalidated within 60 seconds and any active MCP connections using that key receive a 401 on their next request
- [ ] Given I have multiple keys, when I view the API Keys list, then I see each key's name, creation date, last-used timestamp, and revoke button — but never the key value

## Notes

Key format: `smcp_live_` prefix followed by 40 random URL-safe characters. Up to 10 active keys per account on the free tier. Key names are user-defined and should be used to identify the environment (e.g., "Claude Code - laptop"). Related to US-001, US-016, US-017.
