---
id: US-013
title: "View a ticket queue's feed of recent activity"
slug: "view-ticket-queue-activity-feed"
personas: [P-003]
epic: "Tickets & Boards"
priority: "should-have"
complexity: "S"
tags: [tickets, activity-feed, oversight]
---

# US-013: View a ticket queue's feed of recent activity

## User Story

**As a** Delivery Lead (P-003),
**I want to** view a chronological feed of recent activity across a ticket queue,
**So that** I can catch up on what changed — stage moves, comments, assignments — without opening every ticket individually.

## Acceptance Criteria

- [ ] Given a queue with 20 tickets and activity across the last 24 hours (stage moves, field edits, comments), when Priya opens the queue's activity feed, then events are listed newest-first with actor, ticket reference, and a human-readable description of the change.
- [ ] Given a stage move made per US-007, when it occurs, then a corresponding entry appears in the feed within the same request/response cycle, with no significant lag.
- [ ] Given a feed with more than one page of events, when Priya scrolls or requests the next page, then older events load without duplicating or skipping entries already shown.
- [ ] Given a queue Priya doesn't have access to, when she requests its activity feed, then the call is rejected with an authorization error.

## Notes

Aggregates events already produced by other stories (US-007 stage moves, US-008 sprint assignment, US-009/US-010 linking) into one read surface; this story is read/aggregation-only and does not define new mutation events.
