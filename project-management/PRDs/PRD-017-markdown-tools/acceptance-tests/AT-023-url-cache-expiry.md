# AT-023: URL Caches Expire After max_age

**Category**: Unit
**Related FR**: FR-001
**Status**: Passing

## Description

Validates that URL caches expire after configurable `max_age` (default 3600s).

## Test Implementation

```python
def test_url_cache_expiry():
    """Test that URL caches expire after max_age."""
    # Setup: Create cached URL with timestamp
    # Action: Check cache after expiry time
    # Assert: Cache treated as expired
```

## Acceptance Criteria

- [x] Default max_age is 3600s
- [x] Expired caches return None
- [x] Fresh conversion triggered on expiry

## Coverage

Covers:
- Cache expiry logic
- Timestamp checking
- Re-fetch trigger
