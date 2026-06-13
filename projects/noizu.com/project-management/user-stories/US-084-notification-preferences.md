---
id: US-084
title: "Notification Preferences"
slug: "notification-preferences"
personas: [P-007, P-001, P-002]
epic: "Settings & Preferences"
priority: "should-have"
complexity: "S"
tags: [settings, notifications, email, preferences]
---

# US-084: Notification Preferences

## User Story

**As an** existing client with an active engagement (P-007),
**I want to** control which notifications I receive and how often email digests arrive,
**So that** I stay informed about project updates without being overwhelmed by irrelevant messages.

## Acceptance Criteria

- [ ] Given an authenticated user on the Notification Preferences page, then they see toggles for: project milestone updates, new comments on shared documents, RFI status changes, weekly digest emails, and research paper announcements
- [ ] Given each notification toggle, when the user changes its state and saves, then the preference is persisted and future notifications respect the setting
- [ ] Given the email digest frequency selector, when the user selects Daily, Weekly, or Never, then digest emails are scheduled accordingly
- [ ] Given all notification channels disabled, when a triggering event occurs, then no email is sent for that user
- [ ] Given the preferences page, when it loads, then the current saved preferences are reflected accurately in the UI state

## Notes

Email digests aggregate all pending notifications into a single email at the chosen frequency. In-app notification bell (US-028 or similar) is a separate concern. Related to US-083 (profile), US-085 (privacy). Unsubscribe link in all emails must honor the "Never" digest setting per CAN-SPAM.
