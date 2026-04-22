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
from dataclasses import dataclass, field
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


class ToolEntry(TypedDict, total=False):
    # Required fields
    name: str
    category: str
    description: str
    parameters: list[ToolParam]
    # Optional 3.x-native fields (populated when available)
    tags: set[str]      # Derived from category hierarchy + extras
    title: str          # Display title (from FastMCP Tool.title)
    version: str        # Tool version (from FastMCP Tool.version)


class CategoryInfo(TypedDict):
    name: str
    description: str
    tool_count: int


# ---------------------------------------------------------------------------
# Category → tags derivation
# ---------------------------------------------------------------------------

def _category_to_tags(category: str) -> set[str]:
    """Convert a hierarchical category into a set of flat tags.

    Examples:
        ``"Browser"`` → ``{"browser"}``
        ``"Browser.Screenshots"`` → ``{"browser", "browser.screenshots"}``
        ``"Project Management"`` → ``{"project management"}``
    """
    parts = category.lower().split(".")
    return {".".join(parts[: i + 1]) for i in range(len(parts))}


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
    tags: set[str] = field(default_factory=set)


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
    tags: set[str] | None = None,
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
        tags: Optional extra tags in addition to those auto-derived from
              ``category``. Only applied to hidden tools — MCP-registered
              tools carry tags on the FastMCP Tool object directly.
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
            auto_tags = _category_to_tags(category)
            if tags:
                auto_tags |= tags
            _DISCOVERABLE_TOOLS[tool_name] = _DiscoverableInfo(
                category=category,
                fn=fn,
                description=(fn.__doc__ or "").strip(),
                parameters=_extract_params(fn),
                tags=auto_tags,
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
    tags: set[str] | None = None,
) -> None:
    """Programmatically register a tool as discoverable.

    Use this when the decorator pattern is not practical (e.g. wrapping
    third-party functions or registering from a separate module).

    Args:
        name: Tool name as it will appear in the catalog.
        category: Hierarchical category (e.g. ``"Browser.Screenshots"``).
        fn: The callable to dispatch to when ``call_tool(name, ...)`` runs.
        mcp_registered: Set ``True`` when the tool is also registered with
                        FastMCP — only records category metadata then.
        category_description: One-line description for the category (set once).
        tags: Optional extra tags; auto-derived tags from ``category`` are
              always included regardless.
    """
    if category_description and category not in _CATEGORY_DESCRIPTIONS:
        _CATEGORY_DESCRIPTIONS[category] = category_description

    if mcp_registered:
        _MCP_TOOL_CATEGORIES[name] = category
    else:
        auto_tags = _category_to_tags(category)
        if tags:
            auto_tags |= tags
        _DISCOVERABLE_TOOLS[name] = _DiscoverableInfo(
            category=category,
            fn=fn,
            description=(fn.__doc__ or "").strip(),
            parameters=_extract_params(fn),
            tags=auto_tags,
        )


# ---------------------------------------------------------------------------
# Combined MCP + discoverable registration helper
# ---------------------------------------------------------------------------

def mcp_discoverable(
    mcp: "FastMCP",
    *,
    name: str,
    category: str,
    description: str | None = None,
    extra_tags: set[str] | None = None,
    extra_meta: dict[str, Any] | None = None,
) -> Callable[[Callable[..., Any]], Callable[..., Any]]:
    """Register a tool with both FastMCP (MCP-visible) and our discovery catalog.

    This is a convenience wrapper that applies ``@mcp.tool(...)`` and
    ``@discoverable(..., mcp_registered=True)`` in one call, deriving the
    FastMCP-native ``tags`` / ``meta`` from the NPL category hierarchy.

    Populates on the FastMCP ``Tool`` object:

      * ``tags``: derived from the hierarchical category plus any
        ``extra_tags`` supplied by the caller. A category of
        ``"Browser.Screenshots"`` becomes ``{"browser", "browser.screenshots"}``.
      * ``meta``: ``{"npl_category": <category>, "npl_discoverable": True}``
        plus any ``extra_meta``.

    Example::

        @mcp_discoverable(
            mcp,
            name="NPLSpec",
            category="NPL",
            description="Noizu Prompt Lingua specification generation",
        )
        def npl_spec(...): ...

    Args:
        mcp: FastMCP instance to register the tool with.
        name: Tool name exposed over MCP and in the catalog.
        category: Hierarchical NPL category (e.g. ``"Browser.Screenshots"``).
        description: Category description — used once per category.
        extra_tags: Additional tags beyond those derived from ``category``.
        extra_meta: Additional metadata keys beyond the NPL-reserved ones.

    Returns:
        A decorator that, when applied, registers the function with
        FastMCP *and* records it in the NPL discovery catalog.
    """
    tags: set[str] = _category_to_tags(category)
    if extra_tags:
        tags |= extra_tags

    meta: dict[str, Any] = {"npl_category": category, "npl_discoverable": True}
    if extra_meta:
        meta.update(extra_meta)

    def decorator(fn: Callable[..., Any]) -> Callable[..., Any]:
        import functools
        import json
        import time

        @functools.wraps(fn)
        async def _metered(*args: Any, **kwargs: Any) -> Any:
            start = time.perf_counter()
            try:
                result = fn(*args, **kwargs)
                if asyncio.iscoroutine(result):
                    result = await result
                elapsed_ms = int((time.perf_counter() - start) * 1000)
                from npl_mcp.storage.metrics import record_tool_call
                await record_tool_call(
                    tool_name=name,
                    arguments=json.dumps(kwargs, default=str)[:4096] if kwargs else None,
                    result_summary=str(result)[:2048],
                    response_time_ms=elapsed_ms,
                )
                return result
            except Exception as exc:
                elapsed_ms = int((time.perf_counter() - start) * 1000)
                from npl_mcp.storage.metrics import record_tool_call
                await record_tool_call(
                    tool_name=name,
                    arguments=json.dumps(kwargs, default=str)[:4096] if kwargs else None,
                    error=str(exc)[:2048],
                    response_time_ms=elapsed_ms,
                )
                raise

        # Apply @mcp.tool() first so FastMCP records the tool with metadata.
        _metered = mcp.tool(name=name, tags=tags, meta=meta)(_metered)
        # Then record in our catalog — only needs to set _MCP_TOOL_CATEGORIES.
        return discoverable(
            category=category,
            name=name,
            mcp_registered=True,
            description=description,
        )(_metered)

    return decorator


# ---------------------------------------------------------------------------
# ToolCall dispatcher
# ---------------------------------------------------------------------------

async def call_tool(tool_name: str, arguments: dict[str, Any] | None = None) -> Any:
    """Invoke a discoverable (hidden) tool by name.

    Returns the tool's result or raises ``KeyError`` / propagates exceptions.
    """
    import json
    import time

    info = _DISCOVERABLE_TOOLS.get(tool_name)
    if info is None:
        raise KeyError(f"Tool '{tool_name}' not found in discoverable registry")

    start = time.perf_counter()
    try:
        result = info.fn(**(arguments or {}))
        if asyncio.iscoroutine(result):
            result = await result
        elapsed_ms = int((time.perf_counter() - start) * 1000)
        from npl_mcp.storage.metrics import record_tool_call
        await record_tool_call(
            tool_name=tool_name,
            arguments=json.dumps(arguments or {}, default=str)[:4096],
            result_summary=str(result)[:2048],
            response_time_ms=elapsed_ms,
        )
        return result
    except Exception as exc:
        elapsed_ms = int((time.perf_counter() - start) * 1000)
        from npl_mcp.storage.error_log import log_tool_error
        from npl_mcp.storage.metrics import record_tool_call
        await record_tool_call(
            tool_name=tool_name,
            arguments=json.dumps(arguments or {}, default=str)[:4096],
            error=str(exc)[:2048],
            response_time_ms=elapsed_ms,
        )
        await log_tool_error(tool_name, exc)
        raise


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
            entry: ToolEntry = {
                "name": tool.name,
                "category": category,
                "description": tool.description or "",
                "parameters": params,
            }
            # Pull 3.x-native metadata onto the entry when present.
            mcp_tags = getattr(tool, "tags", None)
            if mcp_tags:
                entry["tags"] = set(mcp_tags)
            else:
                entry["tags"] = _category_to_tags(category)
            title = getattr(tool, "title", None)
            if title:
                entry["title"] = title
            version = getattr(tool, "version", None)
            if version:
                entry["version"] = str(version)
            catalog.append(entry)

    # 2. Discoverable-only tools (not in MCP)
    for tool_name, info in _DISCOVERABLE_TOOLS.items():
        if tool_name not in mcp_names:
            discoverable_names.add(tool_name)
            entry: ToolEntry = {
                "name": tool_name,
                "category": info.category,
                "description": info.description,
                "parameters": info.parameters,
                "tags": set(info.tags) if info.tags else _category_to_tags(info.category),
            }
            catalog.append(entry)

    # 3. Stub catalog entries (not in MCP or discoverable)
    try:
        from .stub_catalog import STUB_CATALOG, STUB_CATEGORIES
        # Register stub category descriptions
        for cat_name, cat_desc in STUB_CATEGORIES.items():
            if cat_name not in _CATEGORY_DESCRIPTIONS:
                _CATEGORY_DESCRIPTIONS[cat_name] = cat_desc
        # Add stub entries not already covered. Derive tags from category
        # without mutating the original STUB_CATALOG entries.
        for stub in STUB_CATALOG:
            if stub["name"] in mcp_names or stub["name"] in discoverable_names:
                continue
            enriched: ToolEntry = dict(stub)  # shallow copy preserves original
            if "tags" not in enriched:
                enriched["tags"] = _category_to_tags(enriched["category"])
            catalog.append(enriched)
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
