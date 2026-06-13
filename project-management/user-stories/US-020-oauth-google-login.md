---
id: US-020
title: "OAuth — Google Sign-In"
slug: "oauth-google-login"
personas: [P-007, P-001, P-002]
epic: "Authentication & Onboarding"
priority: "should-have"
complexity: "M"
tags: [auth, oauth, google, sso, onboarding]
---

# US-020: OAuth — Google Sign-In

## User Story

**As a** client who prefers not to manage another password (P-007),
**I want to** sign in with my Google account,
**So that** I can access the client portal without creating and remembering a separate credential.

## Acceptance Criteria

- [ ] Given a visitor navigates to `/auth/login` or `/auth/signup`, when the page renders, then a "Continue with Google" button is visible.
- [ ] Given the "Continue with Google" button is clicked, when the OAuth flow completes, then the user is authenticated and redirected to the dashboard (or onboarding if first login).
- [ ] Given a user signs in with Google whose email matches an existing password account, when OAuth completes, then the accounts are linked and the user can use either method going forward.
- [ ] Given a user signs in with Google for the first time, when the OAuth callback is processed, then a new account is created with email_verified = true (Google email is pre-verified).
- [ ] Given the OAuth provider is temporarily unavailable, when the user clicks Google sign-in, then an error message is shown and the password login option remains accessible.

## Notes

Use NextAuth.js or Auth.js with the Google provider. Ensure GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET are managed via environment secrets (Infisical). Scope requested: email, profile only — no Drive or other sensitive scopes. Related: US-018 (registration), US-021 (login), US-025 (session management).
