# Review: Browser Automation Timeout & Retry Handling

- **Story**: `project-management/user-stories/US-052-browser-automation-timeout-and-retry-handling.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Timeouts exist; retries do not. Browser tools accept various timeout parameters: `capture_page` has a `wait_timeout` selector param and a hardcoded 30s `page.goto` timeout (`src/npl_mcp/browser/capture.py:189,225`), auth capture has `success_timeout` (`capture.py:291,335-337`), and downloads take a `timeout` (default 60s) (`src/npl_mcp/browser/download.py:27,35`). But there is no retry/backoff anywhere in the browser tools — searches for `retry`, `backoff`, and `max_retries` across `src/npl_mcp/browser/` return nothing — so there is no retry policy to configure, no fail-fast override, and no retry-specific diagnostic capture. Failed tool calls do land in structured error storage (`npl_tool_errors` via `src/npl_mcp/storage/error_log.py:4-27`: tool name, exception type, message, session, stack excerpt), which partially covers diagnostics though it records no URL/screenshots/console state. A browser checkpoint subsystem exists (`src/npl_mcp/browser/checkpoint.py`) as the US-024 integration point, but nothing ties it to a retry flow.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Browser tools accept timeout parameter (default 30s) | Partially Met | `capture.py:225` hardcodes 30000ms for `goto`; `wait_timeout` (`capture.py:189`) and download `timeout` (`download.py:27`) are parameters — but not uniformly exposed across navigate/screenshot/form-fill tools as a policy knob |
| Automatic retry on timeout (max 3, exponential backoff) | Not Met | no evidence found in `src/npl_mcp/browser/` |
| Failed retries logged with full diagnostics (URL, screenshots, console errors) | Partially Met | tool errors are logged with type/message/stack/session (`error_log.py:10-27`); no URL/screenshot/console-error bundle on failure |
| User-configurable retry policy in session config | Not Met | no evidence found |
| Manual override to skip retry and fail fast | Not Met | no evidence found (moot while no retry exists) |
| Integration with existing browser checkpoint system (US-024) | Partially Met | `checkpoint.py` exists as substrate; no retry/checkpoint integration code |

## Gaps / Risks

- The story's core value (transient-failure resilience) is absent; a single 30s goto timeout is the only navigation guard.
- Error logging truncates stack excerpts to 2048 chars (`error_log.py:13`), sufficient for diagnosis but not a full-fidelity failure bundle.

## BDD Scenario

```gherkin
Feature: Resilient browser automation

  Scenario: Transient network failure
    Given an agent navigating to a flaky URL
    When the goto times out after 30s
    Then the tool call fails and the error is recorded in npl_tool_errors
    And the story expects 3 exponential-backoff retries with diagnostic capture — not implemented

  Scenario: Fail-fast override
    Given a session configured with retry disabled
    When a navigation times out
    Then the story expects immediate failure without retries
    But no retry policy layer exists, so this scenario cannot be executed
```
