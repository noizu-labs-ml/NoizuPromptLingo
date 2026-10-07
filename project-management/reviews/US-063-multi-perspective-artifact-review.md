# Review: Multi-Perspective Artifact Review

- **Story**: `project-management/user-stories/US-063-multi-perspective-artifact-review.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Python MCP server has a single-reviewer artifact review system that covers some groundwork but none of the multi-persona aggregation: `src/npl_mcp/artifacts/reviews.py` supports persona-attributed reviews (`review_create` with `reviewer_persona`, :46-70), inline persona-tagged comments (`review_add_comment`, :73-113), overlays (:115-129), review lookup with comments (:131-178), and completion/status (:179+), all keyed to `artifact_id` + `revision_id`. There is no multi-reviewer orchestration: no independent/blind review isolation (any reader of `review_list_by_artifact` sees all reviewers' comments, :13-44), no aggregation or conflict/agreement analysis, no theme/outlier highlighting, no per-item accept/reject, and no review-history view across versions. Confidence: high — module read in full.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Specify reviewer personas or roles when sharing artifact | Partially Met | `review_create(artifact_id, revision_id, reviewer_persona, ...)` accepts one persona per review (`reviews.py:46-70`); no multi-persona request surface — callers must create N reviews manually with no coordination |
| Each persona reviews independently without seeing others' feedback | Not Met | `review_list_by_artifact` (:13-44) and `review_get` (:131-178) expose all reviews/comments to any reader; no blinding or sequencing |
| System aggregates reviews with conflict/agreement analysis | Not Met | no evidence found |
| Common themes and outliers are highlighted | Not Met | no evidence found |
| Requester can accept/reject individual feedback items | Not Met | only whole-review status via `review_complete` (:179+); no per-comment disposition |
| Review history tracked per artifact version | Partially Met | reviews and comments are keyed by `revision_id` (`reviews.py:20, 54-56`), so per-version records exist, but no aggregated history view across revisions |

## Gaps / Risks

- The storage schema (persona, revision_id, status) is a workable foundation; the entire aggregation/isolation layer is missing.
- No test evidence found for the review functions' behavioral guarantees (e.g., that revision scoping actually filters).

## BDD Scenario

```gherkin
Feature: Request multi-persona reviews of an artifact

  Scenario: Request reviews from three personas
    Given an artifact revision awaiting feedback
    When the requester requests reviews from three personas at once
    Then no multi-persona request exists — three separate reviews must be created manually

  Scenario: Blind independent review
    Given two reviewers are reviewing the same revision
    When reviewer B lists reviews for the artifact
    Then reviewer A's comments are visible to B (gap: no independence isolation)

  Scenario: Aggregated feedback
    When all reviews complete
    Then no conflict/agreement analysis or theme highlighting is produced (gap)
```
