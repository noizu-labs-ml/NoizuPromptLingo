# FR-005: MCP Protocol Route

**Status**: Completed

## Description

Provide MCP protocol endpoint for unified HTTP mode. The endpoint supports both POST (request-response) and SSE (Server-Sent Events) transports for MCP communication.

## Interface

```python
@app.post("/mcp")
async def mcp_post(request: Request) -> JSONResponse:
    """Handle MCP POST requests."""

@app.get("/mcp")
async def mcp_sse(request: Request) -> StreamingResponse:
    """Handle MCP SSE connections."""
```

## Behavior

- **Given** a client sends MCP POST request
- **When** the request is valid MCP format
- **Then** the MCP tool is executed and result is returned

- **Given** a client opens MCP SSE connection
- **When** the connection is established
- **Then** server-sent events are streamed for MCP protocol

## Edge Cases

- **Invalid MCP message format**: Return error response
- **Unknown MCP tool**: Return tool not found error
- **SSE connection drop**: Handle gracefully and allow reconnect
- **Concurrent SSE connections**: Support multiple clients

## Related User Stories

- (Infrastructure - no direct user story)

## Test Coverage

Expected test count: 8-12 tests
Target coverage: 100% for this FR
