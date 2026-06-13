# AT-014: view-md Applies Filtering and Collapsing

**Category**: Integration
**Related FR**: FR-010
**Status**: Passing

## Description

Validates that `view-md` applies filtering and/or collapsing to converted output.

## Test Implementation

```python
def test_view_md_filters():
    """Test that view-md applies filters to output."""
    # Setup: Create source with sections
    # Action: Convert with --filter and --depth
    # Assert: Filtered + collapsed output
```

## Acceptance Criteria

- [x] Filtering applied to converted content
- [x] Collapsing applied to converted content
- [x] Both operations can be combined

## Coverage

Covers:
- Post-conversion filtering
- Post-conversion collapsing
- Combined operations
