# Chat Room View

| Field | Value |
|-------|-------|
| **ID** | `chat-room-view` |
| **Type** | Primary |
| **Category** | Collaboration |
| **User Stories** | US-016, US-017, US-018, US-020, US-051, US-095, US-097 |

## Description

Single chat room at `/app/[orgId]/chat/[roomId]` for real-time messaging, including threaded replies, pinning, scheduled sends, reactions, and per-room notification preferences. Virtualizes rendering to stay responsive with thousands of messages and respects reduced-motion preferences.

## Key Components

- **Message Timeline (Virtualized)** — windowed rendering for large rooms (US-097)
- **Message Composer** — send box with threaded-reply and schedule-send controls (US-016, US-018)
- **Pinned Message Rail** — surfaces pinned messages above the timeline (US-017)
- **Reaction Picker** — emoji reactions and highlight toggle on a message (US-020)
- **Room Notification Preferences Panel** — per-room notification settings (US-051)
- **Reduced-Motion Aware Transition** — animation layer that respects prefers-reduced-motion (US-095)

## Interactions

- User types a reply and selects a parent message → threaded reply posts under it (US-016)
- User picks a future time in the composer → message queues and sends at that time (US-018)
- User pins a message via its context menu → it appears in the Pinned Message Rail (US-017)
- User reacts to a message → Reaction Picker updates the message's reaction summary (US-020)
- User opens the Room Notification Preferences Panel and adjusts settings → persists per-room (US-051)

## Navigation

- Accessible from: Chat Room List (22)
- Links to: Ticket Detail (26) or Artifact Detail (32) when a message references those entities
