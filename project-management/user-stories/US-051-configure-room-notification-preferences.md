---
id: US-051
title: "Configure Notification Preferences for a Room"
slug: "configure-room-notification-preferences"
personas: [P-001]
epic: "Settings & Preferences"
priority: "could-have"
complexity: "S"
tags: [notifications, rooms, preferences]
---

# US-051: Configure Notification Preferences for a Room

## User Story

**As a** Harness Operator, Jordan Vance (P-001),
**I want to** configure my notification preferences on a per-room basis,
**So that** I only get alerted about the chat rooms I actively care about instead of being flooded by every project's activity.

## Acceptance Criteria

- [ ] Given Jordan is viewing a room's settings panel, when he mutes notifications for that room, then he stops receiving alerts for new messages in that room while other rooms are unaffected.
- [ ] Given Jordan sets a room's preference to "mentions only," when another member posts a message that does not @-mention him, then no notification is generated; when a message does @-mention him, then a notification is generated.
- [ ] Given Jordan has customized preferences across several rooms, when he reloads the app or logs in from a new session, then his per-room preferences persist and apply identically.

## Notes

Scoped to notification delivery only; does not affect room membership or read access.
