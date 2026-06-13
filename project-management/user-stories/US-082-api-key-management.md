---
id: US-082
title: "API Key Management"
slug: "api-key-management"
personas: [P-003, P-007]
epic: "Settings & Preferences"
priority: "should-have"
complexity: "M"
tags: [settings, api, developer, integration, security]
---

# US-082: API Key Management

## User Story

**As a** developer or technical user integrating with the platform (P-003, P-007),
**I want to** create, name, scope, and revoke API keys from my account settings,
**So that** I can securely integrate the platform with external tools, scripts, and AI agents without exposing my account credentials.

## Acceptance Criteria

- [ ] Given I am on Settings > API Keys, when I click "Create new key," then I can enter a label and select permission scopes (read-only, read-write, generation-only), and the full key is shown exactly once upon creation.
- [ ] Given I have created an API key, when I return to the API Keys list, then I see the key label, creation date, last-used timestamp, and scope, but never the full key value.
- [ ] Given I click "Revoke" on an active API key, when I confirm the action, then the key is immediately invalidated and any in-flight requests using it return 401.
- [ ] Given an API key is used to make a request, when the request is processed, then the last-used timestamp for that key is updated within 5 minutes.
- [ ] Given I am on a free plan, when I view the API Keys page, then key creation is disabled with a message indicating API access requires a paid plan.

## Notes

Relates to P-007 (Nova, AI Agent) use cases. Keys should be prefixed with a recognizable string (e.g., `trk_`) for easy identification in logs. Related: US-079 (generation budget) — API-driven generation must also be budget-gated.
