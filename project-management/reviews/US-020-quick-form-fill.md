# Review: Quick Form Fill for Developers

- **Story**: `project-management/user-stories/US-020-quick-form-fill.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

A single-field fill tool is exposed as a real MCP tool (`Browser.Interact.Fill`, `src/npl_mcp/launcher.py:1914`) backed by Playwright (`src/npl_mcp/browser/interact.py:146`, with selector wait via `timeout`). Typing simulation with per-keystroke delay exists in the library (`type_text`, `src/npl_mcp/browser/interact.py:181`, `delay: int = 50`) and multi-element querying exists (`query_elements`, `src/npl_mcp/browser/interact.py:438`) — but neither is exposed as an MCP tool; the `browser_type`/`browser_query_elements` names in `src/npl_mcp/meta_tools/stub_catalog.py:328,395` are stubs (metadata only, no implementation — `meta_tools/catalog.py:505-527` merges stubs for discoverability without wiring a callable). Multi-field `fill_form`, structured aggregate feedback (`{filled, failed, duration_ms}`), and the entire form-profile subsystem (save/apply/list/delete, session vs global scope, `.npl/form-profiles/` storage) have no evidence found. Overall confidence: high that only single-field fill is usable today.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Fill specific field via `browser_fill(selector, value)` | Met | `src/npl_mcp/launcher.py:1914-1923` (`Browser.Interact.Fill`), `src/npl_mcp/browser/interact.py:146-179` |
| Fill multiple fields via `browser_fill_form(field_map)` | Not Met | no evidence found (no multi-field wrapper anywhere) |
| Typing simulation `browser_type(selector, text, delay_ms=50)` | Partially Met | library exists (`src/npl_mcp/browser/interact.py:181-216`) but only stub catalog entry, not callable (`src/npl_mcp/meta_tools/stub_catalog.py:328`) |
| Works with dynamically rendered forms (waits for elements) | Partially Met | `fill`/`type_text` take `timeout` and Playwright waits for the selector; no explicit readiness wait beyond that (`src/npl_mcp/browser/interact.py:165,202`) |
| Structured feedback `{filled, failed, duration_ms}` | Not Met | per-field `InteractionResult` only (`src/npl_mcp/browser/interact.py:35`); no aggregate or duration |
| `save_form_profile` / `fill_from_profile` | Not Met | no evidence found |
| `list_form_profiles` / `delete_form_profile` | Not Met | no evidence found |
| Session-scoped or global profile storage | Not Met | no evidence found |
| Field discovery via `browser_query_elements("input, ...")` | Partially Met | `src/npl_mcp/browser/interact.py:438-486` (library only; MCP name is a stub, `src/npl_mcp/meta_tools/stub_catalog.py:395`) |
| Field metadata `{selector, type, name, placeholder, required, current_value}` | Partially Met | `query_elements` returns tag/text/visible/bounding_box/attributes (`interact.py:460-468`); attributes carry type/name/placeholder but no `current_value` |
| Auto-detect form structure and suggest mappings | Not Met | no evidence found |

## Gaps / Risks

- Entire profile subsystem absent — the story's core "quick access" value proposition (150x faster repeat fills) is unrealized.
- Library code (`type_text`, `query_elements`) exists but is unreachable through the tool surface; the stub catalog advertises tools that cannot execute (misleading discoverability).
- No duration/aggregated feedback; agents must fill fields one call at a time.

## BDD Scenario

```gherkin
Feature: Quick form fill for developers

  Scenario: Fill a single login field via MCP
    Given an interactive browser session is open on a login page
    When the agent calls Browser.Interact.Fill with selector "#email" and value "test@example.com"
    Then the field is filled and a success InteractionResult is returned

  Scenario: Reuse a saved form profile
    Given a profile "login-test-user" was previously saved
    When the agent calls fill_from_profile with name "login-test-user"
    Then no such tool exists today and the workflow fails
```
