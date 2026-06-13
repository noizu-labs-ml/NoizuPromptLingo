# AT-020: view_markdown MCP Tool Registered

**Category**: Integration
**Related FR**: FR-012
**Status**: Not Started

## Description

Validates that `view_markdown` MCP tool is registered in FastMCP server.

## Test Implementation

```python
def test_view_markdown_registered():
    """Test that view_markdown MCP tool is registered."""
    # Setup: Initialize FastMCP server
    # Action: Query available tools
    # Assert: view_markdown in tool list
```

## Acceptance Criteria

- [ ] Tool registered in MCP server
- [ ] Tool callable via FastMCP
- [ ] Tool metadata correct

## Coverage

Covers:
- MCP tool registration
- Server initialization
- Tool discovery
