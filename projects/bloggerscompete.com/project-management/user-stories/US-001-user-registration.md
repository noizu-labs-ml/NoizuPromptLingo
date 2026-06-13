---
id: US-001
title: "User Registration with Email"
slug: "user-registration"
personas: [P-001, P-004]
epic: "Onboarding & Auth"
priority: "must-have"
complexity: "M"
tags: [auth, onboarding, registration]
---

# US-001: User Registration with Email

## User Story

**As a** new blogger (P-004),
**I want to** register for an account using my email address and a password,
**So that** I can access the platform and start submitting my blog.

## Acceptance Criteria

- [ ] Given I am on the registration page, when I submit a valid email and password (min 8 chars, 1 uppercase, 1 number), then my account is created and I am redirected to the email verification step
- [ ] Given I submit an email that is already registered, when the form is submitted, then I see an inline error "An account with this email already exists" and am offered a login link
- [ ] Given I submit a password shorter than 8 characters, when the form is submitted, then I see a specific password requirement error before the request is sent
- [ ] Given registration succeeds, when my account is created, then a verification email is sent to my address within 60 seconds
- [ ] Given I have not verified my email, when I attempt to submit a blog URL, then I see a prompt to verify my email first

## Notes

Password requirements: minimum 8 characters, at least one uppercase letter, at least one number. Related: US-002 (OAuth registration), US-003 (email verification). Free tier is applied by default on account creation.
