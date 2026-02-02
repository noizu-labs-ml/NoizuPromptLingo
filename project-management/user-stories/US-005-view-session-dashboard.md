# User Story: View Session Dashboard

**ID**: US-005
**Persona**: P-002 (Product Manager)
**Priority**: High
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a **product manager**,
I want to **view a session dashboard showing all related rooms and artifacts**,
So that **I can understand the current state of work without digging through individual items**.

## Acceptance Criteria

### MCP Tool Requirements
- [ ] `list_sessions` tool returns all sessions with status and summary metadata
- [ ] `get_session` tool retrieves session details including:
  - Session ID, name, description, status, timestamps
  - Linked chat room IDs
  - Artifact IDs created within the session
  - Associated task queue ID (if applicable)
- [ ] Sessions can be filtered by status (active, completed, archived)

### Web UI Requirements
- [ ] Dashboard page accessible via FastAPI route (e.g., `/sessions`)
- [ ] Session list view shows summary cards with key metrics
- [ ] Session detail view displays:
  - Activity summary (message count, artifact count, task count)
  - Linked chat rooms with quick navigation
  - Artifacts list with preview/download links
- [ ] Web URL provided for browser-based access (integrated with existing FastAPI app)
- [ ] Dashboard renders efficiently with 50+ sessions and 100+ artifacts

## Technical Notes

- **Sessions** group related work together (like a project or sprint) and will be implemented as a new MCP tool category
- **Architecture**: Session management requires:
  - SQLite-backed storage (new `sessions/` module in `src/npl_mcp/`)
  - FastAPI endpoints for web UI rendering
  - MCP tools for CLI/agent access (`list_sessions`, `get_session`, `create_session`)
- **Web UI**: Dashboard will be served via FastAPI app (mentioned in PROJ-ARCH.md) with SSE endpoint at `/sse` and web routes for session pages
- **Performance**: Dashboard should load quickly even with many artifacts; consider pagination and lazy-loading for large data sets
- **Activity Timeline**: Consider showing recent activity timeline (messages, artifact updates, task changes)

## Dependencies

- Session storage system must be implemented (SQLite schema, Database wrapper)
- Session must exist (created via `create_session` MCP tool)
- FastAPI web routes for session pages (building on existing FastAPI app in `src/npl_mcp/web/app.py`)
- Related features:
  - US-007: Create chat room (sessions link to rooms)
  - US-008: Create versioned artifact (sessions contain artifacts)
  - US-016: Create task (sessions may link to task queues)

## Open Questions

- How many sessions to show in list by default? (Recommend: 20 per page with pagination)
- Should dashboard show task queue summary if linked? (Recommend: Yes, show task count breakdown by status)
- Should session dashboard integrate with the Next.js frontend mentioned in PROJ-ARCH.md, or use server-side rendered templates?
- What session metadata fields are required? (name, description, status, created_at, updated_at, owner?)
- Should sessions support hierarchical organization (e.g., projects containing multiple sessions)?

## Related MCP Tools

**Session Tools** (to be implemented in `src/npl_mcp/sessions/`):
- `list_sessions` - Retrieve all sessions with optional status filter
- `get_session` - Get detailed session information by ID
- `create_session` - Create a new session (see US-007 or related story)

**Supporting Tools** (referenced but defined elsewhere):
- `list_artifacts` - Get artifacts within a session (Artifact Tools)
- `get_chat_feed` - View messages in session's chat rooms (Chat Tools)
- `get_task_queue` - View task queue linked to session (Task Queue Tools)

## Implementation Notes

This feature requires:
1. **Database Schema**: Session table with fields: id, name, description, status, created_at, updated_at, metadata (JSON)
2. **MCP Tool Registration**: Add Session Tools to `src/npl_mcp/unified.py`
3. **FastAPI Routes**: Add session dashboard routes to `src/npl_mcp/web/app.py`
4. **UI Components**: Dashboard templates or Next.js pages (see `src/npl_mcp/web/static` for frontend assets)
