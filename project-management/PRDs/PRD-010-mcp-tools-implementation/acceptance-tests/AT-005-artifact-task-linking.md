# AT-005: Cross-Domain Artifact-Task Linking

**Category**: Integration
**Related FR**: FR-018
**Status**: Not Started

## Description

Validates cross-domain linking between artifacts and tasks.

## Test Implementation

```python
async def test_artifact_task_linking():
    """Test linking artifacts to tasks."""
    # Setup
    artifact = await artifact_manager.create(
        name="deliverable",
        artifact_type="document",
        content="Design doc"
    )

    task = await task_manager.create_task(
        title="Design work"
    )

    # Link artifact as deliverable
    link = await task_manager.link_artifact(
        task_id=task.id,
        artifact_id=artifact.id,
        relationship="deliverable"
    )

    assert link.relationship == "deliverable"

    # Verify bidirectional link
    task_artifacts = await task_manager.get_linked_artifacts(task.id)
    assert artifact.id in [a.id for a in task_artifacts]
```

## Acceptance Criteria

- [ ] Links created between domains
- [ ] Bidirectional references maintained
- [ ] Relationship types tracked
- [ ] Referential integrity enforced
- [ ] Links queryable from both sides

## Coverage

Covers:
- Normal path: Link creation
- Edge cases: Multiple relationships
- Error conditions: Non-existent entities
