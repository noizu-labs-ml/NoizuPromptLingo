# FR-010: share_artifact Tool

**Status**: Draft

## Description

Share an artifact in a chat room with preview generation.

## Interface

```python
async def share_artifact(
    room_id: str,
    artifact_id: str,
    version: int | None = None,
    comment: str | None = None,
    ctx: Context
) -> ShareRecord:
    """Share an artifact in a chat room."""
```

## Behavior

- **Given** room ID and artifact ID
- **When** share_artifact is invoked
- **Then**
  - Validates artifact exists and user has access
  - Creates artifact share event in room log
  - Generates preview/thumbnail for display
  - Maintains link to specific version (not auto-updating)
  - Returns ShareRecord with share_id, preview_url

## Edge Cases

- **Non-existent artifact**: Return not found error
- **No room access**: Return permission denied error
- **Invalid version**: Use latest version
- **Large artifact**: Generate thumbnail only

## Related User Stories

- US-031-045
- US-078-083

## Test Coverage

Expected test count: 10-12 tests
Target coverage: 100% for this FR
