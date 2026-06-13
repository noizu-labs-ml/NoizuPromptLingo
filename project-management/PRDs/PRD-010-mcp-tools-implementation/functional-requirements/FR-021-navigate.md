# FR-021: navigate Tool

**Status**: Draft

## Description

Navigate browser to URL with wait conditions.

## Interface

```python
async def navigate(
    session_id: str,
    url: str,
    wait_for: str | None = None,
    timeout: int | None = None,
    ctx: Context
) -> NavigationResult:
    """Navigate browser to URL."""
```

## Behavior

- **Given** session ID and target URL
- **When** navigate is invoked
- **Then**
  - Validates URL is in allowed domains
  - Performs navigation with timeout handling
  - Waits for specified element or networkidle
  - Captures final URL after redirects
  - Returns NavigationResult with status, load_time, final_url

## Edge Cases

- **Blocked domain**: Return permission denied error
- **Timeout exceeded**: Return timeout error with partial state
- **Invalid URL**: Reject with validation error
- **Wait selector not found**: Timeout with descriptive error

## Related User Stories

- US-061-077

## Test Coverage

Expected test count: 10-12 tests
Target coverage: 100% for this FR
