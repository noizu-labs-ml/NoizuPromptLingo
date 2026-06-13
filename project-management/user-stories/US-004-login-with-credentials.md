---
id: US-004
title: "Login with Credentials"
slug: "login-with-credentials"
personas: [P-001, P-002, P-005, P-006]
epic: "Onboarding & Authentication"
priority: "must-have"
complexity: "S"
tags: [auth, login, credentials]
---

# US-004: Login with Credentials

## User Story

**As a** returning user with an email/password account (P-001, P-002, P-005, P-006),
**I want to** log in with my email and password,
**So that** I can resume my research and access my saved bookmarks and settings.

## Acceptance Criteria

- [ ] Given I submit valid credentials, when authentication succeeds, then I am redirected to my previous page or the catalog dashboard
- [ ] Given I submit invalid credentials, when authentication fails, then I receive a generic error ("Invalid email or password") without revealing which field was incorrect
- [ ] Given I fail authentication 5 consecutive times within 15 minutes, when I attempt a 6th login, then my account is temporarily locked and I receive an unlock email
- [ ] Given I am on a trusted device and check "Remember me", when I return within 30 days, then I am automatically authenticated without re-entering credentials

## Notes

Rate limiting and lockout behavior should be consistent with OWASP authentication guidelines. Complements US-006 (2FA) — if 2FA is enabled, login continues to the 2FA challenge step.
