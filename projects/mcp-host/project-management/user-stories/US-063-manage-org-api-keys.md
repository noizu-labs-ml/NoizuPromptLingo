---
id: US-063
title: "Manage API keys at organization level"
slug: "manage-org-api-keys"
personas: [P-002, P-006]
epic: "Organization Management"
priority: "must-have"
complexity: "M"
tags: [organization, api-keys, authentication, credentials]
---

# US-063: Manage API Keys at Organization Level

## User Story

**As a** Platform Engineer (P-002),
**I want to** create and manage API keys at the organization level with configurable scopes and expiration,
**So that** my team can authenticate MCP client connections using org-scoped credentials that I can rotate and revoke centrally.

## Acceptance Criteria

- [ ] Given the user has the admin or developer role (US-062), when they navigate to the organization API keys page, then they can create a new API key by specifying a name, scope (read-only, read-write, admin), and optional expiration date.
- [ ] Given a new API key is created, when the system generates it, then the full key value is displayed once with a warning that it cannot be retrieved again, and only the key prefix is stored for future identification.
- [ ] Given the user is viewing the API keys list, when they view an active key, then they see: the key prefix, name, scope, creation date, expiration date (if set), last used timestamp, and actions to revoke or rotate.
- [ ] Given the admin revokes an API key, when the revocation takes effect, then all active sessions using that key are terminated within 30 seconds and subsequent requests using the key receive a 401 response.
- [ ] Given an API key has an expiration date, when the expiration date is within 7 days, then the system sends a notification to the key creator and org admins prompting rotation.
- [ ] Given the organization has API usage limits (US-068), when API key usage approaches the limit, then the system logs a warning and the key detail page displays current usage against the limit.

## Notes

API keys are the primary auth mechanism for MCP client systems (P-008) connecting to hosted endpoints. Keys should follow the principle of least privilege with scoped permissions. Related: US-061, US-062, US-068.
