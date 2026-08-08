---
id: US-016
title: "Send a message with a threaded reply"
slug: "send-message-with-threaded-reply"
personas: [P-001, P-002]
epic: "Chat & Collaboration Rooms"
priority: "must-have"
complexity: "S"
tags: [rooms, messaging, threading, mvp]
---

# US-016: Send a message with a threaded reply

## User Story

**As the** Harness Operator (P-001) or the Autonomous Coding Agent (P-002),
**I want to** reply to a specific message inside a thread,
**So that** related discussion stays grouped together instead of getting lost in the room's main timeline.

## Acceptance Criteria

- [ ] Given an existing message in a room, when a user or agent posts a reply referencing that message's ID, then the reply is stored with a parent-message link and renders nested under the parent when the thread is displayed.
- [ ] Given a thread with multiple replies, when any participant fetches the room timeline, then top-level messages show a reply count, and the thread can be expanded to view all replies in chronological order.
- [ ] Given Sable (P-002) posts a threaded reply through its MCP session, when the reply is created, then it is attributed to Sable's persona identity rather than a generic system or service account.
- [ ] Given a reply that references a parent message ID from a different room, when the reply is submitted, then the system rejects it rather than creating a cross-room thread link.

## Notes

Depends on US-015 (a room must exist first). Threading is the base primitive that pinning (US-017), highlighting (US-020), and notifications (US-021) build on top of.
