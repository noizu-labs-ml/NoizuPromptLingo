# FR-002: version_artifact Tool

**Status**: Draft

## Description

Create a new version of an existing artifact with change tracking.

## Interface

```python
async def version_artifact(
    artifact_id: str,
    content: str,
    change_summary: str | None = None,
    ctx: Context
) -> VersionRecord:
    """Create a new version of an existing artifact."""
```

## Behavior

- **Given** existing artifact ID and updated content
- **When** version_artifact is invoked
- **Then**
  - Validates artifact exists and is not locked
  - Increments version counter atomically
  - Stores diff metadata for efficient comparison
  - Maintains full content for each version (no delta encoding)
  - Returns VersionRecord with version number, diff stats, previous_version_id

## Edge Cases

- **Non-existent artifact**: Return not found error
- **Locked artifact**: Return conflict error with lock holder info
- **Identical content**: Create version but flag as no-op
- **Missing change_summary**: Allow but recommend providing

## Related User Stories

- US-008-030

## Test Coverage

Expected test count: 10-14 tests
Target coverage: 100% for this FR
