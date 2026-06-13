# AT-001: Tasker Spawn and Lifecycle

**Category**: Integration
**Related FR**: FR-001
**Status**: Not Started

## Description

Validates tasker spawning, lifecycle state transitions, and auto-termination behavior.

## Test Implementation

```python
def test_tasker_spawn_and_lifecycle():
    """Test tasker spawning and automatic lifecycle management."""
    # Setup
    manager = TaskerManager()

    # Action: Spawn tasker with 1-minute timeout, 30-second nag
    tasker = manager.spawn_tasker(
        task="Test task",
        chat_room_id="test-room",
        patterns=["summarize"],
        timeout=1,
        nag_minutes=0.5
    )

    # Assert: Tasker created in IDLE state
    assert tasker["status"] == "IDLE"
    assert tasker["task"] == "Test task"

    # Action: Touch tasker (simulate activity)
    manager.touch_tasker(tasker["id"])

    # Assert: Status transitions to ACTIVE
    tasker = manager.get_tasker(tasker["id"])
    assert tasker["status"] == "ACTIVE"

    # Action: Wait 30+ seconds (no activity)
    time.sleep(35)

    # Assert: Status transitions to NAGGING
    tasker = manager.get_tasker(tasker["id"])
    assert tasker["status"] == "NAGGING"

    # Action: Respond with keep_alive
    manager.keep_alive(tasker["id"])

    # Assert: Status returns to ACTIVE, timer resets
    tasker = manager.get_tasker(tasker["id"])
    assert tasker["status"] == "ACTIVE"

    # Action: Wait 60+ seconds (no activity)
    time.sleep(65)

    # Assert: Auto-terminated
    tasker = manager.get_tasker(tasker["id"])
    assert tasker["status"] == "TERMINATED"
    assert "timeout" in tasker["termination_reason"]
```

## Acceptance Criteria

- [ ] Tasker spawns in IDLE state
- [ ] First activity transitions to ACTIVE
- [ ] No activity for nag_minutes transitions to NAGGING
- [ ] keep_alive resets timer and returns to ACTIVE
- [ ] Timeout without activity transitions to TERMINATED

## Coverage

Covers:
- Tasker spawning
- Lifecycle state transitions
- Timeout detection
- Nag message triggering
- Keep-alive responses
