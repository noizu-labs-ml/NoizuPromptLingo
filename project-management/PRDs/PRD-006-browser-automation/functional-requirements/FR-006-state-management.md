# FR-006: State Management

**Status**: Active

## Description

Provide browser state management including viewport control, cookies, and localStorage. Seven tools enable comprehensive state inspection and modification.

**Tools**: `browser_get_state`, `browser_set_viewport`, `browser_get_cookies`, `browser_set_cookie`, `browser_clear_cookies`, `browser_get_local_storage`, `browser_set_local_storage` (7 tools)

## Interface

```python
async def browser_get_state(session_id: str = None) -> dict:
    """Get current browser state.

    Returns: {
        url: str,
        title: str,
        viewport: {width, height},
        cookies: list,
        local_storage: dict
    }
    """

async def browser_set_viewport(
    width: int,
    height: int,
    session_id: str = None
) -> dict:
    """Set viewport size."""

async def browser_get_cookies(
    session_id: str = None,
    domain: str = None
) -> dict:
    """Get cookies, optionally filtered by domain.

    Returns: {cookies: [{name, value, domain, path, expires}]}
    """

async def browser_set_cookie(
    name: str,
    value: str,
    domain: str = None,
    path: str = "/",
    session_id: str = None
) -> dict:
    """Set cookie."""

async def browser_clear_cookies(
    session_id: str = None,
    domain: str = None
) -> dict:
    """Clear cookies, optionally filtered by domain."""

async def browser_get_local_storage(
    key: str = None,  # null = all keys
    session_id: str = None
) -> dict:
    """Get localStorage value(s).

    Returns: {[key]: value} or {value: str}
    """

async def browser_set_local_storage(
    key: str,
    value: str,
    session_id: str = None
) -> dict:
    """Set localStorage key-value pair."""
```

## Behavior

- **Given** a session ID
- **When** browser_get_state is called
- **Then** current URL, title, viewport, cookies, and localStorage are returned

- **Given** width and height
- **When** browser_set_viewport is called
- **Then** viewport is resized and page is reflowed

- **Given** cookie name, value, and domain
- **When** browser_set_cookie is called
- **Then** cookie is set for domain/path with optional expiry

- **Given** localStorage key and value
- **When** browser_set_local_storage is called
- **Then** key-value pair is stored in page's localStorage

## Edge Cases

- **Invalid viewport size**: Return error for dimensions < 100px or > 3840px
- **Cookie domain mismatch**: Warn if domain doesn't match current page
- **localStorage quota exceeded**: Return quota exceeded error
- **No session**: Create default session automatically
- **Cross-origin restrictions**: localStorage only accessible for current origin

## Related User Stories

- US-024

## Test Coverage

Expected test count: 15-18 tests
Target coverage: 100% for this FR

**Test scenarios**:
- Get state from active session
- Set viewport to standard sizes
- Get all cookies
- Get cookies filtered by domain
- Set cookie with defaults
- Set cookie with expiry
- Clear all cookies
- Clear cookies by domain
- Get all localStorage
- Get specific localStorage key
- Set localStorage value
- localStorage quota handling
- Viewport validation
- Session auto-creation
