---
id: US-004
title: "User Login with Email and Password"
slug: "user-login"
personas: [P-001, P-002, P-003, P-004]
epic: "Onboarding & Auth"
priority: "must-have"
complexity: "S"
tags: [auth, login, session]
---

# US-004: User Login with Email and Password

## User Story

**As a** returning user (P-001),
**I want to** log in with my email and password,
**So that** I can access my dashboard and continue where I left off.

## Acceptance Criteria

- [ ] Given I am on the login page, when I submit my correct email and password, then I am authenticated and redirected to my dashboard
- [ ] Given I submit an incorrect password, when the form is submitted, then I see a generic error "Invalid email or password" (no enumeration of which field is wrong) and the password field is cleared
- [ ] Given I submit incorrect credentials 5 times within 10 minutes, when the fifth attempt fails, then my account is temporarily locked for 15 minutes and I am shown the lockout duration
- [ ] Given my account is locked, when I attempt to log in, then I see the lockout message with remaining time and a link to reset my password
- [ ] Given I am successfully logged in, when I close and reopen the browser, then I remain logged in for up to 30 days (persistent session)

## Notes

Login page must include links to registration (US-001) and password reset (US-007). Account lockout should trigger a notification email. Related: US-002 (OAuth), US-008 (session management).
