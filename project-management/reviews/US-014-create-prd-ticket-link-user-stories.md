# Review: Create a PRD ticket and link multiple user_story tickets to it

- **Story**: `project-management/user-stories/US-014-create-prd-ticket-link-user-stories.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The primitive layers exist: tickets of any type string can be created and retrieved (`backend/lib/noizu_prompt_lingua/domains/tickets/tools/ticket_create.ex:52-57` defaults `ticket_type` to "task" but accepts "prd"/"user_story" unvalidated), and ticket↔ticket links are first-class (`TicketLink` schema with `blocks/blocked_by/relates_to/duplicates/parent_of/child_of` vocabulary, `backend/lib/noizu_prompt_lingua/schema/ticket_link.ex:12`; `Ticket.Link`/`Ticket.Unlink` tools; links surfaced with types in `Ticket.Get` at `backend/lib/noizu_prompt_lingua/domains/tickets/tools/ticket_get.ex:55-64` and VFS `links_doc` at `backend/lib/noizu_prompt_lingua/mcp/vfs/tickets.ex:1073-1090`). What is missing is everything PRD-specific: there is no "implements" link type, no rollup completion computation anywhere in the tickets domain (grep for implements/rollup/completion finds nothing), and `Ticket.Get` does not include the linked tickets' stages, so a PRD view cannot show story status without N+1 follow-up calls. Unlinking is clean (`Ticket.Unlink` deletes the link row), but there is no rollup to update and no orphan-guard beyond the FK.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| "prd" type ticket created and retrievable like any ticket | Met | `ticket_create.ex:52-57` accepts arbitrary `ticket_type`; `Ticket.Get`/`TicketResolver` retrieve by key (`ticket_get.ex:26`) |
| Link three user_story tickets to the PRD as "implements"; detail view lists them with current stage | Partially Met | Ticket↔ticket links exist but the vocabulary has no "implements" (`ticket_link.ex:12`) — closest is parent_of/child_of; `Ticket.Get` returns link_type only, never the linked ticket's stage (`ticket_get.ex:57-63`) |
| Rollup completion indicator ("2/3 stories done") derived from linked stages | Not Met | No rollup logic, view, or field anywhere in the tickets domain (no matches for rollup/completion/done_count in `backend/lib/noizu_prompt_lingua/domains/tickets/`) |
| Story deleted/unlinked → rollup updates, no orphaned reference | Partially Met | `Ticket.Unlink` removes the link row cleanly and ticket deletion cascades via FK (`ticket_link.ex:34-35`), so no orphans — but there is no rollup to update, so half the criterion is vacuous |

## Gaps / Risks

- The story's actual product goal — PRD completion tracking by story rollup — is entirely absent; what exists is generic ticket linking with a different link vocabulary than specified.
- "implements" should either be added to `@link_types` or the story should be amended to `parent_of/child_of`; today an agent following the story verbatim gets a validation error from `validate_inclusion` (`ticket_link.ex:28`).
- `Ticket.Get` returning links without stages forces N+1 `Ticket.Get` calls to build a rollup manually; if rollup lands later, it should ride on this response rather than a new tool.
- Because `ticket_type` is an unvalidated free string, "prd" and "user_story" need not be registered types (US-006/US-012 dependency is looser than the story assumes) — but nothing stops typoes like "user_story " from silently forking the taxonomy.

## BDD Scenario

```gherkin
Feature: PRD ticket with linked user stories

  Scenario: Priya creates a PRD and links stories
    Given types "prd" and "user_story" (or any type strings, since types are unvalidated)
    When Priya creates a "prd" ticket and links three user_story tickets
    Then the PRD is persisted and retrievable via Ticket.Get
    And the links are stored with a link_type from the supported vocabulary
    But "implements" is rejected as an unsupported link_type

  Scenario: Priya checks PRD completion
    Given two linked stories Done and one In Progress
    When Priya fetches the PRD
    Then no rollup indicator ("2/3 done") is returned
    And the linked tickets' stages are not included, forcing per-story lookups

  Scenario: A linked story is unlinked
    When Ticket.Unlink removes the story link
    Then no orphaned link row remains
```
