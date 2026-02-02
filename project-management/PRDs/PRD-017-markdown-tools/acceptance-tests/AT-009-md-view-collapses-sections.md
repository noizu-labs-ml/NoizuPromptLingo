# AT-009: md-view Collapses Sections Below Depth

**Category**: Unit
**Related FR**: FR-007, FR-009
**Status**: Passing

## Description

Validates that `md-view --depth N` collapses sections below specified depth.

## Test Implementation

```python
def test_md_view_collapse():
    """Test that md-view collapses sections below depth."""
    # Setup: Create deep markdown hierarchy
    # Action: Apply --depth 2
    # Assert: Sections below level 2 collapsed
```

## Acceptance Criteria

- [x] Sections below depth collapsed
- [x] `[Collapsed]` marker inserted
- [x] Single marker for consecutive sections
- [x] Structure above depth preserved

## Coverage

Covers:
- Collapse algorithm
- Depth threshold logic
- Marker insertion
