---
id: US-052
title: "Update User Profile Details"
slug: "update-user-profile-details"
personas: [P-001]
epic: "Settings & Preferences"
priority: "could-have"
complexity: "S"
tags: [profile, self-service, account]
---

# US-052: Update User Profile Details

## User Story

**As a** Harness Operator, Jordan Vance (P-001),
**I want to** update my own user profile details (display name, avatar, contact info),
**So that** my identity is accurately represented to teammates and in audit/activity logs.

## Acceptance Criteria

- [ ] Given Jordan is on his profile page, when he updates his display name and saves, then the new name is reflected across the app (room posts, member lists, audit entries) without requiring re-login.
- [ ] Given Jordan uploads a new avatar image, when the upload completes, then the new avatar renders in place of the old one within the same session.
- [ ] Given Jordan enters an invalid value for a validated field (e.g., malformed email), when he attempts to save, then the form shows a field-level error and the invalid change is not persisted.

## Notes

Self-service and org-independent; distinct from admin-driven role/suspension actions in the Admin & Platform Operations epic.
