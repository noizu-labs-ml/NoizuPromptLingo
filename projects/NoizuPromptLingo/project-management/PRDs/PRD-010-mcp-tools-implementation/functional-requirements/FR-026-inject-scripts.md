# FR-026: inject_scripts Tool

**Status**: Draft

## Description

Inject JavaScript into page context with result capture.

## Interface

```python
async def inject_scripts(
    session_id: str,
    script: str,
    context: Literal["isolated", "page"] | None = None,
    await_promise: bool | None = None,
    ctx: Context
) -> ScriptResult:
    """Inject JavaScript into page context."""
```

## Behavior

- **Given** session ID and JavaScript code
- **When** inject_scripts is invoked
- **Then**
  - Injects script in specified context
  - Captures console output during execution
  - Returns script result or error
  - Supports async script execution
  - Returns ScriptResult with result, logs, errors

## Edge Cases

- **Syntax error**: Return compilation error
- **Runtime error**: Capture and return error details
- **Infinite loop**: Timeout after 30 seconds
- **Promise rejection**: Capture rejection reason

## Related User Stories

- US-061-077

## Test Coverage

Expected test count: 12-15 tests
Target coverage: 100% for this FR
