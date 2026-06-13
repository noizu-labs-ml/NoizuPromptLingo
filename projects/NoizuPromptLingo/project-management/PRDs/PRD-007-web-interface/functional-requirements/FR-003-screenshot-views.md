# FR-003: Screenshot Views

**Status**: Completed

## Description

Provide HTML routes for screenshot checkpoint listing, checkpoint detail views, and side-by-side screenshot comparisons. Screenshots are served from file system with proper content-type headers.

## Interface

```python
# Routes
@app.get("/screenshots")
async def screenshots_index() -> HTMLResponse:
    """Render checkpoint listing page."""

@app.get("/screenshots/checkpoint/{slug}")
async def checkpoint_detail(slug: str) -> HTMLResponse:
    """Render checkpoint detail page with all screenshots."""

@app.get("/screenshots/compare/{id}")
async def screenshot_comparison(id: str) -> HTMLResponse:
    """Render side-by-side screenshot comparison."""

@app.get("/screenshots/files/{path:path}")
async def screenshot_file(path: str) -> FileResponse:
    """Serve screenshot image file."""
```

## Behavior

- **Given** a user navigates to /screenshots
- **When** the page loads
- **Then** a list of all checkpoints is displayed

- **Given** a user clicks a checkpoint
- **When** the checkpoint detail page loads
- **Then** all screenshots for that checkpoint are displayed

- **Given** a user selects two screenshots to compare
- **When** the comparison page loads
- **Then** both screenshots are displayed side-by-side

## Edge Cases

- **No checkpoints**: Display "No checkpoints found" message
- **Invalid checkpoint slug**: Return 404 error
- **Missing screenshot file**: Return 404 error
- **Invalid file path**: Sanitize and validate path to prevent directory traversal

## Related User Stories

- US-003

## Test Coverage

Expected test count: 10-14 tests
Target coverage: 100% for this FR
