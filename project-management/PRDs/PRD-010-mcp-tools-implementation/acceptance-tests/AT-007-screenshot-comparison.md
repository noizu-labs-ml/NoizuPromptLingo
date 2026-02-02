# AT-007: Screenshot Comparison and Diff Generation

**Category**: Integration
**Related FR**: FR-024
**Status**: Not Started

## Description

Validates screenshot comparison with diff visualization.

## Test Implementation

```python
async def test_screenshot_comparison():
    """Test screenshot comparison workflow."""
    # Setup
    session = await create_browser_session()

    # Capture baseline
    baseline = await browser_manager.screenshot(
        session_id=session.id
    )

    # Make page change (inject script)
    await browser_manager.inject_scripts(
        session_id=session.id,
        script="document.body.style.backgroundColor = 'red'"
    )

    # Capture comparison
    comparison = await browser_manager.screenshot(
        session_id=session.id
    )

    # Compare screenshots
    result = await browser_manager.compare_screenshots(
        baseline_id=baseline.artifact_id,
        comparison_id=comparison.artifact_id,
        threshold=0.01
    )

    assert not result.match
    assert result.diff_percentage > 0.01
    assert result.diff_artifact_id is not None
```

## Acceptance Criteria

- [ ] Pixel-by-pixel comparison works
- [ ] Diff image generated
- [ ] Threshold respected
- [ ] Ignore regions supported
- [ ] Match percentage accurate

## Coverage

Covers:
- Normal path: Detect differences
- Edge cases: Identical images
- Error conditions: Different dimensions
