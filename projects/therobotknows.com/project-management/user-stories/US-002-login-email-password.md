---
id: US-002
title: "Login with Email and Password"
slug: "login-email-password"
personas: [P-001, P-004]
epic: "Onboarding & Authentication"
priority: "must-have"
complexity: "S"
tags: [auth, login, session]
---

# US-002: Login with Email and Password

## User Story

**As an** epic novelist (P-001),
**I want to** log in with my email and password,
**So that** I can access my world bible and continue working where I left off.

## Acceptance Criteria

- [ ] Given I have a verified account, when I submit correct credentials, then I am authenticated and redirected to my Dashboard.
- [ ] Given I submit incorrect credentials, when the form is submitted, then I see "Invalid email or password" without revealing which field is wrong.
- [ ] Given five consecutive failed login attempts, when the sixth attempt occurs, then the account is locked for 15 minutes and I receive a lockout notification email.
- [ ] Given I am authenticated, when my session has been idle for 30 days, then I am automatically logged out and redirected to the login page.

## Notes

Depends on US-001 (sign-up). Session tokens must be stored as HttpOnly cookies. Related: US-003 (OAuth login), US-008 (email verification gate).
