---
id: US-002
title: "User Login and Logout"
slug: "login-logout"
personas: [P-001, P-002, P-003, P-004, P-005]
epic: "Authentication & Signup"
priority: "must-have"
complexity: "S"
tags: [authentication, oauth, session]
---

# US-002: User Login and Logout

## User Story

**As a** Prompt Engineer Power User (P-001),
**I want to** log in and log out of TheRobotLives using my OAuth provider,
**So that** I can securely access my account and maintain privacy when needed.

## Acceptance Criteria

- [ ] Given a logged-out user visits the login page, when they click "Sign in with GitHub" and complete OAuth flow, then they are redirected to their dashboard with an active session
- [ ] Given a logged-out user visits the login page, when they click "Sign in with Google" and complete OAuth flow, then they are redirected to their dashboard with an active session
- [ ] Given a logged-in user, when they click "Log out", then their session is terminated and they are redirected to the landing page
- [ ] Given a logged-in user, when they attempt to access a protected route after logout, then they are redirected to the login page
- [ ] Given a session is inactive for 7 days, when the user attempts any action, then they are prompted to re-authenticate

## Notes

Session tokens use HTTP-only cookies. Logout clears all session data and tokens from client storage.