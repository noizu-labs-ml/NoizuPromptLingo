# AT-004: List all artifacts

**Category**: Unit
**Related FR**: FR-003
**Status**: Not Started

## Description

Validates that all artifacts can be listed with summary information. This test is currently missing from the test suite.

## Test Implementation

```python
def test_list_artifacts():
    """Test listing all artifacts."""
    # Setup - create multiple artifacts
    artifact1 = await create_artifact(
        name="doc1",
        artifact_type="document",
        file_content_base64=base64.b64encode(b"content1").decode(),
        filename="doc1.md",
        created_by="user1"
    )

    artifact2 = await create_artifact(
        name="img1",
        artifact_type="image",
        file_content_base64=base64.b64encode(b"image data").decode(),
        filename="img1.png",
        created_by="user2"
    )

    # Action
    result = await list_artifacts()

    # Assert
    assert len(result) >= 2

    ids = [a["artifact_id"] for a in result]
    assert artifact1["artifact_id"] in ids
    assert artifact2["artifact_id"] in ids

    # Verify structure
    for artifact in result:
        assert "artifact_id" in artifact
        assert "name" in artifact
        assert "type" in artifact
        assert "current_revision" in artifact
        assert "created_at" in artifact
```

## Acceptance Criteria

- [ ] Returns all artifacts in database
- [ ] Includes summary fields for each artifact
- [ ] Returns empty array when no artifacts exist
- [ ] Does not include deleted artifacts (if soft delete implemented)
- [ ] Performance is acceptable for large artifact counts

## Coverage

Covers:
- List query functionality
- Empty result handling
- Result structure validation
- **CRITICAL GAP**: Currently 0% coverage
