# Review: Extract Web Content Programmatically

- **Story**: `project-management/user-stories/US-091-extract-web-content-programmatically.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

All four capabilities have working library implementations in `src/npl_mcp/browser/interact.py` — `get_text` (`:346`), `get_html` (`:614`), `query_elements` (`:438`, returning tag/text/visible/bounding_box/attributes), and `evaluate` (`:396`) — plus `wait_for` with timeout (`:307`) and persistent session support via `get_or_create_session` (`:1052`). However, none is registered as an MCP tool in this checkout: `src/npl_mcp/unified.py` (cited by the story from another worktree) does not exist here, and `launcher.py` registers only Browser.Interact.{Navigate,Click,Fill,GetState}, Browser.Capture, and session tools (`src/npl_mcp/launcher.py:1847-1966`). The four names are advertised to agents solely as metadata-only stubs (`src/npl_mcp/meta_tools/stub_catalog.py:385, 395, 405, 422, 488, 497`) whose ToolCall returns a stub response. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `browser_get_text(selector)` extracts text | Partially Met | library impl `src/npl_mcp/browser/interact.py:346`; no registered tool, stub only (`src/npl_mcp/meta_tools/stub_catalog.py:385`) |
| `browser_get_html()` returns page/element HTML | Partially Met | `interact.py:614`; stub at `stub_catalog.py:422` |
| `browser_query_elements()` returns structured data | Partially Met | `interact.py:438` (returns tag/text/visible/bounding_box/attributes); stub at `stub_catalog.py:395` |
| `browser_evaluate()` executes custom JavaScript | Partially Met | `interact.py:396`; stub at `stub_catalog.py:405` |
| Timeout parameters for element wait | Partially Met | `wait_for` supports timeout (`interact.py:307`) but unexposed as a tool |
| Structured results with visibility, bounding box, attributes | Partially Met | implemented in `query_elements` (`interact.py:438`); not reachable via MCP |
| Works across persistent browser sessions | Partially Met | `get_or_create_session` (`interact.py:1052`); session tools registered (`launcher.py`) but extraction methods unexposed |

## Gaps / Risks

- ToolSearch advertises browser_get_text/get_html/query_elements/evaluate, but ToolCall on them yields stub responses — a discoverability/behavior mismatch that misleads agents.
- The story cites `src/npl_mcp/unified.py` lines 830-913; that file is absent in this checkout — registration must happen through `launcher.py` (or restore unified.py).
- Story status "Implemented in mcp-server worktree" overstates this checkout's state.

## BDD Scenario

```gherkin
Feature: Extract web content programmatically

  Scenario: Agent scrapes a product page today
    Given a browser session navigated to a page (Browser.Interact.Navigate works)
    When the agent calls ToolCall("browser_get_text", selector="h1.product-title")
    Then the catalog resolves the name but returns a stub response, not page text
    And the working implementation in browser/interact.py:346 is never reached
    And the agent cannot obtain element HTML, query metadata, or evaluate JS through MCP
```
