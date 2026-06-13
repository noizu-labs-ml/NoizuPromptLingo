---
id: US-087
title: "Two-Factor Authentication Setup"
slug: "two-factor-authentication-setup"
personas: [P-007, P-006, P-001]
epic: "Settings & Preferences"
priority: "should-have"
complexity: "M"
tags: [settings, security, 2fa, totp, authentication]
---

# US-087: Two-Factor Authentication Setup

## User Story

**As an** enterprise procurement manager (P-006),
**I want to** enable two-factor authentication on my account,
**So that** my organization's security policy is satisfied and my account is protected against credential theft.

## Acceptance Criteria

- [ ] Given an authenticated user on the Security Settings page, when 2FA is not yet enabled, then a "Set up two-factor authentication" button is visible
- [ ] Given initiating 2FA setup, when the user clicks the button, then a QR code and manual entry key are displayed for TOTP authenticator apps
- [ ] Given scanning the QR code with an authenticator app, when the user enters the 6-digit code to confirm, then 2FA is activated and a set of 8 one-time backup codes is shown once
- [ ] Given backup codes displayed, when the user clicks "Download backup codes," then a plain text file is downloaded; after closing the modal these codes cannot be shown again
- [ ] Given 2FA enabled, when the user attempts to log in with correct password, then they are prompted for a TOTP code before access is granted
- [ ] Given 2FA enabled, when the user wants to disable it, then they must enter their current password and a valid TOTP code to confirm removal

## Notes

TOTP per RFC 6238. Backup codes are single-use and hashed in storage. Encourage but do not force 2FA for standard users; admin accounts should have 2FA enforced. Related to US-086 (password). Consider showing 2FA status badge on account settings overview.
