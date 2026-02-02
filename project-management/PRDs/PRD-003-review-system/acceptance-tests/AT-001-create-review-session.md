# AT-001: Create Review Session

**Category**: Integration
**Related FR**: FR-001
**Status**: Passing

## Description

Validates that a reviewer can create a new review session for an artifact revision with their persona identity.

## Test Implementation

```python
def test_create_review_session():
    """Test creating review session for artifact revision."""
    # Setup: Create artifact and revision
    artifact_id = 1
    revision_id = 2

    # Action: Create review
    review = create_review(
        artifact_id=artifact_id,
        revision_id=revision_id,
        reviewer_persona="mike-developer"
    )

    # Assert
    assert review["artifact_id"] == artifact_id
    assert review["revision_id"] == revision_id
    assert review["reviewer_persona"] == "mike-developer"
    assert review["status"] == "in_progress"
```

## Acceptance Criteria

- [x] Review created with unique ID
- [x] Status initialized to "in_progress"
- [x] Reviewer persona preserved
- [x] Timestamps captured

## Coverage

Covers:
- Normal path: successful review creation
- Multiple reviews per revision
- Reviewer identity tracking
