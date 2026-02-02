# AT-003: Element Interaction

**Category**: Integration
**Related FR**: FR-003
**Status**: Not Started

## Description

Validates all element interaction methods including clicking, typing, selecting, hovering, scrolling, and keyboard input.

## Test Implementation

```python
def test_browser_click_with_screenshot():
    """Click element and capture screenshot after."""
    await browser_navigate(url="https://example.com/form", session_id="click")

    result = await browser_click(
        selector="button[type='submit']",
        session_id="click",
        screenshot_after=True,
        artifact_name="after-submit"
    )
    assert result["clicked"] is True
    assert result["screenshot_artifact_id"] > 0

def test_browser_fill_and_type():
    """Fill input instantly vs type character-by-character."""
    await browser_navigate(url="https://example.com/form", session_id="input")

    fill_result = await browser_fill(
        selector="input[name='username']",
        value="testuser",
        session_id="input"
    )
    assert fill_result["filled"] is True

    type_result = await browser_type(
        selector="input[name='password']",
        text="password123",
        delay=50,
        session_id="input"
    )
    assert type_result["typed"] is True

def test_browser_select():
    """Select option from dropdown."""
    await browser_navigate(url="https://example.com/form", session_id="select")

    result = await browser_select(
        selector="select[name='country']",
        value="US",
        session_id="select"
    )
    assert result["selected"] is True

def test_browser_hover_and_scroll():
    """Hover over element and scroll to visibility."""
    await browser_navigate(url="https://example.com", session_id="hover")

    scroll_result = await browser_scroll(
        selector=".footer",
        session_id="hover"
    )
    assert scroll_result["scrolled"] is True

    hover_result = await browser_hover(
        selector=".dropdown-trigger",
        session_id="hover"
    )
    assert hover_result["hovered"] is True

def test_browser_wait_for_element():
    """Wait for element to become visible."""
    await browser_navigate(url="https://example.com/dynamic", session_id="wait")

    result = await browser_wait_for(
        selector=".loading-spinner",
        state="hidden",
        timeout=10000,
        session_id="wait"
    )
    assert result["state_reached"] is True

def test_browser_press_key():
    """Press keyboard key."""
    await browser_navigate(url="https://example.com", session_id="key")
    await browser_focus(selector="input[type='search']", session_id="key")

    result = await browser_press_key(key="Enter", session_id="key")
    assert result["pressed"] is True
```

## Acceptance Criteria

- [ ] Click interacts with visible elements
- [ ] Screenshot capture after click works
- [ ] Fill sets value instantly
- [ ] Type simulates character-by-character input with delay
- [ ] Select works with single and multiple options
- [ ] Hover triggers hover effects
- [ ] Scroll brings elements into viewport
- [ ] Wait for element supports visible/hidden/attached/detached states
- [ ] Press key sends keyboard events
- [ ] Element not found errors are clear
- [ ] Timeout errors handled gracefully

## Coverage

Covers:
- All 9 interaction tools
- Normal interaction paths
- Screenshot integration
- Wait/timeout behavior
- Element visibility handling
- Error conditions
