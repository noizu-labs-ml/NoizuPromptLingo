# FR-016-001: Structure Validation Engine

**Status**: Draft

## Description

The system must provide a structure validation engine that checks skill directories against SKILL-GUIDELINE.md requirements, including directory structure, file existence, naming conventions, and content format.

## Interface

```python
def validate_skill_structure(skill_path: str, verbose: bool = False) -> ValidationReport:
    """Validate skill directory structure and content.

    Args:
        skill_path: Path to skill directory (e.g., "skills/market-intelligence/")
        verbose: Enable detailed output for debugging

    Returns:
        ValidationReport with status, checks performed, and issues found
    """
```

## Behavior

- **Given** a skill directory path
- **When** validation is executed
- **Then** all structure requirements are checked and a report is generated with pass/fail status and specific issues

## Edge Cases

- **Missing directories**: Reports specific folders that don't exist
- **Malformed files**: Catches YAML/Parquet parsing errors with clear messages
- **Partial content**: Detects when files exist but don't meet line count requirements
- **Invalid naming**: Identifies files not following kebab-case conventions

## Related User Stories

- US-016-001

## Test Coverage

Expected test count: 10-15 tests
Target coverage: 100% for this FR
