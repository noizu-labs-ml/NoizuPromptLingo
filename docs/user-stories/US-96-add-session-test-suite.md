# User Story: Add Session Management Test Suite (0% → 80%)

**ID**: US-0096
**Persona**: P-005 (Dave, DevOps Engineer)
**Priority**: Critical
**Status**: Draft
**PRD Group**: test_coverage
**Created**: 2026-02-02

## As a...
DevOps engineer improving test coverage for core MCP server functionality

## I want to...
Implement comprehensive tests for 4 session management tools to reach 80% coverage

## So that...
Session management is reliable foundation for all other features

## Acceptance Criteria
- [ ] All 4 session tools have 80%+ test coverage
- [ ] Database operations tested (create, read, update, delete)
- [ ] Edge cases covered (expired sessions, concurrent access, ID conflicts)
- [ ] Error handling tested (invalid input, schema violations, missing data)
- [ ] Test suite passes in CI/CD pipeline
- [ ] Coverage report validates 80%+ threshold reached
- [ ] Performance tests establish baseline for session operations

## Implementation Notes

**Reference**: `.tmp/mcp-server/categories/05-session-management.md`

**Tools to Test**:
1. `create_session` - Create new session with metadata
2. `get_session` - Retrieve session by ID
3. `list_sessions` - Query sessions with filters
4. `update_session` - Modify session metadata

**Database Table**: sessions (id, owner, title, status, created_at, updated_at, expires_at)

**Test Categories**:
- Unit: Tool input validation, output formatting
- Integration: Database reads/writes, schema compliance
- Edge cases: Null values, invalid IDs, concurrent writes
- Error handling: 400 Bad Request, 404 Not Found, 409 Conflict
- Performance: Baseline query times for 1K, 10K, 100K sessions

**Current Coverage**: 0% (critical gap)

**Test Framework**: pytest (Python) + coverage.py

**Target Coverage**: 80%+

**Dependencies**:
- Database schema migration scripts
- Fixture data for session creation
- SQLite in-memory for test isolation

## Related Stories
- US-001 (Load NPL Core)
- US-002 (Load Project Context)
- US-003 (Fetch Web as Markdown)
- US-004 (Share Artifact Chat)
- US-005 (View Session Dashboard)
- US-088 (Implement Session Management with Worklogs)

## Notes
Sessions are foundational for the entire MCP server. Zero test coverage is blocker for production. Other features build on session functionality, so reliable tests are prerequisite. Session expiration and concurrency handling require careful testing.
