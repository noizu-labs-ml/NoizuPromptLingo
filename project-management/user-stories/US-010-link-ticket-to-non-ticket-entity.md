---
id: US-010
title: "Link a ticket to a non-ticket entity (polymorphic link)"
slug: "link-ticket-to-non-ticket-entity"
personas: [P-002]
epic: "Tickets & Boards"
priority: "should-have"
complexity: "M"
tags: [tickets, polymorphic-links, artifacts]
---

# US-010: Link a ticket to a non-ticket entity (polymorphic link)

## User Story

**As the** Autonomous Coding Agent (P-002),
**I want to** link a ticket to a non-ticket entity such as a session artifact, wiki page, or persona,
**So that** the ticket carries traceable provenance to the exact work product it resulted from, even when that product isn't itself a ticket.

## Acceptance Criteria

- [ ] Given an existing ticket and an existing session artifact, when the agent creates a polymorphic link from the ticket to that artifact, then the ticket's detail view shows the artifact reference including its type and ID.
- [ ] Given a polymorphic link target type that isn't registered as linkable, when a link to it is attempted, then the call is rejected with a validation error listing supported target types.
- [ ] Given a ticket linked to two different entity types (one artifact, one wiki page), when the ticket is fetched, then both links are returned, each tagged with its own entity type and ID.
- [ ] Given a linked artifact that is later deleted, when the ticket is subsequently fetched, then the link either resolves to a tombstoned/"deleted" indicator or is cleanly removed — it must not error the whole ticket fetch.

## Notes

The polymorphic-link mechanism is what lets tickets reference artifacts, wiki pages, or personas without a dedicated join table per entity type; complexity is M for the target-type validation and deletion-safety handling.
