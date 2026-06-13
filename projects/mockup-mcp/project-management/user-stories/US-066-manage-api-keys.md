---
id: US-066
title: "Manage API keys (create, revoke, rename)"
slug: "manage-api-keys"
personas: [P-001, P-004, P-006, P-008]
epic: "Settings & Preferences"
priority: "must-have"
complexity: "M"
tags: [api-keys, security, settings, authentication, credentials]
---

# US-066: Manage API Keys

## User Story

**As a** Full-Stack Developer (P-001),
**I want to** create, rename, and revoke API keys from my account settings,
**So that** I can manage credentials for different integrations and quickly disable compromised keys.

## Acceptance Criteria

- [ ] Given the API keys settings page, when I create a new key, then the full key value is displayed exactly once (on creation) and never shown again; only a masked preview is stored
- [ ] Given an existing key, when I rename it with a descriptive label, then the new name is reflected in the key list immediately
- [ ] Given an existing key, when I revoke it, then all subsequent API requests using that key return a 401 within 60 seconds of revocation
- [ ] Given the key list, when displayed, then each key shows its label, creation date, last-used date, and masked prefix (e.g., `sk-mock-****abcd`)

## Notes

Key values must never be recoverable after initial display — implement with one-way hash storage. Revocation SLA of 60 seconds accommodates cache TTLs. Related to US-074 (audit log) and US-075 (admin force-revoke).
