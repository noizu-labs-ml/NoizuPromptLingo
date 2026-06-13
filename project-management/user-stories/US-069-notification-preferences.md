---
id: US-069
title: "Notification Preferences"
slug: "notification-preferences"
personas: [P-001, P-002, P-003]
epic: "Settings & Account"
priority: "should-have"
complexity: "S"
tags: [settings, notifications, email, preferences, account]
---

# US-069: Notification Preferences

## User Story

**As a** indie lifestyle blogger (P-001),
**I want to** control which notifications I receive and how,
**So that** I stay informed about things that matter to me without being bombarded by irrelevant emails.

## Acceptance Criteria

- [ ] Given I navigate to /settings/notifications, when the page loads, then I see a list of notification categories with individual email toggle switches
- [ ] Given the notification categories render, when I view them, then I see at minimum: Score updates, Competition results, Competition reminders (24hr before end), New follower, Platform announcements, and Marketing/tips
- [ ] Given I toggle off a notification category, when I save, then I receive no further emails for that category until I re-enable it
- [ ] Given I toggle off all notifications, when I save, then the system still sends transactional emails (password reset, email verification) regardless of my preferences
- [ ] Given I receive a notification email, when I click "Unsubscribe" in the email footer, then I am taken to a one-click unsubscribe page that disables that specific notification category without requiring me to log in

## Notes

Transactional emails (account security, billing confirmations) must always send regardless of notification preferences — these are not optional. One-click unsubscribe links must use a signed token. See US-067 for profile settings, US-070 for privacy settings.
