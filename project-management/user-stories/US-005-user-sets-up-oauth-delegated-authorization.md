---
id: US-005
title: "User sets up OAuth 2.1 delegated authorization for a downstream service"
slug: "user-sets-up-oauth-delegated-authorization"
personas: [P-002, P-004]
epic: "Auth & Onboarding"
priority: "must-have"
complexity: "L"
tags: [auth, oauth, delegation, credentials]
---

# US-005: User Sets Up OAuth 2.1 Delegated Authorization for a Downstream Service

## User Story

**As a** Platform Engineer (P-002) or AI/ML Engineer (P-004),
**I want to** authorize MCP Host as an OAuth delegate for a downstream service (e.g., Gmail, Slack),
**So that** MCP tools can access the service on my behalf with explicitly scoped permissions, without MCP Host ever storing my raw credentials.

## Acceptance Criteria

- [ ] Given the "Connected Services" settings page, when the user clicks "Connect a Service" and selects a supported provider (e.g., Gmail), then the system redirects to the provider's OAuth consent screen with MCP-scoped permissions requested.
- [ ] Given the user grants consent at the provider, when the OAuth callback is received, then the system stores an encrypted refresh token (never the user password), records the granted scopes, and marks the service as connected.
- [ ] Given a connected downstream service, when an MCP tool invocation requires access, then the system retrieves a scoped access token using the encrypted refresh token, narrows the token scope to the minimum required by the caller's policy, and uses it for the downstream call.
- [ ] Given a user who wants to revoke delegation, when they click "Disconnect" on a connected service, then the system deletes the encrypted refresh token, revokes the token at the provider, and all MCP tools using that service immediately fail with a clear "service disconnected" error.
- [ ] Given the connected services list, when the user views a connected service, then the system displays the granted scopes, the connection date, the last time the token was used, and which MCP tools have accessed it.

## Notes

This is the core of the "no credential forwarding" security invariant. MCP Host never sees or stores user passwords for downstream services. Refresh tokens are encrypted at rest with a per-organization key, rotated on use, and revocable per-caller. Related to US-004 (API keys), US-007 (dual-principal), and the SafeMCP product surface.
