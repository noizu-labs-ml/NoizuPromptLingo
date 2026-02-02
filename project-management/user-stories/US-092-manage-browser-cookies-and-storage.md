# User Story: Manage Browser Cookies and Storage

**ID**: US-092
**Persona**: P-001 (AI Agent)
**Priority**: Medium
**Status**: Documented
**Created**: 2026-02-02

## Story

As an **AI agent**,
I want to **read and modify browser cookies and localStorage**,
So that **I can manage session state and authentication tokens for automated workflows**.

## Acceptance Criteria

- [ ] Can retrieve all cookies for current page via `browser_get_cookies()`
- [ ] Can set individual cookies with domain/path via `browser_set_cookie()`
- [ ] Can clear all cookies via `browser_clear_cookies()`
- [ ] Can read localStorage values via `browser_get_local_storage()`
- [ ] Can write localStorage values via `browser_set_local_storage()`
- [ ] Cookie operations support domain and path parameters
- [ ] Storage operations persist across page navigations in same session

## Implementation Status

✅ **Implemented in mcp-server worktree**

### MCP Tools

- `browser_get_cookies(session_id)` - Get all cookies with metadata
- `browser_set_cookie(name, value, session_id, domain, path)` - Set cookie
- `browser_clear_cookies(session_id)` - Clear all cookies
- `browser_get_local_storage(session_id, key)` - Get localStorage value(s)
- `browser_set_local_storage(key, value, session_id)` - Set localStorage value

### Source Files

- Implementation: `worktrees/main/mcp-server/src/npl_mcp/browser/interact.py`
- Tool Definitions: `worktrees/main/mcp-server/src/npl_mcp/unified.py` (lines 1305-1419)

### Documentation Briefs

- **Category Brief**: `.tmp/mcp-server/categories/07-browser-automation.md`
- **Tool List**: `.tmp/mcp-server/tools/by-category/browser-tools.yaml`

## Example Usage

```python
# Get all cookies
cookies = await browser_get_cookies(session_id="auth")
# Returns: {cookies: [{name, value, domain, path, expires, httpOnly, secure, sameSite}], count: N}

# Set authentication cookie
await browser_set_cookie("session_token", "abc123xyz", session_id="auth", domain="example.com")

# Manage localStorage
await browser_set_local_storage("user_prefs", '{"theme":"dark"}', session_id="app")
prefs = await browser_get_local_storage(session_id="app", key="user_prefs")

# Clear all cookies
await browser_clear_cookies(session_id="auth")
```

## Related Stories

- US-019: Automate Form Submission
- US-021: Navigate and Interact with Web Pages
- US-024: Manage Browser Session State
