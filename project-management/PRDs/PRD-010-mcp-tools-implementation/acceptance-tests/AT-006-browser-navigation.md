# AT-006: Browser Navigation and Screenshots

**Category**: Integration
**Related FR**: FR-021, FR-022
**Status**: Not Started

## Description

Validates browser session management, navigation, and screenshot capture.

## Test Implementation

```python
async def test_browser_navigation_and_screenshots():
    """Test browser automation workflow."""
    # Create session
    session = await browser_manager.manage_session(
        action="create",
        config={"viewport": {"width": 1280, "height": 720}}
    )

    # Navigate to page
    nav_result = await browser_manager.navigate(
        session_id=session.id,
        url="https://example.com",
        wait_for="body"
    )
    assert nav_result.status == "success"

    # Capture screenshot
    screenshot = await browser_manager.screenshot(
        session_id=session.id,
        full_page=True,
        format="png"
    )
    assert screenshot.artifact_id is not None

    # Verify artifact created
    artifact = await artifact_manager.get(screenshot.artifact_id)
    assert artifact.artifact_type == "screenshot"
```

## Acceptance Criteria

- [ ] Sessions created with configuration
- [ ] Navigation waits for conditions
- [ ] Screenshots stored as artifacts
- [ ] Full-page capture works
- [ ] Session cleanup occurs

## Coverage

Covers:
- Normal path: Navigate and capture
- Edge cases: Timeouts
- Error conditions: Invalid URLs
