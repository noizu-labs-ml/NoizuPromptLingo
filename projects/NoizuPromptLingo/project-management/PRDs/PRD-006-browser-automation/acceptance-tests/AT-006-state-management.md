# AT-006: State Management

**Category**: Integration
**Related FR**: FR-006
**Status**: Not Started

## Description

Validates browser state management including viewport, cookies, and localStorage.

## Test Implementation

```python
def test_browser_get_state():
    """Get comprehensive browser state."""
    await browser_navigate(url="https://example.com", session_id="state")

    result = await browser_get_state(session_id="state")
    assert "url" in result
    assert "title" in result
    assert "viewport" in result
    assert result["viewport"]["width"] > 0
    assert result["viewport"]["height"] > 0

def test_browser_set_viewport():
    """Set and verify viewport size."""
    await browser_navigate(url="https://example.com", session_id="viewport")

    result = await browser_set_viewport(
        width=800,
        height=600,
        session_id="viewport"
    )
    assert result["width"] == 800
    assert result["height"] == 600

    state = await browser_get_state(session_id="viewport")
    assert state["viewport"]["width"] == 800
    assert state["viewport"]["height"] == 600

def test_browser_cookies():
    """Set, get, and clear cookies."""
    await browser_navigate(url="https://example.com", session_id="cookies")

    # Set cookie
    set_result = await browser_set_cookie(
        name="test_cookie",
        value="test_value",
        domain="example.com",
        session_id="cookies"
    )
    assert set_result["set"] is True

    # Get cookies
    get_result = await browser_get_cookies(session_id="cookies")
    assert len(get_result["cookies"]) > 0
    cookie_names = [c["name"] for c in get_result["cookies"]]
    assert "test_cookie" in cookie_names

    # Clear cookies
    clear_result = await browser_clear_cookies(session_id="cookies")
    assert clear_result["cleared"] is True

    verify = await browser_get_cookies(session_id="cookies")
    assert len(verify["cookies"]) == 0

def test_browser_local_storage():
    """Set and get localStorage values."""
    await browser_navigate(url="https://example.com", session_id="storage")

    # Set value
    set_result = await browser_set_local_storage(
        key="user_id",
        value="12345",
        session_id="storage"
    )
    assert set_result["set"] is True

    # Get specific key
    get_result = await browser_get_local_storage(
        key="user_id",
        session_id="storage"
    )
    assert get_result["value"] == "12345"

    # Get all keys
    all_result = await browser_get_local_storage(session_id="storage")
    assert "user_id" in all_result
    assert all_result["user_id"] == "12345"
```

## Acceptance Criteria

- [ ] Get state returns URL, title, viewport, cookies, localStorage
- [ ] Set viewport resizes browser and reflows page
- [ ] Viewport validation enforces min/max dimensions
- [ ] Set cookie stores with domain/path/expiry
- [ ] Get cookies returns all or domain-filtered cookies
- [ ] Clear cookies removes all or domain-filtered cookies
- [ ] Set localStorage stores key-value pairs
- [ ] Get localStorage returns single key or all keys
- [ ] localStorage quota exceeded handled gracefully
- [ ] Cross-origin restrictions enforced

## Coverage

Covers:
- Complete state inspection
- Viewport management
- Cookie CRUD operations
- localStorage CRUD operations
- Validation and error handling
- Security boundaries
