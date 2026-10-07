# Review: Add Browser Automation Test Suite

- **Story**: `project-management/user-stories/US-098-add-browser-automation-test-suite.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The browser subsystem is implemented in `src/npl_mcp/browser/` (capture.py, diff.py, interact.py, download.py, rest.py, screenshot.py, ping.py, secrets.py, to_markdown.py, checkpoint.py) — note the actual module layout differs substantially from the story's "32 tools in 7 groups" model (there is no navigate/click/fill/cookie tool surface of that shape in this codebase). Tests exist for the periphery: screenshot sizing/output (`tests/test_screenshot.py`, 16 tests), REST client with secret injection (`tests/test_rest.py`, 25), download (`tests/test_download.py`, 16), ping (`tests/test_ping.py`, 35), secrets (`tests/test_secrets.py`, 25), and to_markdown stripping (`tests/test_to_markdown_strip.py`, 28). But the core automation modules are untested: `interact.py` (1,083 lines — navigation/interaction/state logic), `diff.py` (317 lines — visual diff), and `capture.py` (344 lines) have no dedicated tests. No Playwright-based integration suite exists, no coverage measurement validates 80%, and no CI coverage report was found. Confidence: medium-high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| All 32 browser automation tools at 80%+ coverage | Not Met | No coverage measurement or report found; core modules (`interact.py`, `diff.py`, `capture.py`) have no tests at all |
| Navigation tools tested (navigate, back, forward, reload, URL parsing) | Not Met | No tests reference navigate/back/forward/reload (`grep -rl "navigate\|click_element\|fill_input\|get_cookies" tests/` → nothing); no such tool surface exists in `src/npl_mcp/browser/` |
| Interaction tools tested (click, fill, select, scroll, hover) | Not Met | `src/npl_mcp/browser/interact.py` (1,083 lines) has no test file |
| Content extraction tested (page text, HTML, titles, element finding) | Partially Met | Adjacent coverage: markdown conversion/strip tests (`tests/test_to_markdown_strip.py`, `tests/test_markdown_converter.py`) but no page-text/HTML/element-extraction tests |
| Screenshot capture and visual diff tested with actual images | Partially Met | `tests/test_screenshot.py` covers sizing/output/PNG validity, but `diff.py` (visual diff) and `capture.py` (page capture) are untested — no image-based diff tests |
| State management tested (cookies, localStorage, sessionStorage) | Not Met | No cookie/storage tests found; no cookie/storage surface in the current browser modules |
| Session management tested (create, switch tabs, close) | Not Met | No browser-session lifecycle tests found |
| Test suite passes in CI/CD with coverage report validation | Not Met | No coverage gate or browser-test CI job found for this suite |

## Gaps / Risks

- Story/codebase drift: the 32-tool inventory (navigate_to_url, click_element, get_cookies, …) does not match `src/npl_mcp/browser/` — the story should be re-scoped to the real module set before it can be satisfied.
- `interact.py` at 1,083 lines is the largest untested surface in the browser domain; it is precisely where the story's "critical scenarios" (selector robustness, wait conditions, stale elements) would live.
- Visual-diff sensitivity/noise work (a named critical scenario) is entirely untested in `diff.py`.
- 6 of 8 criteria unmet; the existing 146 peripheral tests are real but do not approach the story's intent.

## BDD Scenario

```gherkin
Feature: Browser automation test suite

  Scenario: Regression guard on interaction logic
    Given the browser test suite is wired into CI with a coverage gate
    When the suite runs against src/npl_mcp/browser/
    Then interact.py, diff.py, and capture.py report >= 80% line coverage
    # Today: FAILS — those three modules have no tests.

  Scenario: Screenshot output correctness
    When capture/screenshot helpers run against a fixture page
    Then output resizing respects max-width/max-height constraints
    And the result is a valid PNG or base64 payload
    # Today: MET for the sizing helpers (tests/test_screenshot.py), not for capture.py itself.

  Scenario: Visual diff sensitivity
    Given a baseline screenshot and a perturbed variant
    When the diff algorithm compares them
    Then differences above the sensitivity threshold are flagged and noise is filtered
    # Today: NOT MET — diff.py is untested.

  Scenario: Secret injection in browser REST calls
    Given a request body referencing secret placeholders
    When the browser rest client issues the call
    Then secrets are injected and never appear in the response body or logs
    # Today: MET (tests/test_rest.py, 25 tests).
```
