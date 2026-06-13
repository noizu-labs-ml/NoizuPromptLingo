---
id: US-083
title: "Account Settings — Profile (Name, Email, Avatar, Company)"
slug: "account-settings-profile"
personas: [P-007, P-001, P-002, P-003]
epic: "Settings & Preferences"
priority: "must-have"
complexity: "M"
tags: [settings, profile, account, avatar, onboarding]
---

# US-083: Account Settings — Profile

## User Story

**As an** existing client with an active engagement (P-007),
**I want to** update my profile information including name, email, avatar, and company,
**So that** the portal reflects my current details and Keith can identify me correctly.

## Acceptance Criteria

- [ ] Given an authenticated user on the Account Settings page, when they view the Profile tab, then they see editable fields for display name, email address, company name, and job title
- [ ] Given the profile form, when the user uploads a new avatar image, then the image is cropped to a circle preview and saved on confirmation
- [ ] Given a valid profile form submission, when the user clicks Save, then changes are persisted and a success toast is displayed
- [ ] Given an email address change, when the user submits, then a verification email is sent to the new address and the old address remains active until confirmed
- [ ] Given a required field (display name) left empty, when the form is submitted, then an inline validation error appears and submission is blocked
- [ ] Given avatar upload, when the file exceeds 2MB or is not an image format, then a clear error message is shown

## Notes

Avatar storage: object storage (S3-compatible). Email change requires re-verification to prevent account takeover. Related to US-086 (change password), US-087 (2FA). Company and job title are optional but aid Keith in client context.
