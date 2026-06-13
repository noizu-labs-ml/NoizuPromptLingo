---
id: US-018
title: "User Registration & Sign Up"
slug: "user-registration-signup"
personas: [P-007, P-001, P-002]
epic: "Authentication & Onboarding"
priority: "must-have"
complexity: "M"
tags: [auth, registration, sign-up, accounts]
---

# US-018: User Registration & Sign Up

## User Story

**As a** new client who has just been engaged by Keith (P-007),
**I want to** create an account on noizu.com,
**So that** I can access the client dashboard, track my engagement, and manage support requests.

## Acceptance Criteria

- [ ] Given a visitor navigates to `/auth/signup`, when the page loads, then a form with Email, Password, Confirm Password, and First/Last Name fields is rendered.
- [ ] Given a visitor submits the form with valid data, when the account is created, then an email verification link is sent (US-019) and the user sees a "Check your email" screen.
- [ ] Given a visitor submits the form with a password under 12 characters, when validation runs, then an inline error is shown specifying the minimum length requirement.
- [ ] Given a visitor submits with an email already registered, when the server responds, then a user-friendly message is shown that does not confirm or deny whether the email exists (to prevent account enumeration).
- [ ] Given a visitor submits valid data, when the account is created, then the password is stored as a bcrypt/argon2 hash — never plaintext.
- [ ] Given a visitor is on the signup page, when they prefer OAuth, then they can choose "Continue with Google" as an alternative (US-020).

## Notes

Registration should be invite-gated or admin-approved in v1 — not open public registration, as this is a private client portal, not a SaaS product. Consider magic link as an alternative to password-based auth for simplicity. Related: US-019 (email verification), US-020 (OAuth), US-023 (terms acceptance).
