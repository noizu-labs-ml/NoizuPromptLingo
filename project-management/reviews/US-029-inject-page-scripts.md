# Review: Inject Scripts and Styles

- **Story**: `project-management/user-stories/US-029-inject-page-scripts.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

`browser_inject_script` and `browser_inject_style` exist only as advertised stubs in `src/npl_mcp/meta_tools/stub_catalog.py:488-505` — the catalog header (`stub_catalog.py:1-4`) states these tools are "without implementations" and "return a 'stub' status when called via ToolCall". There is no `browser_inject` module under `src/npl_mcp/browser/` (files: capture, checkpoint, diff, download, interact, ping, report, rest, screenshot, secrets, to_markdown). The underlying Playwright page objects do perform internal `page.evaluate` calls (`src/npl_mcp/browser/interact.py:276-285`, `capture.py:242`), so a real implementation is feasible, but no injection tooling, CDP persistent-injection, CSP handling, audit logging, domain blocklist, or timeout protection exists. No tests cover injection (test hits for "react/inject" were HTML test assets only).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `browser_inject_script(code, persistent)` injects JavaScript | Not Met | stub only — `stub_catalog.py:488` |
| `browser_inject_style(css, persistent)` injects CSS | Not Met | stub only — `stub_catalog.py:497` |
| Injected JS executes in page context with DOM access | Not Met | no evidence found (internal `page.evaluate` in `interact.py:285` is not an exposed injection tool) |
| Returns execution result or error details | Not Met | no evidence found |
| Non-persistent injections apply to current page only | Not Met | no evidence found |
| Persistent injections survive navigations | Not Met | no evidence found |
| Async functions can be injected and awaited | Not Met | no evidence found |
| Validates injection source is trusted agent context | Not Met | no evidence found |
| Logs injections with timestamp + content hash | Not Met | no evidence found |
| Rejects injection on sensitive domains (configurable) | Not Met | no evidence found |
| Sanitizes injection content | Not Met | no evidence found |
| Requires explicit consent for persistent injections | Not Met | no evidence found |
| Clear error when CSP blocks injection | Not Met | no evidence found |
| Fallback suggestions on failure | Not Met | no evidence found |
| Graceful syntax-error handling | Not Met | no evidence found |
| Configurable timeout for long-running scripts | Not Met | no evidence found |

## Gaps / Risks

- Tools are discoverable via ToolSearch/ToolDefinition but non-functional — an agent selecting them gets a stub response, a trap for downstream automation.
- Security requirements (domain blocklist, audit hash, consent) are entirely unaddressed; any future implementation must treat these as gating, not optional.
- Dependency on an active browser session exists (Playwright session management in `browser/`), but the story's CDP-level API is not layered on it yet.

## BDD Scenario

```gherkin
Feature: Inject scripts and styles into pages

  Scenario: One-time script injection
    Given an active browser session on a loaded page
    When the agent calls browser_inject_script with JavaScript that modifies the DOM
    Then the script executes in page context and its result is returned

  Scenario: Persistent injection survives navigation
    Given a persistent script injection is active
    When the session navigates to a new page
    Then the script re-executes on the new document

  Scenario: Security guard (not implemented)
    When injection is attempted on a blocklisted domain
    Then the call is rejected and the attempt is audit-logged with a content hash
```

(Scenario describes target behavior — the tools currently return stub status when invoked.)
