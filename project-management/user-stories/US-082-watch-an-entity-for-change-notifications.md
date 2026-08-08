---
id: US-082
title: "Watch an Entity for Change Notifications"
slug: "watch-an-entity-for-change-notifications"
personas: [P-001, P-003]
epic: "Social & Collaboration"
priority: "should-have"
complexity: "S"
tags: [watch, notifications, tickets, artifacts]
---

# US-082: Watch an Entity for Change Notifications

## User Story

**As a** Harness Operator (Jordan Vance, P-001) or Delivery Lead (Priya Anand, P-003),
**I want to** Watch a specific entity such as a ticket or artifact,
**So that** I get notified whenever it changes without having to keep reloading it to check.

## Acceptance Criteria

- [ ] Given a ticket or artifact the user has access to, when the user issues a Watch action on it, then that entity appears in their watched-items list.
- [ ] Given a watched entity, when its state changes (e.g. ticket status update, artifact new version), then a notification is generated for each user watching it.
- [ ] Given a user is watching an entity, when the user issues an Unwatch action, then no further notifications are generated for them from that entity's subsequent changes.
- [ ] Given the Watch primitive is generic, when applied to two different entity types (e.g. a ticket and an artifact) in the same project, then both can be watched independently by the same user without interference.

## Notes

Generic primitive per product context ("any entity"); this story validates it against the two named entity types (ticket, artifact). Pairs naturally with US-081's channel-follow for agents versus per-entity Watch for humans.
