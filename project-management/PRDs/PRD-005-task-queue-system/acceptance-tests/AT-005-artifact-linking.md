# AT-005: Artifact Linking

**Category**: Integration
**Related FR**: FR-003
**Status**: Not Started

## Description

Validates linking of artifacts, git branches, and files to tasks.

## Test Implementation

```python
async def test_link_artifact():
    """Link artifact to task by artifact_id."""
    task = await create_task(queue_id=1, title="Task")
    link = await add_task_artifact(
        task_id=task["id"],
        artifact_type="artifact",
        artifact_id=42,
        description="Login component"
    )
    assert link["artifact_id"] == 42
    assert link["artifact_type"] == "artifact"


async def test_link_git_branch():
    """Link git branch to task."""
    task = await create_task(queue_id=1, title="Task")
    link = await add_task_artifact(
        task_id=task["id"],
        artifact_type="git_branch",
        git_branch="feature/login"
    )
    assert link["git_branch"] == "feature/login"


async def test_link_file():
    """Link file path to task."""
    task = await create_task(queue_id=1, title="Task")
    link = await add_task_artifact(
        task_id=task["id"],
        artifact_type="file",
        file_path="src/login.py"
    )
    assert link["file_path"] == "src/login.py"


async def test_get_task_with_artifacts():
    """Task retrieval includes linked artifacts."""
    task = await create_task(queue_id=1, title="Task")
    await add_task_artifact(task["id"], artifact_type="artifact", artifact_id=1)
    retrieved = await get_task(task["id"])
    assert len(retrieved["artifacts"]) == 1
```

## Acceptance Criteria

- [ ] Artifact type "artifact" requires artifact_id
- [ ] Artifact type "git_branch" requires git_branch
- [ ] Artifact type "file" requires file_path
- [ ] Multiple artifacts can be linked to same task
- [ ] get_task includes artifact list

## Coverage

Covers:
- All three artifact types
- Parameter validation
- Multiple links per task
- Task retrieval with artifacts
