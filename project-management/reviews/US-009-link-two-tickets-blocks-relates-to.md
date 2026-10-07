# Review: Link two tickets together (blocks/relates-to)

- **Story**: `project-management/user-stories/US-009-link-two-tickets-blocks-relates-to.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Typed ticket-to-ticket links exist: `TicketLink` schema (`backend/lib/noizu_prompt_lingua/schema/ticket_link.ex`) validates required ids, `link_type` inclusion over `blocks, blocked_by, relates_to, duplicates, parent_of, child_of` (line 8, 22), and uniqueness per (source, target, type) (line 23). `Ticket.Link` MCP tool (`backend/lib/noizu_prompt_lingua/domains/tickets/tools/ticket_link.ex:20-32`) creates links; `Ticket.Unlink` removes them; `Tickets.get_links` (`backend/lib/noizu_prompt_lingua/domains/tickets/tickets.ex:102-116`) returns outgoing (preloading target tickets) and incoming (preloading source tickets). `Ticket.Get` renders both directions (`ticket_get.ex:27,55-64`), so viewing B shows A under incoming and viewing A shows B under outgoing. Gaps: **no self-link rejection** (no `source != target` check anywhere), **no validation that source/target tickets exist** (links live in a local table with no ticket FK, while tickets themselves are TRP-backed — dangling links are possible), links render only as `{ticket_id, link_type}` — **the blocker's stage is not included**, satisfying neither the agent-query criterion nor symmetric "related tickets" presentation beyond direction. Tests: `tickets_tools_test.exs:174-190` covers link/unlink tool round-trip.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| A blocks B: viewing B shows A under "blocked by"; viewing A shows B under "blocks" | Met | `Ticket.Get` returns `links.incoming` (source ticket_id + link_type) and `links.outgoing` (`ticket_get.ex:55-64`); `get_links` preloads both directions (`tickets.ex:102-116`) |
| Agent querying B sees blocking relationship AND ticket A's current stage | Partially Met | relationship visible (`ticket_get.ex:60-63`) but response entries carry only ticket_id + link_type — no stage/status of the blocker; agent must issue a second Ticket.Get |
| Self-link rejected with validation error | Not Met | no evidence found: `ticket_link.ex:20-23` casts/validates ids but has no `validate_source_differs_from_target`; `Tickets.link` (`tickets.ex:81-89`) inserts directly |
| relates_to is symmetric — either ticket's view shows the other under "related tickets" | Partially Met | both directions are always returned (`get_links`), so the other side is visible from either ticket, but the presentation is directional (incoming/outgoing buckets), not a unified "related tickets" section, and relates_to is stored one-way |

## Gaps / Risks

- Referential integrity hole: `TicketLink` rows have no FK into the ticket store (tickets are TRP-remote); linking to a nonexistent or deleted ticket id succeeds.
- Self-links (A blocks A) accepted — downstream dependency-resolution logic would deadlock on them.
- No link metadata: no creator, timestamp, or comment on links (schema has only id/timestamps + the three fields).
- `Ticket.Link` is `hidden: true` in the tool registry (`ticket_link.ex:5`) — agents may not discover the capability.

## BDD Scenario

```gherkin
Feature: Link two tickets with blocks/relates-to

  Scenario: Delivery lead marks a blocker
    Given tickets NPL-1 and NPL-2 exist
    When Ticket.Link is called with source=NPL-1, target=NPL-2, link_type="blocks"
    Then Ticket.Get NPL-2 lists NPL-1 under links.incoming with link_type "blocks"
    And Ticket.Get NPL-1 lists NPL-2 under links.outgoing

  Scenario: Agent checks blockers before starting work
    When the agent calls Ticket.Get on NPL-2
    Then the incoming links reveal the blocking ticket
    And the agent must call Ticket.Get on the blocker separately to learn its stage

  Scenario: Invalid links (currently unguarded)
    When Ticket.Link is called with source == target
    Then the link is created today (no self-link rejection) — a spec violation
    When Ticket.Link is called with a nonexistent ticket UUID
    Then the link is created today (no existence check) — integrity risk
```
