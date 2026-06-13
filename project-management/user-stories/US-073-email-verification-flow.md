---
id: US-073
title: "Email Verification Flow"
slug: "email-verification-flow"
personas: [P-001, P-002, P-004, P-008]
epic: "Onboarding & Authentication"
priority: "must-have"
complexity: "S"
tags: [auth, email, verification, onboarding, security]
---

# US-073: Email Verification Flow

## User Story

**As a** new user (all personas),
**I want to** verify my email address after signing up,
**So that** my account is secure and I can receive important notifications about my collections and submissions.

## Acceptance Criteria

- [ ] Given I create an email/password account, when sign-up succeeds, then a verification email is sent within 60 seconds containing a one-time verification link valid for 24 hours
- [ ] Given I click the verification link in the email, when it is valid and unexpired, then my email is marked verified and I am redirected to the app with a success banner
- [ ] Given my email is unverified, when I attempt to submit a site or create a public collection, then I am shown a prompt to verify my email first, with a "Resend verification email" button
- [ ] Given my verification link has expired, when I click it, then an error page is shown with a one-click option to send a new verification email
- [ ] Given I change my email address in settings, when the change is saved, then a new verification email is sent to the new address and the old address is retained until verification completes

## Notes

Email verification should not block browsing or adding to private collections — only gate public-facing contributions (submissions, public collections) to reduce spam. Tokens should be single-use and invalidated on click. Related: US-068 (email signup), US-074 (password reset).
