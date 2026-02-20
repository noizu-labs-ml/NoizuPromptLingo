"""ToolSearch — text-based tool discovery."""

from __future__ import annotations

from .catalog import build_catalog


async def tool_search(
    query: str,
    mode: str = "text",
    limit: int = 10,
    verbose: bool = False,
) -> dict:
    """Search registered tools by text.

    Args:
        query: Search query string.
        mode: "text" for substring matching. ("intent" mode not yet configured.)
        limit: Maximum results to return.
        verbose: If True, include full parameter definitions in each match.

    Returns:
        Dict with search results.
    """
    if mode == "intent":
        result = await _text_search(query, limit)
        result["note"] = "Intent mode is not configured; falling back to text search."
    else:
        result = await _text_search(query, limit)

    if not verbose:
        result["matches"] = [_strip_params(m) for m in result["matches"]]

    return result


def _strip_params(match: dict) -> dict:
    """Return a copy of match without the 'parameters' key."""
    return {k: v for k, v in match.items() if k != "parameters"}


async def _text_search(query: str, limit: int = 10) -> dict:
    """Case-insensitive substring search on tool name and description."""
    catalog = await build_catalog()
    q = query.lower()

    exact_name = []
    name_match = []
    desc_match = []

    for tool in catalog:
        name_lower = tool["name"].lower()
        desc_lower = tool["description"].lower()

        if name_lower == q:
            exact_name.append(tool)
        elif q in name_lower:
            name_match.append(tool)
        elif q in desc_lower:
            desc_match.append(tool)

    matches = (exact_name + name_match + desc_match)[:limit]

    return {
        "mode": "text",
        "query": query,
        "total_matches": len(exact_name) + len(name_match) + len(desc_match),
        "matches": matches,
    }
