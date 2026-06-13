---
id: US-075
title: "Force-revoke a user's API key"
slug: "force-revoke-user-api-key"
personas: [P-004, P-007]
epic: "Admin & Moderation"
priority: "should-have"
complexity: "S"
tags: [admin, api-keys, security, revocation, moderation]
---

# US-075: Force-Revoke a User's API Key

## User Story

**As a** Startup Founder (P-004),
**I want to** immediately revoke any user's API key from the admin panel,
**So that** I can respond to abuse, security incidents, or account termination without waiting for the user to act.

## Acceptance Criteria

- [ ] Given the admin user detail page, when I click "Revoke" on a user's API key, then a confirmation dialog is shown before the action is executed
- [ ] Given I confirm the revocation, when applied, then all API requests using that key return a 401 within 60 seconds
- [ ] Given a key is force-revoked by an admin, when the key owner attempts to use it, then the error response includes a contact support message rather than a generic auth error
- [ ] Given the force-revoke action, when executed, then an entry is written to the audit log (US-074) with the admin's identity, the affected key ID, the affected user ID, and the timestamp

## Notes

The 60-second propagation SLA matches US-066 (user self-revocation) — the same cache-invalidation path is used. The distinct error message for admin-revoked keys helps users understand they need to contact support rather than assuming their key expired. Audit logging is non-optional for this action.
