# Review: Implement MCP Artifact Creation Tool

- **Story**: `project-management/user-stories/US-078-implement-artifact-creation-tool.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Fully implemented in the Python repo. The `Artifact.Create` MCP tool (`src/npl_mcp/launcher.py:884-925`) wraps `artifact_create` (`src/npl_mcp/artifacts/artifacts.py:82-153`), which accepts title (story's "name"), content, kind, description, created_by, notes, and optional binary content + mime_type. Versioning is real: each artifact starts at revision 1 and `artifact_add_revision` (`artifacts.py:156-235`) increments `latest_revision` and inserts a new `npl_artifact_revisions` row. Storage is PostgreSQL (`npl_artifacts`/`npl_artifact_revisions` via asyncpg), not SQLite as the story specifies — functionally equivalent, materially different substrate. Validation covers non-empty title and kind whitelist; there is no name *format* validation beyond non-emptiness (criterion is only partially satisfied). Tests in `tests/test_artifacts.py` cover create/revision/get/list paths including error cases. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `create_artifact` MCP tool accepts name, content, metadata | Met | `src/npl_mcp/launcher.py:884-925` (`Artifact.Create` with title/content/kind/description/created_by/notes); `src/npl_mcp/artifacts/artifacts.py:82-97` |
| Artifacts stored with auto-incrementing versions | Met | `src/npl_mcp/artifacts/artifacts.py:201` (`new_rev_num = latest_revision + 1`), revisions table insert at `:203-218`. Note: PostgreSQL, not SQLite as story states |
| Returns artifact ID and version number | Met | `src/npl_mcp/artifacts/artifacts.py:150-153` returns artifact dict + revision dict with id/revision |
| Validates artifact name format | Partially Met | only non-empty title check (`artifacts.py:98-99`); no format/pattern validation |
| Supports markdown, code, and JSON content types | Met | `VALID_KINDS` includes markdown/json/yaml/code/text/other + binary kinds (`artifacts.py:22-26`) |
| Metadata includes creation timestamp and author | Met | `created_by` + `created_at`/`updated_at` columns returned (`artifacts.py:31-41`, `:39-40`) |

## Gaps / Risks

- Name-format validation is absent (only non-empty); the story explicitly asks for format validation.
- Story's "SQLite" premise is wrong — implementation uses PostgreSQL/asyncpg; harmless but worth reconciling in the story text.
- `artifact_add_revision` is not transactional across the INSERT + UPDATE pair (`artifacts.py:203-230`) — a crash between them could leave `latest_revision` stale.

## BDD Scenario

```gherkin
Feature: Create versioned artifacts via MCP
  Scenario: Agent creates a markdown artifact
    When the agent calls Artifact.Create with title "review-notes", content "...", kind "markdown", created_by "agent-1"
    Then the artifact is stored with revision 1, an id, created_at, and created_by
    And the response returns the artifact id and version number
  Scenario: Agent appends a revision
    Given artifact "review-notes" exists at revision 1
    When the agent calls Artifact.AddRevision with new content
    Then a revision 2 row is appended and latest_revision is updated
  Scenario: Invalid input
    When the agent creates an artifact with an empty title or unknown kind
    Then a validation error is returned without writing any rows
```
