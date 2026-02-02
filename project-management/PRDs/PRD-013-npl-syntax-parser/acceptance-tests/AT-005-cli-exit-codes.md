# AT-005: CLI Exit Codes Suitable for CI Integration

**Category**: Integration
**Related FR**: FR-004
**Status**: Not Started

## Description

Validates that CLI tool uses appropriate exit codes for CI/CD integration.

## Test Implementation

```python
import subprocess

def test_cli_exit_codes():
    """Test that CLI uses correct exit codes."""
    # Test: Valid document returns 0
    result = subprocess.run(
        ["npl-syntax", "validate", "fixtures/valid/agent.md"],
        capture_output=True
    )
    assert result.returncode == 0, "Valid document should exit with 0"

    # Test: Invalid document returns 1
    result = subprocess.run(
        ["npl-syntax", "validate", "fixtures/invalid/errors.md"],
        capture_output=True
    )
    assert result.returncode == 1, "Invalid document should exit with 1"

    # Test: File not found returns 2
    result = subprocess.run(
        ["npl-syntax", "validate", "nonexistent.md"],
        capture_output=True
    )
    assert result.returncode == 2, "Missing file should exit with 2"

    # Test: Invalid usage returns 2
    result = subprocess.run(
        ["npl-syntax", "validate"],
        capture_output=True
    )
    assert result.returncode == 2, "Invalid usage should exit with 2"

def test_github_actions_format():
    """Test GitHub Actions compatible output format."""
    result = subprocess.run(
        ["npl-syntax", "validate", "fixtures/invalid/errors.md", "--format=github"],
        capture_output=True,
        text=True
    )

    # Assert: Output uses GitHub Actions error format
    assert "::error file=" in result.stdout
    assert "line=" in result.stdout
```

## Acceptance Criteria

- [ ] Exit code 0 for successful validation
- [ ] Exit code 1 for validation errors
- [ ] Exit code 2 for usage/file errors
- [ ] GitHub Actions format available
- [ ] JSON format parseable by CI tools

## Coverage

Covers:
- CI/CD integration
- Exit code correctness
- Output format compatibility
