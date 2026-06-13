---
id: US-003
title: "Email Verification"
slug: "email-verification"
personas: [P-001, P-004]
epic: "Onboarding & Auth"
priority: "must-have"
complexity: "S"
tags: [auth, email, verification, onboarding]
---

# US-003: Email Verification

## User Story

**As a** newly registered user (P-004),
**I want to** verify my email address by clicking a link sent to my inbox,
**So that** my account is activated and I can access all platform features.

## Acceptance Criteria

- [ ] Given I have registered with email/password, when the registration succeeds, then I receive a verification email within 60 seconds containing a unique link valid for 24 hours
- [ ] Given I click a valid, unexpired verification link, when the page loads, then my email is marked verified, I am logged in, and I am redirected to the onboarding wizard (US-005)
- [ ] Given I click an expired verification link, when the page loads, then I see an informational message explaining the link has expired with a "Resend verification email" button
- [ ] Given I am logged in but unverified, when I visit my dashboard, then a persistent banner prompts me to verify my email with a "Resend email" action
- [ ] Given I request a new verification email, when I submit the resend request, then I receive a new email within 60 seconds and am shown a confirmation message (rate-limited to once per 60 seconds)

## Notes

Verification tokens must be single-use. After verification, the token is invalidated. Related: US-001 (registration), US-002 (OAuth skips this step).
