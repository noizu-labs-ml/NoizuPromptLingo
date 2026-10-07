# Review: Capture Screenshot of Current Work

- **Story**: `project-management/user-stories/US-012-capture-screenshot.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Two partial capture surfaces exist, each covering a different half of the story. The Python MCP server's `capture_screenshot` (`src/npl_mcp/browser/capture.py:183-273`) supports arbitrary URLs, viewport presets (`parse_viewport`, `:38-72`: desktop/mobile/tablet/4k/WIDTHxHEIGHT), light/dark theme, full_page, `wait_for` selector with timeout, and `network_idle` — exposed as `Browser.Capture` (`src/npl_mcp/launcher.py:1853-1884`) — but returns base64 image + metadata and never persists an artifact. The backend `Browser.Screenshot` tool (`backend/lib/noizu_prompt_lingua/domains/browser/tools/screenshot.ex:23-42`) uploads the capture to object storage and returns a viewable media URL for the org gallery, but only captures the *connected browser session* (no `url` parameter), with no viewport presets, theme, `wait_for`, or `network_idle`. The story's nominal command `screenshot_capture` — URL capture persisted as an artifact with metadata and artifact ID — exists only as a discovery stub (`src/npl_mcp/meta_tools/stub_catalog.py:210-228`) with no implementation behind it.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Capture screenshot of any URL via `screenshot_capture` | Partially Met | Python `Browser.Capture` takes any URL (`capture.py:216`); backend `Browser.Screenshot` cannot (connected browser only, `screenshot.ex:7-9`); the `screenshot_capture` name itself is a stub (`stub_catalog.py:210`) |
| Viewport presets (desktop, tablet, mobile) | Met | `parse_viewport` + `VIEWPORT_PRESETS` (`capture.py:38-51`) |
| Light/dark theme via `theme` parameter | Met | `theme` sets Playwright colorScheme (`capture.py:123`) |
| Full-page capture via `full_page` | Met | `capture.py:227-229`; both tools expose the flag |
| Auto-saved as artifact with URL/viewport/timestamp/theme metadata | Not Met | Python returns b64 + metadata only, no artifact row (`launcher.py:1875-1884`); backend persists to object storage but records no artifact/metadata document |
| Returns artifact ID, file path, and metadata | Partially Met | Python: metadata yes, no artifact ID/path; backend: media URL/short_id yes, no metadata document |
| Wait for element via `wait_for` selector | Met | `capture.py:219-221` with `wait_timeout` |
| Wait for network idle via `network_idle` | Met | `capture.py:214-215` (`wait_until: "networkidle"`) |
| Screenshot associated with session when `session_id` provided | Partially Met | Python `session_key` persists the *browser context*, not an artifact↔session link (`capture.py:195`); backend has no session association |

## Gaps / Risks

- The story's core contract — capture becomes a first-class artifact with ID and metadata — is unmet on both sides; screenshots are either ephemeral base64 or an opaque object-storage URL.
- No single tool combines URL capture with persistence: callers must pair the Python capture with manual artifact creation themselves.
- The stub catalog advertises `screenshot_capture` with exactly the story's parameter list; agents selecting it via ToolSearch will call a tool that has no implementation.
- `wait_timeout` failure raises `TimeoutError` out of `capture_screenshot` with no structured error envelope (contrast with the story's error-handling expectations in sibling US-013).

## BDD Scenario

```gherkin
Feature: Capture a page screenshot as an artifact

  Scenario: Vibe coder captures a mobile view of a page
    When the coder calls Browser.Capture with url, viewport "mobile", theme "dark", full_page true
    Then a PNG is captured after network idle and the selector wait
    And the response includes dimensions, viewport preset, theme, and captured_at
    But no artifact ID or file path is returned

  Scenario: Vibe coder captures from the connected browser
    When the coder calls Browser.Screenshot for their org with full_page true
    Then the image is uploaded to object storage and a viewable URL is returned
    But no viewport/theme/wait options apply and no metadata document is stored
```
