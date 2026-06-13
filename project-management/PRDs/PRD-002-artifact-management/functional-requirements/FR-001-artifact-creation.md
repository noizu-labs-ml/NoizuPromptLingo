# FR-001: Artifact Creation

**Status**: Completed

## Description

System must create versioned artifacts with automatic revision tracking, file storage, and metadata generation. Supports any file type with base64-encoded content.

## Interface

```python
async def create_artifact(
    name: str,
    artifact_type: str,
    file_content_base64: str,
    filename: str,
    created_by: str,
    purpose: str = None
) -> dict:
    """
    Create a new artifact with version 0.

    Returns:
        {
            "artifact_id": int,
            "revision_num": 0,
            "web_url": str
        }
    """
```

**MCP Tool**: `create_artifact`

## Behavior

- **Given** valid name, type, and file content in base64
- **When** create_artifact is called
- **Then** system creates:
  - Database record in `artifacts` table
  - Initial revision (num=0) in `revisions` table
  - File at `data/artifacts/{name}/revision-0-{filename}`
  - Metadata file at `data/artifacts/{name}/revision-0.meta.md` with YAML frontmatter
  - Returns artifact_id, revision_num, and web_url

## Edge Cases

- **Empty name**: Should reject with validation error
- **Invalid base64**: Should catch decode error and return clear message
- **Duplicate name**: Allowed; system uses artifact_id as primary key
- **Missing filename**: Should use default or generate from name
- **Long filenames**: Should sanitize/truncate to filesystem limits

## Related User Stories

- US-008: Create versioned artifact

## Test Coverage

Expected test count: 8-12 tests
Target coverage: 100% for this FR
Current coverage: 53% (needs expansion)
