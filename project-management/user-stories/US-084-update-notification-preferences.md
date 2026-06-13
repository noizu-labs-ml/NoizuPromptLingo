---
id: US-084
title: "Update Notification Preferences"
slug: "update-notification-preferences"
personas: [P-001, P-002, P-005, P-006]
epic: "Settings & Administration"
priority: "should-have"
complexity: "S"
tags: [settings, notifications, preferences, email]
---

# US-084: Update Notification Preferences

## User Story

**As a** registered user who wants relevant but not overwhelming alerts (P-001, P-002, P-005, P-006),
**I want to** configure which events trigger email or in-app notifications,
**So that** I stay informed about things I care about without drowning in noise.

## Acceptance Criteria

- [ ] Given account settings, when I navigate to "Notifications", then I see toggles for each notification category: new techniques in watched categories, scan completion, community reply, disclosure updates, and platform announcements
- [ ] Given a notification toggle, when I disable "Scan completion", then I no longer receive email or in-app alerts when my Defender scans finish
- [ ] Given each notification type, when I configure it, then I can independently set delivery channel (email, in-app, both, none)
- [ ] Given email notifications are enabled, when an event fires, then the email includes an unsubscribe link that immediately honors the request without requiring login
- [ ] Given I save preferences, when the change is committed, then a success toast confirms the update and the preference persists across sessions
- [ ] Given notification digest options, when I prefer batched delivery, then I can select daily or weekly digest mode for low-priority notification types

## Notes

Preferences should be per-user, not per-device. Email unsubscribe links must be one-click (CAN-SPAM / GDPR compliance). In-app notification bell should reflect unread count based on enabled in-app categories only.
