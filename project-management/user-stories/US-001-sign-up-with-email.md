---
id: US-001
title: "Sign Up with Email"
slug: "sign-up-with-email"
personas: [P-002, P-008]
epic: "Onboarding & Auth"
priority: "must-have"
complexity: "M"
tags: [auth, onboarding, registration]
---

# US-001: Sign Up with Email

## User Story

**As an** AI Hobbyist (P-002),
**I want to** create an account using my email address and a password,
**So that** I can participate in the Meat Brains community by submitting and voting on prompts.

## Acceptance Criteria

- [ ] Given I am on the registration page, when I submit a valid email and password (min 8 chars, 1 uppercase, 1 number), then an account is created and I receive a verification email.
- [ ] Given I submit a registration form, when the email address already exists in the system, then I see an error message stating the email is already registered and a link to sign in.
- [ ] Given I submit a registration form, when the password does not meet complexity requirements, then I see inline validation errors specifying which requirements are unmet.
- [ ] Given I submit a valid registration form, when the account is created, then I am redirected to an email verification prompt and cannot perform write actions until verified.

## Notes

Depends on email verification flow (US-004). Password requirements should be displayed inline before submission to reduce friction for new users (P-008). Rate limiting should be applied to this endpoint to prevent abuse.
