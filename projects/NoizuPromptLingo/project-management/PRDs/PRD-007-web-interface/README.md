# PRD-007: Web Interface

**Version**: 1.0
**Status**: Implemented
**Author**: npl-prd-editor
**Created**: 2026-02-02
**Updated**: 2026-02-02

## Overview

FastAPI-based web interface providing browser-accessible views and REST API endpoints for sessions, chat rooms, artifacts, and screenshots. Supports multiple deployment modes (stdio-only, combined MCP+Web, unified HTTP server).

**Implementation Status**: ✅ Complete in mcp-server worktree (0% test coverage)

## Goals

1. Provide web-based dashboard for session and room management
2. Enable browser-based chat room interaction
3. Support screenshot checkpoint viewing and comparison
4. Expose REST API for programmatic access
5. Support unified MCP protocol endpoint for HTTP mode

## Non-Goals

- Authentication/authorization (local development use case only)
- Multi-tenant isolation
- Real-time WebSocket updates (uses SSE for MCP only)
- Mobile-optimized UI

---

## User Stories

Reference stories from global `project-management/user-stories/` directory.

| ID | Title | Persona |
|----|-------|---------|
| [US-003](../../user-stories/US-003-fetch-web-as-markdown.md) | Fetch web content as markdown | P-003 |
| [US-004](../../user-stories/US-004-share-artifact-chat.md) | Share artifact in chat room | P-003 |
| [US-005](../../user-stories/US-005-view-session-dashboard.md) | View session dashboard | P-002 |

Use MCP tools to load full story details:
- **get-story**: Load story by ID
- **edit-story**: Modify story content
- **update-story**: Update story metadata

---

## Functional Requirements

All functional requirements are detailed in `./functional-requirements/` directory.

See `functional-requirements/index.yaml` for complete list.

Key requirements:
- **[FR-001](./functional-requirements/FR-001-session-views.md)**: Session Views (2 HTML routes)
- **[FR-002](./functional-requirements/FR-002-chat-interface.md)**: Chat Interface (4 HTML routes)
- **[FR-003](./functional-requirements/FR-003-screenshot-views.md)**: Screenshot Views (4 HTML routes)
- **[FR-004](./functional-requirements/FR-004-rest-api.md)**: REST API (7 JSON endpoints)
- **[FR-005](./functional-requirements/FR-005-mcp-protocol-route.md)**: MCP Protocol Route (1 endpoint)

---

## Non-Functional Requirements

| ID | Requirement | Metric | Target |
|----|-------------|--------|--------|
| NFR-1 | Test coverage | Line coverage | >= 80% |
| NFR-2 | Response time | HTML page load | < 500ms |
| NFR-3 | Response time | API endpoint | < 200ms |
| NFR-4 | Concurrent users | SSE connections | >= 10 |

---

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

---

## Error Handling

| Error Condition | Error Type | User Message |
|-----------------|------------|--------------|
| Invalid session ID | 404 Not Found | "Session not found" |
| Invalid room ID | 404 Not Found | "Chat room not found" |
| Invalid checkpoint slug | 404 Not Found | "Checkpoint not found" |
| Malformed JSON | 400 Bad Request | "Invalid request format" |
| Server error | 500 Internal Server Error | "An error occurred" |

---

## Acceptance Tests

All acceptance tests detailed in `./acceptance-tests/` directory.

See `acceptance-tests/index.yaml` for test plan.

Summary:
- **6 acceptance tests** covering all FRs
- **Categories**: Integration testing
- **Coverage target**: 80%+ for web interface code

---

## Success Criteria

1. All user stories implemented with acceptance criteria passing
2. Test coverage >= 80% for all new code
3. All acceptance tests passing
4. Clear and actionable error messages
5. All deployment modes functional

---

## Out of Scope

- User authentication and authorization
- WebSocket real-time updates (except SSE for MCP)
- Mobile responsive design
- Frontend JavaScript framework (vanilla JS only)
- Next.js UI integration (handled separately)

---

## Dependencies

**Internal**:
- Sessions management (PRD-003)
- Chat rooms (PRD-004)
- Artifacts (PRD-002)
- Browser automation (PRD-006)

**External**:
- FastAPI >= 0.100.0
- uvicorn >= 0.20.0
- Jinja2 >= 3.0.0
- python-multipart (for form handling)

---

## Security Considerations

- **No authentication/authorization** - Local development use case only
- **HTML auto-escaping** - Jinja2 templates prevent XSS
- **All sessions publicly accessible** - No access control
- **Path traversal protection** - Screenshot file serving validates paths
- **No HTTPS** - Local development only

---

## Open Questions

- [ ] Should we add basic auth for production deployments?
- [ ] Should we implement WebSocket for chat updates?
- [ ] Should we add rate limiting for API endpoints?
