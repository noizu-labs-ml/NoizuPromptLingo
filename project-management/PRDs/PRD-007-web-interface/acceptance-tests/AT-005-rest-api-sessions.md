# AT-005: REST API Sessions

**Category**: Integration
**Related FR**: FR-004
**Status**: Not Started

## Description

Validate that REST API endpoints return proper JSON responses for session queries.

## Test Implementation

```python
def test_api_list_sessions():
    """Test /api/sessions endpoint returns JSON."""
    # Setup: Create test sessions
    session1 = create_test_session("session-1")
    session2 = create_test_session("session-2")

    # Action: GET /api/sessions
    response = client.get("/api/sessions")

    # Assert
    assert response.status_code == 200
    assert response.headers["content-type"] == "application/json"
    data = response.json()
    assert len(data) >= 2
    assert any(s["id"] == "session-1" for s in data)
```

## Acceptance Criteria

- [ ] JSON response is returned
- [ ] All sessions are included
- [ ] Proper content-type header
- [ ] 404 for invalid session ID

## Coverage

Covers:
- Normal path: list sessions
- Normal path: get specific session
- Edge case: empty sessions
- Error condition: invalid session ID
