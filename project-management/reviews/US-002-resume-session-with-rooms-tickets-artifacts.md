# Review: Resume an existing session and see its rooms/tickets/artifacts

- **Story**: `project-management/user-stories/US-002-resume-session-with-rooms-tickets-artifacts.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Session retrieval exists: `Session.Get` (`src/npl_mcp/launcher.py:1067`, `src/npl_mcp/sessions/sessions.py:81`) and the aggregate `Session.Contents` (`src/npl_mcp/launcher.py:1101`, `session_get_contents` at `src/npl_mcp/sessions/sessions.py:214`) return a session with chat rooms and artifacts by session UUID. However, the story's core promises are not met: `Session.Contents` queries rooms and artifacts with **no session scoping** — the rooms query (`sessions.py:231-238`) and artifacts query (`sessions.py:240-245`) have no `WHERE session_id` clause, so *every* room and *every* artifact in the database is returned regardless of the requested session; there is no ticket concept at all (no ticket module in `src/npl_mcp/`; only `npl_tasks`, unlinked to sessions in this path); no org exists in the schema, hence no cross-org authorization check; and there is no resume operation — no "last resumed at" field or update semantics (only generic `updated_at` via `Session.Update`). Confidence: high; the SQL itself was read and it visibly lacks the scoping predicate.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Resume call with prior UUID returns status, title, description, and org/project scope | Partially Met | `session_get` returns status/title/description (`src/npl_mcp/sessions/sessions.py:81-101`) but no org/project scope — fields do not exist on `npl_generic_sessions` (changeset-012) |
| Session with 2 rooms + 5 tickets → all rooms and tickets returned or enumerable without knowing IDs | Not Met | `session_get_contents` returns rooms and artifacts, but unscoped: rooms query has no session filter (`src/npl_mcp/sessions/sessions.py:231-238`), artifacts query likewise (`sessions.py:240-245`); tickets are not returned at all (no ticket linkage; no evidence found) |
| Session UUID from another org → authorization error, no data returned | Not Met | No organizations and no authorization layer anywhere in the sessions path (`src/npl_mcp/sessions/sessions.py` has no auth checks) — no evidence found |
| Active session resumed → status stays "active" and "last resumed at" timestamp updated | Not Met | No resume endpoint; `session_update` sets generic `updated_at` only (`sessions.py:152-206`); no `last_resumed_at` column in changeset-012 — no evidence found |

## Gaps / Risks

- **Cross-session data leak (bug)**: `session_get_contents` returns *all* chat rooms and *all* artifacts in the database for any session ID, because both queries omit the session filter — this would silently violate the story's per-session context guarantee and any future multi-tenant isolation.
- No ticket entity/linkage: the story expects tickets attached to sessions; only `npl_tasks` exists and is not associated with `npl_generic_sessions` in this path.
- No resume semantics: nothing distinguishes "resume" from "get"; callers cannot observe resume events or timing.
- The story references US-004 for session discovery; `Session.List` exists (`src/npl_mcp/launcher.py:1084`) but returns only status-filtered sessions with no org/project/agent filtering.

## BDD Scenario

```gherkin
Feature: Resume a work session and recover its context

  Scenario: Resume a session with prior rooms and tickets
    Given a session UUID from a prior run with two chat rooms and five tickets linked
    When the operator resumes the session by that UUID
    Then the response includes the session's status, title, description, and org/project scope
    And all five tickets and both rooms are returned (or enumerable via a scoped follow-up list)
    And the caller never needs to have known the room or ticket IDs

  Scenario: Attempt cross-organization resume
    Given a session UUID that belongs to a different organization than the caller's auth context
    When resume is attempted with that UUID
    Then the call is rejected with an authorization error
    And no session data is returned

  Scenario: Resume an already-active session
    Given a session left in "active" status
    When it is resumed
    Then its status remains "active"
    And a "last resumed at" timestamp is updated
```
