# FR-002: Navigation & Page State

**Status**: Active

## Description

Provide page navigation controls and network state management. Five tools enable URL navigation, history navigation, page reloading, and waiting for network idle.

**Tools**: `browser_navigate`, `browser_go_back`, `browser_go_forward`, `browser_reload`, `browser_wait_network_idle` (5 tools)

## Interface

```python
async def browser_navigate(
    url: str,
    session_id: str = None,
    wait_until: str = "load"  # load, domcontentloaded, networkidle
) -> dict:
    """Navigate to URL and wait for page load.

    Returns: {url, title, status_code}
    """

async def browser_go_back(session_id: str = None) -> dict:
    """Navigate back in history."""

async def browser_go_forward(session_id: str = None) -> dict:
    """Navigate forward in history."""

async def browser_reload(
    session_id: str = None,
    ignore_cache: bool = False
) -> dict:
    """Reload current page."""

async def browser_wait_network_idle(
    session_id: str = None,
    timeout: int = 30000  # milliseconds
) -> dict:
    """Wait for 500ms of no network activity.

    Returns: {idle: true/false, requests_pending}
    """
```

## Behavior

- **Given** a URL and session ID
- **When** browser_navigate is called
- **Then** page navigates to URL and waits for specified load event

- **Given** an active session with history
- **When** browser_go_back is called
- **Then** session navigates to previous page in history

- **Given** network requests in progress
- **When** browser_wait_network_idle is called
- **Then** function waits up to timeout for 500ms of no network activity

## Edge Cases

- **Invalid URL**: Return error for malformed URLs
- **Navigation timeout**: Return timeout error after wait_until timeout
- **Empty history**: Return error when going back/forward with no history
- **Network never idle**: Timeout after specified milliseconds with pending request count

## Related User Stories

- US-021
- US-052

## Test Coverage

Expected test count: 12-15 tests
Target coverage: 100% for this FR

**Test scenarios**:
- Navigate to valid URL
- Navigate with different wait_until values
- Go back/forward in multi-page session
- Reload with/without cache
- Wait for network idle on loaded page
- Timeout handling for slow loads
- Invalid URL handling
- Empty history navigation
