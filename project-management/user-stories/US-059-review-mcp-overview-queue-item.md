---
id: US-059
title: "Review an MCP Overview Queue Item"
slug: "review-mcp-overview-queue-item"
personas: [P-006]
epic: "Admin & Platform Operations"
priority: "should-have"
complexity: "S"
tags: [admin, mcp, review-queue]
---

# US-059: Review an MCP Overview Queue Item

## User Story

**As a** Platform Administrator, Ilya Petrov (P-006),
**I want to** review, approve, or reject items in the MCP overview queue,
**So that** new or changed MCP tool exposures get a platform-level sanity check before they're trusted broadly.

## Acceptance Criteria

- [ ] Given Ilya is on the MCP overview queue page, when a pending item exists, then he can see its details — submitting org/project, requested tools/scope, submitted timestamp — before deciding.
- [ ] Given Ilya approves a pending queue item, when he confirms, then the item's status changes to "approved" and it is removed from the pending queue.
- [ ] Given Ilya rejects a pending queue item, when he provides a rejection reason and confirms, then the item's status changes to "rejected," the reason is recorded, and it is removed from the pending queue.
- [ ] Given a queue item has already been decided, when Ilya reopens its detail view, then the recorded decision, reason (if any), and deciding admin are shown read-only.

## Notes

A platform-level governance gate distinct from an org owner directly applying a scope in US-050.
