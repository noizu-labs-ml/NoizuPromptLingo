"""Tests for meta_tools/tool_registry.py and pin.py integration."""

from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from npl_mcp.meta_tools.tool_registry import (
    _IMPLEMENTATIONS,
    register_implementation,
    get_implementation,
)
from npl_mcp.meta_tools.pin import (
    tool_pin,
    _pin_tool,
    _unpin_tool,
    create_catalog_tool,
    CatalogStubTool,
)


# ── Registry basics ──────────────────────────────────────────────────────

class TestToolRegistry:
    def test_auto_registered_secret(self):
        assert "Secret" in _IMPLEMENTATIONS

    def test_auto_registered_rest(self):
        assert "Rest" in _IMPLEMENTATIONS

    def test_no_secret_get(self):
        assert "SecretGet" not in _IMPLEMENTATIONS

    def test_get_missing_returns_none(self):
        assert get_implementation("NonExistent") is None

    def test_register_custom(self):
        async def my_fn():
            pass
        register_implementation("CustomTool", my_fn)
        assert get_implementation("CustomTool") is my_fn
        # Cleanup
        del _IMPLEMENTATIONS["CustomTool"]

    def test_implementations_are_callable(self):
        for name, fn in _IMPLEMENTATIONS.items():
            assert callable(fn), f"{name} is not callable"


# ── Pin with real implementation ─────────────────────────────────────────

class TestPinWithImplementation:
    def _make_fastmcp(self, registered: dict | None = None):
        """Create a mock FastMCP with a tool manager."""
        fm = MagicMock()
        fm._tool_manager = MagicMock()
        fm._tool_manager._tools = dict(registered or {})

        def add_tool(tool):
            fm._tool_manager._tools[tool.name] = tool

        fm.add_tool = add_tool
        return fm

    def test_pin_secret_uses_real_impl(self):
        fm = self._make_fastmcp()
        result = _pin_tool("Secret", fm)
        assert result["status"] == "ok"
        tool = fm._tool_manager._tools["Secret"]
        assert not isinstance(tool, CatalogStubTool)

    def test_pin_rest_uses_real_impl(self):
        fm = self._make_fastmcp()
        result = _pin_tool("Rest", fm)
        assert result["status"] == "ok"
        tool = fm._tool_manager._tools["Rest"]
        assert not isinstance(tool, CatalogStubTool)

    def test_pin_unimplemented_gets_stub(self):
        fm = self._make_fastmcp()
        result = _pin_tool("dump_files", fm)
        assert result["status"] == "ok"
        tool = fm._tool_manager._tools["dump_files"]
        assert isinstance(tool, CatalogStubTool)

    def test_pin_already_pinned(self):
        fm = self._make_fastmcp({"Secret": MagicMock()})
        result = _pin_tool("Secret", fm)
        assert result["status"] == "already_pinned"

    def test_pin_unknown_tool(self):
        fm = self._make_fastmcp()
        result = _pin_tool("TotallyFakeTool", fm)
        assert result["status"] == "error"
        assert "not found" in result["message"]


# ── Unpin ────────────────────────────────────────────────────────────────

class TestUnpin:
    def _make_fastmcp(self, registered: dict | None = None):
        fm = MagicMock()
        fm._tool_manager = MagicMock()
        fm._tool_manager._tools = dict(registered or {})

        def remove_tool(name):
            del fm._tool_manager._tools[name]

        fm._tool_manager.remove_tool = remove_tool
        return fm

    def test_unpin_registered(self):
        fm = self._make_fastmcp({"dump_files": MagicMock()})
        result = _unpin_tool("dump_files", fm)
        assert result["status"] == "ok"
        assert "dump_files" not in fm._tool_manager._tools

    def test_unpin_core_tool_rejected(self):
        fm = self._make_fastmcp({"ToolSummary": MagicMock()})
        result = _unpin_tool("ToolSummary", fm)
        assert result["status"] == "error"
        assert "core tool" in result["message"]

    def test_unpin_not_registered(self):
        fm = self._make_fastmcp()
        result = _unpin_tool("dump_files", fm)
        assert result["status"] == "not_pinned"


# ── Catalog entry integrity ──────────────────────────────────────────────

class TestCatalogIntegrity:
    def test_secret_in_catalog(self):
        from npl_mcp.meta_tools.catalog import get_tool_by_name
        entry = get_tool_by_name("Secret")
        assert entry is not None
        assert entry["category"] == "Utility"
        assert len(entry["parameters"]) == 2

    def test_rest_in_catalog(self):
        from npl_mcp.meta_tools.catalog import get_tool_by_name
        entry = get_tool_by_name("Rest")
        assert entry is not None
        assert entry["category"] == "Browser"
        assert len(entry["parameters"]) == 7

    def test_utility_category_exists(self):
        from npl_mcp.meta_tools.catalog import get_category_info
        cat = get_category_info("Utility")
        assert cat is not None
        assert cat["tool_count"] == 1

    def test_discovery_category_exists(self):
        from npl_mcp.meta_tools.catalog import get_category_info
        cat = get_category_info("Discovery")
        assert cat is not None
        assert cat["tool_count"] == 5

    def test_browser_count(self):
        from npl_mcp.meta_tools.catalog import get_category_info
        cat = get_category_info("Browser")
        assert cat is not None
        assert cat["tool_count"] == 37

    def test_total_tool_count(self):
        from npl_mcp.meta_tools.catalog import TOOL_CATALOG
        assert len(TOOL_CATALOG) == 103

    def test_exposed_tools_are_discovery(self):
        from npl_mcp.meta_tools.catalog import EXPOSED_TOOL_NAMES
        assert EXPOSED_TOOL_NAMES == {"ToolSummary", "ToolSearch", "ToolDefinition", "ToolHelp", "ToolPin"}
