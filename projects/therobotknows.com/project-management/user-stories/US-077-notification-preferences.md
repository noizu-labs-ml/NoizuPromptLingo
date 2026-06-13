---
id: US-077
title: "Notification Preferences"
slug: "notification-preferences"
personas: [P-001, P-002, P-003, P-008]
epic: "Settings & Preferences"
priority: "should-have"
complexity: "S"
tags: [settings, notifications, email, collaboration]
---

# US-077: Notification Preferences

## User Story

**As a** collaborator on shared universe projects (P-001, P-002, P-003, P-008),
**I want to** configure which events trigger email or in-app notifications,
**So that** I stay informed about changes that matter to me without being overwhelmed.

## Acceptance Criteria

- [ ] Given I am on Settings > Notifications, when I view the page, then I see toggle controls for each notification category: collaborator edits, consistency check results, AI generation complete, comments/mentions, and billing alerts.
- [ ] Given I disable email notifications for a category, when that event fires, then no email is sent but the in-app notification bell still shows the event.
- [ ] Given I disable all notifications for a category, when that event fires, then neither email nor in-app notification is created.
- [ ] Given I save my notification preferences, when I reload the settings page, then my saved selections are persisted correctly.
- [ ] Given a collaborator edits a canon entry in my universe, when I have that notification enabled, then I receive the notification within 60 seconds of the edit being saved.

## Notes

Related: US-091 (invite collaborators). Notification delivery should be batched for bulk edits — no more than one email per category per 15-minute window per universe.
