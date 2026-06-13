---
id: US-004
title: "User creates an API key with policy binding"
slug: "user-creates-api-key-with-policy-binding"
personas: [P-001, P-004]
epic: "Auth & Onboarding"
priority: "must-have"
complexity: "M"
tags: [auth, api-key, policy, credentials]
---

# US-004: User Creates an API Key with Policy Binding

## User Story

**As a** MCP Tool Developer (P-001) or AI/ML Engineer (P-004),
**I want to** create an API key with an attached policy that defines which tools the key holder can invoke,
**So that** I can grant scoped, auditable access to AI agents without exposing full user credentials.

## Acceptance Criteria

- [ ] Given the API key management page, when the user clicks "Create API Key," then the system presents a form for key name, allowed tools (glob patterns), denied tools, rate limit, and whether user context is required.
- [ ] Given a completed API key form, when the user submits it, then the system generates a unique key prefixed with `mcp_live_`, binds the policy document to the key, and displays the key once with a warning that it cannot be retrieved again.
- [ ] Given an API key with `require_user_context: true`, when an AI agent uses the key, then the system requires a valid user token alongside the API key to authorize the request (dual-principal mode).
- [ ] Given the API key list, when the user selects an existing key, then the system displays the key metadata (name, creation date, last used, policy summary) but never the secret value.
- [ ] Given an existing API key, when the user clicks "Revoke," then the system immediately invalidates the key and all active sessions using it are terminated within 30 seconds.

## Notes

API keys are the primary authentication mechanism for machine callers (AI agents). Each key is bound to a policy document at creation time (see the policy YAML structure in the README). This is a core dependency for US-006 (agent authentication). Related to US-006, US-007, US-008.
