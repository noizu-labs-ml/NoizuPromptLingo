---
id: US-043
title: "Real-Time Presence Indicators on Shared Mockups"
slug: "real-time-presence-indicators"
personas: [P-003, P-002]
epic: "Team & Collaboration"
priority: "could-have"
complexity: "L"
tags: [real-time, presence, collaboration, websocket]
---

# US-043: Real-Time Presence Indicators on Shared Mockups

## User Story

**As a** UX designer (P-003),
**I want to** see who else is currently viewing a mockup in real time,
**So that** I can coordinate live review sessions without scheduling confusion.

## Acceptance Criteria

- [ ] Given a mockup is open, when another user opens the same mockup, then an avatar or initials badge appears in the toolbar indicating their presence
- [ ] Given multiple users are viewing, when one user leaves, then their presence indicator disappears within 10 seconds
- [ ] Given presence indicators, when I hover over an avatar, then I see the user's name and when they joined the session
- [ ] Given a mockup with presence, when a user moves their cursor, then their cursor position is broadcast to other viewers as a colored cursor with name label

## Notes

Requires Phoenix Channels (WebSocket) backend. Cursor broadcasting is optional enhancement; presence itself is the baseline. Presence data should not be persisted — ephemeral only. Consider throttling cursor events to 60ms intervals to reduce server load.
