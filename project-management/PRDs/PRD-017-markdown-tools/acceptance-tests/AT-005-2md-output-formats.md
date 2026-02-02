# AT-005: 2md Supports Output Formats

**Category**: Unit
**Related FR**: FR-008
**Status**: Passing

## Description

Validates that `2md` supports `--format rich|plain|json` output modes.

## Test Implementation

```python
def test_2md_output_formats():
    """Test that 2md supports multiple output formats."""
    # Setup: Mock conversion
    # Action: Run 2md with each format
    # Assert: Output matches expected format
```

## Acceptance Criteria

- [x] `--format rich` includes YAML metadata
- [x] `--format plain` strips metadata
- [x] `--format json` returns structured JSON

## Coverage

Covers:
- Rich format with metadata
- Plain format (content only)
- JSON format structure
