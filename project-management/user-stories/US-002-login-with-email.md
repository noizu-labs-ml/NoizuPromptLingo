---
id: US-002
title: "Login with Email and Password"
slug: "login-with-email"
personas: [P-001, P-002, P-005]
epic: "Onboarding & Auth"
priority: "must-have"
complexity: "S"
tags: [auth, login, session]
---

# US-002: Login with Email and Password

## User Story

**As a** Prompt Engineer (P-001),
**I want to** log in to my account using my email and password,
**So that** I can access my submissions, voting history, and community features.

## Acceptance Criteria

- [ ] Given I am on the login page, when I enter a valid email and correct password, then I am authenticated and redirected to the home feed.
- [ ] Given I am on the login page, when I enter an incorrect password, then I see a generic error message ("Invalid email or password") without revealing which field is wrong, and the attempt is logged.
- [ ] Given a user has failed login 5 times in 10 minutes, when they attempt another login, then they are shown a CAPTCHA challenge before the form is processed.
- [ ] Given I am logged in, when I navigate to a protected page after my session expires, then I am redirected to the login page with a return URL preserved so I land back at my intended destination after re-authenticating.

## Notes

Session management details are covered in US-009. The generic error message on failure is intentional to prevent user enumeration attacks. Return URL preservation is critical for deep-link sharing workflows common among P-001 and P-005.
