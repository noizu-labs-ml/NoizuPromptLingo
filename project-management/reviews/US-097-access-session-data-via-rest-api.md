# Review: Access Session Data via REST API

- **Story**: `project-management/user-stories/US-097-access-session-data-via-rest-api.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The REST API is implemented in `src/npl_mcp/api/router.py` (an `APIRouter` mounted with `prefix="/api"`, `router.py:24`, included by `src/npl_mcp/launcher.py:2117`), and is well covered by tests (`tests/test_rest_api.py`, 88 tests, incl. 404/503/limit-validation paths). All four required capabilities exist, though under route shapes slightly different from the story's spec: session listing/retrieval at `/api/sessions` and `/api/sessions/{uuid}` (vs the story's `/api/session/{id}`), and the chat feed/post at `/api/chat/rooms/{room_id}/messages` plus `/api/chat/rooms/{room_id}/events` (vs `/api/room/{id}/feed` and `/api/room/{id}/message`). Endpoints return JSON, support query-param filtering and pagination, and use proper status codes. The "no authentication" caveat in the story still holds — routes rely on network locality. Story's cited `worktrees/main/mcp-server/web/app.py` path is stale. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| List all sessions via `GET /api/sessions` | Met | `src/npl_mcp/api/router.py:267` (`@router.get("/sessions")` + `/api` prefix), filters `project`/`agent`/`search`, `limit` ≤ 200 |
| Get session details via `GET /api/session/{id}` | Partially Met | Equivalent exists at `GET /api/sessions/{uuid}` (`router.py:451`), with 404 on bad UUID/missing session (`:465-477`); path differs from spec |
| Retrieve chat feed via `GET /api/room/{id}/feed` | Partially Met | Equivalents: `GET /api/chat/rooms/{room_id}/messages` (`router.py:2708`, `limit` + `before_id` cursor pagination) and `GET /api/chat/rooms/{room_id}/events` (`:2787`); path shape differs from spec |
| Post messages programmatically via `POST /api/room/{id}/message` | Partially Met | Equivalent: `POST /api/chat/rooms/{room_id}/messages` (`router.py:2724`, validated `ChatMessageCreateBody`); path shape differs from spec |
| All endpoints return JSON | Met | All handlers return dicts/lists via FastAPI JSON serialization (e.g. `router.py:267-333`, `2708-2742`) |
| Query parameters for filtering and pagination | Met | `project`/`agent`/`search`/`limit` on sessions (`router.py:268-272`); `limit` (max 200, validated) + `before_id` on messages (`:2709-2712`); test `tests/test_rest_api.py:1086,1277,1432,1627` |
| Proper HTTP status codes (200, 404, 400) | Met | 404: `router.py:465-477`; 400: validation errors raised across routes (e.g. `:432,627`); also 503 on DB unavailability (`:2719-2721`) and 500 paths |

## Gaps / Risks

- No authentication/authorization on any `/api` route (consistent with the story's "local development" note, but a risk if ever exposed beyond loopback).
- Route-shape drift from the story spec (`/api/sessions/{uuid}` vs `/api/session/{id}`, `/api/chat/rooms/{id}/messages` vs `/api/room/{id}/feed`) — the story's documented curl examples do not work as written.
- Messages pagination is `before_id`-cursor only; no `since` parameter as in the story's example (`?since=0&limit=20`).

## BDD Scenario

```gherkin
Feature: Query session data via REST API

  Scenario: PM lists active sessions for a dashboard
    When a GET is made to /api/sessions?status=active&limit=50
    Then the response is a JSON array of session objects with metadata
    # Note: actual filter params are project/agent/search; status filtering is via
    # /api/work-sessions (tests/test_rest_api.py:1277).

  Scenario: PM drills into one session
    When a GET is made to /api/sessions/{uuid}
    Then the response is the session's JSON details
    And a nonexistent or malformed UUID yields 404

  Scenario: PM reads a room's message feed with paging
    When a GET is made to /api/chat/rooms/{room_id}/messages?limit=50
    Then the response is {"items": [...], "count": N}
    And subsequent pages use before_id as the cursor

  Scenario: External tool posts a message
    When a POST is made to /api/chat/rooms/{room_id}/messages with JSON body
    Then the message is persisted and returned as JSON
    And an invalid body yields 400
```
