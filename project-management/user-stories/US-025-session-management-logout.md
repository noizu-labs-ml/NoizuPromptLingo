---
id: US-025
title: "Session Management & Logout"
slug: "session-management-logout"
personas: [P-007]
epic: "Authentication & Onboarding"
priority: "must-have"
complexity: "M"
tags: [auth, session, logout, security, jwt]
---

# US-025: Session Management & Logout

## User Story

**As a** logged-in client (P-007),
**I want** my session to be secure, appropriately long-lived, and easy to terminate,
**So that** I stay logged in across normal workday use without being forced to re-authenticate constantly, and I can log out cleanly from any device.

## Acceptance Criteria

- [ ] Given a user successfully logs in, when the session is established, then an HTTP-only, Secure, SameSite=Strict cookie is issued (no JWT in localStorage).
- [ ] Given a session is active, when 30 minutes pass without user activity, then the session is silently extended if the user is still on the page; if the tab is closed, the session expires at the configured TTL (default: 7 days).
- [ ] Given a user clicks "Log out", when the action completes, then the session token is invalidated server-side (not just cleared client-side) and the user is redirected to the public homepage.
- [ ] Given a user's password is reset (US-022), when the reset completes, then all active sessions for that account are immediately invalidated.
- [ ] Given a logged-in user navigates to a protected route on a new device, when the session cookie is absent, then they are redirected to `/auth/login?callbackUrl={original-path}` and returned to the intended page after login.
- [ ] Given a session token is replayed after logout, when the server evaluates it, then the request is rejected with HTTP 401.

## Notes

NextAuth.js database adapter (Prisma/PostgreSQL) provides server-side session storage and invalidation. Avoid JWT-only sessions for the client portal — server-side sessions enable instant revocation. "Remember me" is a session-length variant, not a security bypass. Related: US-021 (login), US-022 (password reset), US-020 (OAuth sessions follow same rules).
