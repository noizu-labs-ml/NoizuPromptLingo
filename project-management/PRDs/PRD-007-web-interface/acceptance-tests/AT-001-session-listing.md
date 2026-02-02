# AT-001: Session Listing Display

**Category**: Integration
**Related FR**: FR-001
**Status**: Not Started

## Description

Validate that the session listing page displays all sessions in a table format with proper navigation links.

## Test Implementation

```python
def test_session_listing_displays_all_sessions():
    """Test that index page shows all sessions in table."""
    # Setup: Create test sessions
    session1 = create_test_session("session-1")
    session2 = create_test_session("session-2")

    # Action: GET /
    response = client.get("/")

    # Assert
    assert response.status_code == 200
    assert "session-1" in response.text
    assert "session-2" in response.text
    assert "<table" in response.text
```

## Acceptance Criteria

- [ ] All sessions are displayed
- [ ] Table format is used
- [ ] Navigation links work
- [ ] Empty state is handled

## Coverage

Covers:
- Normal path: multiple sessions displayed
- Edge case: empty session list
- Error condition: database connection failure
