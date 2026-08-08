---
id: US-089
title: "Handle Orphaned Polymorphic Ticket Links Gracefully"
slug: "orphaned-ticket-link-after-deletion"
personas: [P-003]
epic: "Edge Cases & Error States"
priority: "could-have"
complexity: "S"
tags: [tickets, data-integrity, ux, polymorphic-links]
---

# US-089: Handle Orphaned Polymorphic Ticket Links Gracefully

## User Story

**As** Priya Anand, the Delivery Lead (P-003),
**I want to** see a clear "linked item no longer exists" placeholder when a ticket links to a since-deleted entity,
**So that** dangling references don't break the ticket view or hide the fact that context was lost.

## Acceptance Criteria

- [ ] Given a ticket has a polymorphic link to an entity that is later hard-deleted, when Priya opens the ticket, then the link renders as a distinct "no longer available" placeholder instead of a broken link or a 500 error.
- [ ] Given a dangling link placeholder is shown, when Priya inspects it, then it still shows the last-known type and name of the deleted entity, captured at link time, even though it's no longer navigable.
- [ ] Given the ticket board or list view renders a card with a dangling link, when the page loads, then the dangling link does not prevent the rest of that ticket card from rendering.
- [ ] Given an admin runs a periodic integrity sweep, when dangling links are detected, then they are reported in aggregate rather than requiring every ticket to be opened manually.

## Notes

Kept at S because this is a rendering/guard-rail fix, not a cascading-delete redesign. This is the "delete" counterpart to US-088's "archive" state — both need explicit fallback UI.
