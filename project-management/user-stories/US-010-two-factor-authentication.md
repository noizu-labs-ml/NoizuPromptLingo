---
id: US-010
title: "Two-Factor Authentication (TOTP)"
slug: "two-factor-authentication"
personas: [P-001, P-007]
epic: "Onboarding & Auth"
priority: "could-have"
complexity: "M"
tags: [auth, 2fa, totp, security]
---

# US-010: Two-Factor Authentication (TOTP)

## User Story

**As an** Enterprise AI Lead (P-007),
**I want to** enable two-factor authentication on my account using an authenticator app,
**So that** my account is protected even if my password is compromised.

## Acceptance Criteria

- [ ] Given I am in Account Settings > Security, when I click "Enable Two-Factor Authentication", then I am shown a QR code and a text seed that I can scan with any TOTP-compatible authenticator app (Google Authenticator, Authy, 1Password).
- [ ] Given I have scanned the QR code, when I enter the 6-digit TOTP code from my authenticator app and click "Verify and enable", then 2FA is activated and I am shown 10 single-use backup codes to store securely.
- [ ] Given 2FA is enabled on my account, when I log in with valid credentials, then I am prompted for a 6-digit TOTP code before the session is established.
- [ ] Given I am prompted for a TOTP code at login, when I enter one of my backup codes instead, then the code is accepted, the backup code is consumed (cannot be reused), and a warning is shown that I have N backup codes remaining.
- [ ] Given I am in Account Settings with 2FA enabled, when I click "Disable 2FA" and confirm with my current password, then 2FA is deactivated and all backup codes are invalidated.

## Notes

Backup codes in AC-2 should be hashed before storage, not stored in plaintext. This feature is lower priority than core auth flows (US-001 to US-004) but is a strong expectation for P-007 enterprise users who may require it for compliance reasons.
