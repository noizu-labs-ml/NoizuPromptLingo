# FR-008: CLI Tool - 2md

**Status**: Completed

## Description

Command-line interface for markdown conversion supporting URLs, files, and images with caching.

## Interface

**Module**: `tools/2md.py`
**Console Script**: `2md` (via pyproject.toml)

```bash
2md <source> [output] [options]
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `source` | Yes | URL, file path, or image to convert |
| `output` | No | Output file (default: stdout) |

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `--format` | `rich` | Output format: `rich`, `plain`, `json` |
| `--no-cache` | False | Force fresh conversion (skip cache) |
| `--cache-dir` | `.tmp/cache/markdown/` | Custom cache directory |
| `--timeout` | 30 | Request timeout for URLs (seconds) |
| `--vision-prompt` | None | Custom prompt for image analysis (Phase 3) |
| `-q, --quiet` | False | Suppress non-content output |

## Output Formats

| Format | Description |
|--------|-------------|
| `rich` | Full response with YAML metadata header |
| `plain` | Content only (metadata stripped) |
| `json` | Structured JSON with metadata and content |

## Behavior

- **Given** a source URL or file path
- **When** `2md` is invoked
- **Then** source is converted to markdown and output according to format

## Edge Cases

- Missing source: Display help message
- Invalid URL: Propagate HTTP error
- File not found: Display error message
- Timeout: Display timeout error

## Related User Stories

- US-206: Convert Documentation Sources to Markdown
- US-207: Cache Converted Files with Hybrid Strategy
- US-214: Markdown Output Format Options

## Test Coverage

Expected test count: 10 tests
Target coverage: 85% (CLI interface)
