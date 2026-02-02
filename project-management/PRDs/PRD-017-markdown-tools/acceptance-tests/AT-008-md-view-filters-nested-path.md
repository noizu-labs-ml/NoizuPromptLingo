# AT-008: md-view Filters by Nested Path

**Category**: Unit
**Related FR**: FR-003, FR-009
**Status**: Passing

## Description

Validates that `md-view` filters by nested path (`parent > child`).

## Test Implementation

```python
def test_md_view_nested_path():
    """Test that md-view filters by nested path."""
    # Setup: Create markdown with hierarchy
    # Action: Filter by "Parent > Child"
    # Assert: Child section of Parent returned
```

## Acceptance Criteria

- [x] Nested path navigation with `>` separator
- [x] Hierarchical section matching
- [x] Child content extracted correctly

## Coverage

Covers:
- Path navigation algorithm
- Hierarchy traversal
- Nested section extraction
