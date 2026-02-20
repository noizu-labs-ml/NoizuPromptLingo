"""ToolSearch — text and intent-based tool discovery."""

from __future__ import annotations

import json

from .catalog import build_catalog, ToolEntry
from .inference_cache import cache_key, cache_get, cache_set
from .llm_client import chat_completion


async def tool_search(
    query: str,
    mode: str = "text",
    limit: int = 10,
    verbose: bool = False,
) -> dict:
    """Search registered tools by text or intent.

    Args:
        query: Search query string.
        mode: "text" for substring matching, "intent" for LLM-powered semantic search.
        limit: Maximum results to return.
        verbose: If True, include full parameter definitions in each match.

    Returns:
        Dict with search results.
    """
    if mode == "intent":
        result = await _intent_search(query, limit)
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


def _build_intent_prompt(
    query: str,
    tools: list[ToolEntry],
    limit: int,
) -> list[dict[str, str]]:
    """Build the LLM prompt for intent-based search."""
    tool_lines = []
    for t in tools:
        params = ", ".join(
            f"{p['name']}: {p['type']}" + ("" if p["required"] else "?")
            for p in t["parameters"]
        )
        tool_lines.append(f"- **{t['name']}** [{t['category']}] ({params}): {t['description']}")

    catalog_text = "\n".join(tool_lines)

    system_msg = (
        "You are a tool routing assistant. Given a user's intent and a catalog of "
        "available tools, identify which tools are relevant and explain HOW they can "
        "be used together to accomplish the user's goal.\n\n"
        "Return ONLY a valid JSON object (no markdown fences) with this structure:\n"
        '{"matches": [{"name": "<tool_name>", "category": "<category>", '
        '"relevance": "high"|"medium"|"low", '
        '"explanation": "<how this tool helps with the intent>"}]}\n\n'
        "Rules:\n"
        f"- Include at most {limit} matches, ordered by relevance (high first)\n"
        "- The explanation should describe HOW the tool helps, not just that it matches\n"
        "- If tools should be used together as a workflow, note that in explanations\n"
        '- If no tools match, return {"matches": []}'
    )

    user_msg = f"## User Intent\n{query}\n\n## Available Tools\n{catalog_text}"

    return [
        {"role": "system", "content": system_msg},
        {"role": "user", "content": user_msg},
    ]


def _enrich_matches(
    llm_matches: list[dict],
    catalog: list[ToolEntry],
) -> list[dict]:
    """Add full parameter info from catalog to LLM match results."""
    catalog_by_name = {t["name"]: t for t in catalog}
    enriched = []
    for match in llm_matches:
        name = match.get("name", "")
        tool = catalog_by_name.get(name)
        if tool:
            enriched.append({
                "name": name,
                "category": match.get("category", tool["category"]),
                "description": tool["description"],
                "parameters": tool["parameters"],
                "relevance": match.get("relevance", "medium"),
                "explanation": match.get("explanation", ""),
            })
    return enriched


async def _intent_search(query: str, limit: int = 10) -> dict:
    """LLM-powered intent search with text-search fallback.

    Successful LLM results are cached keyed by catalog version + query + limit.
    """
    key = cache_key("intent_search", query, str(limit))
    cached = cache_get(key)
    if cached is not None:
        return cached

    catalog = await build_catalog()

    try:
        messages = _build_intent_prompt(query, catalog, limit)
        response = await chat_completion(messages)
        content = response["choices"][0]["message"]["content"]

        content = content.strip()
        if content.startswith("```"):
            content = content.split("\n", 1)[1] if "\n" in content else content[3:]
        if content.endswith("```"):
            content = content[:-3]
        content = content.strip()

        result = json.loads(content)
        enriched = _enrich_matches(result.get("matches", []), catalog)

        response_dict = {
            "mode": "intent",
            "query": query,
            "total_matches": len(enriched),
            "matches": enriched[:limit],
        }

        cache_set(key, response_dict)
        return response_dict

    except Exception as e:
        fallback = await _text_search(query, limit)
        fallback["mode"] = "intent"
        fallback["fallback"] = True
        fallback["fallback_reason"] = f"{type(e).__name__}: {e}"
        return fallback
