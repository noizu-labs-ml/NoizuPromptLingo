# Review: Build Multi-Perspective Artifact Review System

- **Story**: `project-management/user-stories/US-089-build-multi-perspective-artifact-review.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Python server has no `src/npl_mcp/reviews/` module; `create_review` exists only as a metadata-only stub (`src/npl_mcp/meta_tools/stub_catalog.py:51`), so the story's primary target surface is unimplemented. However, the Elixir backend ships a real Review domain: `Domains.Reviews` (`backend/lib/noizu_prompt_lingua/domains/review/reviews.ex:6-101`) with MCP tools ReviewCreate/Get/Comment/Overlay/Complete/Compile/Attach (`backend/lib/noizu_prompt_lingua/domains/review/mcp.ex:8-15`). Reviews carry a single `reviewer_persona`, status, summary, and verdict (`backend/lib/noizu_prompt_lingua/schema/review.ex:12-20`), and overlays store positional annotations (x/y/width/height/comment/persona, `backend/lib/noizu_prompt_lingua/schema/review_overlay.ex:10-15`). There is no perspective concept, no severity/fix fields, no agent assignment, and `Review.Compile` is an explicit stub returning `status: "stub"` (`backend/lib/noizu_prompt_lingua/domains/review/tools/review_compile.ex:21-24`). Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Define review perspectives (code quality, docs, security, style) | Not Met | no evidence found in either codebase |
| `create_review` initiates multi-perspective review with agent assignments | Partially Met | Elixir ReviewCreate tool exists (`backend/.../review/mcp.ex:9`) but single `reviewer_persona`, no assignments (`backend/.../schema/review.ex:16`); Python `create_review` is a stub (`src/npl_mcp/meta_tools/stub_catalog.py:51`) |
| Each perspective generates findings, severity levels, recommended fixes | Partially Met | `ReviewOverlay` supports comments/persona per annotation (`backend/.../schema/review_overlay.ex:10-15`) but has no severity or recommended-fix fields |
| `merge_reviews` consolidates perspectives into unified report | Not Met | `Review.Compile` returns `status: "stub", hint: "Compilation not yet implemented."` (`backend/.../review/tools/review_compile.ex:21-24`) |
| Inline comments and suggestions with line-number precision | Partially Met | overlays use x/y/width/height pixel coordinates, not line numbers (`backend/.../schema/review_overlay.ex:10-13`); `Review.Comment` tool exists (`backend/.../review/mcp.ex:11`) |
| Track review history and reviewer profiles for analytics | Partially Met | status lifecycle + `complete/2` freeze (`reviews.ex:22-44`), comment/overlay history via `get/1` (`reviews.ex:10-19`), `count_by_status` (`reviews.ex:101-106`); no reviewer profiles |
| API for custom perspective definitions | Not Met | no evidence found |

## Gaps / Risks

- No perspective abstraction anywhere; a review is one reviewer's artifact-level record, not a multi-perspective merge.
- `Review.Compile` is a stub, so no consolidated annotated output is producible.
- Python-side `create_review` stub advertises the capability via ToolSearch but ToolCall returns a stub response — discoverability/behavior mismatch.
- No severity taxonomy or fix-tracking fields in the overlay schema.

## BDD Scenario

```gherkin
Feature: Multi-perspective artifact review

  Scenario: Review an artifact today
    Given an artifact with a saved revision on the Elixir backend
    When an agent calls Review.Create with a title and reviewer_persona
    Then a review record is created with status "open"
    And the agent can attach overlay annotations (x/y box + comment) via Review.Overlay
    And free-form comments via Review.Comment
    But no perspective (quality/security/style) is solicited or recorded
    And calling Review.Compile returns a stub response instead of an annotated report
    And Review.Complete freezes the review with a summary and verdict
```
