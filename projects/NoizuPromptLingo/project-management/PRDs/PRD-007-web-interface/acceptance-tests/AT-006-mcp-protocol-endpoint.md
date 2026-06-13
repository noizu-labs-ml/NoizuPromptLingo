# AT-006: MCP Protocol Endpoint

**Category**: Integration
**Related FR**: FR-005
**Status**: Not Started

## Description

Validate that the MCP protocol endpoint handles POST and SSE requests properly.

## Test Implementation

```python
def test_mcp_post_request():
    """Test MCP POST endpoint processes requests."""
    # Setup: Create MCP request payload
    mcp_request = {
        "method": "tools/call",
        "params": {
            "name": "hello",
            "arguments": {"name": "World"}
        }
    }

    # Action: POST /mcp
    response = client.post("/mcp", json=mcp_request)

    # Assert
    assert response.status_code == 200
    data = response.json()
    assert "result" in data

def test_mcp_sse_connection():
    """Test MCP SSE endpoint establishes stream."""
    # Action: GET /mcp with SSE headers
    response = client.get(
        "/mcp",
        headers={"Accept": "text/event-stream"}
    )

    # Assert
    assert response.status_code == 200
    assert "text/event-stream" in response.headers["content-type"]
```

## Acceptance Criteria

- [ ] POST requests are handled
- [ ] SSE connections are established
- [ ] Invalid MCP messages return errors
- [ ] Multiple SSE clients supported

## Coverage

Covers:
- Normal path: MCP POST request
- Normal path: MCP SSE connection
- Edge case: malformed MCP message
- Error condition: unknown MCP tool
