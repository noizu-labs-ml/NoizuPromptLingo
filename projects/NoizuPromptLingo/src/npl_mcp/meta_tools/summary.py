"""ToolSummary — tool listing and category browser for tool discovery."""

from __future__ import annotations

from typing import Optional

from .catalog import (
    build_catalog,
    _CATEGORY_DESCRIPTIONS,
    ToolEntry,
)


async def tool_summary(filter: Optional[str] = None) -> dict:
    """Return available tools or drill into a catalog category.

    No filter: returns all non-Discovery tools grouped by category.
    With filter: expands that catalog category showing its tools and subcategories.
    Dot notation drills deeper: "NPL.Sub" shows tools in that subcategory.
    With Category#ToolName: returns a single tool's full definition including parameters.
    Comma-separated: "NPL,Discovery" expands multiple categories at once.

    Parameters are omitted unless you request a specific tool via #ToolName.
    To get full parameter info, use e.g. "NPL#NPLSpec".
    """
    if filter is None:
        return await _all_tools()

    parts = [p.strip() for p in filter.split(",") if p.strip()]
    if len(parts) == 1:
        return await _resolve_single(parts[0])

    results = []
    for part in parts:
        results.append(await _resolve_single(part))
    return {"results": results}


async def _resolve_single(filter_value: str) -> dict:
    """Resolve a single filter value (category or #tool lookup)."""
    if "#" in filter_value:
        return await _get_tool(filter_value)
    return await _expand_category(filter_value)


async def _all_tools() -> dict:
    """Return all non-Discovery tools grouped by category."""
    catalog = await build_catalog()
    tools = [t for t in catalog if t["category"] != "Discovery"]

    by_cat: dict[str, list[dict]] = {}
    for t in tools:
        by_cat.setdefault(t["category"], []).append(
            {"name": t["name"], "description": t["description"]}
        )

    categories = []
    for cat_name, cat_tools in sorted(by_cat.items()):
        desc = _CATEGORY_DESCRIPTIONS.get(cat_name)
        entry: dict = {"category": cat_name, "tools": cat_tools}
        if desc:
            entry["description"] = desc
        categories.append(entry)

    return {
        "total_tools": len(tools),
        "categories": categories,
        "hint": "Use ToolSummary(filter='CategoryName') to explore, or ToolDefinition for full parameter info.",
    }


async def _get_tool(path: str) -> dict:
    """Return a single tool definition by Category.Path#ToolName."""
    catalog = await build_catalog()
    cat_path, tool_name = path.split("#", 1)

    # Try exact category + name match first
    for t in catalog:
        if t["name"] == tool_name and t["category"] == cat_path:
            return {
                "name": t["name"],
                "category": t["category"],
                "description": t["description"],
                "parameters": t["parameters"],
            }

    # Fallback: match just by name
    for t in catalog:
        if t["name"] == tool_name:
            return {
                "name": t["name"],
                "category": t["category"],
                "description": t["description"],
                "parameters": t["parameters"],
            }

    return {"error": f"Tool '{tool_name}' not found in category '{cat_path}'."}


async def _expand_category(category: str) -> dict:
    """Expand a specific category, showing tools and subcategories within it."""
    catalog = await build_catalog()
    prefix = category + "."

    direct_tools = [t for t in catalog if t["category"] == category]
    sub_tools = [t for t in catalog if t["category"].startswith(prefix)]

    if not direct_tools and not sub_tools:
        return {"error": f"Category '{category}' not found."}

    description = _CATEGORY_DESCRIPTIONS.get(category)

    result: dict = {
        "category": category,
        "tool_count": len(direct_tools) + len(sub_tools),
    }
    if description:
        result["description"] = description

    if direct_tools:
        result["tools"] = [
            {"name": t["name"], "description": t["description"]}
            for t in direct_tools
        ]

    subcats = _collect_subcategories(category, sub_tools)
    if subcats:
        result["subcategories"] = subcats

    return result


def _collect_subcategories(parent: str, tools: list[ToolEntry]) -> list[dict]:
    """Group tools into immediate subcategories under parent."""
    depth = parent.count(".") + 1
    buckets: dict[str, list[ToolEntry]] = {}

    for tool in tools:
        parts = tool["category"].split(".")
        if len(parts) <= depth:
            continue
        sub_name = ".".join(parts[: depth + 1])
        buckets.setdefault(sub_name, []).append(tool)

    subcats = []
    for sub_name, sub_tools in sorted(buckets.items()):
        desc = _CATEGORY_DESCRIPTIONS.get(sub_name)
        entry: dict = {"name": sub_name, "tool_count": len(sub_tools)}
        if desc:
            entry["description"] = desc
        subcats.append(entry)

    return subcats
