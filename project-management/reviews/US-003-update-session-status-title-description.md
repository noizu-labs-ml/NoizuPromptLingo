# Review: Update a session's status/title/description as work evolves

- **Story**: `project-management/user-stories/US-003-update-session-status-title-description.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

`session_update` (`src/npl_mcp/sessions/sessions.py:152-206`) implements partial update of title/status/description on `npl_generic_sessions`, exposed as the `Session.Update` MCP tool (`src/npl_mcp/launcher.py:1086-1104`). Validation rejects invalid status values before any write, and `Session.List` filters on the same `status` column, so the status-change/list-visibility interplay works. Tests cover update paths including invalid status rejection (`tests/test_generic_sessions.py:149-194`). The one unimplemented criterion is authorization: the session model has no org/project ownership and `session_update` performs no access check — any caller holding a UUID can update it.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Update title/description with status unchanged | Met | `src/npl_mcp/sessions/sessions.py:152-206` — fields set only when provided; `tests/test_generic_sessions.py:174` |
| Setting status to "completed" removes session from status-filtered "active" list | Met | `src/npl_mcp/sessions/sessions.py:122-135` (`status = $n` WHERE clause) with `VALID_STATUSES` at line 17 |
| Invalid status value rejected with validation error, prior status retained | Met | `src/npl_mcp/sessions/sessions.py:163-167` — validation runs before the UPDATE; `tests/test_generic_sessions.py:154` |
| Unauthorized caller (different org) rejected with authorization error, no fields change | Not Met | no evidence found — no org/ownership columns on `npl_generic_sessions`, no authz check in `session_update` |

## Gaps / Risks

- No authorization layer anywhere in the generic-session path: possession of a session UUID is the only capability check.
- `npl_generic_sessions` has no org/project column, so "different org" cannot even be represented; US-004's project scoping shares this gap.
- Table schema (`CREATE TABLE npl_generic_sessions`) is not in this repo — managed by Liquibase in the infra monorepo; drift risk between code assumptions and schema.

## BDD Scenario

```gherkin
Feature: Session metadata lifecycle
  Scenario: Operator updates a session as work evolves
    Given a generic session exists with status "active" and title "spike"
    When the operator calls Session.Update with session_id and title "authz fix"
    Then the response has status "ok" and session_status "active"
    And Session.Get for that uuid returns the new title with session_status unchanged
  Scenario: Completing a session hides it from active filters
    When the operator calls Session.Update setting status "completed"
    Then Session.List with status="active" does not include that session
    And Session.List with status="completed" does include it
  Scenario: Invalid status is rejected
    When the operator calls Session.Update with status "done"
    Then the call returns status "error" with the supported-enum message
    And Session.Get still shows the prior session_status
  Scenario: Cross-org access is not currently blocked
    Given a caller who is not a member of the owning org holds the session uuid
    When they call Session.Update
    Then today the update succeeds — no authorization error exists
```
