# Review: Annotate Screenshot with Overlay

- **Story**: `project-management/user-stories/US-011-annotate-screenshot.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The coordinate-annotation core exists on the backend: `Review.Overlay` MCP tool accepts x, y, width, height, comment, persona and persists via `Reviews.add_overlay/1` (`backend/lib/noizu_prompt_lingua/domains/review/tools/review_overlay.ex:16-48`, `backend/lib/noizu_prompt_lingua/domains/review/reviews.ex:79-88`), and `Review.Get` returns all overlays alongside comments (`review_get.ex:43-52`). The Python MCP server has the equivalent thinner `review_add_overlay` (`src/npl_mcp/artifacts/reviews.py:115-128`, encodes "@x:X,y:Y" into the comment location). Annotations never touch the original image (separate rows). What is missing is the generation side: `Review.Compile` — the tool meant to render an annotated artifact — is an explicit stub returning `status: "stub", hint: "Compilation not yet implemented."` (`backend/lib/noizu_prompt_lingua/domains/review/tools/review_compile.ex:21-28`), and the Python `generate_annotated_artifact` exists only as a catalog stub with no implementation (`src/npl_mcp/meta_tools/stub_catalog.py:92-100`). So annotated data is captured and retrievable, but no annotated image/output is ever produced. The story's referenced implementation paths (`worktrees/main/mcp-server/...`) do not exist in this checkout.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Add annotation at x,y coordinates on image artifact | Met | `review_overlay.ex:16-28` (x, y, optional width/height) |
| Annotation includes comment text | Met | `comment` required field (`review_overlay.ex:20-21`) |
| Annotations attributed to reviewer_persona | Met | `persona` required field (`review_overlay.ex:22-23`) |
| Retrieve review with all annotations via `get_review` | Met | `Review.Get` returns overlays array (`review_get.ex:43-52`) |
| Generate annotated version of artifact with annotations visible | Not Met | `Review.Compile` is a stub (`review_compile.ex:21-28`); Python `generate_annotated_artifact` is catalog-only (`stub_catalog.py:92-100`) |
| Annotations do not modify original image artifact | Met | Overlays are separate `review_overlays` rows; no artifact mutation anywhere in `reviews.ex` |
| Multiple annotations supported per review | Met | `Reviews.add_overlay` inserts rows keyed by review_id, no limit |
| Annotated images accessible via file path | Not Met | Nothing generates an annotated image; no file path is ever produced |

## Gaps / Risks

- The user-visible payoff of this story — a rendered annotated image — does not exist in either implementation; only structured overlay data does.
- No validation that the review's artifact is actually an image; coordinate annotations on text artifacts are silently accepted.
- The story claims "✅ Implemented in mcp-server worktree" with test coverage 25%, but neither the cited worktree path nor review tests exist in this checkout (`grep review_ tests/` finds nothing review-specific).
- Python-side overlay encoding ("@x:100,y:200" string) is lossy — it drops width/height, which the backend preserves.

## BDD Scenario

```gherkin
Feature: Coordinate overlay annotations on screenshots

  Scenario: PM flags a UI misalignment
    Given an open review on a screenshot artifact
    When the PM calls Review.Overlay with x=120, y=340, comment, and persona
    Then the overlay is stored with the coordinate, comment, and persona
    And Review.Get returns it in the overlays list without altering the original artifact

  Scenario: PM requests the annotated rendering
    When the PM calls Review.Compile for that review
    Then the response is status "stub" with hint "Compilation not yet implemented."
    And no annotated image or file path is produced
```
