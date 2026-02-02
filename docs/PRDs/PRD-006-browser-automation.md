# PRD: Browser Automation

**PRD ID**: PRD-006
**Version**: 1.0
**Status**: Documented
**Documentation Source**: worktrees/main/mcp-server
**Last Updated**: 2026-02-02

## Executive Summary

Playwright-based browser automation with 32 MCP tools covering screenshot capture, visual diffing, navigation, element interaction, content extraction, page modification, state management, and session handling. Supports viewport/theme control and session-based workflows.

**Implementation Status**: ✅ Complete in mcp-server worktree

## Features Documented

### User Stories Addressed
- **US-012**: Capture screenshot of current work
- **US-013**: Compare screenshots for visual regression
- **US-019**: Automate form submission
- **US-020**: Quick form fill for developers
- **US-021**: Navigate and interact with web pages
- **US-024**: Manage browser session state
- **US-029**: Inject scripts and styles
- **US-052**: Browser automation timeout & retry handling

## Functional Requirements

### FR-001: Screenshot & Visual Testing (3 tools)
**Tools**: `screenshot_capture`, `screenshot_diff`, `browser_screenshot`
**Viewports**: desktop (1280x720), mobile (375x667), custom (WxH)
**Themes**: light, dark (via prefers-color-scheme)
**Diff Algorithm**: pixelmatch with configurable threshold (0.0-1.0)

### FR-002: Navigation & Page State (5 tools)
**Tools**: `browser_navigate`, `browser_go_back`, `browser_go_forward`, `browser_reload`, `browser_wait_network_idle`

### FR-003: Element Interaction (9 tools)
**Tools**: `browser_click`, `browser_fill`, `browser_type`, `browser_select`, `browser_hover`, `browser_focus`, `browser_scroll`, `browser_wait_for`, `browser_press_key`

### FR-004: Content Extraction (4 tools)
**Tools**: `browser_get_text`, `browser_get_html`, `browser_query_elements`, `browser_evaluate`

### FR-005: Page Modification (2 tools)
**Tools**: `browser_inject_script`, `browser_inject_style`

### FR-006: State Management (7 tools)
**Tools**: `browser_get_state`, `browser_set_viewport`, `browser_get_cookies`, `browser_set_cookie`, `browser_clear_cookies`, `browser_get_local_storage`, `browser_set_local_storage`

### FR-007: Session Management (2 tools)
**Tools**: `browser_close_session`, `browser_list_sessions`

## API Specification

### screenshot_capture
```python
result = await screenshot_capture(
    url="https://example.com",
    name="homepage-dark",
    viewport="desktop",
    theme="dark",
    full_page=True
)
```

### screenshot_diff
```python
diff = await screenshot_diff(
    baseline_artifact_id=1,
    comparison_artifact_id=2,
    threshold=0.1  # 0.0=max sensitivity, 1.0=min
)
```

### browser_click (with screenshot)
```python
await browser_click(
    selector="button[type='submit']",
    session_id="form",
    screenshot_after=True,
    artifact_name="after-submit"
)
```

### browser_query_elements
```python
elements = await browser_query_elements(
    selector=".product-card",
    session_id="scraper",
    limit=20
)
# Returns: {selector, count, elements: [{tag, text, visible, bounding_box, attributes}]}
```

## Dependencies
- **Internal**: Artifacts (C-02), Sessions (C-05), Database (C-01)
- **External**: playwright, Pillow, pixelmatch

## Testing
- **Coverage**: Not specified
- **Files**: tests/test_browser_*.py (if exist)

## Implementation Notes

**Viewport Presets**: desktop=1280x720, mobile=375x667
**Theme Control**: Sets prefers-color-scheme media query
**Network Idle**: Waits for 500ms of no network activity
**Session Management**: Lazy-created, shared browser instance, separate contexts

## Documentation References
- **Category Brief**: `.tmp/mcp-server/categories/07-browser-automation.md`
- **Tool Spec**: `.tmp/mcp-server/tools/by-category/browser-tools.yaml`
