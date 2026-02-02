# PRD: Web Interface

**PRD ID**: PRD-007
**Version**: 1.0
**Status**: Documented
**Documentation Source**: worktrees/main/mcp-server
**Last Updated**: 2026-02-02

## Executive Summary

FastAPI-based web interface providing browser-accessible views and REST API endpoints for sessions, chat rooms, artifacts, and screenshots. Supports multiple deployment modes (stdio-only, combined MCP+Web, unified HTTP server).

**Implementation Status**: ✅ Complete in mcp-server worktree (0% test coverage)

## Features Documented

### User Stories Addressed
- **US-003**: Fetch web content as markdown
- **US-004**: Share artifact in chat room
- **US-005**: View session dashboard

## Functional Requirements

### FR-001: Session Views (2 HTML routes)
**Routes**: `GET /`, `GET /session/{session_id}`
**Templates**: index.html, session.html
**Features**: Session listing table, room/artifact cards

### FR-002: Chat Interface (4 HTML routes)
**Routes**: `GET /session/{sid}/room/{rid}`, `GET /room/{rid}`, `POST .../message`, `POST .../todo`
**Templates**: chat_room.html
**Features**: Message feed, posting forms, @mention support

### FR-003: Screenshot Views (4 HTML routes)
**Routes**: `GET /screenshots`, `GET /screenshots/checkpoint/{slug}`, `GET /screenshots/compare/{id}`, `GET /screenshots/files/{path}`
**Templates**: screenshots.html, checkpoint_detail.html, comparison.html
**Features**: Checkpoint listing, side-by-side comparisons

### FR-004: REST API (7 JSON endpoints)
**Routes**:
- `GET /api/sessions` - List sessions
- `GET /api/session/{id}` - Session details
- `GET /api/room/{id}/feed` - Chat feed
- `POST /api/room/{id}/message` - Post message
- `GET /api/screenshots/checkpoints` - List checkpoints
- `GET /api/screenshots/checkpoint/{slug}` - Checkpoint metadata

### FR-005: MCP Protocol Route (1 endpoint)
**Route**: `POST/SSE /mcp` - MCP protocol endpoint (unified mode only)
**Protocol**: FastMCP SSE transport

## Deployment Modes

| Mode | Command | Web | MCP Endpoint | Port |
|------|---------|-----|--------------|------|
| stdio-only | npl-mcp | ❌ | stdio | - |
| combined | npl-mcp-web | ✅ | stdio | 8765 |
| unified | npl-mcp-unified | ✅ | /mcp | 8765 |
| launcher | npl-mcp-launcher | ✅ | /mcp | 8765 |

## Environment Variables

- `NPL_MCP_HOST` (default: 127.0.0.1)
- `NPL_MCP_PORT` (default: 8765)
- `NPL_MCP_WEB_HOST` (default: 127.0.0.1)
- `NPL_MCP_WEB_PORT` (default: 8765)
- `NPL_MCP_SINGLETON` (default: false)
- `NPL_MCP_FORCE` (default: false)

## Dependencies
- **Internal**: All categories (Sessions, Chat, Artifacts, Browser)
- **External**: FastAPI, uvicorn, Jinja2, StaticFiles

## Testing
- **Coverage**: 0%
- **Gap**: Web interface untested

## Security Considerations
- No authentication/authorization
- HTML auto-escaping via Jinja2
- All sessions publicly accessible
- **Local development use case only**

## Documentation References
- **Category Brief**: `.tmp/mcp-server/categories/09-web-interface.md`
- **Tool Spec**: `.tmp/mcp-server/tools/by-category/web-routes.yaml`
