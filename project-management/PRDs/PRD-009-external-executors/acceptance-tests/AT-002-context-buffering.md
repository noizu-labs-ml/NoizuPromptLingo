# AT-002: Context Buffering

**Category**: Unit
**Related FR**: FR-001
**Status**: Not Started

## Description

Validates context storage and retrieval for tasker follow-up queries.

## Test Implementation

```python
def test_context_buffering():
    """Test context storage and retrieval."""
    # Setup
    manager = TaskerManager()
    tasker = manager.spawn_tasker("Test task", "room-1", [])

    # Action: Store command context
    manager.store_context(
        tasker["id"],
        command="ls -la",
        raw_output="file1.txt\nfile2.txt",
        analysis="Two text files found",
        result="success"
    )

    manager.store_context(
        tasker["id"],
        command="cat file1.txt",
        raw_output="Hello world",
        analysis="Simple greeting",
        result="success"
    )

    # Assert: Context retrieved in order
    context = manager.get_context(tasker["id"])
    assert len(context) == 2
    assert context[0]["command"] == "ls -la"
    assert context[1]["command"] == "cat file1.txt"
    assert context[0]["analysis"] == "Two text files found"
```

## Acceptance Criteria

- [ ] Context stored with command, output, analysis, result
- [ ] Context retrieved in chronological order
- [ ] Multiple context entries supported
- [ ] Context persists across get_tasker calls

## Coverage

Covers:
- Context storage
- Context retrieval
- Multi-entry buffering
- Data persistence
