# Review: Automate Form Submission

- **Story**: `project-management/user-stories/US-019-automate-form-submission.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

A real Playwright-based interaction engine exists in `src/npl_mcp/browser/interact.py` (`InteractSession`: `navigate` :67, `click` :105, `fill` :146, `type_text` :181, `select` :218, `wait_for` :307, `query_elements` :438, `press_key` :511, `wait_for_network_idle` :814, `screenshot` :488), but only a subset is exposed as MCP tools: `Browser.Interact.Navigate` (`src/npl_mcp/launcher.py:1888`), `Browser.Interact.Click` (:1901), `Browser.Interact.Fill` (:1914), and `Browser.Interact.GetState` (:1927). The remaining story verbs — `browser_type`, `browser_select`, `browser_press_key`, `browser_wait_for`, `browser_wait_network_idle`, `browser_screenshot`, `browser_query_elements` — exist only as **stub catalog entries** (`src/npl_mcp/meta_tools/stub_catalog.py:317-351,395,464-475`) with no registered implementation; `ToolCall` on them returns `{"status": "stub"}` (`launcher.py:434-437`). Screenshots (`Browser.Capture`, `launcher.py:1853-1885`) return base64 PNG with no artifact linkage — `grep web_url/artifact` in `src/npl_mcp/browser/` finds nothing, and there is no form-submission orchestration returning a structured result with final URL + artifact ID. Confidence: high — engine, registrations, and stub catalog all read directly.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Navigate to form URL via `browser_navigate` | Met | `Browser.Interact.Navigate` → `interact.py:67-103` |
| Fill text inputs by CSS selector via `browser_fill` | Met | `Browser.Interact.Fill` → `interact.py:146-179` (`page.fill(selector, value)`) |
| Type with realistic delays via `browser_type` | Not Met | `type_text` implemented with `delay` (`interact.py:181-216`) but not registered as an MCP tool — stub only (`stub_catalog.py:328`) |
| Select dropdown by value via `browser_select` | Not Met | `select` implemented (`interact.py:218-251`) but unregistered — stub only (`stub_catalog.py:340`) |
| Submit via `browser_click` or `browser_press_key` | Partially Met | Click is exposed (`launcher.py:1901-1913`); `press_key` implemented (`interact.py:511-545`) but unregistered (`stub_catalog.py:351`) |
| Wait for result via `browser_wait_for` / `browser_wait_network_idle` | Not Met | both implemented (`interact.py:307-344, 814-843`) but unregistered (`stub_catalog.py:464-475`) |
| Screenshot after submission as artifact | Partially Met | `Browser.Capture` returns b64 PNG (`launcher.py:1853-1885`) but with no artifact ID / artifact-store linkage; `InteractSession.screenshot` unregistered |
| Detect validation errors by querying error elements | Not Met | `query_elements` implemented (`interact.py:438-486`) but unregistered; `Browser.Interact.GetState` offers page state but no element-level error query |
| Retry submission with corrected values | Not Met | possible only through repeated manual navigate/fill/click calls; no retry logic or guidance anywhere |
| Structured result: success, final URL, artifact ID | Not Met | `InteractionResult` carries success/action/message only; no final-URL field, no artifact ID (no evidence found) |

## Gaps / Risks

- The gap is exposure, not capability: five of the story's primitives already work inside `InteractSession` — registering them (fill/type/select/press_key/wait_for/screenshot/query_elements MCP wrappers) would close most of this story cheaply.
- Screenshot-as-artifact requires wiring `Browser.Capture` output into the artifact store (`src/npl_mcp/artifacts/`); today's b64 response is ephemeral and unreferenceable.
- Idempotency note from the story ("safe to retry") has no support: re-filling is fine via `page.fill`, but there is no form-state checkpoint to resume from.
- No tests exercise `interact.py` end-to-end (`tests/test_screenshot.py` and `test_download.py` cover adjacent capture paths only).

## BDD Scenario

```gherkin
Feature: Agent submits a web form end-to-end

  Scenario: Agent fills and submits a login form
    When the agent calls Browser.Interact.Navigate to the login URL
    And Browser.Interact.Fill on "#email" and "#password"
    And Browser.Interact.Click on "button[type=submit]"
    Then the actions succeed against the live page

  Scenario: Agent needs a dropdown or Enter-key submit
    When the agent attempts browser_select or browser_press_key via ToolCall
    Then the tool resolves to {"status": "stub"}
    And the agent cannot complete the form

  Scenario: Submission fails validation
    When the agent wants to read ".error-message" elements
    Then browser_query_elements is a stub
    And the agent cannot programmatically detect the validation errors

  Scenario: Agent archives proof of submission
    When the agent calls Browser.Capture after submitting
    Then it receives a base64 PNG
    And no artifact ID is returned to attach to a task
```
