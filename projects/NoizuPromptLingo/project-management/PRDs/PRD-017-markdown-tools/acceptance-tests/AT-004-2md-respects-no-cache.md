# AT-004: 2md Respects --no-cache Flag

**Category**: Integration
**Related FR**: FR-002, FR-008
**Status**: Passing

## Description

Validates that `2md --no-cache` forces fresh conversion bypassing cache.

## Test Implementation

```python
def test_2md_no_cache():
    """Test that --no-cache forces fresh conversion."""
    # Setup: Create cached content
    # Action: Run 2md with --no-cache
    # Assert: Fresh conversion performed, cache updated
```

## Acceptance Criteria

- [x] `--no-cache` flag bypasses cache read
- [x] Fresh conversion is performed
- [x] New cache written

## Coverage

Covers:
- Force refresh functionality
- Cache bypass behavior
- Cache update after refresh
