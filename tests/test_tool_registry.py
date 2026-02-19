"""Tests for meta_tools/tool_registry.py and pin.py integration."""

from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from npl_mcp.meta_tools.tool_registry import (
    _IMPLEMENTATIONS,
    register_implementation,
    get_implementation,
)


# ── Registry basics ──────────────────────────────────────────────────────

class TestToolRegistry:
    def test_auto_registered_to_markdown(self):
        assert "ToMarkdown" in _IMPLEMENTATIONS

    def test_auto_registered_ping(self):
        assert "Ping" in _IMPLEMENTATIONS

    def test_auto_registered_download(self):
        assert "Download" in _IMPLEMENTATIONS

    def test_auto_registered_screenshot(self):
        assert "Screenshot" in _IMPLEMENTATIONS

    def test_auto_registered_secret(self):
        assert "Secret" in _IMPLEMENTATIONS

    def test_auto_registered_rest(self):
        assert "Rest" in _IMPLEMENTATIONS

    def test_auto_registered_tool_session_generate(self):
        assert "ToolSession.Generate" in _IMPLEMENTATIONS

    def test_auto_registered_tool_session(self):
        assert "ToolSession" in _IMPLEMENTATIONS

    def test_auto_registered_instructions(self):
        assert "Instructions" in _IMPLEMENTATIONS

    def test_auto_registered_instructions_create(self):
        assert "Instructions.Create" in _IMPLEMENTATIONS

    def test_auto_registered_instructions_update(self):
        assert "Instructions.Update" in _IMPLEMENTATIONS

    def test_auto_registered_instructions_active_version(self):
        assert "Instructions.ActiveVersion" in _IMPLEMENTATIONS

    def test_auto_registered_instructions_versions(self):
        assert "Instructions.Versions" in _IMPLEMENTATIONS

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
        assert len(TOOL_CATALOG) == 124

    def test_tool_sessions_category_exists(self):
        from npl_mcp.meta_tools.catalog import get_category_info
        cat = get_category_info("ToolSessions")
        assert cat is not None
        assert cat["tool_count"] == 2

    def test_instructions_category_exists(self):
        from npl_mcp.meta_tools.catalog import get_category_info
        cat = get_category_info("Instructions")
        assert cat is not None
        assert cat["tool_count"] == 6

    def test_exposed_tools_are_non_discovery(self):
        from npl_mcp.meta_tools.catalog import EXPOSED_TOOL_NAMES
        assert EXPOSED_TOOL_NAMES == {
            "ToMarkdown", "Ping", "Download", "Screenshot", "Secret", "Rest",
            "ToolSession", "ToolSession.Generate",
            "Instructions", "Instructions.Create", "Instructions.Update",
            "Instructions.ActiveVersion", "Instructions.Versions",
            "Instructions.List",
        }
