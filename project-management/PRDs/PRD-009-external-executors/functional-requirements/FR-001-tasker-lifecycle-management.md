# FR-001: Ephemeral Tasker Lifecycle Management

**Status**: Completed

## Description

Tasker agents must support automatic lifecycle management with configurable timeouts, idle detection, and context buffering for follow-up queries.

## Interface

```python
class TaskerManager:
    """Manages ephemeral tasker agents with automatic lifecycle management."""

    def spawn_tasker(
        self,
        task: str,
        chat_room_id: str,
        patterns: List[str],
        session_id: Optional[str] = None,
        timeout: int = 15,
        nag_minutes: int = 5
    ) -> Dict:
        """Spawn a new tasker agent."""

    def get_tasker(self, tasker_id: str) -> Optional[Dict]:
        """Get tasker details by ID."""

    def list_taskers(
        self,
        status: Optional[str] = None,
        session_id: Optional[str] = None
    ) -> List[Dict]:
        """List taskers with optional filters."""

    def touch_tasker(self, tasker_id: str) -> bool:
        """Update last_activity timestamp."""

    def keep_alive(self, tasker_id: str) -> bool:
        """Respond to nag message to keep tasker alive."""

    def store_context(
        self,
        tasker_id: str,
        command: str,
        raw_output: str,
        analysis: Optional[str],
        result: Optional[str]
    ) -> bool:
        """Store command execution context."""

    def get_context(self, tasker_id: str) -> List[Dict]:
        """Retrieve stored context for tasker."""

    def dismiss_tasker(self, tasker_id: str, reason: str) -> bool:
        """Terminate a tasker."""
```

## Behavior

- **Given** a tasker is spawned with timeout=15 and nag_minutes=5
- **When** 5 minutes pass without activity
- **Then** a nag message is sent to chat_room_id
- **When** tasker does not respond within 2 minutes
- **Then** tasker auto-terminates with reason "timeout"
- **When** tasker receives keep_alive response
- **Then** lifecycle timer resets

## Edge Cases

- **Tasker spawned without chat_room_id**: Nag messages disabled, auto-terminate only
- **DB connection lost**: In-memory cache continues, reconnect on next operation
- **Multiple keep_alive calls**: Each resets timer, no duplicate nag messages

## Related User Stories

- US-009-001

## Test Coverage

Expected test count: 10-15 tests
Target coverage: 100% for lifecycle logic
