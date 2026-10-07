# Review: Create a Code Review with Overlay Comments

- **Story**: `project-management/user-stories/US-077-create-a-code-review-with-overlay-comments.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Implemented on the Elixir backend (`/Users/keithbrings/Work/Space/Noizu/projects/NoizuPromptLingo/backend`), not the Python `src/npl_mcp/` side. The `Review.Overlay` MCP tool (`backend/lib/noizu_prompt_lingua/domains/review/tools/review_overlay.ex:1-37`) accepts review_id, x, y, width, height, comment, persona and persists via `Reviews.add_overlay` into `review_overlays` (`backend/lib/noizu_prompt_lingua/domains/review/reviews.ex:79-88`). `Reviews.get/1` returns comments + overlays together (`reviews.ex:10-20`), and the HTTP API test asserts the `overlays` collection is returned (`backend/test/noizu_prompt_lingua_web/controllers/review_controller_test.exs:300-309`). General (non-anchored) comments exist via `Review.Comment` tool and the Comment service. The Python repo has a parallel, weaker implementation (`src/npl_mcp/artifacts/reviews.py:115-128`) where "overlay" encodes only `@x:x,y:y` into a free-text location string — no width/height and no bounds checking. Gap: no bounds validation of coordinates against screenshot dimensions anywhere; no evidence of client-side overlay-box rendering verified (storage/retrieval only). Overall: solid data model, missing validation and unverified rendering.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Comment with x/y/width/height stored anchored to region, rendered as overlay when viewed | Partially Met | `backend/lib/noizu_prompt_lingua/domains/review/tools/review_overlay.ex:14-15` (width/height fields); `backend/lib/noizu_prompt_lingua/domains/review/reviews.ex:10-20` (get returns overlays); rendering not verified in frontend |
| Second non-overlapping comment renders independently, no overwrite | Met | `backend/lib/noizu_prompt_lingua/domains/review/reviews.ex:83-88` — `list_overlays/1` returns all rows ordered by inserted_at; inserts are independent rows |
| Out-of-bounds coordinates rejected with validation error | Not Met | `backend/lib/noizu_prompt_lingua/schema/review_overlay.ex:22-28` changeset has no bounds/dimension validation; no screenshot-dimension reference exists |
| Text-only comment with no coordinates accepted as general comment | Met | `backend/lib/noizu_prompt_lingua/domains/review/tools/review_comment.ex` + Comment service (`Reviews.get` returns `comments` separate from overlays) |

## Gaps / Risks

- No coordinate bounds validation: out-of-canvas overlays are silently accepted (review_overlay.ex inserts without checks).
- Overlay render path (client drawing boxes at x/y/w/h) not verified — only API payload confirmed.
- Python-side `Review.AddOverlay` (`src/npl_mcp/artifacts/reviews.py:115-128`, registered `src/npl_mcp/launcher.py:1641`) drops width/height entirely — divergent duplicate surface.
- No test coverage found for the overlay tool itself (controller tests only assert empty overlays list).

## BDD Scenario

```gherkin
Feature: Code review with overlay comments
  Scenario: Drop a pixel-anchored comment on a screenshot review
    Given a review exists for an artifact revision with a screenshot
    When the reviewer calls Review.Overlay with review_id, x=120, y=80, width=200, height=40, comment "button too small", persona "sofia-reyes"
    Then the overlay is stored with those coordinates and returned by Review.Get in the overlays collection
    And a second Review.Overlay at a different region is stored as an independent row alongside the first
  Scenario: Text-only comment
    When the reviewer calls Review.Comment with no coordinates
    Then the comment is stored as a general review comment and returned in the comments collection, separate from overlays
  Scenario: Out-of-bounds coordinates
    When the reviewer submits an overlay at x beyond the screenshot width
    Then no validation error occurs today — the overlay is accepted (gap)
```
