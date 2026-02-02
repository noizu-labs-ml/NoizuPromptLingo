# AT-004: MCP Tool Registration

**Category**: Integration
**Related FR**: FR-003
**Status**: Not Started

## Description

Validates that all tasker and Fabric tools are properly registered and invokable via MCP.

## Test Implementation

```python
def test_mcp_tool_registration():
    """Test all executor tools registered in unified.py."""
    # Setup
    from npl_mcp.unified import mcp

    # Assert: All tasker tools registered
    tool_names = [t.name for t in mcp.list_tools()]

    assert "spawn_tasker" in tool_names
    assert "get_tasker" in tool_names
    assert "list_taskers" in tool_names
    assert "dismiss_tasker" in tool_names
    assert "keep_alive_tasker" in tool_names

    # Assert: All Fabric tools registered
    assert "apply_fabric_pattern" in tool_names
    assert "analyze_with_fabric" in tool_names
    assert "list_fabric_patterns" in tool_names


async def test_mcp_tool_invocation():
    """Test MCP tool invocation works end-to-end."""
    # Setup
    from npl_mcp.unified import mcp

    # Action: Invoke spawn_tasker via MCP
    result = await mcp.call_tool(
        "spawn_tasker",
        task="Test task",
        chat_room_id="test-room",
        patterns=["summarize"]
    )

    # Assert: Tasker spawned
    assert "tasker_id" in result
    tasker_id = result["tasker_id"]

    # Action: Invoke get_tasker
    result = await mcp.call_tool("get_tasker", tasker_id=tasker_id)

    # Assert: Tasker details returned
    assert result["task"] == "Test task"
    assert result["status"] in ["IDLE", "ACTIVE"]
```

## Acceptance Criteria

- [ ] All tasker management tools registered
- [ ] All Fabric tools registered
- [ ] Tools invokable via MCP protocol
- [ ] Tool responses properly formatted

## Coverage

Covers:
- Tool registration
- Tool invocation
- End-to-end MCP flow
- Response formatting
