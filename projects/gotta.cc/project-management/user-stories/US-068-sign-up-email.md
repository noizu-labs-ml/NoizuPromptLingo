---
id: US-068
title: "Sign Up with Email"
slug: "sign-up-email"
personas: [P-001, P-002, P-004, P-008]
epic: "Onboarding & Authentication"
priority: "must-have"
complexity: "M"
tags: [auth, signup, email, password, onboarding]
---

# US-068: Sign Up with Email

## User Story

**As a** casual link-follower (P-004),
**I want to** create an account with my email address and a password,
**So that** I can save collections, submit sites, and follow curators without needing a third-party account.

## Acceptance Criteria

- [ ] Given I visit the sign-up page, when I enter a valid email, a display name, and a password meeting minimum requirements (8+ characters), then my account is created and I am redirected to the first-run tutorial (US-070)
- [ ] Given I submit the sign-up form, when the email is already registered, then an error message indicates "An account with this email already exists" without exposing whether a password or OAuth login exists
- [ ] Given account creation succeeds, when I am redirected, then a verification email is sent to my address and a banner prompts me to verify (see US-073)
- [ ] Given I enter a password below the minimum requirement, when I submit, then inline validation shows the requirement before form submission
- [ ] Given sign-up is complete, when I log in for the first time on a new device, then no additional friction is added beyond email/password entry

## Notes

Password storage must use bcrypt or Argon2 — never plain or reversible encryption. Email verification (US-073) should be prompted but not block basic site usage immediately to reduce drop-off. Related: US-069 (OAuth signup), US-073 (email verification), US-070 (first-run tutorial).
