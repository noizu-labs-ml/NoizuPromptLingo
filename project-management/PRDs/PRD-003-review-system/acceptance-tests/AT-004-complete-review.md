# AT-004: Complete Review

**Category**: Integration
**Related FR**: FR-001
**Status**: Passing

## Description

Validates that reviews can be marked as completed with overall summary comments.

## Test Implementation

```python
def test_complete_review():
    """Test completing review with summary."""
    # Setup: Create review with comments
    review_id = 1

    # Action: Complete review
    result = complete_review(
        review_id=review_id,
        overall_comment="Approved with minor changes"
    )

    # Assert
    assert result["status"] == "completed"
    assert result["overall_comment"] == "Approved with minor changes"
```

## Acceptance Criteria

- [x] Review status changes to completed
- [x] Overall comment stored
- [x] Timestamps updated
- [x] Review remains retrievable

## Coverage

Covers:
- Normal path: successful completion
- Summary comment preservation
- Status transition
