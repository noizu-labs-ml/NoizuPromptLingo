"""ToolPin - dynamic tool visibility management from the catalog.

Allows MCP clients to pin (show) or unpin (hide) tools from the
static catalog at runtime. Pinned tools appear in the client's tool
list under the same MCP server namespace as discovery tools.
All catalog tools are callable whether pinned or not.
"""

import json
from typing import Any

from fastmcp.tools.tool import Tool, ToolResult
from mcp.types import TextContent

from .catalog import get_tool_by_name, ToolEntry
from .tool_registry import get_implementation

# Tools that cannot be unpinned (core discovery tools)
CORE_TOOLS = frozenset({"ToolSummary", "ToolSearch", "ToolDefinition", "ToolHelp", "ToolCall"})

# Python type strings to JSON Schema types
_TYPE_MAP = {
    "str": "string",
    "int": "integer",
    "bool": "boolean",
    "float": "number",
    "list": "array",
    "dict": "object",
}


def _catalog_to_json_schema(entry: ToolEntry) -> dict[str, Any]:
    """Convert catalog parameter definitions to JSON Schema."""
    properties = {}
    required = []

    for param in entry["parameters"]:
        json_type = _TYPE_MAP.get(param["type"], "string")
        properties[param["name"]] = {
            "type": json_type,
            "description": param["description"],
        }
        if param["required"]:
            required.append(param["name"])

    schema: dict[str, Any] = {
        "type": "object",
        "properties": properties,
    }
    if required:
        schema["required"] = required
    return schema


class CatalogStubTool(Tool):
    """A dynamically-pinned tool backed by the static catalog.

    Registered with the correct name, description, and parameter schema
    from the catalog. Calling it returns a stub response indicating that
    the tool is discoverable but not yet implemented.
    """

    catalog_entry: ToolEntry

    async def run(self, arguments: dict[str, Any]) -> ToolResult:
        return ToolResult(
            content=[
                TextContent(
                    type="text",
                    text=json.dumps(
                        {
                            "tool": self.catalog_entry["name"],
                            "category": self.catalog_entry["category"],
                            "status": "stub",
                            "message": (
                                f"Tool '{self.catalog_entry['name']}' is pinned but "
                                f"implementation is pending. Use ToolSummary to see "
                                f"full parameter documentation."
                            ),
                            "arguments_received": arguments,
                        },
                        indent=2,
                    ),
                )
            ]
        )


def create_catalog_tool(entry: ToolEntry) -> CatalogStubTool:
    """Create a CatalogStubTool from a catalog entry."""
    return CatalogStubTool(
        name=entry["name"],
        description=entry["description"],
        parameters=_catalog_to_json_schema(entry),
        catalog_entry=entry,
    )


async def tool_pin(tool_name: str, pin: bool, fastmcp: Any) -> dict:
    """Pin or unpin a catalog tool on the running MCP server.

    Args:
        tool_name: Name of the tool from the catalog.
        pin: True to register, False to unregister.
        fastmcp: The FastMCP server instance (from ctx.fastmcp).

    Returns:
        Status dict with action taken.
    """
    if pin:
        return _pin_tool(tool_name, fastmcp)
    else:
        return _unpin_tool(tool_name, fastmcp)


def _pin_tool(tool_name: str, fastmcp: Any) -> dict:
    """Register a catalog tool with the MCP server."""
    # Check if already registered
    registered = set(fastmcp._tool_manager._tools.keys())
    if tool_name in registered:
        return {
            "tool": tool_name,
            "action": "pin",
            "status": "already_pinned",
            "message": f"Tool '{tool_name}' is already registered.",
            "registered_tools": len(registered),
        }

    # Look up in catalog
    entry = get_tool_by_name(tool_name)
    if entry is None:
        return {
            "tool": tool_name,
            "action": "pin",
            "status": "error",
            "message": f"Tool '{tool_name}' not found in catalog.",
        }

    # Check for a real implementation; fall back to catalog stub
    impl = get_implementation(tool_name)
    if impl is not None:
        tool = Tool.from_function(impl, name=tool_name, description=entry["description"])
    else:
        tool = create_catalog_tool(entry)
    fastmcp.add_tool(tool)

    registered = set(fastmcp._tool_manager._tools.keys())
    return {
        "tool": tool_name,
        "action": "pin",
        "status": "ok",
        "message": f"Tool '{tool_name}' registered successfully.",
        "registered_tools": len(registered),
    }


def _unpin_tool(tool_name: str, fastmcp: Any) -> dict:
    """Unregister a tool from the MCP server."""
    # Protect core tools
    if tool_name in CORE_TOOLS:
        return {
            "tool": tool_name,
            "action": "unpin",
            "status": "error",
            "message": f"Tool '{tool_name}' is a core tool and cannot be unpinned.",
        }

    # Check if registered
    registered = set(fastmcp._tool_manager._tools.keys())
    if tool_name not in registered:
        return {
            "tool": tool_name,
            "action": "unpin",
            "status": "not_pinned",
            "message": f"Tool '{tool_name}' is not currently registered.",
            "registered_tools": len(registered),
        }

    # Remove
    fastmcp._tool_manager.remove_tool(tool_name)

    registered = set(fastmcp._tool_manager._tools.keys())
    return {
        "tool": tool_name,
        "action": "unpin",
        "status": "ok",
        "message": f"Tool '{tool_name}' unregistered successfully.",
        "registered_tools": len(registered),
    }
