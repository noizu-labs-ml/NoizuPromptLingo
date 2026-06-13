# FR-019: ask_question Tool

**Status**: Draft

## Description

Submit a question about a task that optionally blocks progress.

## Interface

```python
async def ask_question(
    task_id: str,
    question: str,
    blocking: bool | None = None,
    notify: list[str] | None = None,
    ctx: Context
) -> QuestionRecord:
    """Submit a question about a task."""
```

## Behavior

- **Given** task ID and question text
- **When** ask_question is invoked
- **Then**
  - Creates question in unanswered state
  - Links question to task for context
  - Optionally blocks task progress until answered
  - Notifies specified members or task owner
  - Returns QuestionRecord with question_id, status, asked_at

## Edge Cases

- **Empty question**: Reject with validation error
- **Non-existent task**: Return not found error
- **No notify list**: Notify task owner by default
- **Blocking question on completed task**: Allow but log warning

## Related User Stories

- US-046-060

## Test Coverage

Expected test count: 10-12 tests
Target coverage: 100% for this FR
