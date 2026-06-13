---
id: US-003
title: "Email Verification"
slug: "email-verification"
personas: [P-001, P-002, P-005]
epic: "Onboarding & Authentication"
priority: "should-have"
complexity: "S"
tags: [auth, email, verification]
---

# US-003: Email Verification

## User Story

**As a** newly registered user (P-001, P-002, P-005),
**I want to** verify my email address before accessing gated content,
**So that** my account is secured and the platform can send me notifications reliably.

## Acceptance Criteria

- [ ] Given I register with email, when I click the verification link in the email, then my account is marked verified and I am redirected to the onboarding wizard
- [ ] Given a verification email was sent, when I request a resend, then a new link is issued and the old link is invalidated within 5 minutes of the resend
- [ ] Given a verification link is older than 24 hours, when I click it, then I am shown an expiry message with a one-click option to resend a fresh link
- [ ] Given my account is unverified, when I attempt to access authenticated-only features, then I am shown a verification reminder banner with a resend option

## Notes

Unverified accounts may browse public catalog pages but cannot bookmark, export, or access reproduction steps. Depends on US-001 for the registration flow.
