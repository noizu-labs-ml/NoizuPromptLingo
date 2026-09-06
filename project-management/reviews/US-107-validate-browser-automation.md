# Review: Validate Browser Automation Implementation

- **Story**: `project-management/user-stories/US-107-validate-browser-automation.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Browser automation exists but at a different shape than the story describes. Playwright is genuinely used (`src/npl_mcp/browser/capture.py:82-84` launches Chromium via `async_playwright`; `src/npl_mcp/browser/screenshot.py:14`), with a session-scoped `BrowserManager` (`capture.py:74-175`). Only 11 `Browser.*` MCP tools are registered (`src/npl_mcp/launcher.py:1847-2060`: Capture, Interact.Navigate/Click/Fill/GetState, ListSessions, CloseSession, Diff, Checkpoint, ListCheckpoints, CompareCheckpoints) — not 32, and whole story categories (modification/injection, cookies/localStorage state, tabs) have no implementation. The visual-diff system is real and sophisticated: `src/npl_mcp/browser/diff.py` implements a pixelmatch-style comparator (:159) with YIQ color distance (:55) and antialiasing detection (:88), exposed via `Browser.Diff` and checkpoint compare tools. Screenshots are stored on disk under a screenshots dir with checkpoint manifests (`src/npl_mcp/browser/checkpoint.py:190-230`), not as rows in an artifacts table. Tests cover screenshot plumbing (`tests/test_screenshot.py`, 16 tests) but no evidence covers navigation/interaction/state. The story's 5 screenshot web routes (`GET /screenshot/{id}` etc.) do not exist in `src/npl_mcp/api/router.py`. Coverage is indeed undocumented, matching the story's own admission.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| All 32 browser automation tools enumerated and working with Playwright | Partially Met | 11 tools registered (`launcher.py:1847-2060`); Playwright integration real (`capture.py:82-84`); 21 story-listed tools missing |
| Screenshot capture system functional (stored in artifacts table) | Partially Met | Capture works (`capture.py:183-272`) but screenshots live on disk + checkpoint manifests (`checkpoint.py:190-230`), not the artifacts table |
| Web routes for screenshots operational (5 routes) | Not Met | No `/screenshot*` routes in `src/npl_mcp/api/router.py` |
| Visual diff system working (comparison and annotation) | Met | `diff.py:159-228` pixelmatch comparison w/ antialias handling; `Browser.Diff` and `Browser.CompareCheckpoints` (`launcher.py:1970-2060`); annotation exists via reviews overlays (`launcher.py:1633-1657`) |
| Navigation, interaction, and extraction tools tested | Partially Met | Navigate/Click/Fill/GetState tools exist (`launcher.py:1888-1944`); extraction tools mostly absent; no tests for these paths |
| State management (cookies, localStorage, sessionStorage) validated | Not Met | No cookie/storage functions in `src/npl_mcp/browser/` |
| Test coverage documented (currently unknown) | Partially Met | `tests/test_screenshot.py` (16 tests) and `tests/test_rest_api.py` (88) cover capture/rest; overall browser coverage still undocumented |

## Gaps / Risks

- Story's tool inventory (32 tools, 7 categories) badly diverges from the 11-tool implementation — grooming needed before this validation story can "pass".
- Screenshot storage is filesystem-based; the story's DB/artifact integration and gallery routes don't exist.
- Browser session state is in-process (`BrowserManager` singleton); a server restart orphans sessions.
- No form-submission tool family (story refs US-019/US-020) — only generic Click/Fill.

## BDD Scenario

```gherkin
Feature: Browser automation for scraping and testing

  Scenario: Capture a screenshot of a page
    When an agent calls Browser.Capture with a URL and viewport
    Then Playwright launches a session, renders the page, and saves the screenshot to disk
    And the result references the stored image path

  Scenario: Interact with a page
    Given an active browser session
    When the agent calls Browser.Interact.Navigate, Click, and Fill
    Then the actions are executed against the live session via Playwright
    And Browser.Interact.GetState reflects the updated page

  Scenario: Compare screenshots for visual regression
    Given two screenshots from different runs of the same page
    When the agent calls Browser.Diff
    Then a pixelmatch-style comparison reports the diff percentage
    And the classification (pass/warn/fail) is derived from the percentage

  Scenario: Manage cookies and storage (NOT yet possible)
    When an agent needs to read or set localStorage for a session
    Then no tool exists for state management in the current surface
```
