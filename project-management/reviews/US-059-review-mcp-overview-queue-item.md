# Review: Review an MCP Overview Queue Item

- **Story**: `project-management/user-stories/US-059-review-mcp-overview-queue-item.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Elixir backend implements an MCP overview review flow as minimal REST (the controller's own moduledoc calls a review UI "a follow-up"): `backend/lib/noizu_prompt_lingua_web/controllers/mcp_overview_controller.ex` with `GET /mcp-overviews` (:11-21), `PATCH /mcp-overviews/:id/approve` (:23), `PATCH /mcp-overviews/:id/reject` (:25), and edit-implies-approve `PATCH /mcp-overviews/:id` (:28-34); routes at `backend/lib/noizu_prompt_lingua_web/router.ex:618-623`. Status lifecycle `generated → approved | rejected` is enforced in the store (`backend/lib/noizu_prompt_lingua/domains/mcp_overview/store.ex:30, 167-174`), and recall never surfaces rejected rows (:130-134). Gaps: no submitting org/project attribution, no rejection-reason capture, no deciding-admin recording. Confidence: high — controller and store status paths read in full.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Pending item shows details: submitting org/project, requested tools/scope, timestamp | Partially Met | `overview_json/1` (`mcp_overview_controller.ex:48-61`) exposes scope_slug, task_text, overview_md, runner, model, status, timestamps — but no org/project submitter fields |
| Approve changes status to "approved" and removes item from pending | Met | `approve/2` (`mcp_overview_controller.ex:23`) → `Store.set_status(id, "approved")` (`store.ex:168-170`); pending set is `status: "generated"` and query excludes approved rows from that filter |
| Reject records a reason, changes status to "rejected", removes from pending | Partially Met | `reject/2` sets status (`store.ex:168-170`) and rejected rows are excluded from recall (:130-134), but `set_status/1` accepts no reason — nothing records why |
| Decided items show decision, reason, and deciding admin read-only | Partially Met | status remains queryable via `index/2` with a `status` filter (`mcp_overview_controller.ex:11-21`), but neither reason nor deciding admin is ever stored |

## Gaps / Risks

- No admin-attribution or reason audit trail: a rejected overview is indistinguishable from any other rejection.
- No frontend review page exists — reviewers must drive raw REST endpoints.
- No authorization scoping visible in the controller (any authenticated route user can approve/reject; route-level auth assumed but unverified here).

## BDD Scenario

```gherkin
Feature: Admin reviews generated MCP overview items

  Scenario: List pending overviews
    Given generated overviews exist
    When Ilya GETs /mcp-overviews?status=generated
    Then each item shows scope, task text, generated markdown, and timestamps
    (no submitting org/project is shown — gap)

  Scenario: Approve a pending item
    When Ilya PATCHes /mcp-overviews/:id/approve
    Then the item's status becomes "approved" and it leaves the generated queue

  Scenario: Reject with reason
    When Ilya PATCHes /mcp-overviews/:id/reject
    Then the item's status becomes "rejected"
    And no reason is recorded (gap) and no deciding admin is recorded (gap)
```
