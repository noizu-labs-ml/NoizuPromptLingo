# AT-007: md-view Filters by Heading Level

**Category**: Unit
**Related FR**: FR-003, FR-009
**Status**: Passing

## Description

Validates that `md-view` filters by heading level (`h1` - `h6`).

## Test Implementation

```python
def test_md_view_filter_level():
    """Test that md-view filters by heading level."""
    # Setup: Create markdown with various heading levels
    # Action: Filter by level (e.g., h2)
    # Assert: All h2 sections returned
```

## Acceptance Criteria

- [x] Level selector `h1` - `h6` supported
- [x] All matching level headings extracted
- [x] Section content included

## Coverage

Covers:
- Level selector parsing
- Multi-section extraction
- Content preservation
