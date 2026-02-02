# User Story: Manage Browser Session State

**ID**: US-024
**Persona**: P-001 (AI Agent)
**Priority**: Medium
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As an **AI agent**,
I want to **manage browser cookies, local storage, and session state**,
So that **I can maintain authenticated sessions, test different user states, and automate workflows that require session persistence**.

## Acceptance Criteria

- [ ] Can retrieve all cookies for the current page/domain
- [ ] Can set individual cookies with domain, path, and expiration
- [ ] Can clear all cookies for a session
- [ ] Can get specific localStorage key values
- [ ] Can set localStorage key-value pairs
- [ ] State persists within a browser session (until session closed)
- [ ] Can list all active browser sessions
- [ ] Can get current page state including URL, title, viewport, and scroll position
- [ ] Can close specific browser sessions to clean up resources

## Implementation Notes

- Essential for authenticated workflows and E2E testing
- Cookies support domain-specific settings for cross-domain testing
- localStorage is page-origin specific (protocol + domain + port)
- Session state includes: URL, page title, viewport dimensions, scroll position
- Browser sessions are identified by `session_id` (default: "default")

## Technical Details

### Cookie Management
- Cookies returned include: name, value, domain, path, expiration, secure flag
- Setting cookies supports optional domain and path parameters
- Clearing cookies affects all cookies in the current browser context

### Local Storage
- Get operations can retrieve specific keys or all storage data
- Set operations replace existing values for the specified key
- Storage is persisted until explicitly cleared or session closed

### Session Management
- Multiple concurrent browser sessions supported
- Each session maintains independent state (cookies, storage, navigation)
- Sessions can be explicitly closed to free resources

## Dependencies

- Browser automation infrastructure (Playwright)
- At least one active browser session (US-021)

## Related Commands

### Cookie Operations
- `browser_get_cookies` – Get all cookies for current page
- `browser_set_cookie` – Set a cookie with name, value, domain, path
- `browser_clear_cookies` – Clear all cookies in the session

### Storage Operations
- `browser_get_local_storage` – Get localStorage value by key
- `browser_set_local_storage` – Set localStorage key-value pair

### Session Management
- `browser_get_state` – Get current page state (URL, title, viewport, scroll)
- `browser_list_sessions` – List all active browser session IDs
- `browser_close_session` – Close a specific browser session

## Example Workflows

### Authenticated Testing
1. Navigate to login page (`browser_navigate`)
2. Fill and submit login form (`browser_fill`, `browser_click`)
3. Retrieve session cookies (`browser_get_cookies`)
4. Use cookies in subsequent test sessions (`browser_set_cookie`)

### State Persistence Testing
1. Set localStorage preferences (`browser_set_local_storage`)
2. Navigate to different pages
3. Verify localStorage persists (`browser_get_local_storage`)
4. Test behavior with cleared storage (`browser_clear_cookies`)

### Multi-Session Testing
1. Create multiple browser sessions with different states
2. List all sessions (`browser_list_sessions`)
3. Switch between sessions by `session_id`
4. Clean up sessions when done (`browser_close_session`)
