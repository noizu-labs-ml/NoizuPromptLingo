# User Story: Add Web Interface Test Suite (0% → 80%)

**ID**: US-0099
**Persona**: P-005 (Dave, DevOps Engineer)
**Priority**: High
**Status**: Draft
**PRD Group**: test_coverage
**Created**: 2026-02-02

## As a...
DevOps engineer improving test coverage for web interface

## I want to...
Create comprehensive tests for 17 web routes and API endpoints to reach 80% coverage

## So that...
Web UI is reliable for users to interact with MCP server functionality

## Acceptance Criteria
- [ ] All 17 routes tested (both HTML pages and API endpoints)
- [ ] HTML pages rendering correctly with proper status codes
- [ ] Form submissions validating and persisting to database
- [ ] API responses validated against schema
- [ ] Error pages (404, 500) functional and user-friendly
- [ ] Pagination working for list views (artifacts, tasks, messages)
- [ ] Test suite passes in CI/CD with 80%+ coverage

## Implementation Notes

**Reference**: `.tmp/mcp-server/categories/09-web-interface.md`

**HTML Pages** (8 pages):
1. `GET /` - Landing page with overview
2. `GET /session/{id}` - Session detail page
3. `GET /room/{id}` - Chat room page with message feed
4. `GET /artifact/{id}` - Artifact detail with version history
5. `GET /tasks` - Task queue list with filters
6. `GET /screenshots` - Screenshot gallery with thumbnails
7. `GET /error/404` - Not found error page
8. `GET /error/500` - Server error page

**API Endpoints** (5+ endpoints):
- `POST /api/sessions` - Create session (form submission)
- `GET /api/sessions/{id}` - Retrieve session JSON
- `POST /api/artifacts` - Create artifact (file upload)
- `GET /api/room/{id}/feed` - Chat messages with pagination
- `GET /api/tasks` - List tasks with filtering
- `POST /api/task/{id}/status` - Update task status
- `POST /api/screenshot` - Capture or upload screenshot

**Tech Stack**:
- Backend: FastAPI (Python) with FastAPI test client
- Frontend: Next.js (JavaScript) with Vitest + Playwright
- Database: SQLite for test fixtures

**Test Categories**:

**Backend Tests** (FastAPI):
- HTTP status codes (200, 201, 400, 404, 500)
- Request validation (form data, JSON, file uploads)
- Response schema validation
- Database state verification
- Error handling and messages
- Authentication/authorization (if applicable)
- Pagination and filtering

**Frontend Tests** (Next.js):
- Component rendering (pages, forms, lists)
- Form submission and validation
- API call integration
- Error display
- User interactions (clicks, form fills)
- Responsive design (if applicable)

**Integration Tests**:
- Full request/response cycle
- Form submission → database persistence → retrieval
- API data → page rendering
- Pagination state management

**Current Coverage**: 0% (frontend test suite missing)

**Test Framework**:
- Backend: pytest + FastAPI TestClient
- Frontend: Vitest + Playwright

**Target Coverage**: 80%+

**Dependencies**:
- Test fixtures (sample sessions, artifacts, tasks)
- SQLite in-memory database
- FastAPI test client
- Frontend testing libraries

**Critical Test Scenarios**:
- Form validation: Required fields, format validation (emails, URLs)
- Pagination: Next/previous pages, offset/limit handling
- Error pages: Proper rendering, helpful error messages
- Data persistence: Create → retrieve → verify
- API schema: Response structure matches spec
- File uploads: Multiple formats, size limits
- List filtering: By status, priority, date range

## Related Stories
- US-005 (View Session Dashboard)
- US-095 (Validate Web Interface Implementation)

## Notes
Web interface is optional for core MCP server but critical for user experience. Frontend currently has 0% test coverage - requires Vitest and Playwright setup. Backend routes need both unit tests (API responses) and integration tests (database). Focus on form submission and data persistence as these are most user-facing. Pagination and filtering common in list views (tasks, artifacts, messages).
