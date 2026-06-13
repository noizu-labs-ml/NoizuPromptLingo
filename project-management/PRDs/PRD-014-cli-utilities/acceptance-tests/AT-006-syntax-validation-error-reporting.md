# AT-006: Syntax Validation Error Reporting

**Category**: Unit
**Related FR**: FR-006
**Status**: Not Started

## Description

Validates that npl-syntax reports errors with accurate line/column positions.

## Test Implementation

```python
def test_syntax_validation_error_reporting(tmp_path):
    """Test syntax errors include line and column information."""
    # Setup: Create file with syntax errors
    test_file = tmp_path / "test.md"
    test_file.write_text("""
# Test Document
Line 3: @agent[gopher-scout]
Line 4: {@flag.undefined}
Line 5: ⌜context
Line 6: content here
""")

    # Action: Validate file
    result = subprocess.run(
        ["npl-syntax", "validate", str(test_file)],
        capture_output=True
    )

    # Assert: Errors reported with positions
    output = result.stdout.decode()
    assert "Line 4" in output  # Undefined flag
    assert "Line 5" in output  # Unclosed boundary
    assert "unknown flag" in output.lower()
    assert "unclosed" in output.lower()
    assert result.returncode == 1  # Validation failed
```

## Acceptance Criteria

- [ ] Errors include line numbers
- [ ] Errors include column positions
- [ ] Error messages are actionable
- [ ] Multiple errors are reported
- [ ] Exit code indicates validation status

## Coverage

Covers:
- Error detection
- Position reporting
- Exit code handling
