"""Migration-critical tests for FastMCP ↔ catalog integration.

These tests validate the integration points between our custom catalog layer
and FastMCP's tool registration/introspection API. They are written to be
version-agnostic: they use whichever tool-introspection method the installed
FastMCP version exposes (``get_tools()`` in 2.x, ``list_tools()`` in 3.x).

If FastMCP changes the shape of registered tool objects or the return type
of its introspection API, these tests should be the first to break.
"""

from unittest.mock import patch

import httpx
import pytest

from npl_mcp.meta_tools.catalog import (
    _DISCOVERABLE_TOOLS,
    _MCP_TOOL_CATEGORIES,
    _category_to_tags,
    _schema_to_params,
    build_catalog,
    call_tool,
    get_tool_by_name,
    mcp_discoverable,
)


EXPECTED_MCP_TOOL_NAMES = {
    "NPLSpec",
    "ToolSummary",
    "ToolSearch",
    "ToolDefinition",
    "ToolHelp",
    "ToolCall",
    "ToolSession.Generate",
    "ToolSession",
    "Instructions",
    "Instructions.Create",
    "Instructions.List",
}

EXPECTED_DISCOVERABLE_NAMES = {
    # Browser
    "ToMarkdown", "Ping", "Download", "Screenshot", "Rest",
    # Utility
    "Secret",
    # Instructions (hidden)
    "Instructions.Update", "Instructions.ActiveVersion", "Instructions.Versions",
    # Projects (DB)
    "Proj.Projects.Create", "Proj.Projects.Get", "Proj.Projects.List",
    # Personas (DB)
    "Proj.UserPersonas.Create", "Proj.UserPersonas.Get", "Proj.UserPersonas.Update",
    "Proj.UserPersonas.Delete", "Proj.UserPersonas.List",
    # Stories (DB)
    "Proj.UserStories.Create", "Proj.UserStories.Get", "Proj.UserStories.Update",
    "Proj.UserStories.Delete", "Proj.UserStories.List",
}


async def _list_mcp_tools(mcp):
    """Version-agnostic tool introspection.

    FastMCP 2.x: ``await mcp.get_tools()`` returns dict[str, FunctionTool].
    FastMCP 3.x: ``await mcp.list_tools()`` returns list[FunctionTool].
    """
    if hasattr(mcp, "list_tools"):
        return list(await mcp.list_tools())
    result = await mcp.get_tools()
    return list(result.values()) if isinstance(result, dict) else list(result)


# ── FastMCP tool introspection ───────────────────────────────────────────

class TestMCPToolIntrospection:
    """Validates the contract with FastMCP's tool registration API."""

    @pytest.mark.asyncio
    async def test_mcp_tools_are_iterable(self, _mcp_app):
        """Introspected tools are iterable and have the required attributes."""
        tools = await _list_mcp_tools(_mcp_app)
        assert len(tools) > 0
        for t in tools:
            assert hasattr(t, "name")
            assert hasattr(t, "description")
            assert hasattr(t, "parameters")

    @pytest.mark.asyncio
    async def test_mcp_tool_count_is_11(self, _mcp_app):
        """Exactly 11 MCP-visible tools are registered."""
        tools = await _list_mcp_tools(_mcp_app)
        assert len(tools) == 11, (
            f"Expected 11 MCP tools, got {len(tools)}: "
            f"{sorted(t.name for t in tools)}"
        )

    @pytest.mark.asyncio
    async def test_mcp_tool_names(self, _mcp_app):
        """All expected MCP tool names are registered."""
        tools = await _list_mcp_tools(_mcp_app)
        names = {t.name for t in tools}
        assert names == EXPECTED_MCP_TOOL_NAMES, (
            f"Name mismatch. Missing: {EXPECTED_MCP_TOOL_NAMES - names}, "
            f"Extra: {names - EXPECTED_MCP_TOOL_NAMES}"
        )

    @pytest.mark.asyncio
    async def test_tool_parameters_are_json_schema(self, _mcp_app):
        """Each tool's parameters attribute is a JSON schema dict with properties."""
        tools = await _list_mcp_tools(_mcp_app)
        for t in tools:
            params = t.parameters
            assert params is not None, f"{t.name} has no parameters"
            assert isinstance(params, dict), f"{t.name}.parameters is not a dict"
            # JSON schema shape: has "properties" key (may be empty for no-arg tools)
            assert "properties" in params, (
                f"{t.name}.parameters missing 'properties' key: {params}"
            )


# ── Catalog builder ──────────────────────────────────────────────────────

class TestCatalogBuilder:
    """Validates the unified catalog merges all three sources correctly."""

    @pytest.mark.asyncio
    async def test_catalog_total_count(self, _mcp_app):
        """Catalog = MCP tools + discoverable-only tools + stub tools."""
        from npl_mcp.meta_tools.stub_catalog import STUB_CATALOG

        catalog = await build_catalog()
        # MCP-visible tools that overlap with _DISCOVERABLE_TOOLS are counted once
        # (MCP takes precedence). Discoverable-only = not in MCP names.
        mcp_names = EXPECTED_MCP_TOOL_NAMES
        discoverable_only = EXPECTED_DISCOVERABLE_NAMES - mcp_names

        expected = len(mcp_names) + len(discoverable_only) + len(STUB_CATALOG)
        assert len(catalog) == expected, (
            f"Catalog count {len(catalog)} != expected {expected} "
            f"(MCP={len(mcp_names)}, discoverable={len(discoverable_only)}, "
            f"stubs={len(STUB_CATALOG)})"
        )

    @pytest.mark.asyncio
    async def test_catalog_no_duplicates(self, _mcp_app):
        """No tool name appears twice in the catalog."""
        catalog = await build_catalog()
        names = [entry["name"] for entry in catalog]
        duplicates = [n for n in set(names) if names.count(n) > 1]
        assert not duplicates, f"Duplicate tool names: {duplicates}"

    @pytest.mark.asyncio
    async def test_mcp_tools_have_categories(self, _mcp_app):
        """Every MCP-registered tool has a non-Uncategorized category."""
        catalog = await build_catalog()
        for entry in catalog:
            if entry["name"] in EXPECTED_MCP_TOOL_NAMES:
                assert entry["category"] != "Uncategorized", (
                    f"MCP tool {entry['name']} has no category"
                )

    @pytest.mark.asyncio
    async def test_all_expected_discoverable_registered(self, _mcp_app):
        """All 22 expected discoverable (hidden) tools are in the registry."""
        missing = EXPECTED_DISCOVERABLE_NAMES - set(_DISCOVERABLE_TOOLS)
        assert not missing, f"Missing discoverable registrations: {missing}"


# ── Schema conversion ────────────────────────────────────────────────────

class TestSchemaConversion:
    """Validates JSON-schema → ToolParam conversion."""

    def test_schema_to_params_basic(self):
        schema = {
            "type": "object",
            "properties": {
                "name": {"type": "string", "description": "Your name"},
                "count": {"type": "integer"},
                "flag": {"type": "boolean"},
            },
            "required": ["name"],
        }
        params = _schema_to_params(schema)
        by_name = {p["name"]: p for p in params}

        assert by_name["name"]["type"] == "str"
        assert by_name["name"]["required"] is True
        assert by_name["name"]["description"] == "Your name"

        assert by_name["count"]["type"] == "int"
        assert by_name["count"]["required"] is False

        assert by_name["flag"]["type"] == "bool"

    def test_schema_to_params_nullable_type(self):
        """Union types (list) should pick the non-null variant."""
        schema = {
            "properties": {
                "maybe": {"type": ["string", "null"]},
            },
        }
        params = _schema_to_params(schema)
        assert params[0]["type"] == "str"

    def test_schema_to_params_empty(self):
        """Empty schema yields empty param list."""
        assert _schema_to_params({}) == []
        assert _schema_to_params({"properties": {}}) == []


# ── http_app / ASGI ──────────────────────────────────────────────────────

class TestHTTPAppIntegration:
    """Validates the http_app/ASGI integration used by launcher.create_asgi_app."""

    def test_http_app_returns_asgi_callable(self, _mcp_app):
        """http_app() returns an ASGI-callable (Starlette/FastAPI app)."""
        asgi = _mcp_app.http_app(path="/", transport="sse")
        assert asgi is not None
        # ASGI apps are callable (async (scope, receive, send))
        assert callable(asgi)


# ── ToolCall dispatcher ──────────────────────────────────────────────────

class TestCallToolDispatcher:
    """Validates that call_tool routes to discoverable tool functions."""

    @pytest.mark.asyncio
    async def test_call_tool_unknown_raises_keyerror(self, _mcp_app):
        """Calling an unregistered tool raises KeyError."""
        with pytest.raises(KeyError):
            await call_tool("DoesNotExist", {})

    @pytest.mark.asyncio
    async def test_call_tool_dispatches_to_discoverable(self, _mcp_app):
        """call_tool invokes the registered function for a discoverable tool."""
        # Ping is registered under "Browser" — patch httpx.AsyncClient.send so we
        # don't hit the network. Use the same pattern as tests/test_ping.py.
        resp = httpx.Response(
            status_code=200,
            text="ok",
            request=httpx.Request("GET", "https://example.com"),
        )

        async def _mock_send(self, request, **kwargs):
            return resp

        with patch.object(httpx.AsyncClient, "send", _mock_send):
            result = await call_tool("Ping", {"url": "https://example.com"})

        assert isinstance(result, dict)
        assert result.get("status_code") == 200

    @pytest.mark.asyncio
    async def test_get_tool_by_name_returns_entry(self, _mcp_app):
        """get_tool_by_name finds registered tools."""
        entry = await get_tool_by_name("Ping")
        assert entry is not None
        assert entry["name"] == "Ping"
        assert entry["category"] == "Browser"


# ── 3.x metadata enrichment ──────────────────────────────────────────────

class TestCategoryToTags:
    """Validates category → tag-set derivation."""

    def test_simple_category(self):
        assert _category_to_tags("Browser") == {"browser"}

    def test_hierarchical_category(self):
        tags = _category_to_tags("Browser.Screenshots")
        assert tags == {"browser", "browser.screenshots"}

    def test_three_level_category(self):
        tags = _category_to_tags("A.B.C")
        assert tags == {"a", "a.b", "a.b.c"}

    def test_category_with_spaces(self):
        """Category with internal spaces is lowercased but not split."""
        assert _category_to_tags("Project Management") == {"project management"}


class TestMCPToolMetadata:
    """Validates FastMCP-native metadata is populated on MCP-registered tools."""

    @pytest.mark.asyncio
    async def test_mcp_tools_have_tags(self, _mcp_app):
        """Each MCP-registered tool has tags derived from its NPL category."""
        for tool in await _mcp_app.list_tools():
            tags = getattr(tool, "tags", None)
            assert tags, f"{tool.name} has no tags"
            # Expect at least the top-level category tag
            category = _MCP_TOOL_CATEGORIES.get(tool.name, "")
            top_tag = category.lower().split(".")[0] if category else None
            if top_tag:
                assert top_tag in tags, (
                    f"{tool.name} missing expected tag '{top_tag}' (tags={tags})"
                )

    @pytest.mark.asyncio
    async def test_mcp_tools_have_meta_category(self, _mcp_app):
        """Each MCP tool carries ``meta['npl_category']`` matching our registry."""
        for tool in await _mcp_app.list_tools():
            meta = getattr(tool, "meta", None) or {}
            expected = _MCP_TOOL_CATEGORIES.get(tool.name)
            assert meta.get("npl_category") == expected, (
                f"{tool.name}: meta.npl_category={meta.get('npl_category')!r} "
                f"!= _MCP_TOOL_CATEGORIES={expected!r}"
            )
            assert meta.get("npl_discoverable") is True, (
                f"{tool.name} missing meta['npl_discoverable']"
            )


class TestCatalogEntryFields:
    """Validates ToolEntry carries the optional fields."""

    @pytest.mark.asyncio
    async def test_mcp_entry_has_tags(self, _mcp_app):
        catalog = await build_catalog()
        entry = next(e for e in catalog if e["name"] == "NPLSpec")
        assert "tags" in entry
        assert "npl" in entry["tags"]

    @pytest.mark.asyncio
    async def test_hidden_entry_has_tags(self, _mcp_app):
        """Hidden tools get tags derived from their category."""
        catalog = await build_catalog()
        entry = next(e for e in catalog if e["name"] == "Ping")
        assert "tags" in entry
        assert "browser" in entry["tags"]

    @pytest.mark.asyncio
    async def test_stub_entry_has_tags(self, _mcp_app):
        """Stub entries gain tags from their category during build_catalog()."""
        catalog = await build_catalog()
        # Pick a known stub entry
        stub = next(e for e in catalog if e["name"] == "dump_files")
        assert "tags" in stub
        assert "scripts" in stub["tags"]

    @pytest.mark.asyncio
    async def test_hierarchical_stub_tags(self, _mcp_app):
        """Browser.Screenshots stubs get both 'browser' and 'browser.screenshots' tags."""
        catalog = await build_catalog()
        stub = next(
            e for e in catalog if e.get("category") == "Browser.Screenshots"
        )
        assert {"browser", "browser.screenshots"}.issubset(stub["tags"])


class TestMCPDiscoverableHelper:
    """Validates the combined @mcp_discoverable decorator."""

    @pytest.mark.asyncio
    async def test_helper_registers_in_both_registries(self, _mcp_app):
        """A tool registered via @mcp_discoverable appears in FastMCP AND has a category."""
        # NPLSpec is registered via @mcp_discoverable in launcher.py
        # Verify FastMCP knows about it
        tool = await _mcp_app.get_tool("NPLSpec")
        assert tool is not None
        assert tool.name == "NPLSpec"
        # Verify our category registry knows about it
        assert _MCP_TOOL_CATEGORIES.get("NPLSpec") == "NPL"

    @pytest.mark.asyncio
    async def test_helper_sets_tags_and_meta(self, _mcp_app):
        """@mcp_discoverable populates FastMCP tags and meta from category."""
        tool = await _mcp_app.get_tool("NPLSpec")
        assert "npl" in (tool.tags or set())
        assert (tool.meta or {}).get("npl_category") == "NPL"


# ── ToolCall status distinction (stub vs mcp vs error) ───────────────────

class TestToolCallStatusDistinction:
    """Validates ToolCall distinguishes MCP-registered tools from stubs."""

    @pytest.mark.asyncio
    async def test_toolcall_on_mcp_tool_returns_status_mcp(self, _mcp_app):
        """Calling an MCP-registered tool via ToolCall returns status='mcp'."""
        # Call the ToolCall handler directly from FastMCP
        tool_call_handler = await _mcp_app.get_tool("ToolCall")
        result = await tool_call_handler.run({"tool": "NPLSpec", "arguments": {}})
        import json
        data = json.loads(result.content[0].text)
        assert data["status"] == "mcp", f"Expected status=mcp, got: {data}"
        assert "MCP tools/call" in data["message"]

    @pytest.mark.asyncio
    async def test_toolcall_on_stub_still_returns_status_stub(self, _mcp_app):
        """Calling a catalog-only stub via ToolCall still returns status='stub'."""
        tool_call_handler = await _mcp_app.get_tool("ToolCall")
        result = await tool_call_handler.run({"tool": "dump_files", "arguments": {}})
        import json
        data = json.loads(result.content[0].text)
        assert data["status"] == "stub", f"Expected status=stub, got: {data}"
        assert "no implementation" in data["message"].lower()

    @pytest.mark.asyncio
    async def test_toolcall_on_unknown_tool_returns_status_error(self, _mcp_app):
        """Calling a tool not in catalog returns status='error'."""
        tool_call_handler = await _mcp_app.get_tool("ToolCall")
        result = await tool_call_handler.run({"tool": "nonexistent_xyz", "arguments": {}})
        import json
        data = json.loads(result.content[0].text)
        assert data["status"] == "error"
        assert "not found" in data["message"].lower()
