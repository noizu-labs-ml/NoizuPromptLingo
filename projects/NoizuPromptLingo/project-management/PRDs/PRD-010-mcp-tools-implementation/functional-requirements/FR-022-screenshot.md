# FR-022: screenshot Tool

**Status**: Draft

## Description

Capture browser screenshot as versioned artifact.

## Interface

```python
async def screenshot(
    session_id: str,
    selector: str | None = None,
    full_page: bool | None = None,
    format: Literal["png", "jpeg", "webp"] | None = None,
    ctx: Context
) -> ScreenshotArtifact:
    """Capture browser screenshot."""
```

## Behavior

- **Given** session ID and optional capture options
- **When** screenshot is invoked
- **Then**
  - Captures viewport or specified element
  - Stores as versioned artifact in artifact system
  - Supports full-page scrolling capture
  - Compresses based on format selection
  - Returns ScreenshotArtifact with artifact_id, dimensions, file_size

## Edge Cases

- **Invalid session**: Return not found error
- **Selector not found**: Return element not found error
- **Full page too large (>20MB)**: Return size limit error
- **Invalid format**: Use default "png"

## Related User Stories

- US-061-077
- US-078-083

## Test Coverage

Expected test count: 10-12 tests
Target coverage: 100% for this FR
