---
id: US-021
title: "User Login"
slug: "user-login"
personas: [P-007]
epic: "Authentication & Onboarding"
priority: "must-have"
complexity: "S"
tags: [auth, login, session, security]
---

# US-021: User Login

## User Story

**As a** returning client (P-007),
**I want to** log in to noizu.com with my email and password,
**So that** I can access my dashboard and engagement details.

## Acceptance Criteria

- [ ] Given a visitor navigates to `/auth/login`, when the page loads, then Email and Password fields plus a Submit button are rendered.
- [ ] Given valid credentials are submitted, when authentication succeeds, then the user is redirected to the dashboard (or the originally requested protected route via `callbackUrl`).
- [ ] Given invalid credentials are submitted, when authentication fails, then a generic error ("Invalid email or password") is shown — the message does not reveal which field is incorrect.
- [ ] Given 5 consecutive failed login attempts for an email, when the sixth attempt occurs, then the account is temporarily locked for 15 minutes and the user is informed.
- [ ] Given a user is logged in, when they navigate to `/auth/login`, then they are automatically redirected to the dashboard.
- [ ] Given the login form is submitted, when the request is in flight, then the Submit button is disabled to prevent duplicate submissions.

## Notes

Account lockout should alert Keith via email if it occurs more than 3 times in an hour (potential brute force). Consider "Remember me" checkbox for 30-day session extension. Related: US-020 (OAuth alternative), US-022 (password reset), US-025 (session management).
