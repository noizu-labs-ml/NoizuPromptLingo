---
id: US-006
title: "Password Reset via Email"
slug: "password-reset"
personas: [P-001, P-004]
epic: "Onboarding & Authentication"
priority: "must-have"
complexity: "S"
tags: [auth, password-reset, security]
---

# US-006: Password Reset via Email

## User Story

**As a** fiction podcaster (P-004),
**I want to** reset my password via a link sent to my email,
**So that** I can regain access to my lore archive if I forget my credentials.

## Acceptance Criteria

- [ ] Given I am on the login page, when I click "Forgot password?" and submit my email, then a reset link is sent if the email exists, with a generic success message shown regardless of whether the email is registered (no account enumeration).
- [ ] Given I click the reset link in the email, when the link is valid and not expired, then I am taken to a form to set a new password.
- [ ] Given the reset link is older than 60 minutes, when I click it, then I see "This link has expired — request a new one" and am redirected to the forgot-password page.
- [ ] Given I successfully set a new password, when the form submits, then all existing sessions are invalidated and I am redirected to the login page.

## Notes

Related: US-002 (login). Reset tokens must be single-use and expire after 60 minutes. The system must not reveal whether an email is registered in any response.
