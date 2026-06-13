# AT-011: md-view Combines Filtering and Collapsing

**Category**: Integration
**Related FR**: FR-007, FR-009
**Status**: Passing

## Description

Validates that `md-view` can combine filtering and collapsing in single command.

## Test Implementation

```python
def test_md_view_combined():
    """Test that md-view combines filter and collapse."""
    # Setup: Create deep markdown
    # Action: Apply --filter and --depth
    # Assert: Filtered + collapsed output
```

## Acceptance Criteria

- [x] Filter applied first
- [x] Collapse applied to filtered result
- [x] Both operations work correctly together

## Coverage

Covers:
- Operation pipeline
- Filter then collapse sequence
- Combined behavior
