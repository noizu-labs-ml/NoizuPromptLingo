# FR-002: Session Grouping

**Status**: Completed (Untested)

## Description

System must provide session management to group related chat rooms, artifacts, and work contexts together.

## Interface

```python
# Create session
async def create_session(
    title: str,
    session_id: str | None = None
) -> dict:
    """Create a session to group related work."""

# Get session details
async def get_session(
    session_id: str
) -> dict:
    """Retrieve session details including rooms and metadata."""

# List all sessions
async def list_sessions(
    status: str | None = None,
    limit: int = 50
) -> list[dict]:
    """List sessions with optional status filter."""

# Update session
async def update_session(
    session_id: str,
    title: str | None = None,
    status: str | None = None
) -> dict:
    """Update session metadata."""
```

## Behavior

- **Given** user creates session with custom ID
- **When** session is created
- **Then** session is accessible by that ID

- **Given** chat room is created with session_id
- **When** room is created
- **Then** room appears in session dashboard

- **Given** user updates session status
- **When** status is changed
- **Then** session appears in filtered lists accordingly

## Edge Cases

- **Duplicate session_id**: Returns existing session if ID already exists
- **Session with no rooms**: Valid, displays empty room list
- **Invalid session_id format**: Accepts any non-empty string
- **Delete session**: Not implemented (sessions are permanent)

## Related User Stories

- US-005
- US-007
- US-031
- US-045

## Test Coverage

**Tools Implemented**: 4
**Expected test count**: 8-10 tests
**Current coverage**: 0%
**Target coverage**: 100%
