# AT-001: Screenshot Capture and Visual Diffing

**Category**: Integration
**Related FR**: FR-001
**Status**: Not Started

## Description

Validates screenshot capture with viewport/theme control and pixel-perfect visual diffing between screenshots.

## Test Implementation

```python
def test_screenshot_capture_desktop_light():
    """Capture screenshot with desktop viewport and light theme."""
    result = await screenshot_capture(
        url="https://example.com",
        name="homepage-desktop-light",
        viewport="desktop",
        theme="light",
        full_page=True
    )
    assert result["artifact_id"] > 0
    assert result["width"] == 1280
    assert result["height"] >= 720

def test_screenshot_capture_mobile_dark():
    """Capture screenshot with mobile viewport and dark theme."""
    result = await screenshot_capture(
        url="https://example.com",
        name="homepage-mobile-dark",
        viewport="mobile",
        theme="dark",
        full_page=False
    )
    assert result["artifact_id"] > 0
    assert result["width"] == 375
    assert result["height"] == 667

def test_screenshot_diff_identical():
    """Diff two identical screenshots should return 0% difference."""
    baseline = await screenshot_capture(url="https://example.com", name="base")
    comparison = await screenshot_capture(url="https://example.com", name="comp")

    diff = await screenshot_diff(
        baseline_artifact_id=baseline["artifact_id"],
        comparison_artifact_id=comparison["artifact_id"],
        threshold=0.1
    )
    assert diff["diff_percent"] < 1.0
    assert diff["match"] is True

def test_screenshot_diff_different():
    """Diff two different screenshots should return >0% difference."""
    baseline = await screenshot_capture(url="https://example.com", name="base")
    comparison = await screenshot_capture(url="https://different.com", name="comp")

    diff = await screenshot_diff(
        baseline_artifact_id=baseline["artifact_id"],
        comparison_artifact_id=comparison["artifact_id"],
        threshold=0.1
    )
    assert diff["diff_percent"] > 0.0
    assert diff["diff_artifact_id"] > 0
```

## Acceptance Criteria

- [ ] Desktop viewport renders at 1280x720
- [ ] Mobile viewport renders at 375x667
- [ ] Dark theme applies prefers-color-scheme: dark
- [ ] Full page screenshots capture entire page height
- [ ] Screenshot artifacts saved with metadata
- [ ] Identical screenshots diff < 1%
- [ ] Different screenshots diff > 0%
- [ ] Diff images generated and saved as artifacts

## Coverage

Covers:
- Viewport presets (desktop, mobile)
- Theme control (light, dark)
- Full page vs viewport-only
- Visual diffing with pixelmatch
- Threshold sensitivity
- Artifact generation
