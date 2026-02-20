from typing import Any, Optional

from fastmcp import FastMCP
from npl_mcp.convention_formatter import NPLDefinition, ComponentSpec
from npl_mcp.meta_tools.catalog import discoverable, init_catalog

mcp = FastMCP("npl-mcp")


# ---------------------------------------------------------------------------
# Core tools (MCP-visible)
# ---------------------------------------------------------------------------

@mcp.tool()
@discoverable(category="NPL", mcp_registered=True,
              description="Noizu Prompt Lingua specification generation and formatting")
def NPLSpec(
    components: list[ComponentSpec] = [],
    rendered: list[ComponentSpec] = [],
    component_priority: int = 0,
    example_priority: int = 0,
    extension: bool = False,
    concise: bool = True,
    xml: bool = False
) -> str:
    """Generate an NPL definition or extension block.

    Args:
        components: List of component specs to include. Empty list includes all conventions.
        rendered: List of component specs already rendered elsewhere.
                 These are excluded from output but treated as known for example selection.
                 Empty list means nothing pre-rendered.
        component_priority: Default max component priority to include.
        example_priority: Default max example priority to include.
        extension: If True, wraps in extend markers instead of definition markers.
        concise: If True, use brief descriptions (default True).
        xml: If True, use XML tags for examples instead of fenced code blocks.
    """
    npl = NPLDefinition()

    return npl.format(
        components=components or None,
        rendered=rendered or None,
        component_priority=component_priority,
        example_priority=example_priority,
        extension=extension,
        flags={"concise": concise, "xml": xml},
    )


# ---------------------------------------------------------------------------
# Discoverable-only tools (hidden from MCP tools/list, callable via ToolCall)
# ---------------------------------------------------------------------------

@discoverable(category="Test", description="Test tools for verifying discovery")
def HelloDiscoverable(name: str = "world") -> str:
    """A simple test tool that returns a greeting.

    Args:
        name: Who to greet.
    """
    return f"Hello, {name}!"


# ---------------------------------------------------------------------------
# Discovery tools (MCP-visible)
# ---------------------------------------------------------------------------

@mcp.tool(name="ToolSummary")
@discoverable(category="Discovery", name="ToolSummary", mcp_registered=True,
              description="Tool discovery: search, browse, and inspect registered tools")
async def tool_summary_handler(filter: Optional[str] = None) -> dict:
    """Browse available tools by category.

    No arguments: lists all tools grouped by category.
    filter="CategoryName": expands that category.
    filter="Category#ToolName": returns full definition with parameters.
    Comma-separated filters supported: "NPL,Discovery".
    """
    from npl_mcp.meta_tools.summary import tool_summary
    return await tool_summary(filter=filter)


@mcp.tool(name="ToolSearch")
@discoverable(category="Discovery", name="ToolSearch", mcp_registered=True)
async def tool_search_handler(
    query: str,
    mode: str = "text",
    limit: int = 10,
    verbose: bool = False,
) -> dict:
    """Search tools by name or description.

    Args:
        query: Search text (matched against tool names and descriptions).
        mode: "text" for substring matching.
        limit: Maximum results to return.
        verbose: If True, include full parameter definitions in each match.
    """
    from npl_mcp.meta_tools.search import tool_search
    return await tool_search(query, mode=mode, limit=limit, verbose=verbose)


@mcp.tool(name="ToolDefinition")
@discoverable(category="Discovery", name="ToolDefinition", mcp_registered=True)
async def tool_definition_handler(tools: list[str]) -> dict:
    """Get full definitions (including parameters) for specific tools.

    Args:
        tools: List of tool names to look up (e.g. ["NPLSpec"]).
    """
    from npl_mcp.meta_tools.definition import tool_definition
    return await tool_definition(tools)


@mcp.tool(name="ToolCall")
@discoverable(category="Discovery", name="ToolCall", mcp_registered=True)
async def tool_call_handler(tool: str, arguments: dict[str, Any] | None = None) -> Any:
    """Invoke a discoverable tool by name.

    Discoverable tools are hidden from the MCP tools/list but can be found
    via ToolSummary / ToolSearch / ToolDefinition and called here.

    Args:
        tool: Name of the discoverable tool to call.
        arguments: Arguments to pass as a JSON object.
    """
    from npl_mcp.meta_tools.catalog import call_tool
    try:
        return await call_tool(tool, arguments)
    except KeyError as exc:
        return {"status": "error", "message": str(exc)}
    except TypeError as exc:
        return {"status": "error", "message": f"Invalid arguments: {exc}"}


# ---------------------------------------------------------------------------
# Initialization
# ---------------------------------------------------------------------------

init_catalog(mcp)


def main():
    mcp.run(transport="sse")


if __name__ == "__main__":
    main()
