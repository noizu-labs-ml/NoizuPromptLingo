# Review: Review Agent-Generated Code

- **Story**: `project-management/user-stories/US-034-review-agent-generated-code.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

A working review workflow exists in the Python MCP server: `Review.Create(artifact_id, revision_id, reviewer_persona)`, `Review.AddComment` with location descriptors (`"line:58"`, `"@x:100,y:200"`), `Review.AddOverlay`, `Review.Get` (returns all inline comments), and `Review.Complete` (`src/npl_mcp/launcher.py:1604-1675`; `src/npl_mcp/artifacts/reviews.py:46-220`). Artifact history is available via `artifact_list_revisions` (`src/npl_mcp/artifacts/artifacts.py:330`). The Elixir backend adds a parallel review entity with a `verdict` of `approved | changes_requested | rejected` and overlay annotations (`backend/lib/noizu_prompt_lingua/schema/review.ex:9-40`; `backend/lib/noizu_prompt_lingua/domains/review/reviews.ex:22-104`). Missing across both: revision-to-revision diffing (`compare_artifact_revisions` — no evidence found), checklists, threaded replies (comments are flat rows with no parent pointer), task-status integration on completion, and agent-learning aggregation of review patterns.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Start review via `create_review(artifact_id, revision_id, reviewer_persona)`; returns review ID | Met | `src/npl_mcp/artifacts/reviews.py:46-70`; tool at `src/npl_mcp/launcher.py:1604` |
| Agent artifacts labeled with creator persona | Partially Met | artifacts carry creator metadata (`src/npl_mcp/artifacts/artifacts.py:82`); no explicit agent-labeling surfacing in review views |
| View artifact history `get_artifact_history` | Met | `src/npl_mcp/artifacts/artifacts.py:330` |
| Diff between consecutive revisions; compare any two revisions | Not Met | `compare_artifact_revisions`: no evidence found in either codebase |
| Line-specific comments with line/range locations | Partially Met | location is a free-text descriptor (`reviews.py:64-88`) — supports "line:58" by convention, but no structured start/end range validation |
| Markdown formatting in comments | Met | comment text stored verbatim (`reviews.py:88-100`) |
| Threaded replies to comments | Not Met | `npl_inline_comments` has no parent_comment_id (`reviews.py:88-91`) |
| Review checklist for common agent mistakes; pass/fail marking | Not Met | no evidence found |
| Failed checklist items link to comments | Not Met | no evidence found |
| Complete review with `approval_status` (approved/changes_requested/needs_discussion) | Partially Met | Python completion is status-only (`reviews.py:179-220`); Elixir schema has `verdict approved/changes_requested/rejected` (`schema/review.ex:9-40`) but the two systems are not integrated and "needs_discussion" is absent |
| Completed reviews visible via `get_artifact` | Partially Met | `review_list_by_artifact` exists (`reviews.py:13-43`); not embedded in `artifact_get` |
| Review completion updates linked task status | Not Met | no evidence found |
| Revision requests / auto-created follow-up tasks | Not Met | no evidence found |
| Comments persist across sessions | Met | comments persisted in `npl_inline_comments` (`reviews.py:88-100`) |
| Review patterns accessible via `npl_load` | Not Met | no evidence found |

## Gaps / Risks

- Two disconnected review systems (Python `npl_reviews` vs Elixir `reviews`) with different vocabularies — risk of divergent workflow semantics; consolidate before adding features.
- No diff capability makes "review the changes the agent made" impossible; reviewers can only read full revision content.
- Flat comments cannot express the story's threaded-discussion scenario (Scenario 5).

## BDD Scenario

```gherkin
Feature: Review Agent-Generated Code

  Scenario: Basic review cycle
    Given an agent-created artifact with revision 1
    When a developer calls Review.Create for that revision
    And adds a comment at location "line:42" and completes the review with a summary
    Then the review is persisted as completed with its inline comments
    And Review.List by artifact shows the completed review

  Scenario: Revision comparison (not available)
    Given an artifact with revisions 1 and 2
    When the developer requests a diff between the two revisions
    Then no comparison tool exists to produce the diff

  Scenario: Threaded discussion (not available)
    Given an inline comment on line 42
    When the agent replies to that comment
    Then no reply/parent mechanism exists; the reply is a separate flat comment
```
