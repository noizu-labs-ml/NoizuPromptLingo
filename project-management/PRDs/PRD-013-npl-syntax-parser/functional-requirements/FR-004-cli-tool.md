# FR-004: CLI Tool

**Status**: Draft

## Description

The CLI tool provides command-line interface for validating NPL documents, listing syntax elements, extracting agent metadata, and outputting results in multiple formats.

## Interface

```bash
# Validate single file
npl-syntax validate path/to/file.md

# Validate directory
npl-syntax validate path/to/dir --recursive

# List elements in file
npl-syntax list path/to/file.md

# Extract agent metadata
npl-syntax extract-agent path/to/agent.md

# Output format options
npl-syntax validate file.md --format=json
npl-syntax validate file.md --format=text
npl-syntax validate file.md --format=github  # GitHub Actions compatible

# Verbosity
npl-syntax validate file.md --verbose
npl-syntax validate file.md --quiet
```

## Behavior

- **Given** valid NPL document
- **When** `npl-syntax validate file.md` is run
- **Then** exits with code 0 and prints "✅ file.md: valid"

- **Given** document with syntax errors
- **When** `npl-syntax validate file.md` is run
- **Then** exits with code 1 and prints error details with line numbers

- **Given** directory path with --recursive
- **When** `npl-syntax validate dir/` is run
- **Then** validates all .md files recursively

## CLI Output Examples

```
$ npl-syntax validate agent.md
agent.md:15:3: error: Unclosed boundary marker '⌜capabilities⌝'
agent.md:42:1: warning: Missing required section '## Usage'
agent.md:67:5: error: Invalid flag syntax '{@invalid}'

2 errors, 1 warning
```

```
$ npl-syntax list agent.md
agent.md:
  Agent Directives: 5
    - @gopher-scout (line 12)
    - @npl-author:create (line 34)
    ...
  Pumps: 3
    - ⟪🧠cot⟫ (line 45)
    ...
  Fences: 8
    - ```python (lines 20-35)
    ...
  Boundary Markers: 4
    - ⌜agent|scout|1.0⌝ (line 1)
    ...
```

## Edge Cases

- **Binary files**: Skips non-text files with warning
- **Large files**: Shows progress indicator for files >1MB
- **Permission errors**: Clear error message when file unreadable
- **Invalid paths**: Helpful error for non-existent paths

## Related User Stories

- US-080: Validate NPL Documents for Syntax Errors
- US-081: CLI Validation with Clear Error Messages
- US-082: Extract Metadata from Agent Definition Files
- US-084: List All Syntax Elements Used in Document

## Test Coverage

Expected test count: 12-15 tests
Target coverage: 100% for CLI commands
