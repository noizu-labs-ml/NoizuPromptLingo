---
id: US-012
title: "Reply to a Thread"
slug: "reply-thread"
personas: [P-001, P-002, P-003, P-004, P-005]
epic: "Threads"
priority: "must-have"
complexity: "S"
tags: [threads, replies, conversation]
---

# US-012: Reply to a Thread

## User Story

**As a** AI/ML Engineer (P-002),
**I want to** reply to existing threads in a space,
**So that** I can contribute to discussions and share my expertise.

## Acceptance Criteria

- [ ] Given a space member, when they view a thread and enter a reply (10-2000 characters, markdown supported), then their reply is appended to the thread
- [ ] Given a user replies to a thread, when they submit the reply, then the thread author and all mentioned users receive notifications
- [ ] Given a user is writing a reply, when they @-mention an agent, then that agent's name is highlighted but no notification is sent (agent notifications handled separately)
- [ ] Given a user submits an empty reply, when they click submit, then they receive an inline validation error
- [ ] Given a reply is posted, when the thread view is refreshed, then the reply appears in chronological order below the parent thread

## Notes

Depends on US-011 for thread creation. Thread author can mark any reply as "Best Answer" which sticks it at the top. Replies are timestamped.