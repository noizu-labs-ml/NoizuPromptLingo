# FR-012: MCP Tool - view_markdown

**Status**: Active

## Description

MCP tool for combined markdown conversion + viewing via FastMCP server (maps to `view-md` CLI functionality).

## Interface

**Tool Name**: `view_markdown`

```python
@mcp.tool()
async def view_markdown(
    source: str,
    filter: Optional[str] = None,
    bare: bool = False,
    depth: Optional[int] = None,
    no_cache: bool = False,
    timeout: int = 30
) -> str:
    """Convert source to markdown, then filter and view with optional collapsing."""
```

## Returns

Processed markdown based on filter/collapse options.

## Behavior

- **Given** a source and optional filter/collapse options
- **When** `view_markdown` MCP tool is invoked
- **Then** source is converted, filtered, and/or collapsed according to parameters

## Examples

```python
# Convert and view specific section
result = await view_markdown("https://docs.python.org", filter="Installation")

# Convert with collapsing
result = await view_markdown("report.pdf", depth=2)

# Show only filtered section
result = await view_markdown("doc.md", filter="API", bare=True)

# Force refresh with depth
result = await view_markdown("https://site.com/page", depth=2, no_cache=True)
```

## Edge Cases

- Invalid source: Return error in markdown format
- Invalid filter: Return error message
- Conversion failure: Return error details

## Related User Stories

- US-211: MCP Tools for Markdown Conversion and Viewing

## Test Coverage

Expected test count: 12 tests
Target coverage: 100% for this FR
