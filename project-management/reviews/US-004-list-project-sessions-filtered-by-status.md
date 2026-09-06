# Review: List all sessions for a project, filtered by status

- **Story**: `project-management/user-stories/US-004-list-project-sessions-filtered-by-status.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Two list surfaces exist. The MCP tool `Session.List` (`src/npl_mcp/sessions/sessions.py:104-149`, registered at `src/npl_mcp/launcher.py:1072-1084`) lists `npl_generic_sessions` with an optional status filter, clamped limit, and empty-list-as-success semantics — but has no project parameter and the table has no project column. The REST endpoint `GET /sessions` (`src/npl_mcp/api/router.py:267-330`) lists `npl_tool_sessions` with a project filter (joined via `npl_projects`) and `updated_at` ordering, but filters by project/agent/search — not by session status. So each half of the story exists in a different, mismatched surface: status filtering without project scoping, and project scoping without status filtering. No authorization exists on either path.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| List all sessions for a project, no filter, returning status/title/last-updated | Partially Met | `Session.List` returns status/title/updated_at for ALL sessions globally (`src/npl_mcp/sessions/sessions.py:130-137`) — no project scope; `GET /sessions?project=` is project-scoped but has no status field and lists tool sessions, not generic ones (`src/npl_mcp/api/router.py:301-324`) |
| Filter by status="active" returns only active sessions | Met | `src/npl_mcp/sessions/sessions.py:122-124` — `status = $n` WHERE clause; `tests/test_generic_sessions.py:117` |
| Zero sessions returns empty list, not error | Met | `src/npl_mcp/sessions/sessions.py:139-149` — returns `{status: ok, sessions: [], count: 0}`; `tests/test_generic_sessions.py:106` |
| Non-member project access rejected with authorization error | Not Met | no evidence found — no membership check in `Session.List` or `GET /sessions` |

## Gaps / Risks

- Core story premise (project-scoped listing) is unmet on the MCP surface: `npl_generic_sessions` lacks a project FK, so a delivery lead cannot scope generic sessions to a project at all.
- Status and project filtering never coexist on one endpoint; combining them requires schema work (add project to generic sessions) plus query changes.
- No authz: any caller can enumerate all sessions across all projects via `Session.List` (limit capped at 200).
- `GET /sessions` search ILIKE is unanchored (`%term%`) — fine functionally, but no pagination cursor, only limit.

## BDD Scenario

```gherkin
Feature: Session listing for delivery oversight
  Scenario: Lead lists a project's sessions by status
    Given a project with sessions in mixed statuses
    When the lead calls Session.List with status="active"
    Then only sessions whose session_status is "active" are returned
    And each entry carries uuid, title, description, created_at, updated_at
  Scenario: Empty project
    When Session.List is called and no sessions match
    Then the response is status "ok" with sessions [] and count 0
  Scenario: Project scoping and authorization
    Given a project the caller is not a member of
    When the caller attempts a project-scoped session list
    Then today no such project parameter exists on Session.List
    And no authorization error is ever raised on any listing path
```
