# FR-001: Screenshot & Visual Testing

**Status**: Active

## Description

Provide screenshot capture and visual diffing capabilities with viewport/theme control. Three tools enable capturing screenshots, comparing them pixel-by-pixel, and managing screenshot artifacts.

**Tools**: `screenshot_capture`, `screenshot_diff`, `browser_screenshot` (3 tools)

## Interface

```python
async def screenshot_capture(
    url: str,
    name: str,
    viewport: str = "desktop",  # desktop (1280x720), mobile (375x667), custom (WxH)
    theme: str = "light",       # light, dark (via prefers-color-scheme)
    full_page: bool = True
) -> dict:
    """Capture screenshot and save as artifact.

    Returns: {artifact_id, path, width, height, timestamp}
    """

async def screenshot_diff(
    baseline_artifact_id: int,
    comparison_artifact_id: int,
    threshold: float = 0.1  # 0.0=max sensitivity, 1.0=min sensitivity
) -> dict:
    """Compare screenshots using pixelmatch algorithm.

    Returns: {diff_percent, diff_artifact_id, match}
    """

async def browser_screenshot(
    session_id: str = None,
    name: str = "screenshot",
    full_page: bool = True
) -> dict:
    """Capture screenshot from active browser session."""
```

## Behavior

- **Given** a URL and viewport configuration
- **When** screenshot_capture is called
- **Then** page is rendered with specified viewport/theme and screenshot saved as artifact

- **Given** two artifact IDs containing screenshots
- **When** screenshot_diff is called with threshold
- **Then** pixelmatch algorithm compares images and returns diff percentage with diff image artifact

## Edge Cases

- **Invalid viewport format**: Return error message with valid format examples
- **Artifact not found**: Return 404 error for missing baseline/comparison artifacts
- **Non-image artifacts**: Validate artifacts contain images before diffing
- **Theme unsupported**: Fallback to light theme if browser doesn't support prefers-color-scheme

## Related User Stories

- US-012
- US-013

## Test Coverage

Expected test count: 10-15 tests
Target coverage: 100% for this FR

**Test scenarios**:
- Capture with different viewports (desktop, mobile, custom)
- Capture with light/dark themes
- Full page vs viewport-only screenshots
- Diff identical screenshots (0% diff)
- Diff different screenshots (>0% diff)
- Threshold sensitivity testing
- Invalid artifact IDs
- Missing session handling
