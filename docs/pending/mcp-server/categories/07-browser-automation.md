# Category: Browser Automation

**Category ID**: C-07
**Tool Count**: 32
**Status**: Documented
**Source**: worktrees/main/mcp-server
**Documentation Source Date**: 2026-02-02

## Overview

The Browser Automation category provides comprehensive Playwright-based browser automation capabilities for web interaction, screenshot capture, visual comparison, and session management. This category enables LLM agents to interact with web pages programmatically, capture visual state, perform regression testing, and maintain persistent browser sessions for complex workflows.

The implementation includes sophisticated viewport management (desktop/mobile/custom), theme control (light/dark mode), visual diff algorithms using pixelmatch, and checkpoint-based regression testing. All browser interactions return structured results and optionally create artifacts for audit trails.

## Features Implemented

### Feature 1: Screenshot Capture & Comparison
**Description**: Capture full-page or element-specific screenshots with viewport/theme control, and generate pixel-level visual diffs between screenshot artifacts.

**MCP Tools**:
- `screenshot_capture(url, name, viewport, theme, full_page, wait_for, wait_timeout, network_idle, session_id, created_by)` - Capture screenshot of webpage and store as artifact
- `screenshot_diff(baseline_artifact_id, comparison_artifact_id, threshold, session_id, created_by)` - Generate visual diff between two screenshots using pixelmatch algorithm
- `browser_screenshot(name, session_id, full_page, selector, created_by)` - Capture screenshot of current browser page or specific element

**Database Tables**:
- `artifacts` - Stores screenshot files and metadata
- `revisions` - Tracks artifact versions

**Web Routes**:
- `GET /artifact/{id}` - View screenshot artifact
- `GET /api/artifact/{id}` - Retrieve screenshot metadata

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/browser/capture.py`
- Diff Logic: `worktrees/main/mcp-server/src/npl_mcp/browser/diff.py`
- Checkpoint Management: `worktrees/main/mcp-server/src/npl_mcp/browser/checkpoint.py`
- Tool Definitions: `worktrees/main/mcp-server/src/npl_mcp/unified.py` (lines 438-595)

**Test Coverage**: Not specified in PROJECT_STATUS.md

**Example Usage**:
```python
# Capture desktop screenshot in dark theme
result = await screenshot_capture(
    url="https://example.com",
    name="homepage-dark",
    viewport="desktop",
    theme="dark",
    full_page=True,
    network_idle=True
)

# Compare two screenshots
diff = await screenshot_diff(
    baseline_artifact_id=1,
    comparison_artifact_id=2,
    threshold=0.1
)
```

### Feature 2: Browser Navigation & Page State
**Description**: Navigate to URLs, manage browser history, control viewport, and query page state including URL, title, viewport dimensions, and scroll position.

**MCP Tools**:
- `browser_navigate(url, session_id, wait_for, timeout)` - Navigate to URL with optional element wait
- `browser_get_state(session_id)` - Get current page URL, title, viewport, scroll position
- `browser_set_viewport(width, height, session_id)` - Change viewport dimensions
- `browser_go_back(session_id)` - Navigate back in history
- `browser_go_forward(session_id)` - Navigate forward in history
- `browser_reload(session_id)` - Reload current page
- `browser_wait_network_idle(session_id, timeout)` - Wait for network activity to cease

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/browser/interact.py`
- Tool Definitions: `worktrees/main/mcp-server/src/npl_mcp/unified.py` (lines 598-1302)

**Example Usage**:
```python
# Navigate to page and wait for content
await browser_navigate(
    url="https://app.example.com/dashboard",
    session_id="test-session",
    wait_for=".dashboard-loaded",
    timeout=30000
)

# Get current state
state = await browser_get_state(session_id="test-session")
# Returns: {url, title, viewport: {width, height}, scroll_position: {x, y}}
```

### Feature 3: Element Interaction
**Description**: Find, query, and interact with page elements using CSS selectors: click, fill forms, type text, select options, hover, focus, and scroll.

**MCP Tools**:
- `browser_click(selector, session_id, timeout, screenshot_after, artifact_name)` - Click element with optional post-click screenshot
- `browser_fill(selector, value, session_id, timeout)` - Fill form field instantly
- `browser_type(selector, text, session_id, delay, timeout)` - Type text character-by-character with delay
- `browser_select(selector, value, session_id, timeout)` - Select dropdown option
- `browser_hover(selector, session_id, timeout)` - Hover over element
- `browser_focus(selector, session_id, timeout)` - Focus on element
- `browser_scroll(direction, amount, selector, session_id)` - Scroll page or element
- `browser_wait_for(selector, state, session_id, timeout)` - Wait for element state (visible/hidden/attached/detached)
- `browser_press_key(key, session_id, modifiers)` - Press keyboard key with optional modifiers

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/browser/interact.py` (BrowserSession class)
- Tool Definitions: `worktrees/main/mcp-server/src/npl_mcp/unified.py` (lines 634-1076)

**Example Usage**:
```python
# Fill and submit login form
await browser_fill("input[name='username']", "test@example.com", session_id="login")
await browser_fill("input[name='password']", "secret123", session_id="login")
await browser_click("button[type='submit']", session_id="login", screenshot_after=True, artifact_name="login-result")

# Type with realistic delay
await browser_type("#search-input", "playwright automation", delay=100, session_id="search")
await browser_press_key("Enter", session_id="search")
```

### Feature 4: Content Extraction
**Description**: Extract text, HTML, and element information from pages using CSS selectors and JavaScript evaluation.

**MCP Tools**:
- `browser_get_text(selector, session_id, timeout)` - Get element text content
- `browser_get_html(session_id, selector, outer)` - Get page or element HTML (outerHTML/innerHTML)
- `browser_query_elements(selector, session_id, limit)` - Query multiple elements returning tag, text, visibility, bounding box, attributes
- `browser_evaluate(expression, session_id)` - Execute JavaScript expression in page context

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/browser/interact.py`
- Tool Definitions: `worktrees/main/mcp-server/src/npl_mcp/unified.py` (lines 830-913)

**Example Usage**:
```python
# Extract data from page
title_text = await browser_get_text("h1.page-title", session_id="scraper")
article_html = await browser_get_html(session_id="scraper", selector="article", outer=False)

# Query all product cards
products = await browser_query_elements(".product-card", session_id="scraper", limit=20)
# Returns: [{tag, text, visible, bounding_box, attributes}, ...]

# Evaluate custom JavaScript
result = await browser_evaluate("document.querySelectorAll('a').length", session_id="scraper")
```

### Feature 5: Page Injection & Modification
**Description**: Inject JavaScript and CSS into pages for custom behavior and styling modifications.

**MCP Tools**:
- `browser_inject_script(script, session_id)` - Inject JavaScript via script tag
- `browser_inject_style(css, session_id)` - Inject CSS styles

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/browser/interact.py`
- Tool Definitions: `worktrees/main/mcp-server/src/npl_mcp/unified.py` (lines 1230-1277)

**Example Usage**:
```python
# Add custom analytics tracking
await browser_inject_script("""
    console.log('Custom analytics loaded');
    window.trackEvent = (name, data) => { /* ... */ };
""", session_id="test")

# Apply custom styling
await browser_inject_style("""
    .ad-banner { display: none !important; }
    body { font-size: 16px; }
""", session_id="test")
```

### Feature 6: Cookie & Storage Management
**Description**: Read and modify browser cookies and localStorage for session management and state persistence.

**MCP Tools**:
- `browser_get_cookies(session_id)` - Get all cookies for current page
- `browser_set_cookie(name, value, session_id, domain, path)` - Set cookie with optional domain/path
- `browser_clear_cookies(session_id)` - Clear all cookies
- `browser_get_local_storage(session_id, key)` - Get localStorage value(s)
- `browser_set_local_storage(key, value, session_id)` - Set localStorage value

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/browser/interact.py`
- Tool Definitions: `worktrees/main/mcp-server/src/npl_mcp/unified.py` (lines 1305-1419)

**Example Usage**:
```python
# Get all cookies
cookies = await browser_get_cookies(session_id="auth")
# Returns: {cookies: [{name, value, domain, path, ...}], count: N}

# Set authentication cookie
await browser_set_cookie("session_token", "abc123xyz", session_id="auth", domain="example.com")

# Manage localStorage
await browser_set_local_storage("user_prefs", '{"theme":"dark"}', session_id="app")
prefs = await browser_get_local_storage(session_id="app", key="user_prefs")
```

### Feature 7: Session Management
**Description**: Create, manage, and close persistent browser sessions for multi-step workflows and state retention.

**MCP Tools**:
- `browser_close_session(session_id)` - Close browser session and cleanup resources
- `browser_list_sessions()` - List all active browser sessions

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/browser/interact.py`
- Tool Definitions: `worktrees/main/mcp-server/src/npl_mcp/unified.py` (lines 985-1019)

**Example Usage**:
```python
# Sessions are created automatically on first use
await browser_navigate(url="https://example.com", session_id="workflow-1")
await browser_click(".button", session_id="workflow-1")

# List active sessions
sessions = await browser_list_sessions()
# Returns: {sessions: ["workflow-1", "default"], count: 2}

# Close when done
await browser_close_session("workflow-1")
```

## MCP Tools Reference

### Screenshot Tools (3 tools)
1. `screenshot_capture(url, name, viewport, theme, full_page, wait_for, wait_timeout, network_idle, session_id, created_by)` → dict
2. `screenshot_diff(baseline_artifact_id, comparison_artifact_id, threshold, session_id, created_by)` → dict
3. `browser_screenshot(name, session_id, full_page, selector, created_by)` → dict

### Navigation Tools (5 tools)
4. `browser_navigate(url, session_id, wait_for, timeout)` → dict
5. `browser_go_back(session_id)` → dict
6. `browser_go_forward(session_id)` → dict
7. `browser_reload(session_id)` → dict
8. `browser_wait_network_idle(session_id, timeout)` → dict

### Interaction Tools (9 tools)
9. `browser_click(selector, session_id, timeout, screenshot_after, artifact_name)` → dict
10. `browser_fill(selector, value, session_id, timeout)` → dict
11. `browser_type(selector, text, session_id, delay, timeout)` → dict
12. `browser_select(selector, value, session_id, timeout)` → dict
13. `browser_hover(selector, session_id, timeout)` → dict
14. `browser_focus(selector, session_id, timeout)` → dict
15. `browser_scroll(direction, amount, selector, session_id)` → dict
16. `browser_wait_for(selector, state, session_id, timeout)` → dict
17. `browser_press_key(key, session_id, modifiers)` → dict

### Content Extraction Tools (4 tools)
18. `browser_get_text(selector, session_id, timeout)` → dict
19. `browser_get_html(session_id, selector, outer)` → dict
20. `browser_query_elements(selector, session_id, limit)` → dict
21. `browser_evaluate(expression, session_id)` → dict

### Page Modification Tools (2 tools)
22. `browser_inject_script(script, session_id)` → dict
23. `browser_inject_style(css, session_id)` → dict

### State Management Tools (6 tools)
24. `browser_get_state(session_id)` → dict
25. `browser_set_viewport(width, height, session_id)` → dict
26. `browser_get_cookies(session_id)` → dict
27. `browser_set_cookie(name, value, session_id, domain, path)` → dict
28. `browser_clear_cookies(session_id)` → dict
29. `browser_get_local_storage(session_id, key)` → dict
30. `browser_set_local_storage(key, value, session_id)` → dict

### Session Management Tools (2 tools)
31. `browser_close_session(session_id)` → dict
32. `browser_list_sessions()` → dict

## Database Model

### Tables
- `artifacts` - Stores screenshot files, diff images, and metadata
  - Fields: id, artifact_name, artifact_type, file_path, created_at, created_by, session_id
- `revisions` - Tracks artifact version history
  - Fields: id, artifact_id, revision_number, file_path, created_at

### Relationships
- artifacts.session_id → sessions.id (optional association)
- revisions.artifact_id → artifacts.id (one-to-many)

## User Stories Mapping

This category addresses:
- US-052: Browser automation timeout and retry handling
- US-042: Audit schema version compatibility (visual regression testing)
- US-048: Real-time agent workflow failure diagnostics (screenshot capture on error)

## Suggested PRD Mapping

- PRD-07: Browser Automation & Visual Testing
  - Screenshot capture with viewport/theme control
  - Visual regression testing with pixelmatch
  - Session-based browser interaction
  - Cookie and storage management

## API Documentation

### MCP Tool Signatures

**Screenshot Capture**
```python
async def screenshot_capture(
    url: str,
    name: str,
    viewport: str = "desktop",  # "desktop" (1280x720), "mobile" (375x667), or "WIDTHxHEIGHT"
    theme: str = "light",  # "light" or "dark"
    full_page: bool = True,
    wait_for: Optional[str] = None,  # CSS selector to wait for
    wait_timeout: int = 5000,  # milliseconds
    network_idle: bool = True,
    session_id: Optional[str] = None,
    created_by: Optional[str] = None,
) -> dict:
    """Returns: {artifact_id, file_path, metadata: {url, viewport, theme, captured_at}}"""
```

**Visual Diff**
```python
async def screenshot_diff(
    baseline_artifact_id: int,
    comparison_artifact_id: int,
    threshold: float = 0.1,  # 0.0-1.0 sensitivity
    session_id: Optional[str] = None,
    created_by: Optional[str] = None,
) -> dict:
    """Returns: {diff_artifact_id, diff_percentage, diff_pixels, total_pixels, dimensions_match, status, baseline, comparison, file_path}"""
```

**Browser Navigation**
```python
async def browser_navigate(
    url: str,
    session_id: str = "default",
    wait_for: Optional[str] = None,
    timeout: int = 30000,
) -> dict:
    """Returns: {success, action, message, page: {url, title, viewport}}"""
```

**Element Interaction**
```python
async def browser_click(
    selector: str,
    session_id: str = "default",
    timeout: int = 5000,
    screenshot_after: bool = False,
    artifact_name: Optional[str] = None,
) -> dict:
    """Returns: {success, action, target, message, screenshot_artifact_id?}"""
```

**Content Extraction**
```python
async def browser_query_elements(
    selector: str,
    session_id: str = "default",
    limit: int = 10,
) -> dict:
    """Returns: {selector, count, elements: [{tag, text, visible, bounding_box, attributes}]}"""
```

**Cookie Management**
```python
async def browser_get_cookies(session_id: str = "default") -> dict:
    """Returns: {cookies: [{name, value, domain, path, expires, httpOnly, secure, sameSite}], count}"""

async def browser_set_cookie(
    name: str,
    value: str,
    session_id: str = "default",
    domain: Optional[str] = None,
    path: str = "/",
) -> dict:
    """Returns: {success, action, target, message}"""
```

### Web Endpoints

- `GET /artifact/{id}` - View artifact (screenshot/diff image)
- `GET /api/artifact/{id}` - Get artifact metadata JSON
- `GET /session/{id}` - View session with associated artifacts

## Dependencies

- **Internal**:
  - Artifact Manager (C-01) - stores screenshots and diffs
  - Session Manager (C-02) - associates browser artifacts with sessions
  - Database (C-04) - persists artifact metadata

- **External**:
  - `playwright` - browser automation
  - `Pillow` (PIL) - image processing
  - `pixelmatch` (via JS or Python port) - visual diff algorithm

## Testing

- **Test Files**:
  - `worktrees/main/mcp-server/tests/test_browser_capture.py`
  - `worktrees/main/mcp-server/tests/test_browser_diff.py`
  - `worktrees/main/mcp-server/tests/test_browser_interact.py`

- **Coverage**: Not specified in PROJECT_STATUS.md

- **Key Test Cases**:
  - Screenshot capture with various viewport presets
  - Visual diff accuracy with known image pairs
  - Session persistence across multiple interactions
  - Cookie and localStorage read/write operations
  - Element selector edge cases (multiple matches, missing elements)
  - Network idle detection
  - JavaScript injection and evaluation

## Documentation References

- **README**: worktrees/main/mcp-server/README.md (Installation section: playwright install chromium)
- **USAGE**: worktrees/main/mcp-server/USAGE.md (no browser examples found)
- **PRD**: worktrees/main/mcp-server/docs/PRD.md (check for browser/screenshot requirements)
- **Status**: worktrees/main/mcp-server/PROJECT_STATUS.md (no explicit browser coverage data)

## Implementation Notes

### Viewport Presets
The system supports three viewport modes:
- `"desktop"` → 1280x720
- `"mobile"` → 375x667
- `"WIDTHxHEIGHT"` → Custom dimensions (e.g., "1920x1080")

### Theme Control
The `theme` parameter sets the browser's `prefers-color-scheme` media query:
- `"light"` → forces light mode
- `"dark"` → forces dark mode

This allows capturing screenshots in both themes without modifying page CSS.

### Network Idle Detection
When `network_idle=True`, the system waits for no network activity for 500ms before capturing. Set to `False` for ad-heavy sites that continuously make requests.

### Session Management
Browser sessions are created lazily on first use with `session_id`. All sessions share a single Playwright browser instance but maintain separate contexts. Use `browser_close_session()` to cleanup resources when done with long-running sessions.

### Diff Algorithm
Visual diffs use the pixelmatch algorithm with configurable threshold (0.0-1.0):
- `0.0` → maximum sensitivity (every pixel must match)
- `0.1` → default (ignores minor antialiasing differences)
- `1.0` → minimum sensitivity (only major changes detected)

Diff images highlight changed pixels in red for easy visual inspection.

### Checkpoint-Based Testing
The browser module includes checkpoint functionality (not exposed as MCP tools) for regression testing:
- `capture_checkpoint()` - captures multiple pages/themes/viewports in batch
- `compare_checkpoints()` - generates full regression report
- `generate_comparison_report()` - creates HTML report with side-by-side diffs

These are implemented in `checkpoint.py` and `report.py` but not currently exposed as MCP tools.
