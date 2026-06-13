# AT-004: Session Cursor Tracking

**Category**: Integration
**Related FR**: FR-003
**Status**: Not Started

## Description

Validates that session cursors correctly track per-agent read positions.

## Test Implementation

```python
def test_session_cursor_tracking(tmp_path):
    """Test cursors track read positions per agent."""
    # Setup: Initialize session and log entries
    subprocess.run(["npl-session", "init", "--task", "Test task"], cwd=str(tmp_path))
    subprocess.run(
        ["npl-session", "log", "--agent", "agent-1", "--action", "start", "--summary", "Entry 1"],
        cwd=str(tmp_path)
    )
    subprocess.run(
        ["npl-session", "log", "--agent", "agent-1", "--action", "progress", "--summary", "Entry 2"],
        cwd=str(tmp_path)
    )

    # Action: Read as parent agent
    result1 = subprocess.run(
        ["npl-session", "read", "--agent", "parent"],
        cwd=str(tmp_path),
        capture_output=True
    )

    # Log another entry
    subprocess.run(
        ["npl-session", "log", "--agent", "agent-1", "--action", "complete", "--summary", "Entry 3"],
        cwd=str(tmp_path)
    )

    # Read again - should only get Entry 3
    result2 = subprocess.run(
        ["npl-session", "read", "--agent", "parent"],
        cwd=str(tmp_path),
        capture_output=True
    )

    # Assert: First read gets 2 entries, second gets 1
    assert result1.stdout.decode().count("Entry") == 2
    assert result2.stdout.decode().count("Entry") == 1
    assert b"Entry 3" in result2.stdout
```

## Acceptance Criteria

- [ ] Cursors track per-agent positions
- [ ] Read returns only new entries since cursor
- [ ] Cursor advances atomically after read
- [ ] Peek does not advance cursor
- [ ] Multiple agents maintain separate cursors

## Coverage

Covers:
- Per-agent cursor isolation
- Cursor advancement
- New entry detection
