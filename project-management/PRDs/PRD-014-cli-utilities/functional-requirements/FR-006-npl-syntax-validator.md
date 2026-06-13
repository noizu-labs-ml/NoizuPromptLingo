# FR-006: npl-syntax Validator

**Status**: Draft

## Description

Implement `npl-syntax` CLI utility for validating NPL documents for syntax correctness.

## Interface

```bash
# Validate file
npl-syntax validate path/to/file.md

# Validate directory
npl-syntax validate path/to/dir --recursive

# List syntax elements
npl-syntax list path/to/file.md

# Check specific category
npl-syntax validate file.md --category agent-directives

# Output formats
npl-syntax validate file.md --format json
npl-syntax validate file.md --format github
```

## Behavior

- **Given** file or directory path
- **When** npl-syntax validate is invoked
- **Then** document is parsed for all 155 syntax elements
- **And** errors are reported with line/column positions
- **And** appropriate exit code is returned
- **And** output format matches requested format

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `validate` | Check document syntax |
| `list` | List syntax elements in document |
| `check` | Quick pass/fail check |

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Valid, no errors |
| 1 | Validation errors found |
| 2 | File not found or unreadable |

## Output Format (text)

```
Validating: path/to/file.md
✓ Line 15: @agent[gopher-scout] - valid
✗ Line 42: {@flag.invalid} - unknown flag
✗ Line 89: ⌜context - unclosed boundary marker

Summary: 2 errors, 1 warning
```

## Output Format (json)

```json
{
  "file": "path/to/file.md",
  "valid": false,
  "errors": [
    {
      "line": 42,
      "column": 5,
      "type": "unknown-flag",
      "message": "Flag 'flag.invalid' is not defined"
    }
  ],
  "warnings": [],
  "element_count": 23
}
```

## Output Format (github)

```
::error file=path/to/file.md,line=42,col=5::Flag 'flag.invalid' is not defined
::warning file=path/to/file.md,line=89::Unclosed boundary marker
```

## Edge Cases

- **Malformed markdown**: Report syntax errors with context
- **Invalid regex patterns**: Report compilation errors
- **Large files**: Stream parsing to avoid memory issues
- **Nested elements**: Validate nesting rules
- **Unknown elements**: Warn but don't fail

## Related User Stories

- US-086

## Test Coverage

Expected test count: 15-18 tests
Target coverage: 100% for this FR
