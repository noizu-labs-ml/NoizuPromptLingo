# FR-018: link_artifact Tool

**Status**: Draft

## Description

Link an artifact to a task with relationship type.

## Interface

```python
async def link_artifact(
    task_id: str,
    artifact_id: str,
    relationship: Literal["input", "output", "reference", "deliverable"],
    ctx: Context
) -> LinkRecord:
    """Link an artifact to a task."""
```

## Behavior

- **Given** task ID, artifact ID, and relationship type
- **When** link_artifact is invoked
- **Then**
  - Validates both task and artifact exist
  - Creates bidirectional link record
  - Updates artifact's task associations
  - Tracks relationship type for workflow
  - Returns LinkRecord with link_id, relationship, linked_at

## Edge Cases

- **Non-existent task/artifact**: Return not found error
- **Already linked**: Update relationship type
- **Invalid relationship**: Reject with validation error
- **Self-reference**: Reject (task cannot link to itself as artifact)

## Related User Stories

- US-046-060
- US-078-083

## Test Coverage

Expected test count: 10-12 tests
Target coverage: 100% for this FR
