---
id: US-014
title: "Create a PRD ticket and link multiple user_story tickets to it"
slug: "create-prd-ticket-link-user-stories"
personas: [P-003]
epic: "Tickets & Boards"
priority: "must-have"
complexity: "M"
tags: [tickets, prd, user-story, rollup]
---

# US-014: Create a PRD ticket and link multiple user_story tickets to it

## User Story

**As a** Delivery Lead (P-003),
**I want to** create a ticket of type "prd" and link several "user_story" tickets to it as implementing children,
**So that** a single PRD ticket gives a rollup view of every story delivering it, and I can track overall PRD completion by story completion.

## Acceptance Criteria

- [ ] Given a project with the "prd" and "user_story" custom types already registered (per US-006/US-012), when Priya creates a ticket of type "prd" with a title and description, then it is persisted and retrievable like any other ticket.
- [ ] Given an existing "prd" ticket and three existing "user_story" tickets, when Priya links all three to the PRD as "implements" relationships, then the PRD's detail view lists all three linked stories along with their current stage.
- [ ] Given a PRD with linked stories in mixed stages (two "Done", one "In Progress"), when the PRD is viewed, then a rollup completion indicator (e.g. "2/3 stories done") is shown, derived from the linked stories' current stages.
- [ ] Given a user_story ticket linked to a PRD, when that story is deleted or unlinked, then the PRD's rollup count updates accordingly and no orphaned reference remains.

## Notes

Builds directly on US-009's generic ticket-linking mechanism, applied specifically as a PRD-to-user_story "implements" relationship with a rollup view; also depends on US-006 (custom type + fields) and US-012 (org-scoped type registration) already being in place.
