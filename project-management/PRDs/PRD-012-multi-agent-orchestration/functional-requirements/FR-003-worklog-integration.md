# FR-003: Worklog Integration

**Status**: Draft

## Description

Manages shared worklog for inter-agent communication with cursor-based reading, real-time subscriptions, and session-scoped storage.

## Interface

```python
class WorklogCoordinator:
    """Manages inter-agent communication via worklog."""

    def write(self, entry: WorklogEntry) -> None:
        """Append entry to shared worklog.

        Args:
            entry: WorklogEntry to append

        Raises:
            ValidationError: If entry is malformed
            StorageError: If write fails
        """

    def read(self, agent_id: str, since_cursor: str = None) -> list[WorklogEntry]:
        """Read entries for agent since cursor position.

        Args:
            agent_id: Agent reading entries
            since_cursor: Cursor position for incremental reads (None = from start)

        Returns:
            List of WorklogEntry objects since cursor
        """

    def subscribe(self, agent_id: str, callback: Callable) -> None:
        """Subscribe to real-time worklog updates.

        Args:
            agent_id: Agent subscribing
            callback: Function called with each new entry
        """

    def get_cursor(self, agent_id: str) -> str:
        """Get agent's current cursor position.

        Args:
            agent_id: Agent identifier

        Returns:
            Cursor string (line number or offset)
        """

    def set_cursor(self, agent_id: str, cursor: str) -> None:
        """Update agent's cursor position.

        Args:
            agent_id: Agent identifier
            cursor: New cursor position
        """
```

## Behavior

- **Given** worklog entry written
- **When** write() is called
- **Then** entry appended to `.npl/sessions/YYYY-MM-DD/worklog.jsonl`

- **Given** agent has cursor position
- **When** read() is called
- **Then** only entries since cursor are returned

- **Given** agent subscribed
- **When** new entry written
- **Then** callback invoked with entry

## Edge Cases

- **Worklog file missing**: Create with header metadata
- **Corrupted cursor**: Reset to beginning and log warning
- **Concurrent writes**: File locking ensures atomicity
- **Subscription callback failure**: Log error, don't block write

## Related User Stories

- US-064: Graceful Failure Recovery
- US-079: Worklog-Based Communication

## Test Coverage

Expected test count: 10-12 tests
Target coverage: 100% for this FR
