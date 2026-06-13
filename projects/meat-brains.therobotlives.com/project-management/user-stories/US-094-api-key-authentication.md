---
id: US-094
title: "API Authentication with API Keys"
slug: "api-key-authentication"
personas: [P-005, P-007, P-003]
epic: "Integration & API"
priority: "should-have"
complexity: "M"
tags: [api, authentication, api-keys, security, developer]
---

# US-094: API Authentication with API Keys

## User Story

**As an** Indie Developer (P-005) or Enterprise AI Lead (P-007),
**I want to** authenticate API requests using a personal API key,
**So that** I can access authenticated endpoints (voting, submitting, user-specific data) programmatically from my applications.

## Acceptance Criteria

- [ ] Given a logged-in user visits their account settings, when they navigate to the API section, then they can generate a new API key with a custom label (e.g., "My automation script")
- [ ] Given an API key is generated, when it is displayed to the user, then it is shown exactly once in full; subsequent views show only the last 4 characters with a regenerate option
- [ ] Given a developer includes a valid API key in the `Authorization: Bearer {key}` header, when the request is processed, then it is treated as authenticated with the key owner's permissions
- [ ] Given a developer's API key is compromised, when they revoke it in settings, then all subsequent requests using that key return HTTP 401 immediately
- [ ] Given an API key is used, when the request is processed, then the usage (timestamp, endpoint, IP) is logged and visible in the user's API usage dashboard

## Notes

API keys should be stored as bcrypt hashes — only the key prefix should be stored in plain text for identification. Keys should have no expiration by default but support optional expiry dates. Rate limits for authenticated API requests should be higher than anonymous limits to incentivize key use. Depends on US-093.
