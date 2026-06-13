# AT-002: Session Detail View

**Category**: Integration
**Related FR**: FR-001
**Status**: Not Started

## Description

Validate that session detail pages display room cards and artifact cards with proper metadata.

## Test Implementation

```python
def test_session_detail_shows_rooms_and_artifacts():
    """Test that session detail page displays rooms and artifacts."""
    # Setup: Create session with rooms and artifacts
    session = create_test_session("test-session")
    room = create_test_room(session, "test-room")
    artifact = create_test_artifact(session, "test-artifact")

    # Action: GET /session/{session_id}
    response = client.get(f"/session/{session.id}")

    # Assert
    assert response.status_code == 200
    assert "test-room" in response.text
    assert "test-artifact" in response.text
```

## Acceptance Criteria

- [ ] Room cards are displayed
- [ ] Artifact cards are displayed
- [ ] Session metadata is shown
- [ ] Invalid session ID returns 404

## Coverage

Covers:
- Normal path: session with rooms and artifacts
- Edge case: session with no rooms
- Error condition: invalid session ID
