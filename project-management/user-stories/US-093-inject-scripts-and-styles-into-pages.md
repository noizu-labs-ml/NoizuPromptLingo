# User Story: Inject Scripts and Styles Into Pages

**ID**: US-093
**Persona**: P-001 (AI Agent)
**Priority**: Low
**Status**: Documented
**Created**: 2026-02-02

## Story

As an **AI agent**,
I want to **inject custom JavaScript and CSS into web pages**,
So that **I can modify page behavior and styling for testing or automation purposes**.

## Acceptance Criteria

- [ ] Can inject JavaScript via `browser_inject_script()`
- [ ] Can inject CSS styles via `browser_inject_style()`
- [ ] Scripts execute in page context with DOM access
- [ ] Styles apply immediately to page rendering
- [ ] Injections persist for session lifetime
- [ ] Multiple injections accumulate (not replace)

## Implementation Status

✅ **Implemented in mcp-server worktree**

### MCP Tools

- `browser_inject_script(script, session_id)` - Inject JavaScript via script tag
- `browser_inject_style(css, session_id)` - Inject CSS styles

### Source Files

- Implementation: `worktrees/main/mcp-server/src/npl_mcp/browser/interact.py`
- Tool Definitions: `worktrees/main/mcp-server/src/npl_mcp/unified.py` (lines 1230-1277)

### Documentation Briefs

- **Category Brief**: `.tmp/mcp-server/categories/07-browser-automation.md`
- **Tool List**: `.tmp/mcp-server/tools/by-category/browser-tools.yaml`

## Example Usage

```python
# Add custom analytics tracking
await browser_inject_script("""
    console.log('Custom analytics loaded');
    window.trackEvent = (name, data) => {
        console.log('Event:', name, data);
    };
""", session_id="test")

# Apply custom styling (hide ads, adjust fonts)
await browser_inject_style("""
    .ad-banner { display: none !important; }
    body { font-size: 16px; }
""", session_id="test")
```

## Related Stories

- US-019: Automate Form Submission
- US-021: Navigate and Interact with Web Pages
- US-024: Manage Browser Session State
- US-029: Inject Scripts and Styles (original)
