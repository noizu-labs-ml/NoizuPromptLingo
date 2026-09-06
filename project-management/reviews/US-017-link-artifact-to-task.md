# Review: Link Artifact to Task

- **Story**: `project-management/user-stories/US-017-link-artifact-to-task.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

`Tasks.AddArtifact` is a real MCP tool (`src/npl_mcp/launcher.py:821-842`) backed by `task_add_artifact` (`src/npl_mcp/tasks/tasks.py:401-432`), inserting into `npl_task_artifacts` (`liquibase/changelogs/changeset-017.enhanced-managers.yaml:352-397`) with `task_id` FK, `artifact_type`, `artifact_id`, `git_branch`, `description`, `created_by`; retrieval is via `Tasks.ListArtifacts` (`launcher.py:843-852`, `tasks.py:435-462`). The link-creation happy path works. But the semantics the story demands are absent: `artifact_type` is free-text (no "artifact"/"git_branch" validation), `artifact_id` has **no FK to `npl_artifacts`** and no application-level existence check, and there is **no unique constraint** on `(task_id, artifact_id)`/`(task_id, git_branch)` — duplicates are accepted. `Tasks.Get` does not embed the artifacts array (the story's `get_task` visibility criterion), and no `web_url` exists anywhere in the codebase. Confidence: high — function bodies and Liquibase DDL read directly; the enhanced path has no unit tests.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Link existing artifact by `artifact_id` | Met | `tasks.py:401-432`; `launcher.py:821-842` |
| Link git branch name without artifact | Met | `git_branch` param, `tasks.py:405,418`; nullable `artifact_id` in DDL |
| Optional description of purpose | Met | `tasks.py:406,419`; DDL `description` column |
| `artifact_type` must be "artifact" or "git_branch" | Partially Met | field exists and is NOT NULL (`changeset-017:367-371`) but accepts any string — no enum/validation in `task_add_artifact` |
| Creator recorded in `created_by` | Met | `tasks.py:407,420`; DDL `created_by` column |
| Multiple links per task | Met | no per-task limit or constraint on `npl_task_artifacts` |
| Returns unique `task_artifact_id` | Met | SERIAL PK returned as `id` (`tasks.py:414-416,426`) |
| Returns task and link details in response | Partially Met | returns link fields only (`tasks.py:424-432`); no task details included |
| Links unidirectional (task → artifact) | Met | `npl_task_artifacts` is task-owned; artifacts table unreferenced |
| Linked artifacts visible via `get_task` | Not Met | `task_get` SELECT omits artifacts (`tasks.py:96-102`); visibility only via separate `Tasks.ListArtifacts` |
| Links persist independently of revisions | Met | stores bare `artifact_id` INT; no revision coupling |
| Non-existent artifact returns error | Not Met | no FK on `artifact_id` (`changeset-017:372-375`) and no existence check in `task_add_artifact` |
| Duplicate links prevented | Not Met | no unique constraint in DDL; no dedupe check in code — same link can be inserted repeatedly |
| Task details endpoint lists all links | Partially Met | `Tasks.ListArtifacts` (`tasks.py:435-462`) lists links, but `Tasks.Get` itself does not |
| Each link shows id/type/description/creator | Met | `tasks.py:449-459` returns id, artifact_type, artifact_id, git_branch, description, created_by |
| Web URL for viewing task with artifacts | Not Met | no `web_url` produced anywhere in `src/npl_mcp/` |

## Gaps / Risks

- Data-integrity hole: dangling `artifact_id` references accumulate silently (no FK, no check) — reviewers following links will hit missing artifacts.
- Duplicate links inflate deliverable lists with no dedupe, contrary to the story's audit-trail intent.
- The story's stated discovery surface (`get_task` includes artifacts array) diverges from the shipped two-call model; either implement the embedding or update the story.
- No tests for `task_add_artifact` / `task_list_artifacts`.

## BDD Scenario

```gherkin
Feature: Link artifacts and branches to tasks

  Scenario: Agent links a completed artifact
    Given a task with id 21 and an artifact with id 42
    When the agent calls Tasks.AddArtifact with artifact_type "artifact",
      artifact_id 42, a description, and created_by
    Then a unique link id is returned and creator is stored

  Scenario: Agent links a work-in-progress branch
    When the agent calls Tasks.AddArtifact with artifact_type "git_branch"
      and git_branch "feature/dark-mode"
    Then the branch link is stored without an artifact_id

  Scenario: Agent links a nonexistent artifact
    When the agent calls Tasks.AddArtifact with artifact_id 999999
    Then the link is accepted anyway — nothing validates the artifact exists

  Scenario: Agent links the same artifact twice
    When Tasks.AddArtifact is called twice with identical arguments
    Then two identical link rows are created — duplicates are not prevented

  Scenario: Reviewer inspects the task's deliverables
    When the reviewer calls Tasks.Get for the task
    Then the response contains no artifacts array
    And a second call to Tasks.ListArtifacts is required to see the links
```
