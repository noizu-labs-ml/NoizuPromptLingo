---
id: US-022
title: "Password Reset"
slug: "password-reset"
personas: [P-007]
epic: "Authentication & Onboarding"
priority: "must-have"
complexity: "S"
tags: [auth, password-reset, security, email]
---

# US-022: Password Reset

## User Story

**As a** client who has forgotten my password (P-007),
**I want to** reset it via a link sent to my registered email,
**So that** I can regain access to my account without contacting Keith directly.

## Acceptance Criteria

- [ ] Given a visitor navigates to `/auth/forgot-password`, when the page loads, then an email input field and Submit button are rendered.
- [ ] Given a registered email is submitted, when the server processes the request, then a password reset email is sent with a unique, time-limited link (valid for 1 hour).
- [ ] Given an unregistered email is submitted, when the server processes the request, then the same success message is shown ("Check your email") — the response must not reveal whether the email is registered.
- [ ] Given the reset link is clicked within 1 hour, when the page loads, then the user is prompted to enter and confirm a new password.
- [ ] Given a new password is submitted successfully, when the update completes, then the reset token is invalidated, all existing sessions for that account are terminated, and the user is redirected to login.
- [ ] Given the reset link has expired, when clicked, then the user sees an error with a link to request a new reset email.

## Notes

Reset tokens must be single-use — invalidate immediately upon use. Timing-safe comparison should be used when validating tokens. Session termination on password reset prevents hijacked sessions from persisting. Related: US-019 (similar token flow), US-021 (login), US-025 (session management).
