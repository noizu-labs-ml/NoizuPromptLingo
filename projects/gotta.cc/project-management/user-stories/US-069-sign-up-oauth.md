---
id: US-069
title: "Sign Up with OAuth (GitHub / Google)"
slug: "sign-up-oauth"
personas: [P-002, P-008, P-007]
epic: "Onboarding & Authentication"
priority: "must-have"
complexity: "M"
tags: [auth, oauth, github, google, signup, social-login]
---

# US-069: Sign Up with OAuth (GitHub / Google)

## User Story

**As a** indie web developer (P-002),
**I want to** sign up and log in using my GitHub or Google account,
**So that** I can start using gotta.cc without creating and managing another password.

## Acceptance Criteria

- [ ] Given I visit the sign-up or login page, when I click "Continue with GitHub" or "Continue with Google", then I am redirected to the provider's OAuth consent screen
- [ ] Given I authorize the OAuth app, when I am redirected back to gotta.cc, then my account is created (or matched to an existing account by email) and I am logged in
- [ ] Given I have signed up via OAuth, when I log in subsequently, then clicking the same provider button immediately logs me in without re-authorizing (using stored refresh token)
- [ ] Given an OAuth account is created, when the first-run flow begins (US-070), then my display name is pre-populated from the provider profile but remains editable
- [ ] Given I attempt OAuth sign-in with an email already registered via email/password, when the accounts are matched, then my existing account is linked to the OAuth provider and I am logged in

## Notes

Account linking by email (last criterion) must be done carefully to avoid account takeover — the link should only happen if the OAuth provider has verified the email. Consider requiring re-entry of the existing password for the initial link. Related: US-068 (email signup), US-070 (first-run tutorial), US-071 (profile setup).
