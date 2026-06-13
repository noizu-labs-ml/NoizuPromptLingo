---
id: US-007
title: "Password Reset via Email"
slug: "password-reset"
personas: [P-001, P-002, P-003, P-004]
epic: "Onboarding & Auth"
priority: "must-have"
complexity: "S"
tags: [auth, password, reset, security]
---

# US-007: Password Reset via Email

## User Story

**As a** returning user (P-002),
**I want to** reset my password via a link sent to my email,
**So that** I can regain access to my account if I forget my password.

## Acceptance Criteria

- [ ] Given I am on the login page, when I click "Forgot password?", then I am taken to a password reset request form with an email field
- [ ] Given I submit my registered email address, when the request is processed, then I receive a password reset email within 60 seconds containing a unique link valid for 1 hour (regardless of whether the email exists, I see "If an account exists, you'll receive an email shortly")
- [ ] Given I click a valid, unexpired reset link, when the page loads, then I am shown a form to enter and confirm a new password meeting the same requirements as registration
- [ ] Given I submit a valid new password, when the reset completes, then my password is updated, the reset token is invalidated, all existing sessions are terminated, and I am redirected to the login page with a success message
- [ ] Given I click an expired or already-used reset link, when the page loads, then I see an error message and a button to request a new reset link

## Notes

Response to the reset request form must be identical whether or not the email is registered (prevents account enumeration). OAuth-only accounts (US-002) should be identified by a message: "Your account uses Google/GitHub login — password reset is not available." Related: US-001, US-004, US-008.
