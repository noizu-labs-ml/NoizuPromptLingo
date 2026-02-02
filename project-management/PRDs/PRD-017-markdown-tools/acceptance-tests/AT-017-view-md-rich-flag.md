# AT-017: view-md Supports --rich Flag

**Category**: Unit
**Related FR**: FR-010
**Status**: Passing

## Description

Validates that `view-md --rich` formats output with Rich library.

## Test Implementation

```python
def test_view_md_rich():
    """Test that view-md --rich formats with Rich."""
    # Setup: Create source content
    # Action: Convert with --rich
    # Assert: Rich formatted output
```

## Acceptance Criteria

- [x] `--rich` flag supported
- [x] Rich formatting applied
- [x] Terminal display enhanced

## Coverage

Covers:
- Rich formatting option
- Terminal output styling
- Display enhancement
