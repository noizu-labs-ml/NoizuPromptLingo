---
id: US-001
title: "Sign Up with Email and Password"
slug: "sign-up-email-password"
personas: [P-005]
epic: "Onboarding & Authentication"
priority: "must-have"
complexity: "S"
tags: [auth, onboarding, registration]
---

# US-001: Sign Up with Email and Password

## User Story

**As a** hobbyist worldbuilder (P-005),
**I want to** create an account using my email address and a password,
**So that** I can start building my worlds without needing a third-party account.

## Acceptance Criteria

- [ ] Given I am on the sign-up page, when I submit a valid email and password (min 8 chars, 1 uppercase, 1 number), then an account is created and I am redirected to email verification.
- [ ] Given I submit an email already in use, when the form is submitted, then an inline error reads "An account with this email already exists."
- [ ] Given I submit a password that does not meet requirements, when the form is submitted, then specific requirement failures are shown inline before submission.
- [ ] Given account creation succeeds, when I am redirected, then a verification email is sent to the address provided.

## Notes

Depends on US-008 (email verification). Passwords must be stored as bcrypt hashes — plain-text storage must never occur. Related: US-002 (login).
