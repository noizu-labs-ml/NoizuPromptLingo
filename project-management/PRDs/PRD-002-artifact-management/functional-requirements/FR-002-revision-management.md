# FR-002: Revision Management

**Status**: Completed

## Description

System must manage artifact revisions by adding new versions, tracking changes, and storing revision notes. Each revision increments the version number automatically.

## Interface

```python
async def add_revision(
    artifact_id: int,
    file_content_base64: str,
    filename: str,
    created_by: str,
    purpose: str = None,
    notes: str = None
) -> dict:
    """
    Add a new revision to an existing artifact.

    Returns:
        {
            "artifact_id": int,
            "revision_num": int,
            "web_url": str
        }
    """

async def get_artifact_history(artifact_id: int) -> list:
    """
    Retrieve all revisions for an artifact.

    Returns:
        [
            {
                "revision_num": int,
                "filename": str,
                "created_by": str,
                "purpose": str,
                "notes": str,
                "created_at": str
            }
        ]
    """
```

**MCP Tools**: `add_revision`, `get_artifact_history`

## Behavior

- **Given** existing artifact_id and new file content
- **When** add_revision is called
- **Then** system:
  - Increments revision_num (finds max + 1)
  - Creates new revision record in database
  - Stores file at `data/artifacts/{name}/revision-{num}-{filename}`
  - Generates metadata file with notes and purpose
  - Updates artifacts.current_revision_id
  - Returns new revision_num and web_url

## Edge Cases

- **Invalid artifact_id**: Should return 404-style error
- **Concurrent revisions**: Should handle race condition in revision numbering
- **Missing notes**: Optional field, should default to empty string
- **Large files**: Should handle memory limits for base64 decode
- **Deleted artifact**: Should prevent revision addition or restore artifact

## Related User Stories

- US-009: Review artifact revision history

## Test Coverage

Expected test count: 10-15 tests
Target coverage: 100% for this FR
Current coverage: 53% (needs expansion)
