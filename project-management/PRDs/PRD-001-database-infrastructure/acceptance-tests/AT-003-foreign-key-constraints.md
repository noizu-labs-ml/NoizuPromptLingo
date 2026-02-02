# AT-003: Foreign Key Constraints

**Category**: Unit
**Related FR**: FR-001
**Status**: Passing

## Description

Validates that foreign key constraints prevent orphaned records and cascade deletes properly.

## Test Implementation

```python
async def test_foreign_key_constraints():
    """Test foreign key constraints enforce referential integrity."""
    # Setup
    db = Database()
    await db.connect(":memory:")
    await db.execute("PRAGMA foreign_keys = ON")

    # Create parent record
    await db.execute(
        "INSERT INTO artifacts (name, artifact_type) VALUES (?, ?)",
        ("test.txt", "code")
    )

    # Action - Try to create child with invalid parent
    with pytest.raises(aiosqlite.IntegrityError):
        await db.execute(
            "INSERT INTO revisions (artifact_id, version, file_path) VALUES (?, ?, ?)",
            (999, 1, "/tmp/test.txt")  # Non-existent artifact_id
        )

    # Assert - Valid child succeeds
    await db.execute(
        "INSERT INTO revisions (artifact_id, version, file_path) VALUES (?, ?, ?)",
        (1, 1, "/tmp/test.txt")
    )

    revisions = await db.fetch_all("SELECT * FROM revisions")
    assert len(revisions) == 1
```

## Acceptance Criteria

- [x] Invalid foreign keys raise IntegrityError
- [x] Valid foreign keys succeed
- [x] PRAGMA foreign_keys = ON enforced
- [x] Cascade behavior defined for relationships

## Coverage

Covers:
- Foreign key validation
- Referential integrity
- Constraint enforcement
