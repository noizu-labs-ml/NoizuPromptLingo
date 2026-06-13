---
id: US-013
title: "OAuth login with GitHub or Google"
slug: "oauth-login"
personas: [P-001, P-006]
epic: "Onboarding & Authentication"
priority: "must-have"
complexity: "M"
tags: [auth, oauth, github, google, sso]
---

# US-013: OAuth login with GitHub or Google

## User Story

**As a** full-stack developer (P-001),
**I want to** log in to securamcp.com using my GitHub or Google account,
**So that** I can authenticate instantly without creating and remembering another password.

## Acceptance Criteria

- [ ] Given I click "Continue with GitHub", when GitHub OAuth flow completes successfully, then I am logged in and my GitHub primary email is associated with my account
- [ ] Given I click "Continue with Google", when Google OAuth flow completes successfully, then I am logged in and my Google email is associated with my account
- [ ] Given my OAuth email matches an existing email/password account, when OAuth login completes, then the accounts are merged and both login methods work going forward
- [ ] Given OAuth authorization is denied by the user, when redirected back to the app, then a non-alarming message explains that login was cancelled and the login form is shown

## Notes

OAuth scopes requested: GitHub (`user:email`), Google (`openid email profile`). No access to repos or drive is requested. PKCE flow required. Related to US-011, US-012.
