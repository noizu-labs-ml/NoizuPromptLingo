---
id: US-043
title: "In-App Messaging Thread with Keith"
slug: "in-app-messaging-thread"
personas: [P-007, P-001, P-002, P-003]
epic: "Support & Communication"
priority: "must-have"
complexity: "L"
tags: [messaging, communication, thread, real-time]
---

# US-043: In-App Messaging Thread with Keith

## User Story

**As an** active client who prefers structured async communication (P-007),
**I want to** send and receive messages with Keith in a persistent in-app thread,
**So that** I have a searchable, organized record of all project communications that isn't fragmented across email threads.

## Acceptance Criteria

- [ ] Given I navigate to a project's Messages section, when the page loads, then I see the full chronological message thread between myself and Keith
- [ ] Given I type a message and click Send, when it is submitted, then it appears in the thread immediately and Keith receives a notification
- [ ] Given Keith replies to my message, when I am viewing the thread, then his reply appears without requiring a page refresh
- [ ] Given I receive a new message while on another page of the dashboard, when a message arrives, then an unread count badge updates on the Messages nav item
- [ ] Given I send a message outside business hours, when I submit, then I see an auto-response indicating expected response times

## Notes

Messaging is per-project (not a global inbox). Consider a global messages view that aggregates unread messages across all projects. Message content should support markdown. Real-time updates via WebSocket or SSE; fallback to polling acceptable at MVP. File attachments covered separately in US-044. This is different from support tickets (US-039) — tickets are formal, tracked issue flows; messages are conversational.
