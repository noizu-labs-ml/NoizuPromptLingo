# FR-005: complete_review Tool

**Status**: Draft

## Description

Finalize a review with approval or rejection decision.

## Interface

```python
async def complete_review(
    review_id: str,
    decision: Literal["approved", "changes_requested", "rejected"],
    summary: str | None = None,
    ctx: Context
) -> ReviewResult:
    """Finalize a review with approval or rejection."""
```

## Behavior

- **Given** review ID and decision
- **When** complete_review is invoked
- **Then**
  - Validates all blocker-severity comments are resolved (for approval)
  - Updates review status to completed
  - Unlocks artifact for modification
  - Triggers completion notification
  - Returns ReviewResult with decision, unresolved_count, completed_at

## Edge Cases

- **Unresolved blockers**: Reject approval, allow changes_requested/rejected
- **Already completed**: Return conflict error
- **Non-existent review**: Return not found error
- **Missing summary**: Allow but recommend providing

## Related User Stories

- US-008-030

## Test Coverage

Expected test count: 10-12 tests
Target coverage: 100% for this FR
