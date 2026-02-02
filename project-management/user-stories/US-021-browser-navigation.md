# User Story: Navigate and Interact with Web Pages

**ID**: US-021
**Persona**: P-001 (AI Agent)
**Priority**: Medium
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As an **AI agent**,
I want to **navigate to URLs and interact with page elements**,
So that **I can perform end-to-end testing and web automation tasks**.

## Acceptance Criteria

- [ ] Can navigate to any URL with configurable timeout (default: 30s)
- [ ] Can wait for specific CSS selector after navigation
- [ ] Supports wait-until strategies ("networkidle")
- [ ] Can click elements by CSS selector with configurable timeout
- [ ] Can scroll page or specific elements in four directions (up, down, left, right)
- [ ] Can wait for elements to reach specific states (visible, hidden, attached, detached)
- [ ] Can get text content from elements matching CSS selectors
- [ ] Can query multiple elements matching a selector (with limit)
- [ ] Can execute JavaScript expressions in page context
- [ ] Returns current page state (URL, title, viewport, scroll position)
- [ ] Supports session-based browser isolation (session_id parameter)
- [ ] All operations return structured result with success/failure status

## Notes

- Foundation for all browser automation workflows
- Uses Playwright under the hood with BrowserSession abstraction
- All selectors are CSS (Playwright native support)
- Built-in waiting strategies: waits for "networkidle" by default on navigation
- Session management allows parallel browser contexts with isolated state
- JavaScript execution via `browser_evaluate` supports arbitrary expressions
- Error handling returns structured InteractionResult with timestamps

## Dependencies

- Playwright browser automation library
- `npl_mcp.browser.interact.BrowserSession` class
- `npl_mcp.browser.capture.get_browser_manager()` for context management

## Open Questions

- ~~How to handle multiple browser sessions?~~ → **Resolved**: Sessions managed via `session_id` parameter with session registry
- ~~Should there be session timeout/cleanup?~~ → **Resolved**: Manual cleanup via `close_session()` API
- Should navigation support additional wait strategies beyond "networkidle"?
- Should scroll operations support smooth scrolling vs. instant jumps?

## Related MCP Tools

All tools accept `session_id` parameter for browser session isolation (default: "default").

| Tool | Purpose | Key Parameters |
|:-----|:--------|:---------------|
| `browser_navigate` | Navigate to URL | `url`, `wait_for`, `timeout` (default: 30000ms) |
| `browser_click` | Click element | `selector`, `timeout`, `screenshot_after` |
| `browser_scroll` | Scroll page/element | `direction` (up/down/left/right), `amount`, `selector` |
| `browser_wait_for` | Wait for element state | `selector`, `state` (visible/hidden/attached/detached), `timeout` |
| `browser_get_text` | Extract text content | `selector`, `timeout` |
| `browser_query_elements` | Query multiple elements | `selector`, `limit` (default: 10) |
| `browser_evaluate` | Execute JavaScript | `expression` (JS code) |

## Implementation Files

- **MCP Tool Definitions**: `/worktrees/main/mcp-server/src/npl_mcp/unified.py` (lines 598-913)
- **BrowserSession Class**: `/worktrees/main/mcp-server/src/npl_mcp/browser/interact.py`
- **Result Types**: `InteractionResult`, `PageState`, `ElementInfo` dataclasses

## Technical Details

### URL Handling

- Absolute URLs required (e.g., `https://example.com`)
- Supports all protocols Playwright recognizes (http, https, file)
- Navigation waits for "networkidle" by default (no network activity for 500ms)
- Optional `wait_for` parameter accepts CSS selector to wait for specific element

### Session Management

Sessions are stored in a global registry (`_sessions` dict in `interact.py`):
- `get_or_create_session(session_id)` - Lazy initialization of browser contexts
- Each session maintains isolated browser state (cookies, localStorage, etc.)
- Session cleanup via `close_session(session_id)` or automatic on page close

### Error Handling

All operations return `InteractionResult` with:
- `success`: Boolean indicating operation outcome
- `action`: Operation name (e.g., "navigate", "click")
- `target`: Target identifier (URL, selector, etc.)
- `message`: Human-readable success/error message
- `timestamp`: ISO 8601 timestamp

### JavaScript Execution

The `browser_evaluate` tool:
- Executes arbitrary JavaScript in page context
- Supports both expressions and statements
- Returns serializable JSON values
- Errors returned as `{"error": "message"}` dict

## Example Usage Scenarios

### Basic Navigation Flow
```
1. browser_navigate(url="https://example.com", session_id="test-session")
   → Returns page state with URL, title, viewport
2. browser_wait_for(selector=".content", state="visible", session_id="test-session")
   → Waits up to 10s for content to appear
3. browser_get_text(selector="h1", session_id="test-session")
   → Extracts heading text
```

### Form Interaction
```
1. browser_navigate(url="https://example.com/form")
2. browser_click(selector="#input-field")
3. browser_fill(selector="#input-field", value="test data")
4. browser_click(selector="button[type=submit]", screenshot_after=True)
   → Captures screenshot after submission
```

### Element Discovery
```
1. browser_query_elements(selector=".product-card", limit=20)
   → Returns list of up to 20 elements with:
     - tag name
     - text content (first 100 chars)
     - visibility status
     - bounding box coordinates
     - all HTML attributes
```
