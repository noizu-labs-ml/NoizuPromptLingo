---
id: US-097
title: "Virtualize Chat Rooms with Thousands of Messages"
slug: "virtualize-chat-room-many-messages"
personas: [P-001]
epic: "Performance & Scale"
priority: "should-have"
complexity: "M"
tags: [performance, virtualization, chat, scale]
---

# US-097: Virtualize Chat Rooms with Thousands of Messages

## User Story

**As** Jordan Vance, the Harness Operator (P-001),
**I want to** have the chat message list virtualize rendering so only visible messages are mounted in the DOM,
**So that** a room with thousands of historical messages doesn't cause scroll jank or slow page load while I coordinate long-running agent sessions.

## Acceptance Criteria

- [ ] Given a chat room has 5,000-plus messages, when Jordan opens it, then only messages near the current scroll position are mounted in the DOM, verified via DOM node count, not the full history.
- [ ] Given Jordan scrolls rapidly through a long history, when scrolling, then frame rate stays smooth with no multi-second jank spikes as off-screen messages mount and unmount.
- [ ] Given Jordan jumps to "latest" after scrolling deep into history, when the jump occurs, then the view scrolls directly to the newest message without first rendering every intermediate message.
- [ ] Given a message contains rich content such as a code block or image, when it scrolls out of and back into the virtualized window, then it re-renders correctly without losing state that matters.

## Notes

Applies the same "don't render everything at once" principle as US-096 to a different high-volume surface. Reduced-motion (US-095) interacts here too — virtualized mount/unmount should not introduce new animated pop-in for reduced-motion users.
