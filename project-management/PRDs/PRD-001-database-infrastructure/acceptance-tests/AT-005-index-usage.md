# AT-005: Index Usage

**Category**: Integration
**Related FR**: FR-003
**Status**: Not Started

## Description

Validates that queries use indexes efficiently and avoid full table scans where indexes are available.

## Test Implementation

```python
async def test_index_usage():
    """Test queries use indexes for optimization."""
    # Setup
    db = Database()
    await db.connect(":memory:")

    # Populate with test data
    for i in range(100):
        await db.execute(
            "INSERT INTO chat_events (room_id, event_type, timestamp) VALUES (?, ?, ?)",
            (1, "message", f"2026-01-01T00:{i:02d}:00Z")
        )

    # Action - Query with indexed column
    explain = await db.fetch_all("EXPLAIN QUERY PLAN SELECT * FROM chat_events WHERE room_id = 1")

    # Assert - Index used (not SCAN TABLE)
    plan = " ".join(row['detail'] for row in explain)
    assert "idx_chat_events_room" in plan or "SEARCH" in plan
    assert "SCAN TABLE" not in plan
```

## Acceptance Criteria

- [ ] Foreign key queries use indexes
- [ ] Timestamp ordering uses indexes
- [ ] Status filtering uses indexes
- [ ] EXPLAIN QUERY PLAN shows index usage

## Coverage

Covers:
- Index effectiveness
- Query optimization
- Performance validation
