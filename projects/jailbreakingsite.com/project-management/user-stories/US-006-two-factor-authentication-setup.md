---
id: US-006
title: "Two-Factor Authentication Setup"
slug: "two-factor-authentication-setup"
personas: [P-001, P-002, P-005, P-007]
epic: "Onboarding & Authentication"
priority: "should-have"
complexity: "M"
tags: [auth, 2fa, totp, security]
---

# US-006: Two-Factor Authentication Setup

## User Story

**As a** security-conscious user (P-001, P-002, P-005, P-007),
**I want to** enable TOTP-based two-factor authentication on my account,
**So that** my account and any sensitive vulnerability data I access are protected against credential compromise.

## Acceptance Criteria

- [ ] Given I navigate to account security settings, when I choose to enable 2FA, then I am presented with a QR code and manual entry key compatible with standard TOTP apps (Authy, Google Authenticator, 1Password)
- [ ] Given I scan the QR code, when I submit a valid 6-digit TOTP code to confirm setup, then 2FA is activated and I am shown 10 single-use recovery codes to save
- [ ] Given 2FA is enabled on my account, when I log in with valid credentials, then I am prompted for a TOTP code before gaining access
- [ ] Given I have lost my authenticator, when I use a recovery code at the 2FA prompt, then I am logged in, that recovery code is consumed, and I am prompted to re-enroll 2FA

## Notes

Recovery codes must be stored as irreversible hashes server-side. Enterprise tier may enforce 2FA as mandatory for all org members (relates to US-009). Complements US-004.
