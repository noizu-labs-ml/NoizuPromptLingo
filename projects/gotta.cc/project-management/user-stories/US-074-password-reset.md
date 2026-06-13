---
id: US-074
title: "Password Reset"
slug: "password-reset"
personas: [P-001, P-002, P-004, P-008]
epic: "Onboarding & Authentication"
priority: "must-have"
complexity: "S"
tags: [auth, password, reset, security, email]
---

# US-074: Password Reset

## User Story

**As a** returning user (all personas),
**I want to** reset my password via email if I have forgotten it,
**So that** I can regain access to my account without losing my collections or submission history.

## Acceptance Criteria

- [ ] Given I am on the login page, when I click "Forgot password?", then I am taken to a password reset request form where I enter my email address
- [ ] Given I submit my email for a reset, when the email is found in the system, then a reset email is sent within 60 seconds with a link valid for 1 hour
- [ ] Given I submit an email not registered in the system, when the form processes, then the UI shows the same "check your email" confirmation message (no email enumeration)
- [ ] Given I click a valid reset link, when the reset page loads, then I can enter and confirm a new password meeting minimum requirements
- [ ] Given I successfully reset my password, when the change is saved, then all existing sessions for that account are invalidated and I am redirected to the login page with a success message

## Notes

Session invalidation on password reset is a security requirement — all previously issued auth tokens must be revoked. Reset links must be single-use. The anti-enumeration response (same message regardless of email existence) is a deliberate security choice. Related: US-068 (email signup), US-073 (email verification).
