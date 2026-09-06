# Review: Create a chat room scoped to a session or project

- **Story**: `project-management/user-stories/US-015-create-chat-room-scoped-to-session-or-project.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The backend implements scoped room creation well: `Chat.CreateRoom` requires an org, accepts optional project and session scope, and resolves/validates that the project belongs to the org (`backend/lib/noizu_prompt_lingua/domains/chat/tools/create_room.ex:22-52`). Persistence records org/project/session scope on the room (`backend/lib/noizu_prompt_lingua/schema/chat_room.ex:18-25`), slug uniqueness is per (org, project) bucket via partial unique indexes with a TOCTOU-safe 23505 retry loop (`chat_room.ex:37-39`, `backend/lib/noizu_prompt_lingua/domains/chat/chat.ex:23-28`), and `list_rooms` filters by project so the room appears in the project's list (`chat.ex:210-213,681-682`). The response returns id, name, slug, org, project, and created_at. Two spec deviations: duplicate *names* are not rejected — the slug collision loop auto-suffixes, so same-named rooms coexist by design — and rooms have no creator field (`created_by` does not exist on the schema), so room metadata cannot answer "who created this".

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Room created with project (and optional session) scope recorded; appears in project's room list | Met | `create_room.ex:29-45` persists org/project/session; `list_rooms` + `maybe_filter_project` scope the list (`chat.ex:210-213,681-682`) |
| Duplicate name in same project scope rejected with conflict error | Partially Met | Slug collisions are rejected atomically per bucket (`chat_room.ex:37-39`, `chat.ex:24-25`), but duplicate *names* are intentionally allowed — `put_base_slug`/`insert_room_with_slug` suffixes the slug and inserts (`chat.ex:27-28`), so no conflict error is ever raised for a repeated name |
| Room metadata includes room ID, scope, creator, creation timestamp | Partially Met | id/org/project/session/created_at returned (`create_room.ex:47-57`); no creator field exists anywhere on `ChatRoom` (`chat_room.ex:17-25`) |
| Room created without session is project-scoped and accessible across sessions | Met | `session_id` is optional and nullable (`chat_room.ex:19,22`); nothing binds the room to a single session |

## Gaps / Risks

- AC2's conflict semantics directly contradict the implementation's (deliberate, ADR-013-cited) slug-suffix design. Either the story or the behavior should change; as written, a PM creating "Sprint 12" twice gets two rooms silently.
- No creator attribution on rooms — an audit/oversight gap for a collaboration primitive, and a hard miss against AC3.
- The Python MCP server's `room_create` (`src/npl_mcp/chat/chat.py:28-40`) is unscoped and has none of these guarantees (no org/project/session, no uniqueness, no creator); the two surfaces will drift unless the Python side is retired or aligned.
- Room deletion is a hard delete with reaction sweeping (`chat.ex:47-77`); combined with no creator field, there is no soft-archive path the story's "durable space" framing might assume.

## BDD Scenario

```gherkin
Feature: Scoped chat room creation

  Scenario: Jordan creates a project-scoped room
    Given an active org and project
    When Jordan calls Chat.CreateRoom with org, project, and name "launch-prep"
    Then the room is persisted with org/project scope recorded and a unique slug
    And it appears in the project's room list via list_rooms with project filter

  Scenario: Jordan creates a second room with the same name
    When Chat.CreateRoom is called again with the same name in the same project
    Then the room is created successfully with an auto-suffixed slug
    And no conflict error is raised

  Scenario: Jordan inspects the room metadata
    When the room is fetched
    Then id, name, slug, organization, project, and created_at are returned
    But no creator is included (the schema has no created_by)

  Scenario: Jordan creates a room without a session
    When Chat.CreateRoom is called with org and project only
    Then the room is project-scoped, session_id is null, and the room remains accessible across sessions
```
