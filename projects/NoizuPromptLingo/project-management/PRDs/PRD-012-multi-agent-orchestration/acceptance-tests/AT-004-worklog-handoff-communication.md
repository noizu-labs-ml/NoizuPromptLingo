# AT-004: Worklog Handoff Communication

**Category**: Integration
**Related FR**: FR-002, FR-003
**Status**: Not Started

## Description

Validates worklog-based handoff from one agent to another with outputs and next steps.

## Test Implementation

```python
def test_worklog_handoff_between_agents():
    """Test agent handoff via worklog entry."""
    protocol = CommunicationProtocol()
    coordinator = WorklogCoordinator()

    # Agent A completes work and hands off to Agent B
    entry = protocol.handoff(
        from_agent="agent-a",
        to_agent="agent-b",
        outputs=[Artifact("research.md", "art-123")],
        next_steps=["Create design from research"],
    )
    coordinator.write(entry)

    # Agent B reads worklog
    entries = coordinator.read("agent-b", since_cursor=None)

    assert len(entries) == 1
    assert entries[0].entry_type == EntryType.HANDOFF
    assert entries[0].target_agent == "agent-b"
    assert len(entries[0].payload["outputs"]) == 1
```

## Acceptance Criteria

- [ ] Handoff entry written to worklog
- [ ] Target agent can read entry via coordinator
- [ ] Outputs and next steps included in payload
- [ ] Cursor tracking works for incremental reads

## Coverage

Covers:
- Worklog handoff pattern
- Coordinator read/write
- Entry payload structure
