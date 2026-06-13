---
id: US-008
title: "Email Verification"
slug: "email-verification"
personas: [P-001, P-006]
epic: "Onboarding & Authentication"
priority: "must-have"
complexity: "S"
tags: [auth, email, verification, security]
---

# US-008: Email Verification

## User Story

**As a** platform admin (P-006),
**I want to** require email verification before users access full platform features,
**So that** spam registrations cannot consume AI generation credits or storage.

## Acceptance Criteria

- [ ] Given I have registered with email/password (US-001), when I attempt to access any feature beyond the verification prompt, then I am redirected to a "Please verify your email" gate page.
- [ ] Given I am on the verification gate, when I click "Resend verification email," then a new email is sent and the button is disabled for 60 seconds to prevent flooding.
- [ ] Given I click the verification link in the email, when the link is valid and not expired (24 hours), then my account is marked verified and I am redirected to the first-run experience (US-005).
- [ ] Given the verification link is expired, when I click it, then I see an option to request a new link without needing to re-enter my email.

## Notes

OAuth accounts (US-003) bypass this flow. Verification tokens expire after 24 hours. Related: US-001, US-006. Admin (P-006) can manually verify accounts via the admin panel.
