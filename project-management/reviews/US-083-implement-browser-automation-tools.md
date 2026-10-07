# Review: Implement Browser Automation Tools

- **Story**: `project-management/user-stories/US-083-implement-browser-automation-tools.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The story's naming (`navigate_url`, `capture_screenshot`, ...) does not exist, but the capabilities largely do under different names. Real MCP-registered tools wrap a Playwright-backed session library: `Browser.Interact.Navigate` / `.Click` / `.Fill` / `.GetState` / `Browser.ListSessions` / `Browser.CloseSession` (`src/npl_mcp/launcher.py:1888-1966`) over `src/npl_mcp/browser/interact.py` (navigate:67, click:105, fill:146, wait_for:307, get_text:346, get_html:614, screenshot:488), plus `Browser.Capture` for PNG screenshots with viewport/theme/full-page options (`launcher.py:1847-1884`, `browser/capture.py`). Sessions persist across commands via `get_or_create_session` (`interact.py:1052`). Gaps: `wait_for` and `get_html`/`get_text` are library-only (their `browser_*` names in `meta_tools/stub_catalog.py` are non-executable stubs), the navigate tool returns only `{success, action, message}` rather than page state, `fill` uses Playwright's fill (no keyboard simulation — `type_text` exists but is unexposed), and no automatic session cleanup/TTL was found.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Navigate: open browser, load URL, wait readiness, return page state | Partially Met | `Browser.Interact.Navigate` (`src/npl_mcp/launcher.py:1888-1897`); readiness wait inside `navigate` (`interact.py:67-103`) but tool returns success/message only, not page state |
| `capture_screenshot` returns PNG with viewport/scroll options | Partially Met | `Browser.Capture` with viewport presets + full_page (`src/npl_mcp/launcher.py:1853-1884`); no arbitrary scroll-position option |
| `click_element` targets by selector with scroll-to-view | Met | `Browser.Interact.Click` → Playwright click auto-scrolls into view (`launcher.py:1901-1910`, `interact.py:105-144`) |
| `fill_input` with keyboard simulation | Partially Met | `Browser.Interact.Fill` uses `page.fill` (`interact.py:165`); `type_text` (keystroke sim, `interact.py:181-216`) not exposed |
| `wait_for_element` with configurable timeout | Partially Met | `interact.py:307` implements it; no MCP/discoverable tool registration (stub only, `meta_tools/stub_catalog.py:464`) |
| `get_page_content` HTML/text with cleanup/formatting | Partially Met | `ToMarkdown` discoverable tool (`meta_tools/discoverable_tools.py:17-27`); raw `get_html`/`get_text` library-only (`interact.py:614,346`) |
| Sessions maintained across commands with automatic cleanup | Partially Met | `get_or_create_session` / `list_sessions` / `close_session` (`interact.py:1052-1066`); no automatic cleanup/TTL found |

## Gaps / Risks

- Stub-catalog entries advertise tools that cannot execute — an agent trusting `ToolSearch` output will fail on call.
- No session pooling or resource reaping: headless browsers can leak for long-lived server processes.
- Named-tool parity with the story is zero; discoverability depends on knowing the `Browser.*` naming.

## BDD Scenario

```gherkin
Feature: Headless browser automation via MCP tools

  Scenario: Agent inspects a web app
    Given the NPL MCP server is running
    When the agent calls Browser.Interact.Navigate then Browser.Interact.Click then Browser.Interact.Fill
    Then each call operates on the same persistent Playwright session and returns a success result

  Scenario: Agent waits for a dynamically inserted element
    When the agent calls the wait_for_element tool with a 10s timeout
    Then no such MCP tool exists today; only the internal library supports waiting
```
