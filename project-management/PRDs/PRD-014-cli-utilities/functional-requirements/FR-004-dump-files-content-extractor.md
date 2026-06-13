# FR-004: dump-files Content Extractor

**Status**: Draft

## Description

Implement `dump-files` CLI utility for extracting and displaying file contents with formatting suitable for context injection.

## Interface

```bash
# Dump all files in directory
dump-files src/

# Filter by glob pattern
dump-files src/ -g "*.py"

# Multiple patterns
dump-files src/ -g "*.py" -g "*.ts"

# Exclude patterns
dump-files src/ -g "*.py" --exclude "*_test.py"

# Output to file
dump-files src/ -g "*.md" > context.txt
```

## Behavior

- **Given** target directory and optional glob patterns
- **When** dump-files is invoked
- **Then** all matching files are read and output with delimiters
- **And** .gitignore patterns are respected
- **And** binary files are skipped
- **And** file size limits are enforced

## Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `target` | positional | Target directory |
| `-g, --glob` | repeated | Glob patterns to include |
| `--exclude` | repeated | Glob patterns to exclude |
| `--max-size` | optional | Maximum file size in KB |
| `--no-header` | optional | Omit file headers |

## Output Format

```
===== src/main.py =====
import sys

def main():
    print("Hello, NPL!")

if __name__ == "__main__":
    main()

* * *

===== src/utils.py =====
def helper():
    pass

* * *
```

## Edge Cases

- **Binary files**: Detect and skip with message
- **Large files**: Truncate if exceeding --max-size
- **Permission denied**: Skip with warning
- **Empty files**: Include with header, no content
- **Invalid encoding**: Attempt UTF-8, fallback to latin-1

## Related User Stories

- US-085

## Test Coverage

Expected test count: 10-12 tests
Target coverage: 100% for this FR
