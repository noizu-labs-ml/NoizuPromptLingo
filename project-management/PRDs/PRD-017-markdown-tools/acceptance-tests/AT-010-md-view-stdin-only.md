# AT-010: md-view Reads from stdin Only

**Category**: Integration
**Related FR**: FR-009
**Status**: Passing

## Description

Validates that `md-view` operates as pure pipe filter (stdin → stdout).

## Test Implementation

```python
def test_md_view_stdin():
    """Test that md-view reads from stdin."""
    # Setup: Prepare markdown content
    # Action: Pipe to md-view
    # Assert: Processed output on stdout
```

## Acceptance Criteria

- [x] No file arguments accepted
- [x] Reads from stdin
- [x] Writes to stdout
- [x] Pipeline compatible

## Coverage

Covers:
- Stdin reading
- Stdout writing
- Pipeline behavior
