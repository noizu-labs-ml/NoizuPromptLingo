# FR-002: Inline Text Comments

**Status**: Completed

## Description

The system must allow reviewers to add location-specific comments to text-based artifacts using line number references.

## Interface

```python
def add_inline_comment(
    review_id: int,
    location: str,
    comment: str,
    persona: str
) -> dict:
    """Add inline comment at specific location.

    Location format: "line:58" for text files.
    Returns comment object with id, created_at.
    """
```

## Behavior

- **Given** review session exists
- **When** reviewer adds comment with location="line:58"
- **Then** comment is stored with location reference

- **Given** multiple comments at same location
- **When** generating annotated artifact
- **Then** all comments appear as footnotes

## Edge Cases

- **Invalid line number**: Accept any positive integer, validation deferred to generation
- **Empty comment text**: Rejected with validation error
- **Location format variation**: Only "line:N" format supported

## Related User Stories

- US-010

## Test Coverage

Expected test count: 6
Target coverage: 100%
Actual coverage: 25%
