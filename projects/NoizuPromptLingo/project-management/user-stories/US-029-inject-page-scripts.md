# User Story: Inject Scripts and Styles

**ID**: US-029
**Persona**: P-001 (AI Agent)
**Priority**: Low
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As an **AI agent**,
I want to **inject JavaScript and CSS into web pages**,
So that **I can modify page behavior for testing or automation**.

## Context

Script injection enables dynamic modification of page behavior without altering source code. This is useful for:
- Adding debugging overlays
- Injecting accessibility testing tools
- Manipulating DOM for automation
- Testing dynamic behaviors

**Implementation Approach**: Uses Chrome DevTools Protocol (CDP) `Page.addScriptToEvaluateOnNewDocument` for persistent injection and `Runtime.evaluate` for one-time execution.

## Acceptance Criteria

### Functional Requirements
- [ ] `browser_inject_script(code: str, persistent: bool = False)` injects JavaScript code
- [ ] `browser_inject_style(css: str, persistent: bool = False)` injects CSS styles
- [ ] Injected JavaScript executes in page context with access to DOM
- [ ] Returns execution result or error details
- [ ] Non-persistent injections apply to current page only
- [ ] Persistent injections survive page navigations within session
- [ ] Can inject async functions and await completion

### Security Requirements
- [ ] Validates injection source is from trusted agent context
- [ ] Logs all injection operations with timestamp and content hash
- [ ] Rejects injection on sensitive domains (configurable whitelist/blacklist)
- [ ] Sanitizes injection content to prevent unintended code execution
- [ ] Requires explicit consent for persistent injections

### Error Handling
- [ ] Returns clear error when CSP blocks injection
- [ ] Provides fallback suggestions when injection fails
- [ ] Handles syntax errors in injected code gracefully
- [ ] Times out long-running injected scripts (configurable timeout)

## Technical Implementation

### Injection Methods
1. **One-time execution**: `Runtime.evaluate` - executes immediately in page context
2. **Persistent injection**: `Page.addScriptToEvaluateOnNewDocument` - runs on every page load
3. **Style injection**: Creates and appends `<style>` element to `<head>`

### CSP Handling Strategy
- Detect CSP violations from browser console errors
- Attempt injection via CDP (bypasses some CSP restrictions)
- If blocked, return error with CSP policy details and suggested alternatives
- Log CSP-blocked attempts for security audit

### Example API Usage
```python
# One-time script injection
result = await browser.inject_script("""
    document.querySelector('#debug-panel').style.display = 'block';
    return document.title;
""")

# Persistent style injection
await browser.inject_style("""
    .debug-overlay {
        position: fixed;
        top: 0;
        right: 0;
        background: rgba(0,0,0,0.8);
    }
""", persistent=True)
```

## Dependencies

- Active browser session (`US-021: Browser Navigation`)
- Browser automation framework (Playwright or Puppeteer with CDP)

## Security Considerations

1. **Audit Trail**: All injections logged to `browser_audit.log` with SHA-256 hash
2. **Domain Restrictions**: Configurable blocklist prevents injection on banking, auth domains
3. **Agent Authentication**: Only authenticated agent contexts can inject
4. **Code Review**: Consider manual review requirement for persistent injections
5. **Timeout Protection**: Scripts auto-terminate after 30s (configurable)

## Related Commands

### MCP Tools
- `browser_inject_script(code: str, persistent: bool = False) -> dict`
  - Returns: `{"success": bool, "result": Any, "error": str | None}`
- `browser_inject_style(css: str, persistent: bool = False) -> dict`
  - Returns: `{"success": bool, "element_id": str, "error": str | None}`
- `browser_evaluate(expression: str, await_promise: bool = True) -> Any`
  - Lower-level alternative for simple expressions

## Test Scenarios

1. **Basic injection**: Inject script that modifies DOM, verify change visible
2. **Return values**: Inject script that returns data, verify returned correctly
3. **Async execution**: Inject async function with Promise, verify awaited
4. **Persistent injection**: Navigate to new page, verify script still active
5. **CSP blocking**: Test on CSP-protected page, verify graceful error
6. **Security audit**: Verify injection logged with correct metadata
7. **Timeout handling**: Inject infinite loop, verify timeout after 30s
8. **Style injection**: Inject CSS, verify styles applied to elements
