"""Tests for discoverable tool registration and catalog integration."""

import pytest

from npl_mcp.meta_tools.catalog import (
    _DISCOVERABLE_TOOLS,
    _MCP_TOOL_CATEGORIES,
    build_catalog,
    call_tool,
    get_tool_by_name,
    get_category_info,
    invalidate_catalog,
)
from npl_mcp.meta_tools import inference_cache


@pytest.fixture(scope="session")
def _mcp_app():
    """Create the MCP app once per test session to register all tools."""
    from npl_mcp.launcher import create_app
    return create_app()


@pytest.fixture(autouse=True)
def _clear_caches(_mcp_app):
    """Clear caches before each test."""
    inference_cache.cache_clear()
    invalidate_catalog()
    yield
    inference_cache.cache_clear()
    invalidate_catalog()


# ── Discoverable registry basics ─────────────────────────────────────────

class TestDiscoverableRegistry:
    def test_registered_to_markdown(self):
        assert "ToMarkdown" in _DISCOVERABLE_TOOLS

    def test_registered_ping(self):
        assert "Ping" in _DISCOVERABLE_TOOLS

    def test_registered_download(self):
        assert "Download" in _DISCOVERABLE_TOOLS

    def test_registered_screenshot(self):
        assert "Screenshot" in _DISCOVERABLE_TOOLS

    def test_registered_secret(self):
        assert "Secret" in _DISCOVERABLE_TOOLS

    def test_registered_rest(self):
        assert "Rest" in _DISCOVERABLE_TOOLS

    def test_registered_instructions_update(self):
        assert "Instructions.Update" in _DISCOVERABLE_TOOLS

    def test_registered_instructions_active_version(self):
        assert "Instructions.ActiveVersion" in _DISCOVERABLE_TOOLS

    def test_registered_instructions_versions(self):
        assert "Instructions.Versions" in _DISCOVERABLE_TOOLS

    def test_missing_returns_none(self):
        assert _DISCOVERABLE_TOOLS.get("NonExistent") is None

    def test_discoverable_fns_are_callable(self):
        for name, info in _DISCOVERABLE_TOOLS.items():
            assert callable(info.fn), f"{name} fn is not callable"


# ── MCP tool category registry ──────────────────────────────────────────

class TestMCPToolCategories:
    def test_mcp_tools_have_categories(self):
        expected = {
            "NPLSpec": "NPL",
            "ToolSummary": "Discovery",
            "ToolSearch": "Discovery",
            "ToolDefinition": "Discovery",
            "ToolHelp": "Discovery",
            "ToolCall": "Discovery",
            "ToolSession.Generate": "ToolSessions",
            "ToolSession": "ToolSessions",
            "Instructions": "Instructions",
            "Instructions.Create": "Instructions",
            "Instructions.List": "Instructions",
        }
        for name, cat in expected.items():
            assert name in _MCP_TOOL_CATEGORIES, f"{name} missing from MCP categories"
            assert _MCP_TOOL_CATEGORIES[name] == cat, (
                f"{name}: expected {cat!r}, got {_MCP_TOOL_CATEGORIES[name]!r}"
            )


# ── Catalog entry integrity ─────────────────────────────────────────────

class TestCatalogIntegrity:
    @pytest.mark.asyncio
    async def test_secret_in_catalog(self):
        entry = await get_tool_by_name("Secret")
        assert entry is not None
        assert entry["category"] == "Utility"

    @pytest.mark.asyncio
    async def test_rest_in_catalog(self):
        entry = await get_tool_by_name("Rest")
        assert entry is not None
        assert entry["category"] == "Browser"

    @pytest.mark.asyncio
    async def test_utility_category_exists(self):
        cat = await get_category_info("Utility")
        assert cat is not None
        assert cat["tool_count"] >= 1

    @pytest.mark.asyncio
    async def test_discovery_category_has_5_tools(self):
        cat = await get_category_info("Discovery")
        assert cat is not None
        assert cat["tool_count"] == 5

    @pytest.mark.asyncio
    async def test_tool_sessions_category_exists(self):
        cat = await get_category_info("ToolSessions")
        assert cat is not None
        assert cat["tool_count"] == 2

    @pytest.mark.asyncio
    async def test_instructions_category_exists(self):
        cat = await get_category_info("Instructions")
        assert cat is not None
        assert cat["tool_count"] >= 6

    @pytest.mark.asyncio
    async def test_npl_category_exists(self):
        cat = await get_category_info("NPL")
        assert cat is not None
        assert cat["tool_count"] >= 1


# ── call_tool dispatcher ────────────────────────────────────────────────

class TestCallTool:
    @pytest.mark.asyncio
    async def test_call_unknown_raises_key_error(self):
        with pytest.raises(KeyError, match="not found"):
            await call_tool("NonExistent")

    @pytest.mark.asyncio
    async def test_call_stub_raises_key_error(self):
        """Stub tools are in catalog but not in discoverable registry."""
        with pytest.raises(KeyError):
            await call_tool("dump_files")
