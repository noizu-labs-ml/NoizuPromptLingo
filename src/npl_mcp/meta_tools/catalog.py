"""Dynamic tool catalog built from FastMCP registered tools + discoverable tools.

Tools decorated with ``@discoverable`` are *not* registered with FastMCP and
therefore hidden from the MCP ``tools/list`` endpoint.  They appear only in
the meta-discovery catalog (ToolSummary, ToolSearch, ToolDefinition) and can
be invoked through the ``ToolCall`` dispatcher.

Tools registered with ``@mcp.tool()`` (and optionally also ``@discoverable``
for category metadata) remain directly visible to MCP clients.

Stub tools (no implementation) from ``stub_catalog.py`` are also included
in the catalog for discoverability.
"""

from __future__ import annotations

import asyncio
import inspect
from collections.abc import Callable
from dataclasses import dataclass
from typing import Any, Optional, TypedDict, TYPE_CHECKING

if TYPE_CHECKING:
    from fastmcp import FastMCP


# ---------------------------------------------------------------------------
# Data structures (compatible with NoizuPromptLingo catalog API)
# ---------------------------------------------------------------------------

class ToolParam(TypedDict):
    name: str
    type: str           # Python type string: "str", "int", "bool", "float", "list", "dict"
    required: bool
    description: str


class ToolEntry(TypedDict):
    name: str
    category: str
    description: str
    parameters: list[ToolParam]


class CategoryInfo(TypedDict):
    name: str
    description: str
    tool_count: int


# ---------------------------------------------------------------------------
# Discoverable registry
# ---------------------------------------------------------------------------

@dataclass
class _DiscoverableInfo:
    """Metadata for a tool registered via ``@discoverable``."""
    category: str
    fn: Callable[..., Any]
    description: str
    parameters: list[ToolParam]


_DISCOVERABLE_TOOLS: dict[str, _DiscoverableInfo] = {}  # tool_name → info
_CATEGORY_DESCRIPTIONS: dict[str, str] = {}              # category  → description

# Also track category for MCP-registered tools that stack @discoverable
_MCP_TOOL_CATEGORIES: dict[str, str] = {}                # tool_name → category


# ---------------------------------------------------------------------------
# Python type → ToolParam type string
# ---------------------------------------------------------------------------

_PYTHON_TYPE_MAP: dict[type, str] = {
    str: "str",
    int: "int",
    bool: "bool",
    float: "float",
    list: "list",
    dict: "dict",
}


def _python_type_to_str(tp: Any) -> str:
    """Convert a Python type annotation to a ToolParam type string."""
    if tp in _PYTHON_TYPE_MAP:
        return _PYTHON_TYPE_MAP[tp]
    origin = getattr(tp, "__origin__", None)
    if origin is list:
        return "list"
    if origin is dict:
        return "dict"
    return "str"


def _extract_params(fn: Callable[..., Any]) -> list[ToolParam]:
    """Extract ToolParam list from a function's signature and type hints."""
    sig = inspect.signature(fn)
    hints = {}
    try:
        hints = {k: v for k, v in inspect.get_annotations(fn, eval_str=True).items()
                 if k != "return"}
    except Exception:
        pass

    params: list[ToolParam] = []
    for pname, param in sig.parameters.items():
        if pname in ("self", "cls"):
            continue
        tp = hints.get(pname, str)
        params.append({
            "name": pname,
            "type": _python_type_to_str(tp),
            "required": param.default is inspect.Parameter.empty,
            "description": "",
        })
    return params


# ---------------------------------------------------------------------------
# @discoverable decorator
# ---------------------------------------------------------------------------

def discoverable(
    category: str,
    *,
    name: str | None = None,
    description: str | None = None,
    mcp_registered: bool = False,
) -> Callable[[Callable[..., Any]], Callable[..., Any]]:
    """Mark a tool as meta-discoverable.

    **Standalone** — the tool is hidden from MCP ``tools/list`` and only
    reachable via ``ToolCall``::

        @discoverable(category="Test")
        def HelloDiscoverable(name: str = "world") -> str: ...

    **Stacked with @mcp.tool()** — the tool stays visible in MCP *and*
    gets a category in the catalog.  Pass ``mcp_registered=True``::

        @mcp.tool()
        @discoverable(category="NPL", mcp_registered=True)
        def NPLSpec(...): ...

    Args:
        category: Category this tool belongs to (e.g. ``"NPL"``).
        name: Tool name override (defaults to ``fn.__name__``).
        description: One-line description for the *category* itself.
                     Only needs to be set once per category.
        mcp_registered: Set ``True`` when also decorated with ``@mcp.tool()``.
                        The tool stays in MCP's tools/list; the decorator
                        only records category metadata.
    """
    def decorator(fn: Callable[..., Any]) -> Callable[..., Any]:
        tool_name = name or fn.__name__

        if description and category not in _CATEGORY_DESCRIPTIONS:
            _CATEGORY_DESCRIPTIONS[category] = description

        if mcp_registered:
            # Tool is already (or will be) registered with FastMCP.
            # Just record category so build_catalog() can label it.
            _MCP_TOOL_CATEGORIES[tool_name] = category
        else:
            # Hidden tool — store everything needed for catalog + ToolCall.
            _DISCOVERABLE_TOOLS[tool_name] = _DiscoverableInfo(
                category=category,
                fn=fn,
                description=(fn.__doc__ or "").strip(),
                parameters=_extract_params(fn),
            )

        return fn
    return decorator


# ---------------------------------------------------------------------------
# Imperative registration (alternative to decorator)
# ---------------------------------------------------------------------------

def register_discoverable(
    name: str,
    *,
    category: str,
    fn: Callable[..., Any],
    mcp_registered: bool = False,
    category_description: str | None = None,
) -> None:
    """Programmatically register a tool as discoverable.

    Use this when the decorator pattern is not practical (e.g. wrapping
    third-party functions or registering from a separate module).
    """
    if category_description and category not in _CATEGORY_DESCRIPTIONS:
        _CATEGORY_DESCRIPTIONS[category] = category_description

    if mcp_registered:
        _MCP_TOOL_CATEGORIES[name] = category
    else:
        _DISCOVERABLE_TOOLS[name] = _DiscoverableInfo(
            category=category,
            fn=fn,
            description=(fn.__doc__ or "").strip(),
            parameters=_extract_params(fn),
        )


# ---------------------------------------------------------------------------
# ToolCall dispatcher
# ---------------------------------------------------------------------------

async def call_tool(tool_name: str, arguments: dict[str, Any] | None = None) -> Any:
    """Invoke a discoverable (hidden) tool by name.

    Returns the tool's result or raises ``KeyError`` / propagates exceptions.
    """
    info = _DISCOVERABLE_TOOLS.get(tool_name)
    if info is None:
        raise KeyError(f"Tool '{tool_name}' not found in discoverable registry")

    result = info.fn(**(arguments or {}))
    if asyncio.iscoroutine(result):
        result = await result
    return result


# ---------------------------------------------------------------------------
# JSON Schema → ToolParam conversion (for MCP-registered tools)
# ---------------------------------------------------------------------------

_JSON_TYPE_MAP: dict[str, str] = {
    "string": "str",
    "integer": "int",
    "boolean": "bool",
    "number": "float",
    "array": "list",
    "object": "dict",
}


def _schema_to_params(schema: dict) -> list[ToolParam]:
    """Convert a JSON Schema 'properties' block into a list of ToolParam."""
    properties = schema.get("properties", {})
    required = set(schema.get("required", []))
    params: list[ToolParam] = []
    for pname, prop in properties.items():
        json_type = prop.get("type", "string")
        if isinstance(json_type, list):
            json_type = next((t for t in json_type if t != "null"), "string")
        params.append({
            "name": pname,
            "type": _JSON_TYPE_MAP.get(json_type, "str"),
            "required": pname in required,
            "description": prop.get("description", ""),
        })
    return params


# ---------------------------------------------------------------------------
# Catalog state
# ---------------------------------------------------------------------------

_mcp_ref: Optional[FastMCP] = None
_catalog_cache: Optional[list[ToolEntry]] = None
_catalog_version: int = 0


def init_catalog(mcp: FastMCP) -> None:
    """Store the FastMCP instance for later introspection."""
    global _mcp_ref
    _mcp_ref = mcp


async def build_catalog() -> list[ToolEntry]:
    """Build (or return cached) the unified catalog.

    Merges three sources:
    1. MCP-registered tools (from ``mcp.list_tools()``)
    2. Discoverable-only tools (hidden from MCP)
    3. Stub catalog entries (tools without implementations)
    """
    global _catalog_cache
    if _catalog_cache is not None:
        return _catalog_cache

    catalog: list[ToolEntry] = []
    mcp_names: set[str] = set()
    discoverable_names: set[str] = set()

    # 1. MCP-registered tools
    if _mcp_ref is not None:
        # FastMCP 3.x: list_tools() returns list[FunctionTool].
        for tool in await _mcp_ref.list_tools():
            mcp_names.add(tool.name)
            category = _MCP_TOOL_CATEGORIES.get(tool.name, "Uncategorized")
            params = _schema_to_params(tool.parameters) if tool.parameters else []
            catalog.append({
                "name": tool.name,
                "category": category,
                "description": tool.description or "",
                "parameters": params,
            })

    # 2. Discoverable-only tools (not in MCP)
    for tool_name, info in _DISCOVERABLE_TOOLS.items():
        if tool_name not in mcp_names:
            discoverable_names.add(tool_name)
            catalog.append({
                "name": tool_name,
                "category": info.category,
                "description": info.description,
                "parameters": info.parameters,
            })

    # 3. Stub catalog entries (not in MCP or discoverable)
    try:
        from .stub_catalog import STUB_CATALOG, STUB_CATEGORIES
        # Register stub category descriptions
        for cat_name, cat_desc in STUB_CATEGORIES.items():
            if cat_name not in _CATEGORY_DESCRIPTIONS:
                _CATEGORY_DESCRIPTIONS[cat_name] = cat_desc
        # Add stub entries not already covered
        for entry in STUB_CATALOG:
            if entry["name"] not in mcp_names and entry["name"] not in discoverable_names:
                catalog.append(entry)
    except ImportError:
        pass  # No stub catalog available

    _catalog_cache = catalog
    return catalog


def invalidate_catalog() -> None:
    """Clear cached catalog so it rebuilds on next access."""
    global _catalog_cache, _catalog_version
    _catalog_cache = None
    _catalog_version += 1


# ---------------------------------------------------------------------------
# Convenience helpers
# ---------------------------------------------------------------------------

async def get_tool_by_name(name: str) -> Optional[ToolEntry]:
    """Look up a single tool by name."""
    catalog = await build_catalog()
    for entry in catalog:
        if entry["name"] == name:
            return entry
    return None


async def get_tools_by_category(category: str) -> list[ToolEntry]:
    """Return all tools in a given category (exact match)."""
    catalog = await build_catalog()
    return [t for t in catalog if t["category"] == category]


async def get_category_info(name: str) -> Optional[CategoryInfo]:
    """Return category metadata if it exists."""
    desc = _CATEGORY_DESCRIPTIONS.get(name)
    if desc is None:
        return None
    catalog = await build_catalog()
    count = sum(1 for t in catalog if t["category"] == name)
    return {"name": name, "description": desc, "tool_count": count}


async def get_categories() -> list[CategoryInfo]:
    """Return all categories with tool counts."""
    catalog = await build_catalog()
    cat_counts: dict[str, int] = {}
    for t in catalog:
        cat_counts[t["category"]] = cat_counts.get(t["category"], 0) + 1

    categories: list[CategoryInfo] = []
    for cat_name, count in sorted(cat_counts.items()):
        desc = _CATEGORY_DESCRIPTIONS.get(cat_name, "")
        categories.append({"name": cat_name, "description": desc, "tool_count": count})
    return categories
