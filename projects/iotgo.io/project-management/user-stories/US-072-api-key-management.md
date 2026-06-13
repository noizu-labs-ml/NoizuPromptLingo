---
id: US-072
title: "API Key Management"
slug: "api-key-management"
personas: [P-001, P-004]
epic: "Settings & Administration"
priority: "must-have"
complexity: "S"
tags: [api, keys, security, integration, admin]
---

# US-072: API Key Management

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** create, label, scope, and revoke API keys for programmatic access to IoTGo,
**So that** I can integrate IoTGo into CI/CD pipelines and external tooling without sharing user credentials and can revoke compromised keys instantly.

## Acceptance Criteria

- [ ] Given I am in the API Keys settings page, when I create a new key, then I can set a name/label, an optional expiry date, and a permission scope (read-only, read-write, admin); the key value is shown once and never again.
- [ ] Given an API key is created, when I view the key list, then I see: label, scope, creation date, expiry date, last used timestamp, and a revoke button — but never the raw key value.
- [ ] Given I revoke an API key, when revocation is confirmed, then any subsequent API request using that key receives a 401 response within seconds.
- [ ] Given an API key is within 7 days of expiry, when I view the key list, then the expiring key is visually flagged and I receive a notification (per US-073 preferences).
- [ ] Given an API key is used from an unexpected IP range (if IP restrictions are configured), when the request is received, then it is rejected and the event is logged in the security audit trail.

## Notes

IP restriction on API keys is a could-have. Key scoping should align with the role permission model defined in US-071. Key values must never be logged server-side.
