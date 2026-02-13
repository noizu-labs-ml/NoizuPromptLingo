"""ToolDefinition - batch lookup of full tool definitions from the catalog."""

from .catalog import TOOL_CATALOG, ToolEntry


def tool_definition(tools: list[str]) -> dict:
    """Return full definitions (including parameters) for the requested tools.

    Args:
        tools: List of tool names to look up (e.g. ["ToMarkdown", "Ping"]).

    Returns:
        Dict with "definitions" list and any "not_found" names.
    """
    catalog_by_name: dict[str, ToolEntry] = {t["name"]: t for t in TOOL_CATALOG}

    definitions = []
    not_found = []

    for name in tools:
        entry = catalog_by_name.get(name)
        if entry:
            definitions.append({
                "name": entry["name"],
                "category": entry["category"],
                "description": entry["description"],
                "parameters": entry["parameters"],
            })
        else:
            not_found.append(name)

    result: dict = {"definitions": definitions}
    if not_found:
        result["not_found"] = not_found
    return result
