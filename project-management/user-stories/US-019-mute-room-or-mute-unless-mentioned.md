---
id: US-019
title: "Mute a room or mute unless mentioned"
slug: "mute-room-or-mute-unless-mentioned"
personas: [P-001]
epic: "Chat & Collaboration Rooms"
priority: "should-have"
complexity: "S"
tags: [rooms, notifications, mute, preferences]
---

# US-019: Mute a room or mute unless mentioned

## User Story

**As the** Harness Operator (P-001),
**I want to** mute a noisy chat room entirely, or only silence it unless I'm directly mentioned,
**So that** I can control notification volume without leaving the room or missing time-critical pings.

## Acceptance Criteria

- [ ] Given a room Jordan is a member of, when he sets it to fully muted, then no new-message notifications are generated for him from that room until he unmutes it.
- [ ] Given a room set to mute-unless-mentioned, when a new message posts that does not @-mention Jordan, then no notification fires for him; when a message does @-mention him, then a notification fires normally.
- [ ] Given a muted room, when Jordan opens the room directly, then he still sees the full, unfiltered message history — muting affects notifications only, never visibility or history.
- [ ] Given Jordan changes a room's mute setting, when he reloads his room list, then the updated setting persists and is reflected in the room list's mute indicator.

## Notes

This story's notification-suppression logic is the direct precondition for US-021's "receive and clear" flow — a fully muted room must not generate the notifications described there.
