---
id: US-504
title: "Emit task-event and notification records so the inbox and activity feed have content"
slug: "activity-feed-event-producers"
personas: [P-003, P-006]
epic: "UX Foundations"
priority: "must-have"
complexity: "L"
tags: [backend, notifications, activity-feed, producers, data-integrity]
---

# US-504: Emit task-event and notification records so the inbox and activity feed have content

## User Story

**As a** Delivery Lead (P-003) relying on the notification inbox and activity feed, with a Platform Administrator (P-006) accountable for the data behind them,
**I want** ticket moves, session completions, and mentions to write records into `npl_task_events` and `npl_chat_notifications`,
**So that** the inbox and feed stop being readers over permanently empty tables and actually report what happened.

## Acceptance Criteria

- [ ] Given a ticket moved across board stages, when the move commits, then a task-event row is written in the same transaction recording actor, verb, object, scope, and timestamp.
- [ ] Given a work session that reaches a completed status, when the status change commits, then a task-event row is written and appears in that project's activity feed query.
- [ ] Given a chat message that mentions a user, when the message is persisted, then a chat-notification row is written for each mentioned recipient, honoring that recipient's mute and mute-unless-mentioned preference.
- [ ] Given a producer write that fails, when the parent mutation is evaluated, then the mutation and the event write succeed or fail together — no silent event loss and no orphaned event for a rolled-back mutation.
- [ ] Given the inbox and activity feed queries, when run against a project with producer traffic, then they return rows newest-first with a resolvable deep-link target on each row.

## Notes

This story closes **S6** in `work-overhaul.md` §5: nothing currently INSERTs into `npl_task_events` or `npl_chat_notifications`, so the Notifications and Feed tools read permanently empty tables; §6 item 3 places producer wiring in the same wave. UX-PLAN §3.2 screens 48 and 49 depend on it and ship behind the `feature.inbox` flag in fixture mode until producers land (decision D5); §7 places it in Phase 1. Related stories: US-013 (ticket queue activity feed), US-021 (receive and clear room notifications), US-019 (mute and mute-unless-mentioned), US-082 (feed consumption), US-051 (inbox).
