# AT-002: Artifact Sharing in Chat

**Category**: Integration
**Related FR**: FR-001
**Status**: Passing

## Description

Validates that artifacts can be shared in chat rooms and appear in feed.

## Test Implementation

```python
def test_share_artifact_in_chat():
    """Test artifact sharing creates event in chat feed."""
    # Setup
    room = create_chat_room("project-chat", ["alice"])
    artifact = create_artifact("test.txt", "content")

    # Action
    share_artifact(room.id, "alice", artifact.id, "Check this out")

    # Assert
    feed = get_chat_feed(room.id)
    artifact_events = [e for e in feed if e["event_type"] == "artifact_shared"]
    assert len(artifact_events) == 1
    assert artifact_events[0]["data"]["artifact_id"] == artifact.id
```

## Acceptance Criteria

- [ ] Artifact share creates chat event
- [ ] Event includes artifact metadata
- [ ] Event includes optional comment
- [ ] Event appears in chronological feed

## Coverage

Covers:
- Artifact sharing with comment
- Artifact sharing without comment
- Feed retrieval includes artifact events
