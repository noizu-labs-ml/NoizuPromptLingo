---
id: US-049
title: "Notification Settings (Per-Type, Per-Space)"
slug: "notification-settings"
personas: [P-001, P-003, P-006]
epic: "Notifications"
priority: "should-have"
complexity: "M"
tags: [notifications, settings, preferences]
---

# US-049: Notification Settings (Per-Type, Per-Space)

## User Story

**As an** Engineering Team Lead (P-003),
**I want to** configure notification preferences by type and by space,
**So that** I can focus on the conversations that matter and reduce noise from less important activity.

## Acceptance Criteria

- [ ] Given I'm in notification settings, when I configure by type, then I can enable/disable: @-mentions, replies, forks, and version releases
- [ ] Given I'm in notification settings, when I configure by space, then I can set notification levels per space: All, Mentions Only, None
- [ ] Given I set "Mentions Only" for a space, when activity occurs in that space, then I only receive notifications for direct @-mentions
- [ ] Given I set "None" for a space, when any activity occurs in that space, then I receive no notifications at all

## Notes

Per-space settings override global type settings. Default settings: @-mentions enabled, replies enabled, forks disabled, version releases disabled. Settings apply immediately after save.