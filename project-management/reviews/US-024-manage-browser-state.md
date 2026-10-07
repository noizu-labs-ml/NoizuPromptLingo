# Review: Manage Browser State

- **Story**: `project-management/user-stories/US-024-manage-browser-state.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The state-management layer is fully built inside `BrowserSession` (`src/npl_mcp/browser/interact.py`): cookies get/set/clear (`:868`, `:882`, `:929`), localStorage get/set (`:954`, `:977`), and a composed `get_page_state` snapshot (`:415`) covering URL/title/scroll/elements. The session registry supports concurrent named sessions with list and close (`:1049-1080`). However, the **live MCP tool surface** (`src/npl_mcp/launcher.py:1886-1966`) exposes only Navigate/Click/Fill/GetState plus ListSessions/CloseSession — there are no live MCP tools for cookie or localStorage operations, so agents cannot actually manage browser state through the product surface; those methods are reachable only in-process/tests. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Agent can read current page state (url, title, elements) | Met | `Browser.Interact.GetState` live → `get_page_state` (`interact.py:415`) |
| Agent can set/get/clear cookies | Not Met at MCP surface | implemented in `BrowserSession` (`interact.py:868-929`) but no live MCP tool registered |
| Agent can manage localStorage | Not Met at MCP surface | implemented (`interact.py:954-977`) but not exposed via MCP |
| Named concurrent sessions with cleanup | Partially Met | registry + List/Close tools live (`interact.py:1049-1080`); no MCP tool to create *named* sessions explicitly |

## Gaps / Risks

- Pattern repeats across the browser cluster: strong engine, thin tool surface. Registering the existing methods as MCP tools is mostly mechanical.
- Untested surface: no browser/interact test files found under `tests/` — recommend coverage when tools are exposed.

## BDD Scenario

```gherkin
Feature: Manage browser state
  Scenario: Agent snapshots a page
    Given an open browser session via MCP
    When the agent calls Browser.Interact.GetState
    Then url, title, and element summary are returned
  Scenario: Agent tries to set a cookie via MCP
    When the agent needs to persist auth state in the browser
    Then no MCP tool exists for cookie/localStorage operations
    And the capability remains locked inside BrowserSession
```
