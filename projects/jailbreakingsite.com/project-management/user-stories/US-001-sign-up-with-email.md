---
id: US-001
title: "Sign Up with Email"
slug: "sign-up-with-email"
personas: [P-001, P-006]
epic: "Onboarding & Authentication"
priority: "must-have"
complexity: "S"
tags: [auth, registration, email]
---

# US-001: Sign Up with Email

## User Story

**As a** security professional new to the platform (P-001, P-006),
**I want to** create an account using my email address and a password,
**So that** I can access the jailbreak catalog and begin my research.

## Acceptance Criteria

- [ ] Given I visit the sign-up page, when I submit a valid email and password meeting complexity requirements, then my account is created and I am redirected to the email verification step
- [ ] Given I submit a sign-up form, when the email address is already registered, then I receive a clear error message with an option to log in or reset my password
- [ ] Given I submit a sign-up form, when the password does not meet minimum requirements (12 chars, mixed case, number or symbol), then inline validation errors are shown before submission
- [ ] Given successful account creation, when I land on the verification step, then a verification email is sent within 30 seconds

## Notes

Depends on US-003 (email verification) for the post-registration flow. Password requirements should align with NIST SP 800-63B guidelines given the security-professional audience.
