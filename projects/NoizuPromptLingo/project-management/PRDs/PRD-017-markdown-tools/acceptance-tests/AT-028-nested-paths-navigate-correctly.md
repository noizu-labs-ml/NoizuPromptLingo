# AT-028: Nested Paths Navigate Hierarchy Correctly

**Category**: Unit
**Related FR**: FR-003
**Status**: Passing

## Description

Validates that nested paths navigate markdown hierarchy correctly.

## Test Implementation

```python
def test_nested_path_navigation():
    """Test that nested paths navigate correctly."""
    # Setup: Create hierarchy A > B > C
    # Action: Filter for "A > B > C"
    # Assert: Section C under B under A
```

## Acceptance Criteria

- [x] Multi-level navigation works
- [x] Path separator `>` recognized
- [x] Correct child section extracted

## Coverage

Covers:
- Hierarchical navigation
- Path parsing
- Tree traversal
