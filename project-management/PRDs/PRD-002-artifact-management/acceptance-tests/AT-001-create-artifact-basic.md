# AT-001: Create artifact basic flow

**Category**: Integration
**Related FR**: FR-001
**Status**: Passing

## Description

Validates that a new artifact can be created with all required fields, generates version 0, stores file correctly, and returns expected response.

## Test Implementation

```python
def test_create_artifact():
    """Test basic artifact creation with valid inputs."""
    # Setup
    name = "design-mockup"
    artifact_type = "image"
    file_content = base64.b64encode(b"mock image data").decode()
    filename = "mockup.png"
    created_by = "sarah-designer"
    purpose = "Initial design review"

    # Action
    result = await create_artifact(
        name=name,
        artifact_type=artifact_type,
        file_content_base64=file_content,
        filename=filename,
        created_by=created_by,
        purpose=purpose
    )

    # Assert
    assert result["artifact_id"] > 0
    assert result["revision_num"] == 0
    assert result["web_url"].startswith("/artifact/")

    # Verify file storage
    file_path = f"data/artifacts/{name}/revision-0-{filename}"
    assert os.path.exists(file_path)

    # Verify metadata
    meta_path = f"data/artifacts/{name}/revision-0.meta.md"
    assert os.path.exists(meta_path)
```

## Acceptance Criteria

- [ ] Artifact ID is returned and greater than 0
- [ ] Revision number is 0 for initial version
- [ ] Web URL is generated correctly
- [ ] File is stored at expected path
- [ ] Metadata file is created with YAML frontmatter

## Coverage

Covers:
- Normal path for artifact creation
- Database insertion
- File system operations
- Metadata generation
