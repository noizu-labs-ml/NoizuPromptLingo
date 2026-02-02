# FR-016-003: CLI Interface

**Status**: Draft

## Description

The system must provide a command-line interface for running structure validation with options for single skills, bulk validation, and report generation in JSON/HTML formats.

## Interface

```python
def main(args: list[str]) -> int:
    """CLI entry point for skill validator.

    Usage:
        skill_validator <skill-path> [--all] [--report html|json] [--output path] [-v]

    Returns:
        Exit code (0=success, 1=failure)
    """
```

## Behavior

- **Given** command-line arguments
- **When** validator is invoked
- **Then** appropriate validation is run and results are output in requested format

## Edge Cases

- **Invalid paths**: Clear error message for non-existent directories
- **Permission errors**: Handles read-only files gracefully
- **Multiple skills**: Aggregates results when validating all skills
- **Report output failures**: Fallbacks to stdout if report file can't be written

## Related User Stories

- US-016-001

## Test Coverage

Expected test count: 8-10 tests
Target coverage: 100% for this FR
