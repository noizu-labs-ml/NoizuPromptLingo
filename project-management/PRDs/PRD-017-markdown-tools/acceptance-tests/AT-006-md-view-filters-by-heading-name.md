# AT-006: md-view Filters by Heading Name

**Category**: Unit
**Related FR**: FR-003, FR-009
**Status**: Passing

## Description

Validates that `md-view` filters markdown by heading name (case-insensitive).

## Test Implementation

```python
def test_md_view_filter_heading():
    """Test that md-view filters by heading name."""
    # Setup: Create markdown with multiple sections
    # Action: Filter by heading name
    # Assert: Only matching section returned
```

## Acceptance Criteria

- [x] Case-insensitive matching
- [x] Returns matched section with content
- [x] Other sections excluded

## Coverage

Covers:
- Heading name matching
- Case-insensitive search
- Section extraction
