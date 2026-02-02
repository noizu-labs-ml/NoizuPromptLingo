# AT-001: Artifact Creation and Versioning

**Category**: Integration
**Related FR**: FR-001, FR-002
**Status**: Not Started

## Description

Validates artifact creation, versioning, and content storage.

## Test Implementation

```python
async def test_artifact_creation_and_versioning():
    """Test artifact creation with versioning workflow."""
    # Setup
    artifact_manager = ArtifactManager(db)

    # Create artifact
    artifact = await artifact_manager.create(
        name="test-code",
        artifact_type="code",
        content="def hello(): pass"
    )
    assert artifact.version == 1

    # Version artifact
    v2 = await artifact_manager.version(
        artifact_id=artifact.id,
        content="def hello(): return 'world'",
        change_summary="Added return value"
    )
    assert v2.version == 2
    assert v2.previous_version_id == artifact.id
```

## Acceptance Criteria

- [ ] Artifacts created with unique IDs
- [ ] Initial version is v1
- [ ] Versioning increments counter
- [ ] Content persists correctly
- [ ] Metadata stored and retrievable

## Coverage

Covers:
- Normal path: Create and version
- Edge cases: Duplicate names
- Error conditions: Invalid types
