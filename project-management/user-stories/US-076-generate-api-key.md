---
id: US-076
title: "Generate API Key from Account Settings"
slug: "generate-api-key"
personas: [P-001, P-006]
epic: "API & Integration"
priority: "must-have"
complexity: "S"
tags: [api, authentication, settings, developer]
---

# US-076: Generate API Key from Account Settings

## User Story

**As a** security researcher and API consumer (P-001, P-006),
**I want to** generate and manage API keys from my account settings,
**So that** I can authenticate programmatic requests to the catalog and defender APIs without exposing my login credentials.

## Acceptance Criteria

- [ ] Given I am on the account settings page, when I click "Generate API Key", then a new key is created and displayed once in full (not truncated)
- [ ] Given a key has been generated, when I view the API keys list, then I see the key name, creation date, last used date, and a masked preview (first 8 chars only)
- [ ] Given I want to scope a key, when I create it, then I can assign permissions (read-only catalog, defender scan, write/submit) independently
- [ ] Given I have an existing key, when I click "Revoke", then the key is immediately invalidated and a confirmation is shown
- [ ] Given a key is displayed after creation, when I navigate away, then the full key is no longer retrievable (user must copy it at creation time)
- [ ] Given an org plan, when a member generates a key, then org admins can see and revoke all member keys

## Notes

Keys should follow a prefixed format (e.g., `jbs_live_...`) for easy identification in logs and secret scanners. Maximum of 10 active keys per user on free tier, 50 on paid.
