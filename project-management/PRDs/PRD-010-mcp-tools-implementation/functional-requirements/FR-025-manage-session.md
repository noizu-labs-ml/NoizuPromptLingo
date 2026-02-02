# FR-025: manage_session Tool

**Status**: Draft

## Description

Create, configure, or destroy browser session.

## Interface

```python
async def manage_session(
    action: Literal["create", "configure", "destroy"],
    session_id: str | None = None,
    config: dict | None = None,
    ctx: Context
) -> SessionRecord:
    """Create, configure, or destroy browser session.

    Config structure:
    {
        "viewport": {"width": int, "height": int},
        "user_agent": str,
        "cookies": [{"name": str, "value": str, ...}],
        "headers": {"key": "value"}
    }
    """
```

## Behavior

- **Given** action type and optional configuration
- **When** manage_session is invoked
- **Then**
  - Creates isolated browser context for new sessions
  - Applies configuration to existing sessions
  - Cleans up resources on destroy
  - Enforces session timeout limits
  - Returns SessionRecord with session_id, status, config

## Edge Cases

- **Create without config**: Use default configuration
- **Configure non-existent session**: Return not found error
- **Destroy non-existent session**: Accept (idempotent)
- **Invalid viewport**: Use default values

## Related User Stories

- US-061-077

## Test Coverage

Expected test count: 10-12 tests
Target coverage: 100% for this FR
