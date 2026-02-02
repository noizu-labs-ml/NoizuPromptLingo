# AT-015: view-md Supports --bare Flag

**Category**: Unit
**Related FR**: FR-010
**Status**: Passing

## Description

Validates that `view-md --bare` shows filtered content only (no collapse markers).

## Test Implementation

```python
def test_view_md_bare():
    """Test that view-md --bare shows filtered content only."""
    # Setup: Create source with sections
    # Action: Filter with --bare
    # Assert: Only filtered section, no markers
```

## Acceptance Criteria

- [x] `--bare` flag supported
- [x] Shows filtered content only
- [x] No collapse markers in output

## Coverage

Covers:
- Bare output mode
- Filtered-only display
- Marker suppression
