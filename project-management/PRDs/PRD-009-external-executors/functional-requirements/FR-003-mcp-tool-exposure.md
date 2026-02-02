# FR-003: MCP Tool Exposure

**Status**: Draft

## Description

All tasker management and Fabric integration functions must be exposed as MCP tools registered in unified.py.

## Interface

```python
@mcp.tool()
async def spawn_tasker(
    task: str,
    chat_room_id: str,
    patterns: List[str],
    session_id: Optional[str] = None,
    timeout: int = 15,
    nag_minutes: int = 5
) -> str:
    """Spawn ephemeral tasker agent."""

@mcp.tool()
async def get_tasker(tasker_id: str) -> str:
    """Get tasker details."""

@mcp.tool()
async def list_taskers(
    status: Optional[str] = None,
    session_id: Optional[str] = None
) -> str:
    """List taskers with filters."""

@mcp.tool()
async def dismiss_tasker(tasker_id: str, reason: str) -> str:
    """Terminate a tasker."""

@mcp.tool()
async def keep_alive_tasker(tasker_id: str) -> str:
    """Respond to nag message."""

@mcp.tool()
async def apply_fabric_pattern(
    content: str,
    pattern: str,
    model: Optional[str] = None
) -> str:
    """Apply Fabric pattern to content."""

@mcp.tool()
async def analyze_with_fabric(
    content: str,
    patterns: List[str],
    combine_results: bool = False
) -> str:
    """Apply multiple Fabric patterns."""

@mcp.tool()
async def list_fabric_patterns() -> str:
    """List available Fabric patterns."""
```

## Behavior

- **Given** MCP tools are registered in unified.py
- **When** Claude invokes `spawn_tasker`
- **Then** new tasker created with lifecycle monitoring

- **Given** tasker lifecycle monitoring is running
- **When** tasker times out
- **Then** nag message sent to chat room via MCP

## Edge Cases

- **Tool invoked when lifecycle monitor not started**: Auto-start monitor
- **Invalid tasker_id provided**: Return clear error message
- **Fabric not installed**: Return error with installation instructions

## Related User Stories

- US-009-003

## Test Coverage

Expected test count: 8-10 tests
Target coverage: 100% for MCP tool wrappers
