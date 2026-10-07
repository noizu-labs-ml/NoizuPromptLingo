# Review: Link a ticket to a non-ticket entity (polymorphic link)

- **Story**: `project-management/user-stories/US-010-link-ticket-to-non-ticket-entity.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The backend implements the polymorphic-link mechanism directly: `TicketEntityLink` schema (`backend/lib/noizu_prompt_lingua/schema/ticket_entity_link.ex`) — no DB FK on `entity_id`, entity_type vocabulary validated by changeset inclusion, unique constraint per (ticket, entity_type, entity_id, link_type) — plus the `Links` context (`backend/lib/noizu_prompt_lingua/domains/links/links.ex`) and `Ticket.LinkEntity` / `Ticket.UnlinkEntity` MCP tools. The VFS ticket view surfaces entity links under `links.entities` with type and ID (`backend/lib/noizu_prompt_lingua/mcp/vfs/tickets.ex:1074-1090`). Weak spots: the link vocabulary does not include "session artifact" as such (it has `artifact`, `wiki_page`, `review`, `asset` via `@from_entity_subject_types`, but `Ticket.LinkEntity`'s documented input only advertises the marketing entities); `Ticket.Get` (the MCP detail view) returns only ticket↔ticket links and omits entity links; and deletion safety (AC4) is entirely unimplemented — nothing validates the target exists at link time and nothing tombstones or cleans up when the target later disappears.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Link created to session artifact; detail view shows reference with type and ID | Partially Met | Link persists via `Links.link_entity/4` (`links.ex:18-39`); VFS shows entities (`vfs/tickets.ex:1082-1090`) but `Ticket.Get` omits them (`ticket_get.ex:55-64` maps only ticket links) |
| Unregistered target type rejected with error listing supported types | Partially Met | `validate_inclusion(:entity_type, ...)` rejects junk (`ticket_entity_link.ex:43`), but the error is a raw changeset inspect that does not list supported types (`ticket_link_entity.ex:57-58`) |
| Links to two entity types both returned, each tagged with type and ID | Met | `Links.get_entity_links/1` returns all links with `entity_type`/`entity_id` (`links.ex:56-61`); `links_doc` renders each tagged (`vfs/tickets.ex:1082-1090`) |
| Deleted linked entity → tombstone or clean removal, fetch never errors | Partially Met | No FK so a ticket fetch cannot error, but there is no existence validation at link time (`ticket_link_entity.ex:33-42` skips it), no tombstone, and no cleanup on target deletion — dangling links are returned verbatim |

## Gaps / Risks

- `Ticket.Get` (MCP) and the VFS view disagree: the canonical detail tool hides entity links while the VFS shows them. Any consumer relying on `Ticket.Get` sees an incomplete ticket.
- `Ticket.LinkEntity`'s description/input schema advertises only the 10 marketing entity types, yet the changeset accepts the extended vocabulary (`chat_message`, `wiki_page`, `artifact`, `asset`, `review`). Documented API and actual behavior diverge.
- The story's deletion-safety requirement ("tombstoned/deleted indicator or cleanly removed") is unmet: dangling references accumulate silently and there is no sweeper or validity check on read.
- The rejection error message fails the story's explicit requirement to list supported target types.

## BDD Scenario

```gherkin
Feature: Polymorphic ticket links to non-ticket entities

  Scenario: Agent links a ticket to an artifact
    Given an existing ticket and an existing artifact
    When the agent calls Ticket.LinkEntity with entity_type "artifact" and the artifact UUID
    Then the link is persisted with the artifact's type and ID
    And the VFS ticket view lists it under links.entities with entity_type and entity_id

  Scenario: Agent attempts a link to an unregistered type
    When the agent calls Ticket.LinkEntity with entity_type "bananas"
    Then the call is rejected with a validation error
    But the error does not enumerate the supported target types

  Scenario: Linked artifact is later deleted
    Given a ticket linked to an artifact that is then deleted
    When the ticket is fetched
    Then the fetch does not error
    But the link is returned as a bare dangling reference with no deleted/tombstone indicator
```
