# FR-003: Artifact Retrieval

**Status**: Partially Completed (list_artifacts untested)

## Description

System must retrieve artifacts by ID, list all artifacts, and serve files via web routes. Supports both API and web UI access patterns.

## Interface

```python
async def get_artifact(
    artifact_id: int,
    revision: int = None
) -> dict:
    """
    Retrieve artifact metadata and content.

    Args:
        artifact_id: Primary key
        revision: Optional specific revision number (defaults to current)

    Returns:
        {
            "artifact_id": int,
            "name": str,
            "type": str,
            "current_revision": int,
            "revision": {
                "revision_num": int,
                "filename": str,
                "file_path": str,
                "created_by": str,
                "purpose": str,
                "notes": str,
                "created_at": str
            }
        }
    """

async def list_artifacts() -> list:
    """
    List all artifacts with current revision info.

    Returns:
        [
            {
                "artifact_id": int,
                "name": str,
                "type": str,
                "current_revision": int,
                "created_at": str
            }
        ]
    """
```

**MCP Tools**: `get_artifact`, `list_artifacts`
**Web Routes**:
- `GET /artifact/{id}` - Serve artifact file
- `GET /api/artifact/{id}` - Return artifact JSON metadata

## Behavior

- **Given** valid artifact_id
- **When** get_artifact is called
- **Then** system:
  - Queries database for artifact and current/specified revision
  - Returns full metadata including file paths
  - Optionally retrieves specific revision by number

- **Given** web request to /artifact/{id}
- **When** route handler processes request
- **Then** system:
  - Loads artifact file from filesystem
  - Sets appropriate Content-Type header
  - Streams file content to response

## Edge Cases

- **Invalid artifact_id**: Should return 404 with clear message
- **Missing revision**: Should default to current_revision
- **Invalid revision number**: Should return error with valid range
- **Deleted file**: Should detect missing file and return 500 with recovery info
- **Empty artifact list**: Should return empty array, not error

## Related User Stories

- US-009: Review artifact revision history
- US-004: Share artifact in chat room

## Test Coverage

Expected test count: 12-18 tests
Target coverage: 100% for this FR
Current coverage: 0% for list_artifacts (critical gap)
