---
id: US-071
title: "Update Display Name and Avatar"
slug: "update-display-name-avatar"
personas: [P-001, P-002, P-005, P-006, P-008]
epic: "Settings & Preferences"
priority: "must-have"
complexity: "S"
tags: [settings, profile, avatar, display-name, account]
---

# US-071: Update Display Name and Avatar

## User Story

**As an** AI hobbyist (P-002),
**I want to** update my display name and profile avatar,
**So that** my community identity reflects how I want to present myself to other members.

## Acceptance Criteria

- [ ] Given I am authenticated and on my account settings page, when I edit my display name and save, then the new name appears on my profile and all my existing content within a short propagation window
- [ ] Given I upload a new avatar image, when it is accepted, then it is resized, stored, and displayed on my profile and beside my content across the site
- [ ] Given I upload an invalid file type or an image exceeding the size limit, when validation runs, then I receive an inline error message specifying the accepted formats and maximum size
- [ ] Given my display name change is saved, when another user views my profile or content, then they see the updated name

## Notes

Display names should allow unicode characters but be sanitized to prevent XSS. Avatars should support JPEG, PNG, and WebP, with a maximum upload size of 5MB, resized server-side to a standard resolution. Consider Gravatar fallback for users who have not uploaded a custom avatar.
