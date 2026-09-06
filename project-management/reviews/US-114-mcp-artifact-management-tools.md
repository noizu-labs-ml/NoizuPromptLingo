# Review: MCP Artifact Management Tools

- **Story**: `project-management/user-stories/US-114-mcp-artifact-management-tools.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Implemented in both codebases. Python MCP server: `src/npl_mcp/artifacts/artifacts.py` (create/list/get/list-revisions/add-revision/get-binary over `npl_artifacts`/`npl_artifact_revisions`, with kind classification incl. binary kinds and a 15MB cap, artifacts.py:22-28,82-235) and `src/npl_mcp/artifacts/reviews.py` (review create/get/add-comment/add-overlay/complete, reviews.py:46-204). All are wired to MCP tools in `src/npl_mcp/launcher.py` (Artifact.Create/Get/List/ListRevisions/AddRevision/GetBinary, Review.Create/Get/AddComment/Complete/AddOverlay). The Elixir backend (noted: Elixir backend at /Users/keithbrings/Work/Space/Noizu/projects/NoizuPromptLingo/backend) mirrors the same tool names in `lib/noizu_prompt_lingua/domains/artifacts/tools/` and `domains/review/tools/`, with organization/project scoping (artifact_create.ex resolves org + project_in_org before insert) and a richer `Review.Complete` accepting a verdict of approved/changes_requested/rejected (review_complete.ex). The only soft spot is approval/rejection on the Python side, where complete only sets status='completed' with no verdict; the Elixir side carries the verdict field.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Create new artifacts with type classification | Met | `src/npl_mcp/artifacts/artifacts.py:82-153` — VALID_KINDS incl. markdown/json/yaml/code/image/pdf (artifacts.py:22-26); Elixir `Artifact.Create` with kind enum at Elixir backend `lib/noizu_prompt_lingua/domains/artifacts/tools/artifact_create.ex` |
| Version existing artifacts with change summaries | Met | `artifact_add_revision` with `notes` + auto-increment + latest_revision sync, artifacts.py:156-235; Elixir `Artifact.AddRevision` tool |
| Initiate code reviews on specific versions | Met | `review_create(artifact_id, revision_id, reviewer_persona)` reviews.py:46-70; Elixir backend `domains/review/tools/review_create.ex` |
| Add line-specific inline comments during reviews | Met | `review_add_comment` with `location` ("line:58") + existence check on review, reviews.py:73-112; Elixir `Review.Comment` |
| Complete reviews with approval/rejection decisions | Partially Met | Python `review_complete` sets only status='completed', no approve/reject verdict (reviews.py:179-204); Met on the Elixir backend via `verdict` field "approved, changes_requested, rejected" in `domains/review/tools/review_complete.ex` |
| Annotate screenshot artifacts with visual markers | Met | `review_add_overlay` stores `@x:{x},y:{y}` location markers via the same comment table, reviews.py:115-128; Elixir `Review.Overlay` |

## Gaps / Risks

- Python review completion has no approve/reject verdict — callers on the Python surface cannot record a rejection decision (Elixir backend only).
- No authz on the Python side: any caller can read/modify any artifact or review by integer id; no org/project scoping (unlike the Elixir tools, which resolve org/project before every mutation).
- review_create does not validate that `revision_id` belongs to `artifact_id` (reviews.py:46-61 inserts unchecked).
- Binary artifacts: content is stored as bytes in Postgres with a 15MB cap, served back via Artifact.GetBinary — fine for MVP, but no dedupe or external storage.
- Coverage: `tests/test_artifacts.py` exists for artifacts; review module has lighter/no direct test coverage (no tests/test_reviews*.py observed).

## BDD Scenario

```gherkin
Feature: Create and version artifacts with inline code review

  Scenario: Create, revise, and review an artifact
    Given the MCP server is connected
    When the agent calls ToolCall("Artifact.Create", {"title": "deploy notes", "kind": "markdown", "content": "..."})
    Then a npl_artifacts row and revision 1 are created
    When the agent calls ToolCall("Artifact.AddRevision", {"artifact_id": <id>, "content": "...", "notes": "added rollout steps"})
    Then revision 2 exists and latest_revision is 2
    When the agent calls ToolCall("Review.Create", {"artifact_id": <id>, "revision_id": <rev2-id>, "reviewer_persona": "reviewer"})
    Then a review in status "open" is returned
    When the agent calls ToolCall("Review.AddComment", {"review_id": <rid>, "location": "line:12", "comment": "typo", "persona": "reviewer"})
    Then an inline comment is stored at line:12
    When the agent calls ToolCall("Review.Complete", {"review_id": <rid>, "overall_comment": "lgtm"})
    Then the review status becomes "completed"
    # On the Elixir backend, Review.Complete additionally accepts verdict: approved|changes_requested|rejected.

  Scenario: Annotate a screenshot artifact
    Given an artifact of kind "image" with binary content uploaded
    When the agent calls ToolCall("Review.AddOverlay", {"review_id": <rid>, "x": 100, "y": 200, "comment": "button too small", "persona": "qa"})
    Then an inline comment with location "@x:100,y:200" is stored
```
