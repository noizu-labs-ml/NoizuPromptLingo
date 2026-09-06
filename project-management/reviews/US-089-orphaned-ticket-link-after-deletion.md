# Review: Handle Orphaned Polymorphic Ticket Links Gracefully

- **Story**: `project-management/user-stories/US-089-orphaned-ticket-link-after-deletion.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The underlying polymorphic link store exists: `Domains.Links` (`backend/lib/noizu_prompt_lingua/domains/links/links.ex:18-75`) writes `ticket_entity_links` rows with an explicit `metadata` map and no DB FK on `entity_id` by design (`links.ex:4-7`). But the story's actual subject — graceful rendering of dangling links — has no implementation. The ticket detail page in the new frontend renders no entity links at all (`frontend/src/app/app/[orgId]/tickets/[id]/page.tsx` contains no link-rendering code), no "no longer exists" placeholder exists anywhere (repo-wide grep for orphan/dangling/"no longer available" finds nothing in UI code), and no periodic integrity sweep job exists in the backend workers. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Dangling link renders as "no longer available" placeholder, not broken link/500 | Not Met | no evidence found; `frontend/src/app/app/[orgId]/tickets/[id]/page.tsx` has no entity-link rendering |
| Placeholder shows last-known type and name captured at link time | Partially Met | `metadata` map is captured on the link row at creation (`backend/.../links/links.ex:23`) — a storage hook exists, but nothing populates it with a display name or reads it |
| Dangling link does not prevent rest of ticket card from rendering | Not Met | no evidence found — no card-level link rendering or guard exists |
| Periodic integrity sweep reports dangling links in aggregate | Not Met | no evidence found in `backend/lib/noizu_prompt_lingua/workers/` or domains |

## Gaps / Risks

- `link_entity/4` validates the ticket but deliberately does not validate the entity target ("entity targets are validated by the calling tool", `links.ex:13-15`) — so dangling rows are possible, and nothing detects them.
- The `metadata` field is the natural home for last-known type/name but defaults to `%{}` and is never written by the domain with snapshot data.
- If link rendering is added later without a guard, a deleted target will surface as an unhandled lookup failure rather than a placeholder.

## BDD Scenario

```gherkin
Feature: Orphaned polymorphic ticket links

  Scenario: Open a ticket whose linked entity was hard-deleted (today)
    Given a ticket with a ticket_entity_links row pointing at a deleted entity
    When Priya opens the ticket detail page
    Then no linked-entities section is rendered at all
    And no placeholder, error, or last-known name is shown
    And no integrity sweep has flagged the dangling row
```
