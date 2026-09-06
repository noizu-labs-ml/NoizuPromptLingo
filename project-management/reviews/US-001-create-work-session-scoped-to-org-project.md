# Review: Create a new work session scoped to an org/project

- **Story**: `project-management/user-stories/US-001-create-work-session-scoped-to-org-project.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

A generic `Session.Create` MCP tool exists (`src/npl_mcp/launcher.py:1029`, backed by `session_create` in `src/npl_mcp/sessions/sessions.py:48`) and creates a row in `npl_generic_sessions` with default status "active" and a unique UUID (short-uuid string) — satisfying the basic create-and-return-UUID flow. However, the org/project scoping at the heart of this story is entirely absent: `npl_generic_sessions` (changeset-012, `liquibase/changelogs/changeset-012.generic-sessions-table.yaml`) has no organization or project columns, `session_create` accepts only title/description/status/created_by, and there is no JWT/auth layer anywhere in the sessions path. The project-scoped variant, `ToolSession.Generate` (`src/npl_mcp/tool_sessions/tool_sessions.py:38`), resolves a project name via `upsert_project` (`src/npl_mcp/tool_sessions/projects.py:24`) — but that is a different session type keyed by (project, agent, task), it silently *creates* unknown projects rather than rejecting them, and the "organization" concept does not exist anywhere in the schema or code. Confidence: high that scoping is unimplemented; the searches covered schema, src, and tests.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Session.Create with org slug, project slug, title → session created "active" with unique UUID returned | Partially Met | Create+UUID+active-default works, but with **no org/project parameters**: `src/npl_mcp/sessions/sessions.py:48-78`, `src/npl_mcp/launcher.py:1038-1055`; schema `liquibase/changelogs/changeset-012.generic-sessions-table.yaml:10-52` (no org/project columns); no JWT auth layer found |
| Invalid org slug → error identifying the org, no session created | Not Met | No organization entity or validation exists; closest analog `upsert_project` *creates* missing projects instead of erroring (`src/npl_mcp/tool_sessions/projects.py:24-39`); no evidence of org validation |
| Omitted org+project with exactly one default project → scoped to default | Not Met | No default-project logic anywhere in `src/npl_mcp/` (grep for default project fallback: no evidence found) |
| Query after creation returns matching org/project associations | Not Met | Nothing to return — `session_get` (`src/npl_mcp/sessions/sessions.py:81-101`) and `_row_to_dict` (`sessions.py:36-45`) expose no org/project fields |

## Gaps / Risks

- No organization concept exists in the Python MCP schema at all (`npl_projects` in changeset-006 has no org FK either) — the story cannot be satisfied without schema work, not just code.
- `ToolSession.Generate` auto-creates projects on first use (`upsert_project` upsert semantics) — directly contradicts the story's reject-invalid-project requirement if reused as the implementation basis.
- No authentication/authorization layer (JWT or otherwise) on any Sessions tool; any client can create sessions.
- Project scoping exists only on `npl_tool_sessions` (changeset-006), not on `npl_generic_sessions` — two parallel session models, only one partially scoped.

## BDD Scenario

```gherkin
Feature: Org/project-scoped work session bootstrap

  Scenario: Create a scoped session with valid org and project
    Given an authenticated MCP client with a valid JWT and no active session
    When the agent calls Session.Create with organization "noizu-labs", project "noizu-infra", and title "infra sweep"
    Then a new session record is created with status "active"
    And a unique session UUID is returned
    And a later Session.Get on that UUID shows the same organization and project scope

  Scenario: Reject an unknown organization
    Given an authenticated MCP client with a valid JWT
    When the agent calls Session.Create with organization "does-not-exist"
    Then the API returns an error identifying the invalid organization
    And no session record is created

  Scenario: Fall back to the single configured default project
    Given the harness operator has exactly one default project configured
    When the agent calls Session.Create with no organization and no project
    Then the session is created scoped to that default project
```
