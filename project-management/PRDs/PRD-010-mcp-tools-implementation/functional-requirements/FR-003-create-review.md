# FR-003: create_review Tool

**Status**: Draft

## Description

Initiate a code review on a specific artifact version.

## Interface

```python
async def create_review(
    artifact_id: str,
    version: int | None = None,
    reviewers: list[str] | None = None,
    ctx: Context
) -> ReviewRecord:
    """Initiate a code review on an artifact version."""
```

## Behavior

- **Given** artifact ID and optional version/reviewers
- **When** create_review is invoked
- **Then**
  - Creates review record in pending state
  - Associates review with specific artifact version (default: latest)
  - Notifies designated reviewers
  - Optionally blocks artifact modification during active review
  - Returns ReviewRecord with review_id, status, created_at

## Edge Cases

- **No reviewers specified**: Create review anyway, assignable later
- **Invalid version**: Return version not found error
- **Already under review**: Allow multiple reviews or return conflict
- **Artifact locked**: Allow review creation but note lock status

## Related User Stories

- US-008-030

## Test Coverage

Expected test count: 8-10 tests
Target coverage: 100% for this FR
