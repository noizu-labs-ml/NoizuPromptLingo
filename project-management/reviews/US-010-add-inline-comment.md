# Review: Add Inline Review Comment

- **Story**: `project-management/user-stories/US-010-add-inline-comment.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Two surfaces implement inline comments. (1) Python MCP server: `review_add_comment` / `review_get` (`src/npl_mcp/artifacts/reviews.py:73-112`, `:131-176`), registered as `Review.Create/AddComment/Get/Complete` (`src/npl_mcp/launcher.py:1604-1690`) — flat comments with a free-form location string, no threading. (2) Elixir backend: `Review.Comment` MCP tool with `reply_to_id` threading and location (`backend/lib/noizu_prompt_lingua/domains/review/tools/review_comment.ex:11`), generic polymorphic comments (`backend/lib/noizu_prompt_lingua/schema/comment.ex:9-14`) and `Review.Get` returning comments + overlays (`backend/lib/noizu_prompt_lingua/domains/review/tools/review_get.ex:26-52`). The typed location model from the spec (line / line_range / char_range / coordinate objects) was never built — location is a free string ("line:58" style) with coordinate feedback handled separately via overlays. Threading is storage-only: `reply_to_id` is persisted but not returned by `Review.Get`, so threads cannot be reconstructed by clients. Note: the story's own "Implementation Status" section points to `worktrees/main/mcp-server/...` paths that do not exist in this checkout.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Add comment to existing review by review ID | Met | `backend/.../review/tools/review_comment.ex:24-30`; `src/npl_mcp/artifacts/reviews.py:89-93` (not_found guard) |
| Location via typed formats (line / line_range / char_range / coordinate) | Not Met | Location is an unvalidated free string (`comment.ex:13`, `reviews.py:83`); no format parsing or validation found |
| Comment includes markdown text | Met | `content` stored verbatim; rendering is client-side (`review_get.ex:36`) |
| Attributed to reviewer persona with timestamp | Met | `author` + `inserted_at` (`review_get.ex:37-39`) |
| Returns unique comment ID | Met | `review_comment.ex:32`; `reviews.py:105` |
| Reply to existing comment via parent ID | Met | `reply_to_id` input accepted (`review_comment.ex:11,17`) |
| Replies inherit location from parent | Not Met | No inheritance logic in `Comment.add` or `review_comment.ex` |
| Comment hierarchy maintained (parent/child) | Partially Met | `reply_to_id` column persisted (`comment.ex:14`) but no tree building anywhere |
| Retrieve full thread for a comment | Not Met | `Reviews.get/1` returns a flat list; no thread endpoint |
| Comments visible via `get_review` | Met | `Review.Get` includes comments (`review_get.ex:33-42`) |
| Comments grouped by location in review view | Not Met | Flat chronological list (`review_get.ex:33`), no grouping |
| Thread structure preserved in retrieval (nested) | Not Met | `reply_to_id` is omitted from the `Review.Get` response (`review_get.ex:36-40`) |
| Multiple independent comments per review | Met | Polymorphic `comments` table, no constraint preventing this |
| Multiple comments at same location | Met | Location is unindexed free text; duplicates allowed |

## Gaps / Risks

- Threading is write-only: clients can set `reply_to_id` but can never read it back — threads are unrecoverable via the API.
- Location strings are unvalidated; typos silently produce unusable groupings. The typed location discriminated-union from the spec was dropped without a documented replacement.
- The Python and backend implementations have different location conventions ("line:58" / "@x:100,y:200") with no shared parser.
- No edit/delete/resolve support (story's open questions remain open); comments are immutable by omission, not by policy.
- Story file's `worktrees/main/mcp-server/` references are stale for this checkout.

## BDD Scenario

```gherkin
Feature: Inline review comments

  Scenario: PM adds a line comment to a review
    Given a review exists for artifact revision 2
    When the PM calls Review.Comment with review_id, location "line:42", and markdown content
    Then the comment is persisted with a unique ID, the persona slug, and a timestamp
    And Review.Get returns the comment among the review's flat comment list

  Scenario: PM replies to a comment
    Given an existing comment "c-1" on review "r-1"
    When the PM calls Review.Comment with reply_to_id "c-1"
    Then the reply is stored with reply_to_id = "c-1"
    But Review.Get still lists the reply flat, without its parent reference
    And no endpoint can return the reconstructed thread
```
