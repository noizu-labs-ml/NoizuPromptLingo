"""ToolDefinition — batch lookup of full tool definitions from the catalog."""

from __future__ import annotations

from .catalog import build_catalog, ToolEntry


async def tool_definition(tools: list[str]) -> dict:
    """Return full definitions (including parameters) for the requested tools.

    Args:
        tools: List of tool names to look up (e.g. ["NPLSpec"]).

    Returns:
        Dict with "definitions" list and any "not_found" names.
    """
    catalog = await build_catalog()
    catalog_by_name: dict[str, ToolEntry] = {t["name"]: t for t in catalog}

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
