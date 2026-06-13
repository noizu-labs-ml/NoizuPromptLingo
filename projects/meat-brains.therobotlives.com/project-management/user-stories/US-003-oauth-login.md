---
id: US-003
title: "OAuth Login via GitHub and Google"
slug: "oauth-login"
personas: [P-001, P-003, P-005]
epic: "Onboarding & Auth"
priority: "must-have"
complexity: "M"
tags: [auth, oauth, github, google, onboarding]
---

# US-003: OAuth Login via GitHub and Google

## User Story

**As an** Indie Developer (P-005),
**I want to** sign in using my existing GitHub or Google account,
**So that** I can join the community without managing another password.

## Acceptance Criteria

- [ ] Given I am on the login or registration page, when I click "Continue with GitHub", then I am redirected to GitHub's OAuth authorization page with the correct scopes (email, read:user).
- [ ] Given I complete GitHub/Google OAuth authorization, when I return to Meat Brains for the first time, then an account is automatically created using my provider email and display name, and I am directed to the profile setup flow (US-005).
- [ ] Given I complete GitHub/Google OAuth authorization, when an account with my provider email already exists (created via email/password), then the OAuth identity is linked to the existing account and I am logged in.
- [ ] Given I deny or cancel the OAuth authorization, when I am redirected back to Meat Brains, then I see an informational message and remain on the login page without an error state.
- [ ] Given I am logged in via OAuth, when I visit account settings, then I can see which OAuth providers are linked and can add or remove providers (provided at least one auth method remains).

## Notes

GitHub OAuth is highest priority given the developer-heavy audience (P-001, P-005). Google serves broader user acquisition. Account linking behavior in AC-3 prevents duplicate account creation and should match on verified email only.
