# AT-019: to_markdown MCP Tool Registered

**Category**: Integration
**Related FR**: FR-011
**Status**: Not Started

## Description

Validates that `to_markdown` MCP tool is registered in FastMCP server.

## Test Implementation

```python
def test_to_markdown_registered():
    """Test that to_markdown MCP tool is registered."""
    # Setup: Initialize FastMCP server
    # Action: Query available tools
    # Assert: to_markdown in tool list
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
