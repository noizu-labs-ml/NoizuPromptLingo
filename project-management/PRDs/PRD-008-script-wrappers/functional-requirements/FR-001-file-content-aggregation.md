# FR-001: File Content Aggregation

**Status**: Implemented

## Description

Provide MCP tool to aggregate file contents with glob filtering, returning concatenated content with headers for batch file inspection.

## Interface

```python
async def dump_files(path: str, glob_filter: str = "*") -> str:
    """Aggregate file contents from directory.

    Args:
        path: Absolute directory path (no relative paths)
        glob_filter: Optional glob pattern (default: "*")

    Returns:
        Concatenated file contents with headers

    Raises:
        ValueError: If path is relative
    """
```

## Behavior

- **Given** an absolute directory path and glob filter
- **When** dump_files is invoked
- **Then** all matching files are concatenated with headers

## Edge Cases

- **Relative path provided**: Raises ValueError with instruction to use `pwd`
- **Empty directory**: Returns empty string
- **No matches**: Returns empty string
- **Binary files**: Skipped or error handling by script

## Related User Stories

- US-047

## Test Coverage

Expected test count: 6-8 tests
Target coverage: N/A (external script)
