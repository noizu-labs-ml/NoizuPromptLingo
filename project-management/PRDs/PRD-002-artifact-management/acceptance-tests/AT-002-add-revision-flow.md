# AT-002: Add revision to existing artifact

**Category**: Integration
**Related FR**: FR-002
**Status**: Passing

## Description

Validates that a new revision can be added to an existing artifact, increments version number, stores new file, and preserves original versions.

## Test Implementation

```python
def test_add_revision():
    """Test adding a revision to existing artifact."""
    # Setup - create initial artifact
    artifact = await create_artifact(
        name="doc",
        artifact_type="document",
        file_content_base64=base64.b64encode(b"v1 content").decode(),
        filename="doc-v1.md",
        created_by="alex"
    )
    artifact_id = artifact["artifact_id"]

    # Action - add revision
    revision = await add_revision(
        artifact_id=artifact_id,
        file_content_base64=base64.b64encode(b"v2 content").decode(),
        filename="doc-v2.md",
        created_by="alex",
        notes="Updated with feedback"
    )

    # Assert
    assert revision["artifact_id"] == artifact_id
    assert revision["revision_num"] == 1

    # Verify both versions exist
    assert os.path.exists("data/artifacts/doc/revision-0-doc-v1.md")
    assert os.path.exists("data/artifacts/doc/revision-1-doc-v2.md")

    # Verify history
    history = await get_artifact_history(artifact_id)
    assert len(history) == 2
    assert history[0]["revision_num"] == 0
    assert history[1]["revision_num"] == 1
    assert history[1]["notes"] == "Updated with feedback"
```

## Acceptance Criteria

- [ ] Revision number increments correctly
- [ ] New file is stored separately from original
- [ ] Original version is preserved unchanged
- [ ] Revision notes are captured
- [ ] History returns all revisions in order

## Coverage

Covers:
- Revision increment logic
- File system versioning
- History retrieval
- Metadata preservation
