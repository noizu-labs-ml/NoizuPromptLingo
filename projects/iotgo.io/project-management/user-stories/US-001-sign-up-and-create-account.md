---
id: US-001
title: "Sign Up and Create Account"
slug: "sign-up-and-create-account"
personas: [P-001, P-004]
epic: "Onboarding & Fleet Connection"
priority: "must-have"
complexity: "S"
tags: [onboarding, auth, registration]
---

# US-001: Sign Up and Create Account

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** sign up for an IoTGo account using my work email,
**So that** I can begin connecting my fleet and deploying AI agents.

## Acceptance Criteria

- [ ] Given I visit the IoTGo homepage, when I click "Get Started," then I am presented with a registration form requiring name, work email, and password.
- [ ] Given I submit a valid registration form, when the system processes it, then I receive a verification email and am redirected to an email-confirmation pending screen.
- [ ] Given I click the verification link in my email, when the token is valid, then my account is activated and I am redirected to the onboarding wizard.
- [ ] Given I attempt to register with an already-registered email, when I submit the form, then I see a clear error message directing me to log in or reset my password.

## Notes

This is the entry point for all personas. The onboarding wizard initiated after verification is covered in US-002. Password requirements must meet enterprise minimums (12+ chars, complexity).
