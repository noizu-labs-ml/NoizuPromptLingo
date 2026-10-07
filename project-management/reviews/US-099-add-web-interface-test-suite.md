# Review: Add Web Interface Test Suite

- **Story**: `project-management/user-stories/US-099-add-web-interface-test-suite.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Substantial test coverage exists on both sides of the web interface, though it diverges from the story's route inventory. Backend: `tests/test_rest_api.py` (88 tests) covers the `/api` router (`src/npl_mcp/api/router.py`, `APIRouter(prefix="/api")` at `router.py:24`) including sessions, instructions, projects, personas, stories, PRDs, artifacts, tasks, errors — with 404 paths (`:292`), 503 DB-unavailable paths (`:1636`), limit validation (`:1627`, rejects `limit > 200`), and filtering/pagination params (`:1086, 1277, 1432`). `tests/test_rest.py` (25 tests) covers browser REST helpers. Frontend: the Next.js app (`frontend/`) has Playwright e2e specs (`frontend/e2e/room-view.spec.ts`, `compose.spec.ts`, `reactions.spec.ts`, `mcp-setup.spec.ts`, `xss.spec.ts`), unit/contract tests via node test-runner (`frontend/src/components/app-shell.contract.test.ts`, `frontend/src/lib/mcp-setup.test.ts`, etc.), and a Playwright config with an Authentik SSO flow. The story's specific inventory does not match reality: the 8 FastAPI-served HTML pages (e.g. `GET /room/{id}`, `GET /error/404`) don't exist — pages are Next.js-served — and there is no coverage-percentage gate proving 80%. Confidence: medium-high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| All 17 routes tested (HTML pages + API endpoints) | Partially Met | API surface broadly tested (`tests/test_rest_api.py`, 88 tests) but the route set differs from the story's list (e.g. `/api/chat/rooms/{id}/messages` vs story's `/api/room/{id}/feed`); the 8 listed FastAPI HTML pages don't exist as such (Next.js serves pages) |
| HTML pages rendering correctly with proper status codes | Partially Met | Playwright e2e covers room view, compose, reactions, mcp-setup (`frontend/e2e/*.spec.ts`) — not a systematic all-pages status-code check |
| Form submissions validating and persisting to database | Partially Met | Message compose e2e (`compose.spec.ts`) and backend POST-route tests (`tests/test_rest_api.py:213-263` notes append; `:2724` route) cover submission/persistence for some forms; no exhaustive form matrix |
| API responses validated against schema | Met | `tests/test_rest_api.py` asserts response shapes for sessions, projects, personas, stories, PRDs, errors (e.g. `:187-331, 378-525`) |
| Error pages (404, 500) functional and user-friendly | Partially Met | API-level 404/503/500 tests exist (`tests/test_rest_api.py:157, 292, 1636`); HTML error-page rendering untested |
| Pagination working for list views | Partially Met | Limit/filter params tested incl. upper-bound rejection (`tests/test_rest_api.py:1086, 1627, 1277`); full pagination-state coverage (next/prev flows) absent |
| Test suite passes in CI/CD with 80%+ coverage | Not Met | No coverage measurement or gate found for either backend (`uv run pytest` bare) or frontend (`test:contracts` script, `frontend/package.json:15`); 80% is unverified |

## Gaps / Risks

- The story's premise (8 FastAPI HTML pages) is architecturally stale — the interface is a Next.js SPA + JSON API; the story should be re-scoped to the actual route inventory.
- No coverage tooling (pytest-cov config, vitest coverage) anywhere — the 80% target is unmeasurable as things stand.
- HTML error-page UX (user-friendliness of 404/500) is the least-covered user-facing area.
- Frontend e2e depends on Authentik/storage-state setup (`test:e2e:authentik` script) — CI wiring for it is a prerequisite for the "passes in CI/CD" criterion.

## BDD Scenario

```gherkin
Feature: Web interface test suite

  Scenario: API regression suite in CI
    Given the backend test suite runs in CI against a test database
    When the /api routes are exercised
    Then session/project/story/PRD/artifact/task endpoints return their documented JSON shapes
    And missing resources yield 404 and DB outages yield 503
    # Today: LARGELY MET (tests/test_rest_api.py, 88 tests) minus a coverage gate.

  Scenario: Chat room page works end-to-end
    Given a user is authenticated via the SSO storage state
    When they open a room view and compose a message
    Then the message renders in the feed and persists across reload
    # Today: PARTIALLY MET via frontend/e2e/room-view.spec.ts + compose.spec.ts.

  Scenario: Pagination guard rails
    When a list endpoint is called with limit=9999
    Then the API rejects it (max 200) with a 4xx response
    # Today: MET (tests/test_rest_api.py:1627).

  Scenario: Coverage gate
    When the CI pipeline completes the web test suites
    Then combined coverage of web routes/pages is reported and must be >= 80%
    # Today: NOT MET — no coverage tooling is configured.
```
