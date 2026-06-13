---
id: US-067
title: "Edit Profile (Name, Email, Avatar)"
slug: "edit-profile"
personas: [P-001, P-002, P-004]
epic: "Settings & Account"
priority: "must-have"
complexity: "M"
tags: [settings, profile, avatar, account, edit]
---

# US-067: Edit Profile (Name, Email, Avatar)

## User Story

**As a** indie lifestyle blogger (P-001),
**I want to** edit my profile name, email address, and avatar,
**So that** my public profile accurately represents my brand and my account details stay current.

## Acceptance Criteria

- [ ] Given I navigate to /settings/profile, when the page loads, then I see editable fields for: display name, email address, bio (max 280 chars), and an avatar upload zone
- [ ] Given I upload a new avatar, when the upload completes, then I see a live preview of the image cropped to a circle before I save
- [ ] Given I change my email address, when I save, then a verification email is sent to the new address and the change is not applied until confirmed
- [ ] Given I save profile changes, when the save succeeds, then I see a success toast and the updated information is reflected immediately across my public profile page
- [ ] Given I enter a bio longer than 280 characters, when I try to save, then an inline validation error prevents submission and shows the character count remaining (e.g., "-12 chars")
- [ ] Given I upload an avatar image, when the file size exceeds 5MB, then an inline error message rejects the file before upload begins

## Notes

Display name and bio appear on the public profile page. Email change requires verification to prevent account takeover. Avatar is stored in object storage; crop is applied server-side. See US-068 for password change, US-070 for privacy settings.
