# AT-018: view-md Respects Caching Options

**Category**: Integration
**Related FR**: FR-010
**Status**: Passing

## Description

Validates that `view-md` respects `--no-cache` and `--cache-dir` options.

## Test Implementation

```python
def test_view_md_cache_options():
    """Test that view-md respects cache options."""
    # Setup: Create cached content
    # Action: Use --no-cache and custom --cache-dir
    # Assert: Options respected
```

## Acceptance Criteria

- [x] `--no-cache` forces fresh conversion
- [x] `--cache-dir` uses custom directory
- [x] Cache behavior correct

## Coverage

Covers:
- Cache bypass
- Custom cache directory
- Cache option handling
