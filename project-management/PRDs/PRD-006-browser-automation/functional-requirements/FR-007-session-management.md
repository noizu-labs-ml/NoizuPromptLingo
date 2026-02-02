# FR-007: Session Management

**Status**: Active

## Description

Provide session lifecycle management with session listing and cleanup. Two tools enable session inspection and resource management.

**Tools**: `browser_close_session`, `browser_list_sessions` (2 tools)

## Interface

```python
async def browser_close_session(session_id: str) -> dict:
    """Close browser session and free resources.

    Returns: {closed: true, session_id: str}
    """

async def browser_list_sessions() -> dict:
    """List all active browser sessions.

    Returns: {
        sessions: [{
            session_id: str,
            url: str,
            title: str,
            created_at: str,
            last_activity: str
        }],
        count: int
    }
    """
```

## Behavior

- **Given** a session ID
- **When** browser_close_session is called
- **Then** session context is closed, resources freed, and confirmation returned

- **Given** no parameters
- **When** browser_list_sessions is called
- **Then** all active sessions are returned with metadata

## Edge Cases

- **Session not found**: Return error for non-existent session ID
- **Already closed**: Return success if session already closed
- **Empty session list**: Return empty array with count=0
- **Session persistence**: Sessions survive until explicitly closed or process exits
- **Resource cleanup**: Ensure full cleanup of browser contexts and pages

## Related User Stories

- US-024

## Test Coverage

Expected test count: 6-8 tests
Target coverage: 100% for this FR

**Test scenarios**:
- Close existing session
- Close non-existent session
- List sessions with active sessions
- List sessions when empty
- Verify resource cleanup after close
- Verify session metadata accuracy
- Session lifecycle tracking
