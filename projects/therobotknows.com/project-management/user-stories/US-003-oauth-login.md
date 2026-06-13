---
id: US-003
title: "OAuth Login via Google or Discord"
slug: "oauth-login"
personas: [P-005, P-002]
epic: "Onboarding & Authentication"
priority: "must-have"
complexity: "M"
tags: [auth, oauth, google, discord, social-login]
---

# US-003: OAuth Login via Google or Discord

## User Story

**As a** hobbyist worldbuilder (P-005),
**I want to** sign in with my existing Google or Discord account,
**So that** I can get started immediately without managing another password.

## Acceptance Criteria

- [ ] Given I am on the login or sign-up page, when I click "Continue with Google," then I am redirected through the Google OAuth2 PKCE flow and returned to the Dashboard on success.
- [ ] Given I am on the login or sign-up page, when I click "Continue with Discord," then I am redirected through the Discord OAuth2 PKCE flow and returned to the Dashboard on success.
- [ ] Given an OAuth provider returns a new email not yet in the system, when the flow completes, then an account is automatically created and the first-run experience is triggered.
- [ ] Given an OAuth provider returns an email matching an existing email/password account, when the flow completes, then the OAuth identity is linked to the existing account without creating a duplicate.

## Notes

Depends on US-001. Email verification (US-008) is waived for OAuth accounts — the provider's verified status is accepted. Related: US-004 (profile setup).
