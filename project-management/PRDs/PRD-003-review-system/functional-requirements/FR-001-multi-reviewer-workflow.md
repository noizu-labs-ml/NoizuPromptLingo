# FR-001: Multi-Reviewer Workflow

**Status**: Completed

## Description

The system must support multiple independent reviewers creating separate review sessions for the same artifact revision, with each reviewer's feedback tracked separately.

## Interface

```python
def create_review(artifact_id: int, revision_id: int, reviewer_persona: str) -> dict:
    """Create new review session for artifact revision.

    Returns review object with id, status='in_progress'.
    """

def get_review(review_id: int) -> dict:
    """Retrieve review details including all comments."""

def complete_review(review_id: int, overall_comment: str) -> dict:
    """Mark review as completed with summary comment."""
```

## Behavior

- **Given** artifact revision exists
- **When** reviewer creates review with persona
- **Then** new review session is created with unique ID

- **Given** review session exists
- **When** reviewer completes review with summary
- **Then** status changes to completed and summary is stored

## Edge Cases

- **Multiple reviews by same persona**: Allowed, creates separate review instances
- **Review without comments**: Valid, can be completed with only overall summary

## Related User Stories

- US-010
- US-011
- US-023
- US-063

## Test Coverage

Expected test count: 8
Target coverage: 100%
Actual coverage: 25%
