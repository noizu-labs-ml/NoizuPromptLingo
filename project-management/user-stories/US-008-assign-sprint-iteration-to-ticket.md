---
id: US-008
title: "Assign a sprint/iteration to a ticket"
slug: "assign-sprint-iteration-to-ticket"
personas: [P-003]
epic: "Tickets & Boards"
priority: "must-have"
complexity: "S"
tags: [tickets, sprints, planning]
---

# US-008: Assign a sprint/iteration to a ticket

## User Story

**As a** Delivery Lead (P-003),
**I want to** assign a ticket to a specific sprint or iteration,
**So that** I can scope and track delivery commitments over fixed time windows instead of an undifferentiated backlog.

## Acceptance Criteria

- [ ] Given an open sprint "Sprint 14" on a project, when Priya assigns a ticket to it, then the ticket's sprint field is set to "Sprint 14" and it appears when tickets are filtered by that sprint.
- [ ] Given a ticket currently assigned to "Sprint 13", when it is reassigned to "Sprint 14", then it no longer appears under a Sprint-13 filter and does appear under Sprint-14.
- [ ] Given a sprint that has been closed/archived, when an attempt is made to assign a ticket to it, then the assignment is rejected with a validation error.
- [ ] Given a ticket with no sprint assigned, when board/list views are filtered by "no sprint", then that ticket is included in the results.

## Notes

Complements US-007 (kanban stage); sprint is orthogonal to stage — a ticket can be "In Progress" within any sprint.
