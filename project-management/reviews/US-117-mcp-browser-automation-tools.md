# Review: MCP Browser Automation Tools

- **Story**: `project-management/user-stories/US-117-mcp-browser-automation-tools.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Implemented in the Python server with a Playwright-backed browser stack: `src/npl_mcp/browser/capture.py` (screenshots with viewport presets or WxH and light/dark color-scheme, capture.py:38-51,97-125), `checkpoint.py` + `diff.py` (named checkpoints with manifests, pixelmatch-style comparison with configurable 0.0-1.0 threshold, diff.py:159-294, checkpoint.py:430-441), and `interact.py` (a session-keyed browser manager with navigate/click/fill/get_state, add_script/add_style injection with error handling, and session list/close, interact.py:67-152,752-811,1066-1077). All are exposed via launcher tools Browser.Capture, Browser.Checkpoint, Browser.ListCheckpoints, Browser.CompareCheckpoints, Browser.Diff, Browser.Interact.Navigate/Click/Fill/GetState, Browser.ListSessions, Browser.CloseSession (launcher.py:1849-2057). The Elixir backend (noted: Elixir backend at /Users/keithbrings/Work/Space/Noizu/projects/NoizuPromptLingo/backend) offers a parallel surface (domains/browser/tools/: navigate, click, fill, get_state, screenshot, record_start/stop). The only criterion short of full is form submission: fill and click primitives exist, but there is no dedicated form-submission automation (e.g., fill-multiple-fields-and-submit helper).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Capture screenshots with viewport and theme control | Met | `src/npl_mcp/browser/capture.py:97-125` — viewport presets (desktop/mobile/tablet/4k/WxH) at :38-51 and `color_scheme` dark/light at :123 |
| Compare screenshots with configurable threshold | Met | `pixelmatch(threshold=0.1)` with per-pixel YIQ color-distance comparison `src/npl_mcp/browser/diff.py:159-202`; `compare_checkpoints(threshold=...)` checkpoint.py:430-441 |
| Automate form submission | Partially Met | `fill` (interact.py:146) + `click` (interact.py:105) primitives; no dedicated form-submit automation or multi-field form helper in either codebase |
| Navigate and interact with web pages | Met | `InteractSession.navigate` interact.py:67-101, click/fill/get_state; Elixir backend navigate/click/fill/get_state tools in `domains/browser/tools/` |
| Manage browser session state | Met | Session-keyed manager (interact.py:46-67), `list_sessions`/`close_session` interact.py:1066-1077, launcher Browser.ListSessions/CloseSession; auth-persistent `session_key` in checkpoints (checkpoint.py:254-266) |
| Inject scripts and styles | Met | `add_script`/`add_style` via Playwright `add_script_tag`/`add_style_tag` with failure capture, interact.py:752-811 |

## Gaps / Risks

- No dedicated form-submission flow: automating a full form requires the caller to chain Fill+Click manually with no atomicity.
- Diff results depend on locally stored checkpoint PNGs under a screenshots/checkpoints directory — no central storage, so comparisons only work on the machine that captured them.
- Script/style injection executes arbitrary JS/CSS in the target page by design — safe for QA use, but no allowlisting or guard if pointed at production URLs.
- Session state is in-memory in the Python server; Browser.Interact sessions are lost on server restart (checkpoint session_key persistence covers auth cookies only).
- No browser automation tests in `tests/` beyond static asset/screenshot-module checks; the Playwright paths are exercised only manually.

## BDD Scenario

```gherkin
Feature: Automated visual regression testing via MCP

  Scenario: Capture and compare themed screenshots
    Given the MCP server has Playwright available
    When the agent calls ToolCall("Browser.Checkpoint", {"name": "login-dark", "url": "https://app.example/login", "viewport": "mobile", "theme": "dark"})
    Then a screenshot is stored as a named checkpoint with manifest metadata (git commit, viewport, theme)
    When the agent calls ToolCall("Browser.CompareCheckpoints", {"base": "login-dark", "candidate": "login-dark-v2", "threshold": 0.05})
    Then a pixel-level diff runs with the 0.05 sensitivity threshold
    And the result classifies the change (pass/minor/major) with a diff image

  Scenario: Drive a form through a live session
    When the agent calls ToolCall("Browser.Interact.Navigate", {"session_id": "qa-1", "url": "https://app.example/signup"})
    Then the page loads inside session "qa-1"
    When the agent calls ToolCall("Browser.Interact.Fill", {"session_id": "qa-1", "selector": "#email", "value": "qa@example.com"})
    And ToolCall("Browser.Interact.Click", {"session_id": "qa-1", "selector": "button[type=submit]"})
    Then the form is submitted through the primitives
    # A dedicated one-shot form automation tool does not exist.
```
