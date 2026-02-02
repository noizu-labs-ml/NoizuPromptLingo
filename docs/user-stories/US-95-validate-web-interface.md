# User Story: Validate Web Interface Implementation

**ID**: US-0095
**Persona**: P-005 (Dave, DevOps Engineer)
**Priority**: Medium
**Status**: Draft
**PRD Group**: implementation_validation
**Created**: 2026-02-02

## As a...
DevOps engineer validating MCP server implementation

## I want to...
Verify that all 17 web routes and API endpoints are functional

## So that...
The web UI is production-ready for users to interact with sessions, artifacts, and tasks

## Acceptance Criteria
- [ ] All 17 routes documented (HTML pages + API endpoints)
- [ ] HTML pages functional (8 pages verified)
- [ ] API endpoints working (5+ endpoints tested)
- [ ] Form submissions validating and persisting correctly
- [ ] Frontend test coverage identified (currently 0% - needs assessment)
- [ ] Error pages (404, 500) rendering correctly
- [ ] Pagination working for list views (artifacts, tasks, messages)

## Implementation Notes

**Reference**: `.tmp/mcp-server/tools/by-category/web-routes.yaml`

**HTML Pages** (8 pages):
1. `/` - Landing page
2. `/session/{id}` - Session detail page
3. `/room/{id}` - Chat room page
4. `/artifact/{id}` - Artifact detail with revisions
5. `/tasks` - Task queue list
6. `/screenshots` - Screenshot gallery
7. `/error/404` - Not found page
8. `/error/500` - Server error page

**API Endpoints** (5+ endpoints):
- POST `/api/sessions` - Create session
- GET `/api/sessions/{id}` - Get session details
- POST `/api/artifacts` - Create artifact
- GET `/api/room/{id}/feed` - Chat room messages
- GET `/api/tasks` - List tasks
- POST `/api/task/{id}/status` - Update task status
- POST `/api/screenshot` - Capture/upload screenshot

**Tech Stack**: FastAPI (backend) + Next.js (frontend)

**Frontend Build**:
- Source: `worktrees/main/mcp-server/frontend`
- Build command: `npm install && npm run build`
- Output: `src/npl_mcp/web/static` (mounted by FastAPI)

**Dependencies**:
- FastAPI app running
- SQLite database populated
- Next.js built (optional for core server, required for UI)

**Test Coverage Current**: 0% (frontend needs test suite)

## Related Stories
- US-005 (View Session Dashboard)
- US-097 (Add Web Interface Test Suite 0% → 80%)

## Notes
Web interface provides human access to MCP server functionality. Frontend is optional for core server operation but critical for user experience. Test coverage currently absent - needs frontend test suite (Vitest, Cypress) to achieve production readiness.
