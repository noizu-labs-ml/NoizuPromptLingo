---
id: US-004
title: "List all sessions for a project, filtered by status"
slug: "list-project-sessions-filtered-by-status"
personas: [P-003]
epic: "Work Sessions"
priority: "should-have"
complexity: "S"
tags: [sessions, filtering, oversight]
---

# US-004: List all sessions for a project, filtered by status

## User Story

**As a** Delivery Lead (P-003),
**I want to** list every session recorded against a project, filterable by status,
**So that** I can see which coding-agent work is currently active versus completed or abandoned without asking each contributor individually.

## Acceptance Criteria

- [ ] Given a project with 12 sessions in mixed statuses, when Priya calls the session list for that project with no status filter, then all 12 sessions are returned with their status, title, and last-updated timestamp.
- [ ] Given the same project, when she calls the session list with status="active", then only sessions currently marked active are returned.
- [ ] Given a project with zero sessions, when the session list is called, then an empty list is returned, not an error.
- [ ] Given a project Priya is not a member of, when she calls the session list against it, then the call is rejected with an authorization error.

## Notes

Read-only oversight view; underpins delivery-lead visibility into concurrent agent work across a project without touching individual sessions (contrast with US-003, which mutates one session).
