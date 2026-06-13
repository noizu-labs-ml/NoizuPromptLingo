---
id: US-007
title: "Password Reset via Email"
slug: "password-reset"
personas: [P-002, P-008]
epic: "Onboarding & Auth"
priority: "must-have"
complexity: "S"
tags: [auth, password, reset, email]
---

# US-007: Password Reset via Email

## User Story

**As an** AI Hobbyist (P-002),
**I want to** reset my password via a link sent to my email,
**So that** I can regain access to my account if I forget my credentials.

## Acceptance Criteria

- [ ] Given I am on the login page, when I click "Forgot password?" and submit my email address, then I receive a password reset email within 2 minutes containing a unique, time-limited link (expires in 1 hour).
- [ ] Given I click a valid, unexpired reset link, when I submit a new password meeting complexity requirements, then my password is updated, all existing sessions are invalidated, and I am redirected to the login page with a success message.
- [ ] Given I submit an email address that does not exist in the system, when the form is submitted, then I see the same confirmation message as a valid email ("If an account exists, you'll receive a reset email") to prevent email enumeration.
- [ ] Given a reset link has already been used or has expired, when I try to access it, then I see an error message with a link to request a new reset email.

## Notes

All active sessions must be invalidated on password change to prevent session hijacking scenarios. The anti-enumeration response in AC-3 is a security requirement. Password reset requests should be rate-limited to 3 per hour per email address.
