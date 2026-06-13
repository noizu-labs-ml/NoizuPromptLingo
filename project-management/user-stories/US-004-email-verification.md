---
id: US-004
title: "Email Verification"
slug: "email-verification"
personas: [P-002, P-008]
epic: "Onboarding & Auth"
priority: "must-have"
complexity: "S"
tags: [auth, email, verification, onboarding]
---

# US-004: Email Verification

## User Story

**As an** AI Newcomer (P-008),
**I want to** verify my email address after registering,
**So that** my account is secured and I can access full community features.

## Acceptance Criteria

- [ ] Given I have registered with email/password, when the account is created, then a verification email containing a unique time-limited link (expires in 24 hours) is sent to my registered address.
- [ ] Given I click the verification link in my email, when the link is valid and unexpired, then my email is marked as verified, I am logged in, and I am redirected to the profile setup flow (US-005).
- [ ] Given I click a verification link, when the link has expired, then I see an error message with a button to resend a new verification email.
- [ ] Given I am logged in but unverified, when I attempt to submit a prompt or cast a vote, then I see a banner prompting me to verify my email and a resend link, and the action is blocked.
- [ ] Given I request a resend, when I have already requested one in the past 5 minutes, then the resend button is disabled with a countdown timer to prevent email flooding.

## Notes

Unverified users can browse all content in read-only mode. The 24-hour expiry and resend throttle are both configurable via environment variables. Depends on US-001 for registration flow.
