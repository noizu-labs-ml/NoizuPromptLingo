# Review: Browser Navigation

- **Story**: `project-management/user-stories/US-021-browser-navigation.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The underlying browser engine is complete: `BrowserSession` (`src/npl_mcp/browser/interact.py:45`) implements navigate (default 30s timeout, networkidle, CSS wait) at `:67`, click `:105`, scroll `:253`, wait_for `:307`, get_text `:346`, evaluate `:396`, query_elements `:438`, plus cookie/storage/state APIs (`:868-1005`) and a session registry (`:1049-1080`). However, the *live MCP tool surface* exposes only a fraction of this: `src/npl_mcp/launcher.py:1886-1966` registers Browser.Interact.Navigate/Click/Fill/GetState, Browser.ListSessions, Browser.CloseSession — and Navigate/Click take only `session_id`+`url`/`selector`, with no `wait_for`/`timeout` parameters. Scroll, wait_for, get_text, query_elements, and evaluate exist in `stub_catalog.py` as stubs that return `{"status": "stub"}` when called via ToolCall (`launcher.py:434-437`). Confidence: high (implementations read directly).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Agent can open a URL in a managed browser session | Met | `Browser.Interact.Navigate` live (`launcher.py:1886-1966`); `BrowserSession.navigate` (`interact.py:67`) |
| Navigation waits for page readiness | Partially Met | implementation waits networkidle + CSS (`interact.py:67`), but the live MCP tool does not expose wait_for/timeout params |
| Agent can click links/buttons by selector | Met | `Browser.Interact.Click` live; `interact.py:105` |
| Agent can scroll and read page content | Not Met | scroll is a stub (`stub_catalog.py` browser_scroll); get_text (`interact.py:346`) not registered as a live tool |
| Multiple concurrent named sessions | Partially Met | session registry supports it (`interact.py:1049-1077`) and List/Close tools are live, but Fill/GetState are the only other live interact verbs |

## Gaps / Risks

- Wide gap between BrowserSession capability and the registered MCP tool surface — most story-level functionality is unreachable by agents today.
- Stubs return `{"status": "stub"}` rather than an error, which can mislead agents into thinking an action succeeded.

## BDD Scenario

```gherkin
Feature: Browser navigation via MCP
  Scenario: Agent opens and interacts with a page
    Given a running NPL MCP server
    When the agent calls Browser.Interact.Navigate with a URL
    Then the page loads and a state snapshot is returned
    And Browser.Interact.Click activates a selector
  Scenario: Agent attempts to scroll
    When the agent calls the scroll tool
    Then a stub status is returned and no scrolling occurs
```
