# FR-004: add_inline_comment Tool

**Status**: Draft

## Description

Add a line-specific comment during a code review.

## Interface

```python
async def add_inline_comment(
    review_id: str,
    line_start: int,
    line_end: int | None = None,
    comment: str,
    severity: Literal["comment", "suggestion", "issue", "blocker"] | None = None,
    ctx: Context
) -> CommentRecord:
    """Add a line-specific comment during review."""
```

## Behavior

- **Given** review ID, line range, and comment text
- **When** add_inline_comment is invoked
- **Then**
  - Validates review exists and is not completed
  - Stores line range and comment content with markdown support
  - Supports threaded replies via parent_comment_id
  - Tracks resolution status per comment
  - Returns CommentRecord with comment_id, position, severity

## Edge Cases

- **Invalid line numbers**: Validate against artifact content length
- **Review completed**: Reject with status error
- **Negative line numbers**: Reject with validation error
- **Empty comment**: Reject with validation error

## Related User Stories

- US-008-030

## Test Coverage

Expected test count: 10-12 tests
Target coverage: 100% for this FR
