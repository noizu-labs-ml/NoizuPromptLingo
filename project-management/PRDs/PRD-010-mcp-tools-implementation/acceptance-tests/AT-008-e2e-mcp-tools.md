# AT-008: End-to-End MCP Tool Invocation

**Category**: End-to-End
**Related FR**: All
**Status**: Not Started

## Description

Validates complete MCP tool invocation through STDIO transport.

## Test Implementation

```python
async def test_e2e_mcp_tool_invocation():
    """Test MCP tool invocation via STDIO transport."""
    # Start MCP server
    server_process = await start_mcp_server()

    # Create MCP client
    client = MCPClient(transport="stdio")

    # Test artifact creation tool
    result = await client.call_tool(
        "create_artifact",
        {
            "name": "e2e-test",
            "artifact_type": "code",
            "content": "print('hello')"
        }
    )
    assert result["version"] == 1

    # Test task creation tool
    task_result = await client.call_tool(
        "create_task",
        {
            "title": "E2E test task",
            "priority": "high"
        }
    )
    assert task_result["status"] == "backlog"

    # Test link tool
    link_result = await client.call_tool(
        "link_artifact",
        {
            "task_id": task_result["task_id"],
            "artifact_id": result["id"],
            "relationship": "output"
        }
    )
    assert link_result["relationship"] == "output"
```

## Acceptance Criteria

- [ ] All 27 tools invocable via MCP
- [ ] Parameter validation works
- [ ] Error responses formatted correctly
- [ ] State persists across calls
- [ ] Context propagates correctly

## Coverage

Covers:
- Normal path: All tool invocations
- Edge cases: Invalid parameters
- Error conditions: Server errors
