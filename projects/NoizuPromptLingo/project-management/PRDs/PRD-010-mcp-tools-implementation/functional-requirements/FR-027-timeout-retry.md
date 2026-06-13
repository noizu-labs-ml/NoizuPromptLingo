# FR-027: timeout_retry Tool

**Status**: Draft

## Description

Execute action with timeout and exponential backoff retry logic.

## Interface

```python
async def timeout_retry(
    session_id: str,
    action: dict,
    timeout: int,
    retries: int | None = None,
    backoff: float | None = None,
    ctx: Context
) -> RetryResult:
    """Execute action with timeout and retry logic.

    Action structure:
    {
        "type": "navigate" | "click" | "wait" | "screenshot",
        "params": {...}
    }
    """
```

## Behavior

- **Given** session ID, action spec, and timeout
- **When** timeout_retry is invoked
- **Then**
  - Wraps action with timeout enforcement
  - Implements exponential backoff between retries
  - Captures all attempt results for debugging
  - Returns final result or last error
  - Returns RetryResult with success, attempts, final_result

## Edge Cases

- **Success on first try**: Return immediately
- **All retries fail**: Return aggregated error
- **Timeout too short**: Log warning, proceed anyway
- **Invalid action type**: Return validation error

## Related User Stories

- US-061-077

## Test Coverage

Expected test count: 12-15 tests (including timing tests)
Target coverage: 100% for this FR
