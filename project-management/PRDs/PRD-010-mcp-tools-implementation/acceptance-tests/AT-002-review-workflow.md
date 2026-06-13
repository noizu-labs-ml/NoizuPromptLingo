# AT-002: Code Review Workflow

**Category**: Integration
**Related FR**: FR-003, FR-004, FR-005
**Status**: Not Started

## Description

Validates complete review workflow with comments and approval.

## Test Implementation

```python
async def test_review_workflow():
    """Test complete review workflow from creation to approval."""
    # Setup
    artifact = await create_test_artifact()

    # Create review
    review = await artifact_manager.create_review(
        artifact_id=artifact.id,
        reviewers=["reviewer-1"]
    )
    assert review.status == "pending"

    # Add comment
    comment = await artifact_manager.add_inline_comment(
        review_id=review.id,
        line_start=1,
        line_end=1,
        comment="Looks good!",
        severity="comment"
    )

    # Complete review
    result = await artifact_manager.complete_review(
        review_id=review.id,
        decision="approved"
    )
    assert result.decision == "approved"
    assert result.unresolved_count == 0
```

## Acceptance Criteria

- [ ] Review created in pending state
- [ ] Comments attached to correct lines
- [ ] Blocker comments prevent approval
- [ ] Approval unlocks artifact
- [ ] Notifications sent to reviewers

## Coverage

Covers:
- Normal path: Full approval workflow
- Edge cases: Multiple reviewers
- Error conditions: Unresolved blockers
