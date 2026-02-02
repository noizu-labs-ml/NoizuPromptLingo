# AT-003: Session Dashboard Display

**Category**: End-to-End
**Related FR**: FR-002
**Status**: Not Started

## Description

Validates that session dashboard displays all rooms and activity for a session.

## Test Implementation

```python
def test_session_dashboard_shows_rooms():
    """Test session dashboard lists all associated rooms."""
    # Setup
    session = create_session("Q4 Planning", "q4-2025")
    room1 = create_chat_room("design", ["alice"], session_id=session.id)
    room2 = create_chat_room("dev", ["bob"], session_id=session.id)

    # Action
    session_data = get_session(session.id)

    # Assert
    assert len(session_data["rooms"]) == 2
    room_names = [r["name"] for r in session_data["rooms"]]
    assert "design" in room_names
    assert "dev" in room_names
```

## Acceptance Criteria

- [ ] Session lists all associated chat rooms
- [ ] Session shows recent activity summary
- [ ] Session metadata (title, status) displayed
- [ ] Navigation links to individual rooms work

## Coverage

Covers:
- Session with multiple rooms
- Session with no rooms
- Room association at creation time
