---
id: US-011
title: "Sign up for securamcp.com account"
slug: "sign-up-for-account"
personas: [P-001, P-002, P-004]
epic: "Onboarding & Authentication"
priority: "must-have"
complexity: "S"
tags: [auth, registration, onboarding, email]
---

# US-011: Sign up for securamcp.com account

## User Story

**As a** startup founder (P-004),
**I want to** create a securamcp.com account using my email address,
**So that** I can access the mockup generation service and manage my team's API keys.

## Acceptance Criteria

- [ ] Given a valid email and password meeting complexity requirements, when the signup form is submitted, then an account is created and a verification email is sent within 60 seconds
- [ ] Given an already-registered email address, when signup is attempted, then a clear error is shown without revealing whether an account exists (security: no user enumeration)
- [ ] Given the verification email, when the verification link is clicked within 24 hours, then the account is activated and the user is redirected to the onboarding wizard (US-015)
- [ ] Given the verification link has expired, when it is clicked, then a "resend verification" option is presented

## Notes

Password requirements: minimum 8 characters, at least one uppercase, one digit. Magic-link (passwordless) signup is a future enhancement. Related to US-012, US-013, US-015.
