# User Story: Link Artifact to Task

**ID**: US-017
**Persona**: P-001 (AI Agent)
**Priority**: High
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As an **AI agent**,
I want to **link artifacts and git branches to tasks**,
So that **reviewers can find all deliverables associated with a task and understand what outputs were produced during task execution**.

## Acceptance Criteria

### Link Creation
- [ ] Can link existing artifact to a task by `artifact_id`
- [ ] Can link git branch name to a task (without artifact)
- [ ] Link includes optional description of artifact purpose
- [ ] Link includes `artifact_type` field (must be "artifact" or "git_branch")
- [ ] Creator persona recorded in `created_by` field
- [ ] Multiple artifacts/branches can be linked to same task
- [ ] Returns unique `task_artifact_id` for each link
- [ ] Returns task and link details in response

### Link Semantics
- [ ] Links are unidirectional: task → artifact (tasks own their artifact references)
- [ ] Linked artifacts/branches visible when calling `get_task`
- [ ] Links persist independently of artifact revisions
- [ ] Linking non-existent artifact returns error
- [ ] Duplicate links to same artifact are prevented

### Visibility & Access
- [ ] Task details endpoint lists all linked artifacts/branches
- [ ] Each link shows: artifact ID/branch name, type, description, creator
- [ ] Web URL provided for viewing task with linked artifacts

## Notes

### Design Rationale
- **Unidirectional links**: Tasks own their artifact references. This simplifies the mental model—when you get a task, you see its deliverables. Artifacts don't need to know which tasks reference them.
- **Critical for traceability**: Links create an audit trail between work items and outputs
- **Git branch support**: Allows linking work-in-progress branches before artifacts are created

### Usage Patterns
- Agents should link artifacts immediately after creating them
- Link git branches at task start, artifacts at completion
- Use description field to explain artifact's role (e.g., "Implementation code", "Design mockup", "Test results")

### Future Considerations
- Consider auto-linking artifacts created in task-specific chat rooms
- Consider reverse lookup: "which tasks reference artifact X?" (would require indexing)

## Open Questions

- Should linking create a chat room event (if task has associated chat room)?
- How to handle unlinked artifacts? (Should there be a warning/report for orphaned artifacts?)
- Should there be a limit on number of artifacts per task?
- Should duplicate links be silently ignored or return an error?
- Should `get_artifact` show which tasks reference it (reverse lookup)?

## Related Commands

- `add_task_artifact` (Task Queue Tools) - Creates link between task and artifact/branch
- `get_task` (Task Queue Tools) - Returns task details including linked artifacts array

## Example Usage

### Link an artifact to a task
```json
{
  "task_id": 21,
  "artifact_type": "artifact",
  "artifact_id": 42,
  "description": "Design mockup for new UI",
  "created_by": "alice"
}
```

**Response:**
```json
{
  "status": "ok",
  "result": {
    "task_artifact_id": 7,
    "task_id": 21,
    "artifact_type": "artifact",
    "artifact_id": 42
  }
}
```

### Link a git branch to a task
```json
{
  "task_id": 21,
  "artifact_type": "git_branch",
  "git_branch": "feature/dark-mode",
  "description": "Implementation branch",
  "created_by": "bob"
}
```

**Response:**
```json
{
  "status": "ok",
  "result": {
    "task_artifact_id": 8,
    "task_id": 21,
    "artifact_type": "git_branch",
    "git_branch": "feature/dark-mode"
  }
}
```

### View task with linked artifacts
```json
{
  "task_id": 21
}
```

**Response includes:**
```json
{
  "status": "ok",
  "result": {
    "task_id": 21,
    "title": "Add dark mode",
    "status": "in_progress",
    "artifacts": [
      {
        "task_artifact_id": 7,
        "artifact_type": "artifact",
        "artifact_id": 42,
        "description": "Design mockup for new UI"
      },
      {
        "task_artifact_id": 8,
        "artifact_type": "git_branch",
        "git_branch": "feature/dark-mode",
        "description": "Implementation branch"
      }
    ]
  }
}
```
