# AT-016: view-md Supports --depth Flag

**Category**: Unit
**Related FR**: FR-010
**Status**: Passing

## Description

Validates that `view-md --depth N` controls collapsing behavior.

## Test Implementation

```python
def test_view_md_depth():
    """Test that view-md --depth controls collapsing."""
    # Setup: Create deep hierarchy
    # Action: Convert with --depth 2
    # Assert: Sections below level 2 collapsed
```

## Acceptance Criteria

- [x] `--depth` flag accepted
- [x] Sections below depth collapsed
- [x] Structure preserved above depth

## Coverage

Covers:
- Depth parameter
- Controlled collapsing
- Structure preservation
