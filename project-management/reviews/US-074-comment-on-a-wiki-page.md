# Review: Comment on a Wiki Page

- **Story**: `project-management/user-stories/US-074-comment-on-a-wiki-page.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Comment creation, threading, listing, and deletion exist on the Elixir backend: `Wiki.CommentCreate` (`backend/lib/noizu_prompt_lingua/domains/wiki/tools/comment_create.ex:19-48`) attaches a comment (author label, defaulting `"mcp"`) to a validated page and supports replies via `parent`; `CommentList` returns id/author/body/parent_id/created_at (`tools/comment_list.ex:25-45`); `CommentDelete` removes a comment "and its replies" (`tools/comment_delete.ex`). Deletion cascades to replies at the tool-description level, and the shared model is reusable (the wiki domain even notes it keeps its own comment table vs the shared Services.Comment). What's missing: **no comment edit** (no `comment_update` tool and `Wiki` has no `update_comment`), and **no author verification on delete** — any caller can delete any comment. Timestamps are recorded (`inserted_at`) and shown. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Comment with text appears attached to the Page, visible to project members, with author + timestamp | Met | `comment_create.ex:26-45`; `comment_list.ex:27-45` returns author, body, created_at; notifications fan-out best-effort (`wiki.ex:133-141`) |
| Reply threads under the original comment, not as a new top-level comment | Met | `parent` field → `parent_id` (`comment_create.ex:29`, schema `comment.ex:10`); list exposes `parent_id` for client-side threading |
| Author can edit or delete own comment; other comments unaffected | Partially Met | delete exists (`comment_delete.ex:16-25`) and is targeted by id (single row + replies), but there is no edit capability (no `comment_update` tool) and **no author check** — any caller may delete anyone's comment |

## Gaps / Risks

- No comment edit path: the only "update" is delete-and-repost.
- `Wiki.delete_comment/1` (`wiki.ex:143-148`) deletes without author identity verification; with the default author label `"mcp"` for all callers, attribution is weak (actor is caller-supplied, not resolved server-side — cf. ToolGuard's server-side identity rule).
- Reply validation is FK-level only; a reply can target a comment on a *different* page (parent page not cross-checked).

## BDD Scenario

```gherkin
Feature: Comment on a wiki page

  Scenario: Ask a question on a page
    When the agent calls Wiki.CommentCreate with page=<id>, author="jordan", body="Is step 3 current?"
    Then CommentList(page=<id>) shows the comment with author "jordan" and created_at

  Scenario: Thread a reply
    When the agent calls Wiki.CommentCreate with page=<id>, parent=<comment id>, body="Yes, updated last week"
    Then the reply carries parent_id=<comment id> and does not appear as a top-level comment

  Scenario: Remove an outdated comment
    When the agent calls Wiki.CommentDelete with comment=<comment id>
    Then the comment and its replies are removed and other comments remain

  Scenario: Edit a comment (unsupported)
    When the author wants to fix a typo in their comment
    Then no Wiki.CommentUpdate tool exists — the comment must be deleted and recreated
```
