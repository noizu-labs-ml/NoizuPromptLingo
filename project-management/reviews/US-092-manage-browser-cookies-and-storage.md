# Review: Manage Browser Cookies and Storage

- **Story**: `project-management/user-stories/US-092-manage-browser-cookies-and-storage.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Full library implementations exist in `src/npl_mcp/browser/interact.py`: cookie get/set/clear with domain and path support (`interact.py:868-1009`) and localStorage get/set (evaluated in page context). Persistent sessions underpin both (`get_or_create_session`, `interact.py:1052`). As with the other browser-extraction stories, none of these is registered as an MCP tool in this checkout — `launcher.py` registers no cookie/localStorage tools (`src/npl_mcp/launcher.py:1847-1966` covers Navigate/Click/Fill/GetState/Capture/sessions only), and the five names exist solely as metadata-only stubs (`src/npl_mcp/meta_tools/stub_catalog.py:510-555`) whose ToolCall returns a stub response. The story cites `unified.py` lines 1305-1419, which does not exist in this checkout. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `browser_get_cookies()` retrieves all cookies | Partially Met | `interact.py:868-1009`; stub at `stub_catalog.py:510-555` |
| `browser_set_cookie()` with domain/path | Partially Met | implemented in cookie methods (`interact.py:868-1009`); unexposed |
| `browser_clear_cookies()` | Partially Met | implemented (`interact.py:868-1009`); unexposed |
| `browser_get_local_storage()` | Partially Met | implemented in page-context evaluation; unexposed (stub catalog `stub_catalog.py:510-555`) |
| `browser_set_local_storage()` | Partially Met | same as above |
| Cookie operations support domain and path parameters | Partially Met | supported at library level (`interact.py:868-1009`); no MCP surface |
| Storage persists across navigations in same session | Partially Met | persistent session substrate exists (`interact.py:1052`); cannot be exercised end-to-end via MCP |

## Gaps / Risks

- Same stub-catalog mismatch as US-091-extract: ToolSearch advertises the five tool names; ToolCall returns stubs.
- Cookie write paths touch authentication state — once exposed, they will need the same session-scoping discipline as the rest of `interact.py` (per-session browser context) to avoid cross-session leakage; current session separation appears sound but is untested through MCP.

## BDD Scenario

```gherkin
Feature: Manage browser cookies and storage

  Scenario: Agent manages an authenticated session today
    Given a persistent browser session previously logged in
    When the agent calls ToolCall("browser_get_cookies", session_id="auth")
    Then a stub response is returned instead of cookie data
    And browser_set_cookie / browser_clear_cookies / localStorage tools behave identically
    While the equivalent calls inside browser/interact.py:868-1009 would work
```
