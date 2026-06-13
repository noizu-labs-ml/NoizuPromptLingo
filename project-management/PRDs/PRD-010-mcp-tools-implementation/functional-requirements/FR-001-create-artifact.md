# FR-001: create_artifact Tool

**Status**: Draft

## Description

Create a new versioned artifact with metadata in the artifact management system.

## Interface

```python
async def create_artifact(
    name: str,
    artifact_type: Literal["code", "document", "config", "schema"],
    content: str,
    metadata: dict | None = None,
    ctx: Context
) -> ArtifactRecord:
    """Create a new versioned artifact with metadata."""
```

## Behavior

- **Given** valid artifact name, type, and content
- **When** create_artifact is invoked
- **Then**
  - Validates artifact name uniqueness within project scope
  - Creates initial version (v1) in SQLite artifacts table
  - Stores content blob with compression for large files
  - Triggers notification event for artifact watchers
  - Returns ArtifactRecord with id, version, created_at

## Edge Cases

- **Duplicate name**: Return error indicating conflict
- **Empty content**: Accept but log warning
- **Invalid type**: Reject with validation error
- **Large content (>10MB)**: Apply compression automatically

## Related User Stories

- US-008-030

## Test Coverage

Expected test count: 8-12 tests
Target coverage: 100% for this FR
