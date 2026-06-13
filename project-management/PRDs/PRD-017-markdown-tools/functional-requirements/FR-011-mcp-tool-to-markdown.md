# FR-011: MCP Tool - to_markdown

**Status**: Active

## Description

MCP tool for markdown conversion via FastMCP server (maps to `2md` CLI functionality).

## Interface

**Tool Name**: `to_markdown`

```python
@mcp.tool()
async def to_markdown(
    source: str,
    no_cache: bool = False,
    timeout: int = 30
) -> str:
    """Convert URL, file, or image to markdown with caching."""
```

## Returns

Formatted markdown with YAML metadata header.

## Behavior

- **Given** a source URL or file path
- **When** `to_markdown` MCP tool is invoked
- **Then** source is converted to markdown with caching

## Examples

```python
# Convert URL
result = await to_markdown("https://docs.example.com/api")

# Force fresh conversion
result = await to_markdown("report.pdf", no_cache=True)

# With custom timeout
result = await to_markdown("https://slow-site.com", timeout=60)
```

## Edge Cases

- Invalid URL: Return error in markdown format
- File not found: Return error message
- Timeout: Return timeout error

## Related User Stories

- US-211: MCP Tools for Markdown Conversion and Viewing

## Test Coverage

Expected test count: 8 tests
Target coverage: 100% for this FR
