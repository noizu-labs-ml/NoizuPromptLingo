# Review: Inject Scripts and Styles Into Pages

- **Story**: `project-management/user-stories/US-093-inject-scripts-and-styles-into-pages.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Library implementations exist: `add_script` (`src/npl_mcp/browser/interact.py:752`) and `add_style` (`interact.py:783`), operating on the persistent Playwright session from `get_or_create_session` (`interact.py:1052`). Neither is registered as an MCP tool in this checkout: `launcher.py` exposes no inject tools (`src/npl_mcp/launcher.py:1847-1966`), and the two names are advertised only as metadata-only stubs (`src/npl_mcp/meta_tools/stub_catalog.py:488, 497`) whose ToolCall returns a stub response. The story cites `unified.py` lines 1230-1277, absent in this checkout. Persistence ("session lifetime") and accumulation semantics depend on DOM injection surviving SPA navigations — the implementations add nodes to the current document, so hard navigations clear them; nothing in the code re-applies injections after navigation. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `browser_inject_script()` injects JavaScript | Partially Met | `interact.py:752` impl; stub-only surface (`stub_catalog.py:488`) |
| `browser_inject_style()` injects CSS | Partially Met | `interact.py:783` impl; stub-only surface (`stub_catalog.py:497`) |
| Scripts execute in page context with DOM access | Partially Met | script-tag injection in the live page (`interact.py:752`) provides page context; not reachable via MCP |
| Styles apply immediately to page rendering | Partially Met | style-tag insertion (`interact.py:783`) applies on insert; unexposed |
| Injections persist for session lifetime | Partially Met | persists only until next document navigation; no re-application hook exists |
| Multiple injections accumulate (not replace) | Partially Met | no replacement logic in `interact.py:752,783` (append semantics), but no explicit accumulation guarantee/test |

## Gaps / Risks

- Injecting arbitrary JS/CSS is the most security-sensitive browser capability in the library; when exposed as a tool it should be gated (session ownership check, possibly an allowlist flag), none of which exists yet.
- Story's "persist for session lifetime" is not actually satisfied by the implementation across navigations — a re-injection or route hook would be needed.

## BDD Scenario

```gherkin
Feature: Inject scripts and styles into pages

  Scenario: Agent restyles a page for scraping (today)
    Given a persistent browser session on a target page
    When the agent calls ToolCall("browser_inject_style", css=".ad{display:none}")
    Then a stub response is returned and no style is applied
    And the working add_style implementation at interact.py:783 is unreachable
    And even if exposed, the style would vanish on the next full navigation
```
