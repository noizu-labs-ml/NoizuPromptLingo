---
id: US-083
title: "Generate and Manage API Keys"
slug: "generate-manage-api-keys"
personas: [P-007]
epic: "API & Integration"
priority: "must-have"
complexity: "M"
tags: [api, authentication, developer, keys, account]
---

# US-083: Generate and Manage API Keys

## User Story

**As an** API Developer (P-007),
**I want to** generate and manage API keys from my account dashboard,
**So that** I can authenticate programmatic access to the gotta.cc directory data without using my personal credentials.

## Acceptance Criteria

- [ ] Given I am logged in and on the API settings page, when I click "Generate New Key," then a new API key is created and displayed once in full — it is not retrievable again after leaving the page
- [ ] Given I have generated an API key, when I view my API keys list, then I see each key's label, creation date, last-used date, and current rate limit tier — but not the full key value
- [ ] Given I want to revoke an API key, when I click "Revoke" and confirm, then the key is immediately invalidated and any subsequent requests using it receive a 401 response
- [ ] Given I have multiple API keys, when I label each key during creation, then the label appears in usage dashboards so I can distinguish keys by application
- [ ] Given my account tier does not include API access, when I visit the API settings page, then I see an upgrade prompt explaining which subscription tier unlocks API access

## Notes

API key generation is the entry gate for the entire API & Integration epic. Store only the hashed key server-side; display the plaintext key exactly once at creation. Related to US-088 (rate limiting and usage dashboard) and US-091 (Creator tier analytics).
