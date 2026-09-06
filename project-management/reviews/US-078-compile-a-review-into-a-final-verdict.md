# Review: Compile a Review into a Final Verdict

- **Story**: `project-management/user-stories/US-078-compile-a-review-into-a-final-verdict.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Implemented on the Elixir backend (`/Users/keithbrings/Work/Space/Noizu/projects/NoizuPromptLingo/backend`). `Review.Complete` MCP tool (`backend/lib/noizu_prompt_lingua/domains/review/tools/review_complete.ex:1-29`) and the HTTP `POST .../reviews/:id/complete` endpoint (`backend/lib/noizu_prompt_lingua_web/controllers/review_controller.ex:111-135`) set status to "completed" with an enum-validated verdict (`approved|changes_requested|rejected`, `backend/lib/noizu_prompt_lingua/schema/review.ex:8,31`) plus summary; controller tests verify verdict persistence and 422 on invalid verdict (`review_controller_test.exs:329-347`). However, re-completion is NOT rejected: `Reviews.complete/2` (`reviews.ex:22-39`) has no status guard, so a second `Review.Complete` silently overwrites the verdict — only the generic update path is frozen (`{:error, :completed}`, `reviews.ex:59-60`). The ticket linkage (verdict attached back to originating ticket) does not exist: reviews reference only `artifact_id`, no ticket field or ticket-review join was found, and `Review.Compile` is an explicit stub (`tools/review_compile.ex:22-24`, `status: "stub"`).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Final verdict (approve/request-changes/reject) + summary marks review complete, verdict displayed at top | Partially Met | `backend/lib/noizu_prompt_lingua/domains/review/tools/review_complete.ex:17-27`; `schema/review.ex:31` verdict enum; "displayed at top" is a UI concern, data layer verified via `review_controller_test.exs:329-340` |
| Verdict attached back to originating ticket; ticket shows status + link to review | Not Met | `schema/review.ex:13-19` has artifact_id/revision_id only; no ticket-review linkage found in `lib/noizu_prompt_lingua/`; `tools/review_compile.ex:22-24` returns `status: "stub"` |
| Second verdict without reopening is rejected | Partially Met | update path frozen: `reviews.ex:58-60` `{:error, :completed}` + controller 409 (`review_controller_test.exs:111-115`); but `Reviews.complete/2` (`reviews.ex:22-39`) has no completed-status guard — MCP `Review.Complete` and the `/complete` endpoint can overwrite a verdict silently |

## Gaps / Risks

- Verdict-overwrite hole: re-calling Review.Complete (or POST /complete) on a completed review replaces the recorded outcome with no error and no reopen semantics — exactly the failure mode the criterion names.
- No review↔ticket attachment means reviewers cannot close the loop back to the work item the story's premise depends on.
- `Review.Compile` (annotated-artifact generation) is an unimplemented stub despite being the story's namesake operation.

## BDD Scenario

```gherkin
Feature: Compile a review into a final verdict
  Scenario: Reviewer submits the final verdict
    Given a review with overlay and general comments exists in status "in_progress"
    When the reviewer calls Review.Complete with verdict "changes_requested" and summary "fix the nav spacing"
    Then the review status becomes "completed" with that verdict and summary persisted
    And an invalid verdict like "lgtm" is rejected with a validation error (422)
  Scenario: Attach verdict back to ticket
    When the reviewer attaches the verdict to the originating ticket
    Then no such linkage exists today — the operation fails / is unsupported (gap)
  Scenario: Double verdict
    Given the review is already completed with verdict "approved"
    When the reviewer calls Review.Complete again with verdict "rejected"
    Then the verdict is silently overwritten today instead of being rejected (gap); the update/edit path is correctly frozen with 409
```
