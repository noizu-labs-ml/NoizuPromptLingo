# AT-002: Absolute Path Validation

**Category**: Unit
**Related FR**: FR-001, FR-002
**Status**: Not Started

## Description

Validates that filesystem tools reject relative paths and enforce absolute path requirements.

## Test Implementation

```python
async def test_relative_path_rejected():
    """Test that relative paths raise ValueError."""
    # Setup: Prepare relative path
    # Action: Call dump_files/git_tree with relative path
    # Assert: ValueError raised with clear message
```

## Acceptance Criteria

- [ ] Relative paths rejected
- [ ] Clear error message provided
- [ ] Instructions to use `pwd` included

## Coverage

Covers:
- Path validation
- Error handling
- User guidance
