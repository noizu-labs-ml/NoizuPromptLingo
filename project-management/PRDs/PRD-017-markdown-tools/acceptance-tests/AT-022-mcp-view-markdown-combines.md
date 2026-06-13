# AT-022: view_markdown Combines Conversion and Filtering

**Category**: Integration
**Related FR**: FR-012
**Status**: Not Started

## Description

Validates that `view_markdown` MCP tool combines conversion and filtering in single call.

## Test Implementation

```python
def test_view_markdown_combines():
    """Test that view_markdown combines operations."""
    # Setup: Mock source with sections
    # Action: Call view_markdown with filter
    # Assert: Converted + filtered output
```

## Acceptance Criteria

- [ ] Single call performs both operations
- [ ] Conversion happens first
- [ ] Filtering applied to result

## Coverage

Covers:
- Combined operation pipeline
- Single-call convenience
- Operation sequencing
