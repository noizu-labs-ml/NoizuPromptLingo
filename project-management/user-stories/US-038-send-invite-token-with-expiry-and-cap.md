---
id: US-038
title: "Send an Invite Token with Expiry and Use Cap"
slug: "send-invite-token-with-expiry-and-cap"
personas: [P-004]
epic: "Onboarding & Auth"
priority: "must-have"
complexity: "S"
tags: [invites, organizations, security]
---

# US-038: Send an Invite Token with Expiry and Use Cap

## User Story

**As the** Org Owner (P-004),
**I want to** generate an invite token with a configurable expiry and a maximum-use cap,
**So that** I can bring new members into my organization without issuing a credential that stays valid forever or for unlimited signups.

## Acceptance Criteria

- [ ] Given I am on my organization's members page, when I generate an invite with an expiry (e.g., 7 days) and a use cap (e.g., 5 uses), then a hashed invite token is created and the raw token value is shown to me exactly once.
- [ ] Given an invite token has reached its configured use cap, when a new user attempts to redeem it, then redemption is rejected with a clear "invite exhausted" error and no additional member is added.
- [ ] Given an invite token's expiry has passed, when a user attempts to redeem it, then redemption is rejected with a clear "invite expired" error even if unused capacity remains.

## Notes

The redeeming side of this flow is covered in US-039. Only the hashed form of the token is ever stored server-side.
