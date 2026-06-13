# Category: Web Interface

**Category ID**: C-09
**Tool Count**: 0 (web routes, not MCP tools)
**Status**: Documented
**Source**: worktrees/main/mcp-server
**Documentation Source Date**: 2026-02-02

## Overview

The Web Interface provides browser-accessible views and API endpoints for all MCP-managed content. Built on FastAPI, it enables team collaboration by exposing shareable URLs for sessions, chat rooms, artifacts, and browser screenshots. This component bridges the gap between stdio-based MCP tool calls and human-readable web interfaces, allowing stakeholders to review and participate in AI-assisted workflows without specialized tooling.

The interface supports multiple deployment modes (stdio-only, combined MCP+Web, unified HTTP server) and maintains real-time synchronization with the underlying SQLite database. All web routes are served alongside the MCP protocol endpoint, enabling seamless transitions between programmatic and browser-based interactions.

## Features Implemented

### Feature 1: Session Management Web Views
**Description**: Browser-accessible session pages showing grouped chat rooms and artifacts with navigation and metadata display.

**Web Routes**:
- `GET /` - Landing page listing all sessions with counts and status
- `GET /session/{session_id}` - Session detail page with room/artifact cards

**Database Tables**:
- `sessions` - Session metadata (id, title, created_at, updated_at, status)
- `chat_rooms` - Room linkage via session_id foreign key
- `artifacts` - Artifact linkage via session_id foreign key

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/web/app.py`
- Templates: `worktrees/main/mcp-server/src/npl_mcp/web/templates/*.html`
- Database: `worktrees/main/mcp-server/src/npl_mcp/storage/schema.sql`
- Tests: None (web interface integration untested)

**Test Coverage**: 0%

**Example Usage**:
```bash
# Start unified server
npl-mcp-launcher

# Visit in browser
open http://127.0.0.1:8765/
open http://127.0.0.1:8765/session/abc12345
```

### Feature 2: Chat Room Web Interface
**Description**: Interactive chat room pages with message history, member lists, and posting forms. Supports web-based participation alongside MCP tool calls.

**Web Routes**:
- `GET /session/{session_id}/room/{room_id}` - Chat room in session context
- `GET /room/{room_id}` - Standalone chat room view
- `POST /session/{session_id}/room/{room_id}/message` - Post message via web form
- `POST /session/{session_id}/room/{room_id}/todo` - Create todo via web form
- `POST /room/{room_id}/message` - Post message to standalone room

**Database Tables**:
- `chat_rooms` - Room metadata
- `chat_events` - Message and event stream
- `notifications` - @mention tracking

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/web/app.py`
- Chat logic: `worktrees/main/mcp-server/src/npl_mcp/chat/rooms.py`
- Templates: `worktrees/main/mcp-server/src/npl_mcp/web/templates/chat_room.html`

**Test Coverage**: 0%

**Example Usage**:
```bash
# Visit chat room in browser
open http://127.0.0.1:8765/session/abc12345/room/3

# Post message via form (no MCP tool required)
# Fill out persona dropdown and message textarea, click submit
```

### Feature 3: REST API Endpoints
**Description**: JSON API endpoints for programmatic access to sessions, chat feeds, and artifacts. Enables AJAX calls and third-party integrations.

**API Endpoints**:
- `GET /api/sessions` - List all sessions (JSON)
- `GET /api/session/{session_id}` - Get session details (JSON)
- `GET /api/room/{room_id}/feed` - Get chat event stream (JSON)
- `POST /api/room/{room_id}/message` - Post message programmatically (JSON)

**Query Parameters**:
- `/api/sessions?status=active` - Filter by session status
- `/api/room/{id}/feed?since=123&limit=50` - Pagination and filtering

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/web/app.py`
- Database: `worktrees/main/mcp-server/src/npl_mcp/storage/db.py`

**Test Coverage**: 0%

**Example Usage**:
```bash
# Query sessions via API
curl http://127.0.0.1:8765/api/sessions

# Get chat feed
curl http://127.0.0.1:8765/api/room/3/feed?since=0&limit=20

# Post message via API
curl -X POST http://127.0.0.1:8765/api/room/3/message \
  -H "Content-Type: application/json" \
  -d '{"persona": "alice", "message": "Hello from API"}'
```

### Feature 4: Screenshot Management Web Interface
**Description**: Browser-accessible views for screenshot checkpoints and comparisons, enabling visual regression testing and design review workflows.

**Web Routes**:
- `GET /screenshots` - Screenshot checkpoint listing page
- `GET /screenshots/checkpoint/{slug}` - Individual checkpoint detail view
- `GET /screenshots/compare/{comparison_id}` - Side-by-side comparison view
- `GET /screenshots/files/{path:path}` - Static file serving for images

**API Endpoints**:
- `GET /api/screenshots/checkpoints` - List all checkpoints (JSON)
- `GET /api/screenshots/checkpoint/{slug}` - Get checkpoint metadata (JSON)

**Database Tables**:
- `screenshot_checkpoints` - Checkpoint metadata
- `screenshot_comparisons` - Comparison metadata

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/web/app.py`
- Screenshot logic: `worktrees/main/mcp-server/src/npl_mcp/browser/screenshots.py`
- Templates: `worktrees/main/mcp-server/src/npl_mcp/web/templates/screenshots*.html`

**Test Coverage**: 0%

**Example Usage**:
```bash
# View screenshot dashboard
open http://127.0.0.1:8765/screenshots

# View specific checkpoint
open http://127.0.0.1:8765/screenshots/checkpoint/homepage-2025-01-15

# View comparison
open http://127.0.0.1:8765/screenshots/compare/comp-abc123
```

## Web Routes Reference

### HTML Routes (User-Facing Pages)

| Route | Method | Description | Template |
|-------|--------|-------------|----------|
| `/` | GET | Session listing landing page | `index.html` |
| `/session/{session_id}` | GET | Session detail with rooms/artifacts | `session.html` |
| `/session/{sid}/room/{rid}` | GET | Chat room in session context | `chat_room.html` |
| `/room/{room_id}` | GET | Standalone chat room view | `chat_room.html` |
| `/screenshots` | GET | Screenshot checkpoint listing | `screenshots.html` |
| `/screenshots/checkpoint/{slug}` | GET | Checkpoint detail view | `checkpoint_detail.html` |
| `/screenshots/compare/{id}` | GET | Screenshot comparison view | `comparison.html` |
| `/screenshots/files/{path:path}` | GET | Static image serving | (StaticFiles) |

### Form Submission Routes (POST)

| Route | Method | Description | Redirect Target |
|-------|--------|-------------|-----------------|
| `/session/{sid}/room/{rid}/message` | POST | Post message to chat room | Session room view |
| `/session/{sid}/room/{rid}/todo` | POST | Create todo in room | Session room view |
| `/room/{room_id}/message` | POST | Post message to standalone room | Standalone room view |

### API Routes (JSON)

| Route | Method | Description | Response Format |
|-------|--------|-------------|-----------------|
| `/api/sessions` | GET | List sessions with metadata | JSON array |
| `/api/session/{id}` | GET | Get session details | JSON object |
| `/api/room/{id}/feed` | GET | Get chat event stream | JSON array |
| `/api/room/{id}/message` | POST | Post message programmatically | JSON object |
| `/api/screenshots/checkpoints` | GET | List screenshot checkpoints | JSON array |
| `/api/screenshots/checkpoint/{slug}` | GET | Get checkpoint metadata | JSON object |

### MCP Protocol Route

| Route | Method | Description | Protocol |
|-------|--------|-------------|----------|
| `/mcp` | POST/SSE | MCP protocol endpoint | FastMCP SSE |

## Database Model

### Tables
- `sessions`: Session metadata (id, title, created_at, updated_at, status)
- `chat_rooms`: Chat room definitions with session_id foreign key
- `chat_events`: Message and event stream
- `notifications`: @mention tracking
- `artifacts`: Artifact metadata with session_id foreign key
- `screenshot_checkpoints`: Screenshot checkpoint metadata
- `screenshot_comparisons`: Comparison tracking

### Relationships
- `chat_rooms.session_id → sessions.id` (many-to-one)
- `artifacts.session_id → sessions.id` (many-to-one)
- `chat_events.room_id → chat_rooms.id` (many-to-one)

## User Stories Mapping
This category addresses:
- US-003: View session via web browser
- US-004: View chat history in browser
- US-005: Post messages via web form
- FR-005: Landing Page
- FR-006: Session Detail Page
- FR-007: Chat Room View
- FR-008: Message Posting
- FR-009: Todo Creation via Web
- FR-016: REST API for Sessions
- FR-017: REST API for Chat

## Suggested PRD Mapping
- PRD-1: NPL MCP Server Web UI and Session Management (Complete PRD)

## API Documentation

### Web Endpoints

#### GET /
**Description**: Landing page with session listing table
**Response**: HTML page with sessions, counts, timestamps

#### GET /session/{session_id}
**Description**: Session detail page with room/artifact cards
**Parameters**:
- `session_id` (path): Session identifier
**Response**: HTML page with breadcrumb navigation and resource cards
**Status Codes**: 200 OK, 404 Not Found

#### GET /session/{session_id}/room/{room_id}
**Description**: Chat room view in session context
**Parameters**:
- `session_id` (path): Session identifier
- `room_id` (path): Room identifier
**Response**: HTML page with message feed and posting form
**Status Codes**: 200 OK, 404 Not Found

#### POST /session/{session_id}/room/{room_id}/message
**Description**: Post message to chat room via web form
**Parameters**:
- `session_id` (path): Session identifier
- `room_id` (path): Room identifier
- `persona` (form): Sender persona name
- `message` (form): Message text
**Response**: 303 See Other (redirect to chat room)
**Status Codes**: 303 Redirect, 400 Bad Request

#### POST /session/{session_id}/room/{room_id}/todo
**Description**: Create todo in chat room via web form
**Parameters**:
- `session_id` (path): Session identifier
- `room_id` (path): Room identifier
- `persona` (form): Creator persona
- `description` (form): Todo description
- `assigned_to` (form, optional): Assignee persona
**Response**: 303 See Other (redirect to chat room)
**Status Codes**: 303 Redirect, 400 Bad Request

#### GET /api/sessions
**Description**: List all sessions with metadata
**Query Parameters**:
- `status` (optional): Filter by session status ("active", "archived")
**Response**: JSON array of session objects
**Example**:
```json
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

#### GET /api/session/{session_id}
**Description**: Get session details with rooms and artifacts
**Parameters**:
- `session_id` (path): Session identifier
**Response**: JSON object with session metadata and contents
**Status Codes**: 200 OK, 404 Not Found

#### GET /api/room/{room_id}/feed
**Description**: Get chat event stream
**Parameters**:
- `room_id` (path): Room identifier
**Query Parameters**:
- `since` (optional): Event ID offset
- `limit` (optional): Max events to return
**Response**: JSON array of event objects
**Status Codes**: 200 OK, 404 Not Found

#### POST /api/room/{room_id}/message
**Description**: Post message to room programmatically
**Parameters**:
- `room_id` (path): Room identifier
**Request Body** (JSON):
```json
{
  "persona": "alice",
  "message": "Hello from API"
}
```
**Response**: JSON object with event details
**Status Codes**: 200 OK, 400 Bad Request

## Dependencies
- **Internal**: Session Management (C-06), Chat System (C-05), Artifact Management (C-02), Browser Automation (C-08)
- **External**: FastAPI (>=0.104.0), uvicorn (>=0.24.0), Jinja2 templates, StaticFiles

## Testing
- **Test Files**: None (web interface untested)
- **Coverage**: 0%
- **Key Test Cases**:
  - Session page rendering
  - Chat room pagination
  - Form submission and redirect
  - API endpoint JSON responses
  - 404 handling for invalid IDs
  - HTML escaping for security

## Documentation References
- **README**: worktrees/main/mcp-server/README.md (Web UI Routes section, API Endpoints section)
- **USAGE**: worktrees/main/mcp-server/USAGE.md (no web UI examples)
- **PRD**: worktrees/main/mcp-server/docs/PRD.md (Web Interface section, FR-005 through FR-017)
- **Status**: worktrees/main/mcp-server/PROJECT_STATUS.md (no web-specific coverage)

## Implementation Notes

### Server Modes
The web interface is available in multiple deployment modes:
- **stdio-only** (`npl-mcp`): No web server, MCP tools only
- **Combined** (`npl-mcp-web`): MCP on stdio, web on HTTP (background thread)
- **Unified** (`npl-mcp-unified`): Single HTTP server with MCP at `/mcp` and web at `/`
- **Launcher** (`npl-mcp-launcher`): Singleton mode with auto-start

### Template Engine
Uses Jinja2 templates with dark theme styling. Templates are located in `src/npl_mcp/web/templates/`.

### Security Considerations
- No authentication or authorization implemented
- HTML escaping via Jinja2 auto-escape
- Session data publicly accessible via URL
- Local development use case only

### Future Enhancements
- Real-time WebSocket updates for chat
- User authentication and session ownership
- Artifact editing via web interface
- Mobile-responsive layouts
- Export/download functionality
