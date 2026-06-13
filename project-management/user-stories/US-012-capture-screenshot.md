# User Story: Capture Screenshot of Current Work

**ID**: US-012
**Persona**: P-003 (Vibe Coder)
**Priority**: Medium
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a **vibe coder**,
I want to **capture a screenshot of a web page and save it as an artifact**,
So that **I can quickly document visual state without manual screenshot tools**.

## Acceptance Criteria

- [ ] Can capture screenshot of any URL via `screenshot_capture`
- [ ] Supports viewport presets (desktop, tablet, mobile)
- [ ] Can toggle light/dark theme via `theme` parameter
- [ ] Supports full-page capture via `full_page` parameter
- [ ] Screenshot automatically saved as artifact with metadata (URL, viewport, timestamp, theme)
- [ ] Returns artifact ID, file path, and metadata
- [ ] Can wait for specific elements via `wait_for` selector
- [ ] Can wait for network idle via `network_idle` parameter
- [ ] Captured screenshot is associated with session if `session_id` provided

## Implementation Details

**Command**: `screenshot_capture`

**Required Parameters**:
- `url` (str) - The web page URL to capture
- `name` (str) - Name for the screenshot artifact

**Optional Parameters**:
- `viewport` (str) - Viewport preset: "desktop", "tablet", "mobile" (default: "desktop")
- `theme` (str) - Theme mode: "light" or "dark"
- `full_page` (bool) - Capture full scrollable page (default: true)
- `wait_for` (str) - CSS selector to wait for before capture
- `wait_timeout` (int) - Timeout in milliseconds for wait_for (default: 5000)
- `network_idle` (bool) - Wait for network to be idle before capture (default: true)
- `session_id` (str) - Associate screenshot with session
- `created_by` (str) - Persona/user capturing the screenshot

**Returns**:
```json
{
  "artifact_id": 88,
  "file_path": "/artifacts/homepage.png",
  "metadata": {
    "url": "https://example.com",
    "viewport": {"width": 1280, "height": 720, "preset": "desktop"},
    "theme": "light",
    "full_page": true,
    "captured_at": "2026-02-02T10:15:00Z"
  }
}
```

## Notes

- Replaces manual screenshot workflow
- Metadata automatically includes: URL, viewport (width/height/preset), theme, full_page flag, captured_at timestamp
- For multiple viewports, call `screenshot_capture` once per viewport configuration
- Screenshots are stored in the artifacts system and can be retrieved via `get_artifact`
- Screenshot artifacts can be shared in chat rooms via `share_artifact`

## Open Questions

- Default viewport sizes for desktop/tablet/mobile presets?
- How to handle sites requiring authentication? (Consider `browser_set_cookie` or `browser_set_local_storage` for auth tokens)
- Should we support capturing specific element regions via selector parameter?

## Related Commands

- `screenshot_capture` - Primary command for capturing screenshots (Screenshot Tools)
- `create_artifact` - Artifact storage (Artifact Tools)
- `get_artifact` - Retrieve screenshot artifact (Artifact Tools)
- `share_artifact` - Share screenshot in chat rooms (Chat Tools)
- `screenshot_diff` - Compare two screenshots (Screenshot Tools)
- `browser_screenshot` - Alternative screenshot via active browser session (Browser Tools)
