"""ToolSummary - exposed tool listing and category browser for tool discovery."""

from typing import Optional

from .catalog import TOOL_CATALOG, CATEGORIES, EXPOSED_TOOL_NAMES, ToolEntry


async def tool_summary(filter: Optional[str] = None) -> dict:
    """Return available tools or drill into a catalog category.

    No filter: returns only the directly-exposed tools (Browse, Ping, etc.).
    With filter: expands that catalog category showing its tools and subcategories.
    Dot notation drills deeper: "Browser.Screenshots" shows screenshot tools.
    With Category#ToolName: returns a single tool's full definition including parameters.
    Comma-separated: "Scripts,Chat" expands multiple categories at once.

    Parameters are omitted unless you request a specific tool via #ToolName.
    To get full parameter info, use e.g. "Browser.Screenshots#screenshot_capture".
    """
    if filter is None:
        return _exposed_tools()

    # Support comma-separated filters
    parts = [p.strip() for p in filter.split(",") if p.strip()]
    if len(parts) == 1:
        return _resolve_single(parts[0])

    # Multiple filters: merge results
    results = []
    for part in parts:
        results.append(_resolve_single(part))
    return {"results": results}


def _resolve_single(filter_value: str) -> dict:
    """Resolve a single filter value (category or #tool lookup)."""
    if "#" in filter_value:
        return _get_tool(filter_value)
    return _expand_category(filter_value)


def _exposed_tools() -> dict:
    """Return exposed tools and a catalog overview for discovery.

    Groups directly-registered tools by category, then lists all available
    catalog categories so agents know what can be explored via drill-down
    or pinned via ToolPin.
    """
    tools = [t for t in TOOL_CATALOG if t["name"] in EXPOSED_TOOL_NAMES]

    # Group by category
    by_cat: dict[str, list[dict]] = {}
    for t in tools:
        by_cat.setdefault(t["category"], []).append(
            {"name": t["name"], "description": t["description"]}
        )

    categories = []
    for cat_name, cat_tools in sorted(by_cat.items()):
        # Look up category description
        desc = None
        for c in CATEGORIES:
            if c["name"] == cat_name:
                desc = c["description"]
                break
        entry: dict = {"category": cat_name, "tools": cat_tools}
        if desc:
            entry["description"] = desc
        categories.append(entry)

    return {
        "total_tools": len(tools),
        "categories": categories,
        "hint": "Use ToolSummary(filter='CategoryName') to explore, or ToolPin to activate a tool.",
    }


def _get_tool(path: str) -> dict:
    """Return a single tool definition by Category.Path#ToolName."""
    cat_path, tool_name = path.split("#", 1)
    for t in TOOL_CATALOG:
        if t["name"] == tool_name and t["category"] == cat_path:
            return {
                "name": t["name"],
                "category": t["category"],
                "description": t["description"],
                "parameters": t["parameters"],
            }
    # Try matching just by name (in case category path is partial)
    for t in TOOL_CATALOG:
        if t["name"] == tool_name:
            return {
                "name": t["name"],
                "category": t["category"],
                "description": t["description"],
                "parameters": t["parameters"],
            }
    return {"error": f"Tool '{tool_name}' not found in category '{cat_path}'."}


def _expand_category(category: str) -> dict:
    """Expand a specific category, showing tools and subcategories within it."""
    prefix = category + "."

    # Tools directly in this category (exact match)
    direct_tools = [t for t in TOOL_CATALOG if t["category"] == category]

    # Tools in subcategories (starts with prefix)
    sub_tools = [t for t in TOOL_CATALOG if t["category"].startswith(prefix)]

    if not direct_tools and not sub_tools:
        return {"error": f"Category '{category}' not found."}

    # Look up description from CATEGORIES
    description = None
    for c in CATEGORIES:
        if c["name"] == category:
            description = c["description"]
            break

    result: dict = {
        "category": category,
        "tool_count": len(direct_tools) + len(sub_tools),
    }
    if description:
        result["description"] = description

    # Tool names and descriptions (use #ToolName for full parameter info)
    if direct_tools:
        result["tools"] = [
            {
                "name": t["name"],
                "description": t["description"],
            }
            for t in direct_tools
        ]

    # Nested subcategories (one level deeper)
    subcats = _collect_subcategories(category, sub_tools)
    if subcats:
        result["subcategories"] = subcats

    return result


def _collect_subcategories(
    parent: str, tools: list[ToolEntry]
) -> list[dict]:
    """Group tools into immediate subcategories under parent."""
    depth = parent.count(".") + 1
    buckets: dict[str, list[ToolEntry]] = {}

    for tool in tools:
        parts = tool["category"].split(".")
        if len(parts) <= depth:
            continue  # direct tool, not a subcategory
        sub_name = ".".join(parts[: depth + 1])
        buckets.setdefault(sub_name, []).append(tool)

    subcats = []
    for sub_name, sub_tools in sorted(buckets.items()):
        # Look up description from CATEGORIES
        desc = None
        for c in CATEGORIES:
            if c["name"] == sub_name:
                desc = c["description"]
                break
        entry: dict = {
            "name": sub_name,
            "tool_count": len(sub_tools),
        }
        if desc:
            entry["description"] = desc
        subcats.append(entry)

    return subcats
