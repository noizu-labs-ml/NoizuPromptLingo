# AT-003: Retrieve artifact by ID

**Category**: Integration
**Related FR**: FR-003
**Status**: Passing

## Description

Validates that artifacts can be retrieved by ID with full metadata, optionally at specific revisions.

## Test Implementation

```python
def test_get_artifact():
    """Test retrieving artifact by ID."""
    # Setup - create artifact with multiple revisions
    artifact = await create_artifact(
        name="test-doc",
        artifact_type="document",
        file_content_base64=base64.b64encode(b"v1").decode(),
        filename="test.md",
        created_by="user1"
    )
    artifact_id = artifact["artifact_id"]

    await add_revision(
        artifact_id=artifact_id,
        file_content_base64=base64.b64encode(b"v2").decode(),
        filename="test.md",
        created_by="user2"
    )

    # Action - retrieve current version
    result = await get_artifact(artifact_id)

    # Assert
    assert result["artifact_id"] == artifact_id
    assert result["name"] == "test-doc"
    assert result["current_revision"] == 1
    assert result["revision"]["revision_num"] == 1
    assert result["revision"]["created_by"] == "user2"

    # Action - retrieve specific revision
    result_v0 = await get_artifact(artifact_id, revision=0)

    # Assert
    assert result_v0["revision"]["revision_num"] == 0
    assert result_v0["revision"]["created_by"] == "user1"
```

## Acceptance Criteria

- [ ] Can retrieve artifact by valid ID
- [ ] Returns full metadata including all fields
- [ ] Defaults to current revision when not specified
- [ ] Can retrieve specific revision by number
- [ ] Returns correct file paths for each revision

## Coverage

Covers:
- Database query by ID
- Default revision behavior
- Specific revision retrieval
- Metadata completeness
