---
id: US-019
title: "Email Verification"
slug: "email-verification"
personas: [P-007]
epic: "Authentication & Onboarding"
priority: "must-have"
complexity: "S"
tags: [auth, email-verification, onboarding, security]
---

# US-019: Email Verification

## User Story

**As a** newly registered client (P-007),
**I want to** verify my email address by clicking a link sent to my inbox,
**So that** my account is activated and Keith can trust that my contact information is valid.

## Acceptance Criteria

- [ ] Given a user completes registration (US-018), when the account is created, then a verification email containing a unique, time-limited link is sent to their registered address.
- [ ] Given the verification link is clicked within 24 hours, when the server validates the token, then the account's email_verified flag is set to true and the user is redirected to the onboarding flow (US-024).
- [ ] Given the verification link has expired (> 24 hours), when clicked, then the user sees an error page with a "Resend verification email" option.
- [ ] Given an unverified user attempts to log in, when auth is evaluated, then they are shown a warning that their email is unverified with an option to resend.
- [ ] Given the resend button is clicked, when the new email is sent, then the previous token is invalidated and a fresh token is issued.

## Notes

Tokens should be cryptographically random (at least 32 bytes, URL-safe base64). Store token hash in DB, not plaintext. Verification email should be sent from a no-reply address with Reply-To set to Keith's email. Related: US-018 (registration), US-022 (password reset uses similar flow), US-015 (transactional email provider).
