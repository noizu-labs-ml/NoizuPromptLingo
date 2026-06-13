---
id: US-012
title: "Log in with email and password"
slug: "log-in-email-password"
personas: [P-001, P-002, P-003, P-004]
epic: "Onboarding & Authentication"
priority: "must-have"
complexity: "S"
tags: [auth, login, session, security]
---

# US-012: Log in with email and password

## User Story

**As a** full-stack developer (P-001),
**I want to** log in to securamcp.com with my email and password,
**So that** I can access my API keys, usage dashboard, and saved mockups.

## Acceptance Criteria

- [ ] Given valid credentials, when the login form is submitted, then I am redirected to my dashboard within 2 seconds and a session cookie is set with `HttpOnly` and `Secure` flags
- [ ] Given invalid credentials, when login is attempted, then a generic "Invalid email or password" error is shown (no enumeration) and no session is created
- [ ] Given 5 consecutive failed login attempts within 10 minutes, when a sixth attempt is made, then the account is temporarily locked and an unlock email is sent
- [ ] Given a successful login, when I close and reopen the browser, then my session persists for 30 days unless explicitly logged out

## Notes

Session tokens are JWT signed with RS256, stored as `HttpOnly` cookies. Refresh token rotation is handled server-side by Phoenix. Related to US-011, US-013.
