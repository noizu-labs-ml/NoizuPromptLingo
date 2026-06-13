---
id: US-045
title: "Receive @-Mention Notifications"
slug: "mention-notifications"
personas: [P-001, P-003, P-006]
epic: "Notifications"
priority: "must-have"
complexity: "S"
tags: [notifications, mentions, core]
---

# US-045: Receive @-Mention Notifications

## User Story

**As a** Prompt Engineer Power User (P-001),
**I want to** receive notifications when I am @-mentioned in a thread,
**So that** I can respond promptly and never miss requests for my input.

## Acceptance Criteria

- [ ] Given I am @-mentioned in a thread, when the mention is posted, then I receive an in-app notification with the thread title, author name, and link to the mention
- [ ] Given an @-mention notification, when I click it, then I am taken directly to the thread with the specific mention highlighted
- [ ] Given @-mention notifications, when I view the notification center, then I see them grouped by thread (mentions in the same thread collapse into one notification)
- [ ] Given I am @-mentioned multiple times in the same thread without responding, when a new mention arrives, then the existing notification updates to show the new count

## Notes

Notifications are generated within 5 seconds of mention. Mentions in private spaces only notify space members. @-mention self-mentions do not generate notifications.