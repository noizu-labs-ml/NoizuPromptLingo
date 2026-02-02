# FR-003: Task Artifact Linking

**Status**: Active

## Description

System must allow linking of artifacts, git branches, and files to tasks. Supports multiple artifact types and maintains relationship metadata.

## Interface

```python
async def add_task_artifact(
    task_id: int,
    artifact_type: str,
    artifact_id: Optional[int] = None,
    git_branch: Optional[str] = None,
    file_path: Optional[str] = None,
    description: str = "",
    created_by: str = "system"
) -> dict:
    """Link an artifact to a task.

    Args:
        artifact_type: "artifact", "git_branch", or "file"
        artifact_id: Required if artifact_type == "artifact"
        git_branch: Required if artifact_type == "git_branch"
        file_path: Required if artifact_type == "file"

    Returns:
        dict with keys: id, task_id, artifact_type, artifact_id,
        git_branch, description, created_by, created_at
    """
```

## Behavior

- **Given** valid task_id and artifact_id
- **When** add_task_artifact(artifact_type="artifact") called
- **Then** artifact linked to task with relationship record

- **Given** task_id and git branch name
- **When** add_task_artifact(artifact_type="git_branch") called
- **Then** branch name stored in task_artifacts table

- **Given** task_id and file path
- **When** add_task_artifact(artifact_type="file") called
- **Then** file path stored for task reference

## Edge Cases

- **Missing required field**: artifact_id required for type "artifact", git_branch for "git_branch", etc.
- **Invalid task_id**: Foreign key constraint fails
- **Invalid artifact_id**: Foreign key constraint to artifacts table fails
- **Duplicate links**: Allowed (same artifact can be linked multiple times)
- **Long file paths**: Database column sized appropriately

## Related User Stories

- US-017

## Test Coverage

Expected test count: 10-12 tests
Target coverage: 100% for this FR

**Test categories**:
- Artifact linking (all three types)
- Missing required parameters
- Foreign key validation
- Duplicate link handling
- Retrieval via get_task
