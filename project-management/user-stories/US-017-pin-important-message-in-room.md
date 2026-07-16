---
id: US-017
title: "Pin an important message in a room"
slug: "pin-important-message-in-room"
personas: [P-003]
epic: "Chat & Collaboration Rooms"
priority: "should-have"
complexity: "S"
tags: [rooms, messaging, pin, moderation]
---

# US-017: Pin an important message in a room

## User Story

**As the** Delivery Lead (P-003),
**I want to** pin a key message to the top of a chat room,
**So that** important decisions or status updates stay visible to the whole team without anyone scrolling back through history.

## Acceptance Criteria

- [ ] Given a message exists in a room Priya has access to, when she pins it, then the message is added to the room's pinned list and surfaced in a persistent pinned-messages panel visible to all members.
- [ ] Given a room already has a pinned message, when Priya pins a second message, then both remain pinned, ordered most-recently-pinned first, unless the room enforces a pin limit, in which case the system reports that limit clearly instead of failing silently.
- [ ] Given a pinned message, when Priya unpins it, then it is removed from the pinned list but remains unchanged in the normal room timeline.
- [ ] Given a member without moderator-level room permissions, when they attempt to pin a message, then the action is rejected with a permissions error.

## Notes

Depends on US-016 (a message must exist to pin). Complements the lighter-weight per-message highlight in US-020 — pins are room-wide and persistent, highlights are not.
