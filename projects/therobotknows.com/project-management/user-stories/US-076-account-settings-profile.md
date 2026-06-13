---
id: US-076
title: "Account Settings & Profile Management"
slug: "account-settings-profile"
personas: [P-001, P-002, P-003, P-004, P-005, P-008]
epic: "Settings & Preferences"
priority: "must-have"
complexity: "M"
tags: [settings, profile, account, authentication]
---

# US-076: Account Settings & Profile Management

## User Story

**As a** registered user (P-001, P-002, P-003, P-004, P-005, P-008),
**I want to** manage my account profile including display name, avatar, email, and password,
**So that** my identity is accurate and my account remains secure.

## Acceptance Criteria

- [ ] Given I am logged in, when I navigate to Settings > Account, then I see fields for display name, email, avatar upload, and password change.
- [ ] Given I update my display name, when I save, then my new name appears in the nav header and any universe collaborator lists within 5 seconds.
- [ ] Given I upload an avatar image, when the file exceeds 5MB or is not PNG/JPG/WebP, then an inline error message is shown and the upload is rejected.
- [ ] Given I request a password change, when I submit my current password and a new password meeting complexity rules, then a confirmation email is sent and the password is updated.
- [ ] Given I change my email address, when I save, then a verification email is sent to the new address and the change does not take effect until verified.

## Notes

Depends on US-001 (sign-up) and US-002 (login). Avatar storage should use the same CDN pipeline as universe cover images. Password complexity: min 8 chars, 1 uppercase, 1 number.
