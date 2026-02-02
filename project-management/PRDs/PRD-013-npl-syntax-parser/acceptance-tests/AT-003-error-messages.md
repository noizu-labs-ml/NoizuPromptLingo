# AT-003: Actionable Error Messages with Line Numbers

**Category**: Integration
**Related FR**: FR-002, FR-004
**Status**: Not Started

## Description

Validates that error messages include accurate line/column numbers and actionable descriptions.

## Test Implementation

```python
def test_error_messages_include_position():
    """Test that errors include accurate position information."""
    # Setup: Document with known errors at specific lines
    invalid_doc = """
    Line 1: Valid content
    Line 2: ⌜unclosed-boundary
    Line 3: More content
    Line 4: {@invalid-flag syntax}
    Line 5: @undefined-agent
    """

    # Action: Parse and validate
    parser = NPLParser()
    try:
        document = parser.parse(invalid_doc)
    except ParseError as e:
        errors = e.errors

    # Assert: Errors contain position info
    assert any(e.line == 2 for e in errors), "Unclosed boundary error at line 2"
    assert any(e.line == 4 for e in errors), "Invalid flag error at line 4"
    assert any(e.line == 5 for e in errors), "Undefined agent error at line 5"

    # Assert: Error messages are actionable
    boundary_error = [e for e in errors if e.line == 2][0]
    assert "unclosed" in boundary_error.message.lower()
    assert "⌜" in boundary_error.message
```

## Acceptance Criteria

- [ ] Errors include line numbers
- [ ] Errors include column numbers
- [ ] Error messages describe the problem clearly
- [ ] Error messages suggest fixes when possible

## Coverage

Covers:
- Position tracking accuracy
- Error message quality
- Multi-error reporting
