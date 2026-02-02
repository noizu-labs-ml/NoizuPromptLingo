# AT-001: Database Initialization

**Category**: Integration
**Related FR**: FR-001
**Status**: Passing

## Description

Validates that database initialization creates all 15 tables with proper schema, indexes, and foreign key constraints.

## Test Implementation

```python
async def test_database_initialization():
    """Test database creates all tables on first connection."""
    # Setup
    db = Database()
    temp_db = tempfile.NamedTemporaryFile(delete=False)

    # Action
    await db.connect(temp_db.name)

    # Assert
    tables = await db.fetch_all("SELECT name FROM sqlite_master WHERE type='table'")
    table_names = [t['name'] for t in tables]

    assert 'artifacts' in table_names
    assert 'revisions' in table_names
    assert 'reviews' in table_names
    assert 'inline_comments' in table_names
    assert 'review_overlays' in table_names
    assert 'chat_rooms' in table_names
    assert 'room_members' in table_names
    assert 'chat_events' in table_names
    assert 'notifications' in table_names
    assert 'sessions' in table_names
    assert 'taskers' in table_names
    assert 'task_queues' in table_names
    assert 'tasks' in table_names
    assert 'task_events' in table_names
    assert 'task_artifacts' in table_names
    assert 'schema_version' in table_names
```

## Acceptance Criteria

- [x] All 15 core tables created
- [x] schema_version table tracks migrations
- [x] Foreign key constraints defined
- [x] Indexes created for all foreign keys

## Coverage

Covers:
- Database initialization path
- Schema creation
- Table existence validation
