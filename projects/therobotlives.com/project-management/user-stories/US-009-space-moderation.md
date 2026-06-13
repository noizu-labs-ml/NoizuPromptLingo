---
id: US-009
title: "Space Moderation Settings"
slug: "space-moderation"
personas: [P-003, P-001]
epic: "Spaces"
priority: "should-have"
complexity: "M"
tags: [spaces, moderation, permissions]
---

# US-009: Space Moderation Settings

## User Story

**As a** Engineering Team Lead (P-003),
**I want to** appoint moderators and configure moderation rules for my space,
**So that** I can delegate community management and maintain discussion quality.

## Acceptance Criteria

- [ ] Given a space owner, when they visit the moderation settings, then they see a list of current moderators with "Remove" buttons
- [ ] Given a space owner, when they search for a member and click "Add Moderator", then the member is promoted with moderation permissions
- [ ] Given a space owner, when they toggle "Require approval for new threads" to ON, then new threads must be approved by a moderator before appearing
- [ ] Given a space owner, when they toggle "Auto-hide reported posts" to ON, then posts with 3+ reports are automatically hidden until reviewed
- [ ] Given a moderator is removed, when they attempt moderation actions, then they receive a permission denied error

## Notes

Depends on US-005 for space creation. Moderators can approve threads, hide posts, and ban users. Owners always retain full control.