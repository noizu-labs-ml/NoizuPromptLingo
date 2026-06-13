# FR-009: CLI Tool - md-view

**Status**: Completed

## Description

Pure pipe filter for markdown (stdin → stdout) with optional filtering and collapsing. Designed for pipeline operations.

## Interface

**Module**: `tools/md_view.py`
**Console Script**: `md-view` (via pyproject.toml)

```bash
md-view [options]
```

## Arguments

None (reads from stdin only)

## Options

| Option | Description |
|--------|-------------|
| `--filter` | Filter selector (heading path, level, CSS, XPath) |
| `--bare` | Show ONLY filtered content (no collapsed headings) |
| `--depth` | Collapse headings below this depth (1-6) |
| `--rich` | Format markdown output with Rich (terminal styling) |

## Behavior

- **Given** markdown content on stdin
- **When** `md-view` is invoked with options
- **Then** filtered/collapsed markdown is written to stdout

## Pipeline Operations

```bash
# Filter by heading level from stdin
cat document.md | md-view --filter "h2"

# Filter by heading path from pipe
2md https://example.com | md-view --filter "API"

# Collapse deep sections
md-view --depth 2 < doc.md

# Filter with bare output
md-view --bare --filter "Features" < doc.md
```

## Edge Cases

- Empty stdin: Output nothing
- Invalid filter: Output error message
- Invalid depth: Output original content

## Related User Stories

- US-209: Filter Markdown by Heading Path
- US-212: Collapse Markdown Sections Below Depth Level
- US-213: Combine Filtering and Collapsing in Pipeline

## Test Coverage

Expected test count: 12 tests
Target coverage: 85% (CLI interface)
