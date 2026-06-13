# FR-003: Element Interaction

**Status**: Active

## Description

Provide comprehensive element interaction capabilities including clicking, typing, selecting, hovering, scrolling, and keyboard input. Nine tools enable full user interaction simulation.

**Tools**: `browser_click`, `browser_fill`, `browser_type`, `browser_select`, `browser_hover`, `browser_focus`, `browser_scroll`, `browser_wait_for`, `browser_press_key` (9 tools)

## Interface

```python
async def browser_click(
    selector: str,
    session_id: str = None,
    screenshot_after: bool = False,
    artifact_name: str = None
) -> dict:
    """Click element matching selector.

    Returns: {clicked: true, screenshot_artifact_id: int|null}
    """

async def browser_fill(
    selector: str,
    value: str,
    session_id: str = None
) -> dict:
    """Fill input element instantly (no typing delay)."""

async def browser_type(
    selector: str,
    text: str,
    delay: int = 0,  # milliseconds between keystrokes
    session_id: str = None
) -> dict:
    """Type text character-by-character with optional delay."""

async def browser_select(
    selector: str,
    value: str | list[str],
    session_id: str = None
) -> dict:
    """Select option(s) from <select> element."""

async def browser_hover(
    selector: str,
    session_id: str = None
) -> dict:
    """Hover over element to trigger hover effects."""

async def browser_focus(
    selector: str,
    session_id: str = None
) -> dict:
    """Focus element for keyboard input."""

async def browser_scroll(
    selector: str = None,
    x: int = None,
    y: int = None,
    session_id: str = None
) -> dict:
    """Scroll to element or coordinates."""

async def browser_wait_for(
    selector: str,
    state: str = "visible",  # visible, hidden, attached, detached
    timeout: int = 30000,
    session_id: str = None
) -> dict:
    """Wait for element to reach specified state."""

async def browser_press_key(
    key: str,  # e.g., "Enter", "Tab", "Escape"
    session_id: str = None
) -> dict:
    """Press keyboard key."""
```

## Behavior

- **Given** a selector and session
- **When** browser_click is called with screenshot_after=True
- **Then** element is clicked and screenshot artifact is created

- **Given** a text input selector and value
- **When** browser_fill is called
- **Then** input is cleared and filled instantly with value

- **Given** a selector with typing delay
- **When** browser_type is called
- **Then** text is typed character-by-character with delay between keystrokes

## Edge Cases

- **Element not found**: Return clear error with selector details
- **Element not visible**: Wait for visibility or return timeout error
- **Element not interactable**: Return error if element is disabled or obscured
- **Invalid selector syntax**: Return syntax error message
- **Multiple matches**: Interact with first matching element
- **Invalid key name**: Return error with valid key examples

## Related User Stories

- US-019
- US-020
- US-021
- US-052

## Test Coverage

Expected test count: 20-25 tests
Target coverage: 100% for this FR

**Test scenarios**:
- Click visible button
- Click with screenshot capture
- Fill input field
- Type with delay simulation
- Select single option
- Select multiple options
- Hover for dropdown
- Focus for keyboard input
- Scroll to element
- Wait for element visibility
- Press special keys (Enter, Tab, Escape)
- Element not found errors
- Timeout handling
- Disabled element handling
