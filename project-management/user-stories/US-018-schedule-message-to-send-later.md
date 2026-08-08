---
id: US-018
title: "Schedule a message to send later"
slug: "schedule-message-to-send-later"
personas: [P-001]
epic: "Chat & Collaboration Rooms"
priority: "could-have"
complexity: "M"
tags: [rooms, messaging, scheduling, async]
---

# US-018: Schedule a message to send later

## User Story

**As the** Harness Operator (P-001),
**I want to** compose a message now but have it delivered to the room at a future time I choose,
**So that** I can queue async status updates or reminders without needing to be online when they should land.

## Acceptance Criteria

- [ ] Given Jordan composes a message and sets a future send-at timestamp, when he confirms scheduling, then the message is stored in a pending state and does not appear in the room timeline until that time arrives.
- [ ] Given a scheduled message's send time arrives, when the scheduler processes it, then the message is delivered into the room timeline and triggers the same notification behavior as a live-sent message (per US-021).
- [ ] Given a scheduled message that has not yet sent, when Jordan views his pending scheduled messages, then he can edit its content or send time, or cancel it outright, before it fires.
- [ ] Given a send-at time in the past, when Jordan attempts to schedule a message for it, then the system rejects the request with a validation error and does not create the pending message.

## Notes

Complexity M — requires a durable scheduler/worker process, not just a timestamp flag on the message row. Builds on the base message model from US-016.
