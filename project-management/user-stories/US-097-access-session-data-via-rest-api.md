# User Story: Access Session Data via REST API

**ID**: US-097
**Persona**: P-002 (Product Manager)
**Priority**: Medium
**Status**: Documented
**Created**: 2026-02-02

## Story

As a **product manager**,
I want to **query session data, chat feeds, and artifacts via REST API**,
So that **I can integrate MCP server data into dashboards and third-party tools**.

## Acceptance Criteria

- [ ] Can list all sessions via `GET /api/sessions`
- [ ] Can get session details via `GET /api/session/{id}`
- [ ] Can retrieve chat feed via `GET /api/room/{id}/feed`
- [ ] Can post messages programmatically via `POST /api/room/{id}/message`
- [ ] All endpoints return JSON format
- [ ] Supports query parameters for filtering and pagination
- [ ] Returns proper HTTP status codes (200, 404, 400)

## Implementation Status

✅ **Implemented in mcp-server worktree**

### REST API Endpoints

- `GET /api/sessions` - List all sessions with metadata (JSON)
- `GET /api/session/{id}` - Get session details (JSON)
- `GET /api/room/{id}/feed` - Get chat event stream (JSON)
- `POST /api/room/{id}/message` - Post message programmatically (JSON)

### Source Files

- Implementation: `worktrees/main/mcp-server/src/npl_mcp/web/app.py`
- Database: `worktrees/main/mcp-server/src/npl_mcp/storage/db.py`

### Documentation Briefs

- **Category Brief**: `.tmp/mcp-server/categories/09-web-interface.md`
- **Tool List**: `.tmp/mcp-server/tools/by-category/web-routes.yaml`

## Example Usage

```bash
# List all sessions
curl http://127.0.0.1:8765/api/sessions

# Get session details
curl http://127.0.0.1:8765/api/session/abc12345

# Get chat feed with pagination
curl "http://127.0.0.1:8765/api/room/3/feed?since=0&limit=20"

# Post message via API
curl -X POST http://127.0.0.1:8765/api/room/3/message \
  -H "Content-Type: application/json" \
  -d '{"persona": "alice", "message": "Hello from API"}'
```

## Response Format

```json
// GET /api/sessions
[
  {
    "id": "abc12345",
    "title": "Feature Development",
    "created_at": "2025-10-09T12:00:00",
    "updated_at": "2025-10-09T15:30:00",
    "status": "active",
    "room_count": 3,
    "artifact_count": 5
  }
]
```

## Query Parameters

- `/api/sessions?status=active` - Filter by session status
- `/api/room/{id}/feed?since=123&limit=50` - Pagination and filtering

## Notes

- No authentication or authorization implemented (local development use)
- All endpoints return JSON for programmatic access
- Complements HTML web interface routes

## Related Stories

- US-005: View Session Dashboard
- US-006: Send Message to Chat Room
- US-007: Create Chat Room for Collaboration
