---
id: US-021
title: "Receive a room notification and clear it"
slug: "receive-room-notification-and-clear-it"
personas: [P-001, P-002]
epic: "Chat & Collaboration Rooms"
priority: "must-have"
complexity: "S"
tags: [rooms, notifications, mvp, agent-ux]
---

# US-021: Receive a room notification and clear it

## User Story

**As the** Harness Operator (P-001) or the Autonomous Coding Agent (P-002),
**I want to** receive a notification when something relevant happens in a room I follow, and clear it once seen,
**So that** I can stay on top of activity without manually re-scanning every room.

## Acceptance Criteria

- [ ] Given a new message posts in a room Jordan or Sable follows and the room is not muted (per US-019), when the message is created, then a notification is generated and appears in that participant's notification list.
- [ ] Given Sable polls its notifications via MCP, when it fetches unread notifications, then it receives structured data including room ID, message ID, and a brief content preview, sufficient to decide whether to act without opening the full room.
- [ ] Given a notification exists in Jordan's list, when he marks it read/clears it, then it is removed from his unread count and does not reappear on subsequent fetches.
- [ ] Given multiple unread notifications across several rooms, when Jordan issues a bulk "clear all" action, then all of them are marked read in a single call.

## Notes

Downstream of US-016 (messages create notifications) and US-019 (mute settings gate whether a notification fires at all).
