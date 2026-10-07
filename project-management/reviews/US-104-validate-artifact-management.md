# Review: Validate Artifact Management Implementation

- **Story**: `project-management/user-stories/US-104-validate-artifact-management.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The artifact system is real and more capable than the story describes: six MCP tools in `src/npl_mcp/launcher.py:884-1030` (`Artifact.Create`, `Artifact.AddRevision`, `Artifact.Get`, `Artifact.List`, `Artifact.ListRevisions`, `Artifact.GetBinary`) delegate to `src/npl_mcp/artifacts/artifacts.py` (`artifact_create` :82, `artifact_add_revision` :156, `artifact_get` :238, `artifact_list` :288, `artifact_list_revisions` :330, `artifact_get_binary` :357). Web retrieval routes exist: `GET /artifacts`, `GET /artifacts/{id}`, revision list/create plus raw revision download (`src/npl_mcp/api/router.py:2036-2275`) — though the path is `/artifacts/{id}`, not `/artifact/{id}`. A dedicated test suite exists (`tests/test_artifacts.py`, 22 tests). The story's `annotate_artifact` tool does not exist; inline commenting was implemented separately as the review system (`src/npl_mcp/artifacts/reviews.py`, `Review.AddOverlay`/`Review.Get`/`Review.Complete` at `launcher.py:1659-1685`). The database is PostgreSQL via asyncpg, not SQLite as the story assumes. The 53% coverage figure is a stale snapshot claim and cannot be confirmed as "verified and documented"; no performance baseline evidence exists.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| All 5 artifact tools tested against the actual database | Partially Met | 5/5 named tools exist (annotate replaced by reviews system); `tests/test_artifacts.py` has 22 tests but uses mocked pools (unit-level), not the actual DB |
| Versioning system validates schema constraints and relationships | Partially Met | `artifacts.py:156-235` add_revision creates versioned rows; constraint validation in code, no evidence of schema-level relationship tests |
| Web routes for artifact retrieval functional | Met | `api/router.py:2036-2275` — GET /artifacts, GET /artifacts/{artifact_id}, revisions CRUD, raw revision endpoint (`/artifacts/{id}` not `/artifact/{id}`) |
| Current test coverage of 53% is verified and documented | Not Met | No coverage report or documentation of the 53% figure found in the repo |
| Artifact metadata, content, and revision history queries tested | Partially Met | `tests/test_artifacts.py` covers create/get/list/revisions paths via mocked pool fixtures; binary content path untested |
| Tool error handling validated (invalid IDs, schema violations) | Partially Met | `artifact_get` returns not-found dict (`artifacts.py:238-286`); input-validation tests present in `tests/test_artifacts.py`; binary/edge paths less covered |
| Performance baseline established for artifact operations | Not Met | No benchmark or baseline artifacts found |

## Gaps / Risks

- Story's stated tables (`artifacts`/`revisions` in SQLite) don't match implementation (Postgres `npl_artifacts`-style schema via asyncpg) — story needs updating, not the code.
- `annotate_artifact` acceptance is satisfied only by the separate reviews subsystem; artifact-version-scoped inline comments are not the same surface the story names.
- Tests mock the storage pool, so schema-constraint and relationship behavior is unvalidated against a real database.
- No documented coverage measurement exists to confirm or refute the 53% figure or the 80% target.

## BDD Scenario

```gherkin
Feature: Versioned artifact management

  Scenario: Create and revise an artifact
    When an agent calls Artifact.Create with title, type, and content
    Then the artifact row is created with an initial revision
    When the agent calls Artifact.AddRevision with new content
    Then a new revision row is created and becomes the current version

  Scenario: Retrieve an artifact over the web API
    Given artifact 12 exists with three revisions
    When a client GETs /artifacts/12
    Then the current artifact metadata and content are returned
    And GET /artifacts/12/revisions lists the revision history

  Scenario: Retrieve a missing artifact
    When a client GETs /artifacts/99999
    Then the API returns a not-found response rather than an error crash

  Scenario: Annotate an artifact (via reviews subsystem)
    Given a review exists against a screenshot artifact
    When an agent calls Review.AddOverlay with x, y, and comment
    Then the overlay comment is stored and returned by Review.Get
```
