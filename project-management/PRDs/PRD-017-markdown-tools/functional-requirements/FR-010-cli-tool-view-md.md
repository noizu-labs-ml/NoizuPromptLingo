# FR-010: CLI Tool - view-md

**Status**: Completed

## Description

Combined tool for converting a source and viewing with optional filtering/collapsing. Equivalent to `2md | md-view` but in single command.

## Interface

**Module**: `tools/view_md.py`
**Console Script**: `view-md` (via pyproject.toml)

```bash
view-md <source> [output] [options]
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `source` | Yes | URL, file path, or image to convert and view |
| `output` | No | Output file (default: stdout) |

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `--filter` | None | Filter selector (heading path, level, CSS, XPath) |
| `--bare` | False | Show ONLY filtered content (no collapsed headings) |
| `--depth` | None | Collapse headings below this depth (1-6) |
| `--rich` | False | Format markdown output with Rich (stdout only) |
| `--no-cache` | False | Force fresh conversion (skip cache) |
| `--cache-dir` | `.tmp/cache/markdown/` | Custom cache directory |
| `--timeout` | 30 | Request timeout for URLs (seconds) |
| `-q, --quiet` | False | Suppress non-content output |

## Behavior

- **Given** a source URL or file path
- **When** `view-md` is invoked with filtering/collapsing options
- **Then** source is converted, filtered, and/or collapsed according to options

## Pipeline Equivalent

```bash
# These are equivalent:
view-md https://example.com --filter "API"
2md https://example.com | md-view --filter "API"
```

## Edge Cases

- Missing source: Display help message
- Invalid filter: Output error in markdown
- Conversion failure: Propagate error

## Related User Stories

- US-206: Convert Documentation Sources to Markdown
- US-209: Filter Markdown by Heading Path
- US-213: Combine Filtering and Collapsing in Pipeline

## Test Coverage

Expected test count: 15 tests
Target coverage: 85% (CLI interface)
