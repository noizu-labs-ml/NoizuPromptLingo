---
id: US-073
title: "Manage Notification Settings"
slug: "manage-notification-settings"
personas: [P-001, P-002, P-005, P-006, P-007]
epic: "Settings & Preferences"
priority: "should-have"
complexity: "M"
tags: [settings, notifications, preferences, email, in-app]
---

# US-073: Manage Notification Settings

## User Story

**As an** enterprise AI lead (P-007),
**I want to** manage my notification settings from a single settings page,
**So that** I receive alerts through the right channels at the right frequency without being overwhelmed.

## Acceptance Criteria

- [ ] Given I navigate to notification settings, when the page loads, then I see all notification categories with toggles for in-app and email delivery independently
- [ ] Given I disable email for a specific category, when an event in that category fires, then no email is sent but the in-app notification still appears per its own toggle
- [ ] Given I enable a weekly digest option, when events accumulate during the week, then a single digest email is sent rather than individual emails
- [ ] Given I save changes, when the page reloads, then all my settings are correctly reflected

## Notes

This story builds on the notification preference model defined in US-059 and surfaces it in the account settings UI context. Categories should include at minimum: replies, mentions, follows, upvotes on my content, moderation actions, and community announcements. Unsubscribe links in emails must route directly to this settings page.
