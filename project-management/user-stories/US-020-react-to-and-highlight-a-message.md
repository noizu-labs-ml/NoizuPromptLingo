---
id: US-020
title: "React to and highlight a message"
slug: "react-to-and-highlight-a-message"
personas: [P-007]
epic: "Chat & Collaboration Rooms"
priority: "could-have"
complexity: "S"
tags: [rooms, messaging, reactions, review]
---

# US-020: React to and highlight a message

## User Story

**As the** Design & Code Reviewer (P-007),
**I want to** add an emoji reaction to a message and highlight a specific span of text within it,
**So that** I can give lightweight feedback during a review discussion without writing a full reply.

## Acceptance Criteria

- [ ] Given a message in a room Sofia is reviewing, when she adds an emoji reaction, then the reaction attaches to the message and its aggregated count/avatar summary becomes visible to all room members.
- [ ] Given the same message already carries a reaction of that emoji from another user, when Sofia reacts with the same emoji, then her reaction merges into the existing group's count rather than appearing as a duplicate entry.
- [ ] Given a message containing text, when Sofia selects a substring and applies a highlight, then the highlighted span is visibly marked for other room members viewing that message.
- [ ] Given Sofia has already reacted to a message, when she clicks her own reaction again, then it toggles off and removes her from that reaction group.

## Notes

Distinct from pinning (US-017): reactions and highlights are lightweight, per-message annotations rather than room-wide persistent state.
