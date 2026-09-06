# Review: Create Versioned Artifact

- **Story**: `project-management/user-stories/US-008-create-versioned-artifact.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

`Artifact.Create` MCP tool (`backend/lib/noizu_prompt_lingua/domains/artifacts/tools/artifact_create.ex`) creates an artifact plus its initial revision atomically in `Domains.Artifacts.create` (`backend/lib/noizu_prompt_lingua/domains/artifacts/artifacts.ex:6-18`): artifact row (UUID binary_id, kind enum, title, mime_type, org/project scope) + revision v1 (number starts at 1, `create_revision` line 95-104). Response includes `id`, `artifact_url`, `revision_id`, `created_at` (`artifact_create.ex:57-70`). Type validation exists as a kind enum — `code, document, image, wiki, config, binary` (`schema/artifact.ex:10,25`), which diverges from the story's `markdown/code/image/json/yaml/text/binary` list. Content is required on the revision (`schema/artifact_revision.ex:20`), so empty content is rejected. Major gaps vs the story: **no base64 validation, no 10MB size limit, no SHA-256 content hash, no creator attribution** (neither `Artifact` nor `ArtifactRevision` has a creator field and the tool takes no `created_by`), no session_id grouping (project_id is the only grouping key), and no filename-extension type auto-detection. Tests: `backend/test/` covers artifact flows (53%-ish coverage claimed in the story; the cited legacy Python paths no longer exist).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Create with required name/type/content | Met | `artifact_create.ex:34` required org/kind/title/content; revision content required (`artifact_revision.ex:20`) |
| Unique UUID on creation | Met | `binary_id` primary keys (`artifact.ex:6`, `artifact_revision.ex:6`) |
| Creator persona ID recorded | Not Met | no creator field on `Artifact`/`ArtifactRevision`; `Artifact.Create` input has no created_by (`artifact_create.ex:8-35`) |
| Creation timestamp (ISO 8601) | Met | `timestamps(type: :utc_datetime)`; `artifact_create.ex:69` |
| Optional session ID grouping | Partially Met | no session_id; project scoping exists instead (`artifact_create.ex:14-15`, `artifacts.ex:114-115`) |
| Base64 validation before storage | Not Met | content stored verbatim (`artifacts.ex:95-104`); no evidence found of Base.decode64 checks |
| Max content size 10MB | Not Met | no size/length validation in either changeset (`artifact.ex:24-32`, `artifact_revision.ex:18-24`) |
| Empty content rejected | Met | `validate_required([..., :content, ...])` (`artifact_revision.ex:20`) |
| First revision v1 auto-created | Met | `artifacts.ex:12` (revision_number 1) |
| Integer-sequential revision numbers | Met | `max+1` (`artifacts.ex:50-56`) — note: not concurrency-safe (read-then-insert, no unique constraint visible) |
| Each revision immutable | Met | no update/delete path for revisions in `artifacts.ex` or tools |
| Revision includes version, timestamp, creator, hash | Partially Met | version ✓ (`artifact_revision.ex:12`), timestamp ✓, creator ✗, hash ✗ (no such fields) |
| Type enum validated | Met | `validate_inclusion(:kind, @kinds)` (`artifact.ex:25`) — though the enum differs from the story's list |
| Auto-detect type from filename extension | Not Met | no filename input or detection logic found |
| Response returns id, name, type, timestamp, first revision details | Met | `artifact_create.ex:60-70` (id, artifact_url, revision_id, kind, title, created_at) |
| Returns web URL | Met | `Urls.artifact_url(artifact)` (`artifact_create.ex:63`) |

## Gaps / Risks

- No size cap: multi-hundred-MB contents land in Postgres text columns via MCP — DoS/operational risk.
- No content hash → integrity verification (story's stated purpose) is impossible.
- No creator attribution → the audit trail story (US-009 history) cannot answer "who".
- `add_revision` max+1 numbering can collide under concurrent revisions (no unique constraint check performed here).
- Kind enum drift vs story (`document` vs `markdown`/`text`/`yaml`/`json`) — consumers must translate.

## BDD Scenario

```gherkin
Feature: Create a versioned artifact

  Scenario: Agent persists a deliverable
    When an agent calls Artifact.Create with organization, kind="document",
      title="design-mockup-v1", content=<content>
    Then the response contains an artifact UUID, an artifact_url, and revision_id
    And Artifact.ListRevisions shows revision_number=1
    And Artifact.Get with no revision returns the v1 content

  Scenario: Invalid type rejected
    When Artifact.Create is called with kind="spreadsheet"
    Then the call fails with a kind inclusion validation error

  Scenario: Size guard (currently missing)
    When Artifact.Create is called with a 50MB content string
    Then the write succeeds today (no size limit exists) — a spec violation
```
