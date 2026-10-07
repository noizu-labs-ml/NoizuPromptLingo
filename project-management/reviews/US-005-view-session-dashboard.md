# Review: View Session Dashboard

- **Story**: `project-management/user-stories/US-005-view-session-dashboard.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The MCP half substantially exists. `Session.List` (`src/npl_mcp/sessions/sessions.py:104-149`) lists sessions with status filtering; `Session.Get` (`sessions.py:81-101`) returns id/title/description/status/timestamps; `Session.Contents` (`sessions.py:214-268`) aggregates a session with chat rooms (message counts, last activity) and artifacts (title, kind, latest revision) — registered as `Session.Create/Get/List/Update/Contents/Archive` in `src/npl_mcp/launcher.py:1030-1126`. Tests cover the generic-session layer (`tests/test_generic_sessions.py`). However, `Session.Contents` is wrong in a load-bearing way: its rooms query and artifacts query have **no session linkage filter** — they return ALL rooms and ALL artifacts in the database, not the ones belonging to the session (there is no session→room/artifact association table). No task-queue linkage exists. The web UI half is absent: `src/npl_mcp/web/` contains only a `.gitignore`, and no HTML dashboard/routes exist. JSON-only REST endpoints exist in `src/npl_mcp/api/router.py:267-330` (`GET /sessions`, `/sessions/{uuid}`, `/sessions/{uuid}/tree`) but they back the *tool-session* tables (`npl_tool_sessions`), not generic sessions, and are data APIs, not a dashboard.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `list_sessions` returns all sessions with status and summary metadata | Met | `src/npl_mcp/sessions/sessions.py:104-149` (uuid/title/status/description/timestamps); `tests/test_generic_sessions.py:106-130` |
| `get_session` returns session details (id, name, description, status, timestamps) | Met | `src/npl_mcp/sessions/sessions.py:81-101`; `tests/test_generic_sessions.py:84` |
| `get_session` includes linked chat room IDs | Partially Met | `session_get_contents` returns rooms with counts (`sessions.py:231-238`) but unscoped — returns every room, none are actually linked to the session; no association table |
| `get_session` includes artifact IDs created within the session | Partially Met | artifacts listed in `session_get_contents` (`sessions.py:240-245`) but unscoped — returns ALL artifacts globally |
| `get_session` includes associated task queue ID | Not Met | no evidence found — no session↔task-queue linkage in `sessions.py` or schema |
| Sessions filterable by status (active/completed/archived) | Met | `VALID_STATUSES` includes all three plus paused (`sessions.py:17`); WHERE filter at `sessions.py:122-124`; `tests/test_generic_sessions.py:117` |
| Dashboard page via FastAPI route (e.g. `/sessions`) | Not Met | no evidence found — `/sessions` route (`api/router.py:267`) returns JSON for tool sessions; no HTML/dashboard rendering; `src/npl_mcp/web/` is empty |
| Session list view with summary cards | Not Met | no evidence found — no UI layer |
| Session detail view (activity summary, rooms nav, artifacts list) | Not Met | no evidence found — data only, and room/artifact data is mis-scoped as above |
| Web URL for browser-based access | Not Met | no evidence found |
| Renders efficiently with 50+ sessions / 100+ artifacts | Not Met | `session_get_contents` fetches every room and every artifact unbounded (`sessions.py:231-245`) — would degrade exactly at the stated scale; no pagination |

## Gaps / Risks

- Correctness bug, not just a gap: `session_get_contents` presents all-rooms/all-artifacts as the session's contents. Any consumer treating that output as session-scoped gets wrong data today.
- No session→room, session→artifact, or session→task-queue association schema exists; the story's core data model (sessions group rooms/artifacts/tasks) is unrepresented in Postgres.
- Web dashboard is entirely missing (`src/npl_mcp/web/` empty), so 6 of 11 criteria fail on the UI side.
- Efficiency criterion cannot be met by current queries (global unbounded fetches).
- Naming collision hazard: `tool_sessions` (ToolSession.Generate, project-scoped) vs. generic sessions (`Session.*`) — story's implementation notes (`src/npl_mcp/sessions/`, `unified.py`, `web/app.py`) reference paths/structure that no longer match the codebase.

## BDD Scenario

```gherkin
Feature: Session dashboard
  Scenario: PM reviews session state via MCP
    Given sessions exist in mixed statuses
    When the PM calls Session.List with status "active"
    Then sessions with session_status "active" are returned with title/description/timestamps
    And Session.Get on one uuid returns its full metadata
  Scenario: PM views session contents
    When the PM calls Session.Contents for a session
    Then chat rooms and artifacts are returned with counts and latest_revision
    But today the rooms/artifacts are NOT limited to that session — every room and artifact in the database is returned
  Scenario: PM opens the web dashboard
    When the PM browses to a /sessions dashboard URL
    Then today no HTML page exists — only the JSON REST endpoints under the FastAPI app
  Scenario: Scale check
    When 50+ sessions and 100+ artifacts exist
    Then Session.Contents fetches all rooms and artifacts unbounded — no pagination or scoping protects the response
```
