"""Tests for meta tools: ToolSummary, ToolSearch, ToolDefinition, ToolHelp."""

import json
from unittest.mock import AsyncMock, patch

import httpx
import pytest

from npl_mcp.meta_tools.catalog import (
    build_catalog,
    invalidate_catalog,
    get_tool_by_name,
    get_categories,
)
from npl_mcp.meta_tools.summary import tool_summary
from npl_mcp.meta_tools.search import tool_search
from npl_mcp.meta_tools.definition import tool_definition
from npl_mcp.meta_tools.help import tool_help
from npl_mcp.meta_tools import inference_cache


# ---------------------------------------------------------------------------
# Catalog integrity
# ---------------------------------------------------------------------------

class TestCatalogIntegrity:
    """Verify the dynamic catalog is well-formed."""

    @pytest.mark.asyncio
    async def test_categories_not_empty(self):
        categories = await get_categories()
        assert len(categories) >= 9

    @pytest.mark.asyncio
    async def test_every_category_has_fields(self):
        categories = await get_categories()
        for cat in categories:
            assert "name" in cat
            assert "description" in cat
            assert "tool_count" in cat
            assert cat["tool_count"] > 0

    @pytest.mark.asyncio
    async def test_catalog_not_empty(self):
        catalog = await build_catalog()
        assert len(catalog) > 0

    @pytest.mark.asyncio
    async def test_every_tool_has_required_fields(self):
        catalog = await build_catalog()
        for tool in catalog:
            assert "name" in tool and tool["name"], f"Tool missing name: {tool}"
            assert "category" in tool and tool["category"], f"Tool {tool['name']} missing category"
            assert "description" in tool, f"Tool {tool['name']} missing description"
            assert "parameters" in tool, f"Tool {tool['name']} missing parameters"

    @pytest.mark.asyncio
    async def test_every_tool_has_valid_category(self):
        catalog = await build_catalog()
        categories = await get_categories()
        category_names = {c["name"] for c in categories}
        for tool in catalog:
            assert tool["category"] in category_names, (
                f"Tool {tool['name']} has unknown category {tool['category']!r}. "
                f"Valid: {category_names}"
            )

    @pytest.mark.asyncio
    async def test_no_duplicate_tool_names(self):
        catalog = await build_catalog()
        names = [t["name"] for t in catalog]
        assert len(names) == len(set(names)), f"Duplicate names: {[n for n in names if names.count(n) > 1]}"

    @pytest.mark.asyncio
    async def test_parameters_well_formed(self):
        catalog = await build_catalog()
        for tool in catalog:
            for param in tool["parameters"]:
                assert "name" in param, f"Tool {tool['name']} has param without name"
                assert "type" in param, f"Tool {tool['name']} param {param.get('name')} missing type"
                assert "required" in param, f"Tool {tool['name']} param {param['name']} missing required"
                assert "description" in param, f"Tool {tool['name']} param {param['name']} missing description"

    @pytest.mark.asyncio
    async def test_ping_has_url_param(self):
        ping = await get_tool_by_name("Ping")
        assert ping is not None
        param_names = {p["name"] for p in ping["parameters"]}
        assert "url" in param_names

    @pytest.mark.asyncio
    async def test_screenshot_has_max_size_params(self):
        ss = await get_tool_by_name("Screenshot")
        assert ss is not None
        param_names = {p["name"] for p in ss["parameters"]}
        assert "max_width" in param_names
        assert "max_height" in param_names

    @pytest.mark.asyncio
    async def test_tomarkdown_has_image_params(self):
        tm = await get_tool_by_name("ToMarkdown")
        assert tm is not None
        param_names = {p["name"] for p in tm["parameters"]}
        assert "with_image_descriptions" in param_names
        assert "image_model" in param_names
        assert "output" in param_names

    @pytest.mark.asyncio
    async def test_mcp_tools_in_catalog(self):
        """All MCP-registered tools appear in the catalog."""
        catalog = await build_catalog()
        catalog_names = {t["name"] for t in catalog}
        expected_mcp = {
            "ToolSummary", "ToolSearch", "ToolDefinition", "ToolHelp", "ToolCall",
            "ToolSession", "ToolSession.Generate",
            "Instructions", "Instructions.Create", "Instructions.List",
            "NPLSpec",
        }
        assert expected_mcp.issubset(catalog_names)

    @pytest.mark.asyncio
    async def test_discoverable_tools_in_catalog(self):
        """All discoverable (hidden) tools appear in the catalog."""
        catalog = await build_catalog()
        catalog_names = {t["name"] for t in catalog}
        expected_discoverable = {
            "ToMarkdown", "Ping", "Download", "Screenshot", "Rest", "Secret",
        }
        assert expected_discoverable.issubset(catalog_names)


# ---------------------------------------------------------------------------
# ToolSummary - default (all non-Discovery tools)
# ---------------------------------------------------------------------------

class TestToolSummary:

    @pytest.mark.asyncio
    async def test_returns_dict(self):
        result = await tool_summary()
        assert isinstance(result, dict)
        assert "total_tools" in result
        assert "categories" in result

    @pytest.mark.asyncio
    async def test_lists_all_non_discovery_tools(self):
        """Default view shows all tools except Discovery category."""
        result = await tool_summary()
        catalog = await build_catalog()
        non_discovery = [t for t in catalog if t["category"] != "Discovery"]
        assert result["total_tools"] == len(non_discovery)

    @pytest.mark.asyncio
    async def test_no_discovery_category(self):
        result = await tool_summary()
        for cat in result["categories"]:
            assert cat["category"] != "Discovery"

    @pytest.mark.asyncio
    async def test_tools_grouped_by_category(self):
        result = await tool_summary()
        assert len(result["categories"]) >= 1
        for cat in result["categories"]:
            assert "category" in cat
            assert "tools" in cat

    @pytest.mark.asyncio
    async def test_tools_omit_parameters(self):
        result = await tool_summary()
        for cat in result["categories"]:
            for tool in cat["tools"]:
                assert "name" in tool
                assert "description" in tool
                assert "parameters" not in tool

    @pytest.mark.asyncio
    async def test_category_has_description(self):
        result = await tool_summary()
        browser_cat = next(
            (c for c in result["categories"] if c["category"] == "Browser"), None
        )
        assert browser_cat is not None
        assert "description" in browser_cat

    @pytest.mark.asyncio
    async def test_no_catalog_categories_in_default(self):
        result = await tool_summary()
        assert "catalog_categories" not in result

    @pytest.mark.asyncio
    async def test_includes_hint(self):
        result = await tool_summary()
        assert "hint" in result


# ---------------------------------------------------------------------------
# ToolSummary - category drill-down
# ---------------------------------------------------------------------------

class TestToolSummaryCategory:

    @pytest.mark.asyncio
    async def test_expand_scripts(self):
        result = await tool_summary(filter="Scripts")
        assert result["category"] == "Scripts"
        assert result["tool_count"] == 5
        assert "tools" in result

    @pytest.mark.asyncio
    async def test_expand_browser_root(self):
        result = await tool_summary(filter="Browser")
        assert result["category"] == "Browser"
        assert result["tool_count"] == 37
        assert "subcategories" in result
        assert "tools" in result
        direct_names = {t["name"] for t in result["tools"]}
        assert {"ToMarkdown", "Ping", "Download", "Screenshot", "Rest"}.issubset(direct_names)

    @pytest.mark.asyncio
    async def test_expand_browser_subcategory(self):
        result = await tool_summary(filter="Browser.Screenshots")
        assert result["category"] == "Browser.Screenshots"
        assert result["tool_count"] == 3
        assert "tools" in result

    @pytest.mark.asyncio
    async def test_expand_system(self):
        """System category no longer exists."""
        result = await tool_summary(filter="System")
        assert "error" in result

    @pytest.mark.asyncio
    async def test_tool_lookup_by_hash(self):
        result = await tool_summary(filter="Browser.Screenshots#screenshot_capture")
        assert result["name"] == "screenshot_capture"
        assert result["category"] == "Browser.Screenshots"
        assert "parameters" in result

    @pytest.mark.asyncio
    async def test_tool_lookup_by_hash_exposed(self):
        result = await tool_summary(filter="Browser#ToMarkdown")
        assert result["name"] == "ToMarkdown"
        assert "parameters" in result

    @pytest.mark.asyncio
    async def test_tool_lookup_not_found(self):
        result = await tool_summary(filter="Scripts#nonexistent_tool")
        assert "error" in result

    @pytest.mark.asyncio
    async def test_unknown_category(self):
        result = await tool_summary(filter="Nonexistent")
        assert "error" in result

    @pytest.mark.asyncio
    async def test_category_tools_omit_parameters(self):
        result = await tool_summary(filter="Scripts")
        for tool in result["tools"]:
            assert "name" in tool
            assert "description" in tool
            assert "parameters" not in tool

    @pytest.mark.asyncio
    async def test_comma_separated_categories(self):
        result = await tool_summary(filter="Scripts,Chat")
        assert "results" in result
        assert len(result["results"]) == 2
        assert result["results"][0]["category"] == "Scripts"
        assert result["results"][1]["category"] == "Chat"

    @pytest.mark.asyncio
    async def test_comma_separated_with_tool_lookup(self):
        result = await tool_summary(filter="Scripts,Browser#ToMarkdown")
        assert "results" in result
        assert len(result["results"]) == 2
        assert result["results"][0]["category"] == "Scripts"
        assert result["results"][1]["name"] == "ToMarkdown"
        assert "parameters" in result["results"][1]

    @pytest.mark.asyncio
    async def test_single_filter_no_results_wrapper(self):
        """Single filter should return directly, not wrapped in results."""
        result = await tool_summary(filter="Scripts")
        assert "results" not in result
        assert result["category"] == "Scripts"


# ---------------------------------------------------------------------------
# ToolSearch - text mode
# ---------------------------------------------------------------------------

class TestTextSearch:

    @pytest.mark.asyncio
    async def test_returns_dict(self):
        result = await tool_search("ToMarkdown", mode="text")
        assert isinstance(result, dict)

    @pytest.mark.asyncio
    async def test_exact_name_match(self):
        result = await tool_search("ToMarkdown", mode="text")
        assert result["mode"] == "text"
        assert result["total_matches"] >= 1
        assert result["matches"][0]["name"] == "ToMarkdown"

    @pytest.mark.asyncio
    async def test_substring_match(self):
        result = await tool_search("download", mode="text")
        assert result["total_matches"] >= 1
        names = {m["name"] for m in result["matches"]}
        assert "Download" in names

    @pytest.mark.asyncio
    async def test_no_results(self):
        result = await tool_search("zzz_nonexistent_zzz", mode="text")
        assert result["total_matches"] == 0
        assert result["matches"] == []

    @pytest.mark.asyncio
    async def test_searches_full_catalog(self):
        result = await tool_search("browser", mode="text")
        names = {m["name"] for m in result["matches"]}
        assert len(names) > 5

    @pytest.mark.asyncio
    async def test_limit(self):
        result = await tool_search("a", mode="text", limit=1)
        assert len(result["matches"]) <= 1

    @pytest.mark.asyncio
    async def test_ping_searchable(self):
        result = await tool_search("Ping", mode="text")
        assert result["total_matches"] >= 1
        assert any(m["name"] == "Ping" for m in result["matches"])

    @pytest.mark.asyncio
    async def test_screenshot_searchable(self):
        result = await tool_search("Screenshot", mode="text")
        assert result["total_matches"] >= 1
        assert any(m["name"] == "Screenshot" for m in result["matches"])

    @pytest.mark.asyncio
    async def test_no_params_without_verbose(self):
        result = await tool_search("ToMarkdown", mode="text")
        for match in result["matches"]:
            assert "parameters" not in match

    @pytest.mark.asyncio
    async def test_params_with_verbose(self):
        result = await tool_search("ToMarkdown", mode="text", verbose=True)
        assert result["total_matches"] >= 1
        assert "parameters" in result["matches"][0]
        assert len(result["matches"][0]["parameters"]) > 0


# ---------------------------------------------------------------------------
# ToolSearch - intent mode
# ---------------------------------------------------------------------------

def _mock_llm_response(matches_json: str) -> dict:
    return {
        "choices": [
            {"message": {"content": matches_json}}
        ]
    }


class TestIntentSearch:

    @pytest.mark.asyncio
    async def test_intent_search_with_mocked_llm(self):
        llm_result = json.dumps({
            "matches": [
                {
                    "name": "ToMarkdown",
                    "category": "Browser",
                    "relevance": "high",
                    "explanation": "Use ToMarkdown to convert the URL to markdown.",
                }
            ]
        })
        with patch(
            "npl_mcp.meta_tools.search.chat_completion",
            new_callable=AsyncMock,
            return_value=_mock_llm_response(llm_result),
        ):
            result = await tool_search("view a doc", mode="intent")
            assert result["mode"] == "intent"
            assert result["total_matches"] >= 1
            assert result["matches"][0]["name"] == "ToMarkdown"
            assert "explanation" in result["matches"][0]
            assert "fallback" not in result

    @pytest.mark.asyncio
    async def test_intent_fallback_on_timeout(self):
        with patch(
            "npl_mcp.meta_tools.search.chat_completion",
            new_callable=AsyncMock,
            side_effect=httpx.TimeoutException("timeout"),
        ):
            result = await tool_search("ToMarkdown", mode="intent")
            assert result["mode"] == "intent"
            assert result["fallback"] is True

    @pytest.mark.asyncio
    async def test_intent_fallback_on_invalid_json(self):
        with patch(
            "npl_mcp.meta_tools.search.chat_completion",
            new_callable=AsyncMock,
            return_value=_mock_llm_response("not valid json {{{"),
        ):
            result = await tool_search("test", mode="intent")
            assert result["fallback"] is True

    @pytest.mark.asyncio
    async def test_intent_strips_markdown_fences(self):
        llm_result = '```json\n{"matches": []}\n```'
        with patch(
            "npl_mcp.meta_tools.search.chat_completion",
            new_callable=AsyncMock,
            return_value=_mock_llm_response(llm_result),
        ):
            result = await tool_search("nothing", mode="intent")
            assert result["mode"] == "intent"
            assert result["total_matches"] == 0
            assert "fallback" not in result

    @pytest.mark.asyncio
    async def test_intent_no_params_without_verbose(self):
        llm_result = json.dumps({
            "matches": [
                {
                    "name": "ToMarkdown",
                    "category": "Browser",
                    "relevance": "high",
                    "explanation": "Converts URLs to markdown.",
                }
            ]
        })
        with patch(
            "npl_mcp.meta_tools.search.chat_completion",
            new_callable=AsyncMock,
            return_value=_mock_llm_response(llm_result),
        ):
            result = await tool_search("convert page", mode="intent")
            for match in result["matches"]:
                assert "parameters" not in match

    @pytest.mark.asyncio
    async def test_intent_params_with_verbose(self):
        llm_result = json.dumps({
            "matches": [
                {
                    "name": "ToMarkdown",
                    "category": "Browser",
                    "relevance": "high",
                    "explanation": "Converts URLs to markdown.",
                }
            ]
        })
        with patch(
            "npl_mcp.meta_tools.search.chat_completion",
            new_callable=AsyncMock,
            return_value=_mock_llm_response(llm_result),
        ):
            result = await tool_search("convert page", mode="intent", verbose=True)
            assert "parameters" in result["matches"][0]


# ---------------------------------------------------------------------------
# MCP registration
# ---------------------------------------------------------------------------

class TestMCPRegistration:

    @pytest.mark.asyncio
    async def test_only_discovery_and_registered_tools_registered(self, _mcp_app):
        tools = await _mcp_app.list_tools()
        tool_names = {t.name for t in tools}
        assert tool_names == {
            "ToolSummary", "ToolSearch", "ToolDefinition", "ToolHelp", "ToolCall",
            "ToolSession", "ToolSession.Generate", "Instructions", "Instructions.Create",
            "Instructions.List", "NPLSpec",
        }


# ---------------------------------------------------------------------------
# ToolDefinition - batch tool lookup
# ---------------------------------------------------------------------------

class TestToolDefinition:

    @pytest.mark.asyncio
    async def test_single_tool(self):
        result = await tool_definition(["Ping"])
        assert len(result["definitions"]) == 1
        defn = result["definitions"][0]
        assert defn["name"] == "Ping"
        assert defn["category"] == "Browser"
        assert "parameters" in defn
        assert "not_found" not in result

    @pytest.mark.asyncio
    async def test_multiple_tools(self):
        result = await tool_definition(["Ping", "ToMarkdown", "Download"])
        assert len(result["definitions"]) == 3
        names = [d["name"] for d in result["definitions"]]
        assert names == ["Ping", "ToMarkdown", "Download"]

    @pytest.mark.asyncio
    async def test_not_found(self):
        result = await tool_definition(["nonexistent_xyz"])
        assert len(result["definitions"]) == 0
        assert result["not_found"] == ["nonexistent_xyz"]

    @pytest.mark.asyncio
    async def test_mixed_found_and_not_found(self):
        result = await tool_definition(["Ping", "no_such_tool", "Screenshot"])
        assert len(result["definitions"]) == 2
        assert result["definitions"][0]["name"] == "Ping"
        assert result["definitions"][1]["name"] == "Screenshot"
        assert result["not_found"] == ["no_such_tool"]

    @pytest.mark.asyncio
    async def test_empty_list(self):
        result = await tool_definition([])
        assert result["definitions"] == []
        assert "not_found" not in result

    @pytest.mark.asyncio
    async def test_includes_full_parameters(self):
        result = await tool_definition(["ToMarkdown"])
        defn = result["definitions"][0]
        assert len(defn["parameters"]) > 0
        param = defn["parameters"][0]
        assert "name" in param
        assert "type" in param
        assert "required" in param
        assert "description" in param

    @pytest.mark.asyncio
    async def test_hidden_tools_accessible(self):
        """ToolDefinition can look up any catalog tool, not just MCP-registered ones."""
        result = await tool_definition(["browser_click", "create_artifact"])
        assert len(result["definitions"]) == 2
        assert result["definitions"][0]["name"] == "browser_click"
        assert result["definitions"][1]["name"] == "create_artifact"


# ---------------------------------------------------------------------------
# ToolCall - dispatch to catalog tool implementations
# ---------------------------------------------------------------------------

class TestToolCall:
    """Test ToolCall dispatches to catalog tool implementations."""

    @pytest.mark.asyncio
    async def test_call_implemented_tool(self, _mcp_app):
        """ToolCall dispatches to a real implementation and returns its result."""
        mock_result = {"url": "https://example.com", "status_code": 200, "response_time_ms": 42.0}
        with patch(
            "npl_mcp.meta_tools.catalog.call_tool",
            new_callable=AsyncMock,
            return_value=mock_result,
        ):
            tool = await _mcp_app.get_tool("ToolCall")
            result = await tool.run({"tool": "Ping", "arguments": {"url": "https://example.com"}})
            data = json.loads(result.content[0].text)
            assert data["status_code"] == 200
            assert data["url"] == "https://example.com"

    @pytest.mark.asyncio
    async def test_call_unknown_tool(self, _mcp_app):
        """ToolCall returns error for tools not in catalog."""
        tool = await _mcp_app.get_tool("ToolCall")
        result = await tool.run({"tool": "nonexistent_xyz"})
        data = json.loads(result.content[0].text)
        assert data["status"] == "error"
        assert "not found" in data["message"]

    @pytest.mark.asyncio
    async def test_call_stub_tool(self, _mcp_app):
        """ToolCall returns stub status for tools without implementation."""
        tool = await _mcp_app.get_tool("ToolCall")
        result = await tool.run({"tool": "dump_files", "arguments": {"path": "/tmp"}})
        data = json.loads(result.content[0].text)
        assert data["status"] == "stub"
        assert "no implementation" in data["message"].lower()

    @pytest.mark.asyncio
    async def test_call_bad_arguments(self, _mcp_app):
        """ToolCall returns error when arguments don't match the function signature."""
        tool = await _mcp_app.get_tool("ToolCall")
        result = await tool.run({"tool": "Ping", "arguments": {"bad_param": "value"}})
        data = json.loads(result.content[0].text)
        assert data["status"] == "error"

    @pytest.mark.asyncio
    async def test_call_no_arguments(self, _mcp_app):
        """ToolCall with no arguments passes empty dict."""
        mock_result = {"error": "missing url"}
        with patch(
            "npl_mcp.meta_tools.catalog.call_tool",
            new_callable=AsyncMock,
            return_value=mock_result,
        ):
            tool = await _mcp_app.get_tool("ToolCall")
            result = await tool.run({"tool": "Ping"})
            data = json.loads(result.content[0].text)
            assert data is not None

    @pytest.mark.asyncio
    async def test_call_runtime_error(self, _mcp_app):
        """ToolCall catches non-TypeError exceptions from implementations."""
        with patch(
            "npl_mcp.meta_tools.catalog.call_tool",
            new_callable=AsyncMock,
            side_effect=ConnectionError("network down"),
        ):
            tool = await _mcp_app.get_tool("ToolCall")
            result = await tool.run({"tool": "Ping", "arguments": {"url": "https://example.com"}})
            data = json.loads(result.content[0].text)
            assert data["status"] == "error"
            assert "ConnectionError" in data["message"]

    @pytest.mark.asyncio
    async def test_toolcall_in_catalog(self):
        """ToolCall appears in the catalog under Discovery."""
        entry = await get_tool_by_name("ToolCall")
        assert entry is not None
        assert entry["category"] == "Discovery"
        param_names = {p["name"] for p in entry["parameters"]}
        assert "tool" in param_names
        assert "arguments" in param_names


# ---------------------------------------------------------------------------
# Inference cache
# ---------------------------------------------------------------------------

class TestInferenceCache:

    def test_cache_miss(self):
        key = inference_cache.cache_key("test", "query")
        assert inference_cache.cache_get(key) is None

    def test_cache_hit(self):
        key = inference_cache.cache_key("test", "query")
        inference_cache.cache_set(key, {"result": 42})
        assert inference_cache.cache_get(key) == {"result": 42}

    def test_catalog_version_is_stable(self):
        v1 = inference_cache._get_catalog_version()
        v2 = inference_cache._get_catalog_version()
        assert v1 == v2

    def test_catalog_version_included_in_key(self):
        key = inference_cache.cache_key("intent_search", "hello")
        version = inference_cache._get_catalog_version()
        assert key.startswith(version + "|")

    def test_different_params_different_keys(self):
        k1 = inference_cache.cache_key("intent_search", "query_a", "10")
        k2 = inference_cache.cache_key("intent_search", "query_b", "10")
        assert k1 != k2

    def test_cache_clear(self):
        key = inference_cache.cache_key("test", "data")
        inference_cache.cache_set(key, "value")
        assert inference_cache.cache_get(key) == "value"
        inference_cache.cache_clear()
        assert inference_cache.cache_get(key) is None

    def test_invalidation_changes_version(self):
        """Invalidating the catalog increments the version counter."""
        v1 = inference_cache._get_catalog_version()
        invalidate_catalog()
        v2 = inference_cache._get_catalog_version()
        assert v1 != v2


# ---------------------------------------------------------------------------
# Intent search caching integration
# ---------------------------------------------------------------------------

class TestIntentSearchCaching:

    @pytest.mark.asyncio
    async def test_second_call_uses_cache(self):
        """LLM should only be called once for the same query."""
        llm_result = json.dumps({
            "matches": [
                {
                    "name": "ToMarkdown",
                    "category": "Browser",
                    "relevance": "high",
                    "explanation": "Converts to markdown.",
                }
            ]
        })
        with patch(
            "npl_mcp.meta_tools.search.chat_completion",
            new_callable=AsyncMock,
            return_value=_mock_llm_response(llm_result),
        ) as mock_llm:
            r1 = await tool_search("cache test query", mode="intent")
            r2 = await tool_search("cache test query", mode="intent")
            assert mock_llm.call_count == 1
            assert r1["matches"][0]["name"] == r2["matches"][0]["name"]

    @pytest.mark.asyncio
    async def test_different_queries_not_cached(self):
        llm_result = json.dumps({"matches": []})
        with patch(
            "npl_mcp.meta_tools.search.chat_completion",
            new_callable=AsyncMock,
            return_value=_mock_llm_response(llm_result),
        ) as mock_llm:
            await tool_search("query alpha", mode="intent")
            await tool_search("query beta", mode="intent")
            assert mock_llm.call_count == 2

    @pytest.mark.asyncio
    async def test_fallback_not_cached(self):
        """Failed LLM calls should not populate the cache."""
        with patch(
            "npl_mcp.meta_tools.search.chat_completion",
            new_callable=AsyncMock,
            side_effect=httpx.TimeoutException("timeout"),
        ) as mock_llm:
            r1 = await tool_search("fail query", mode="intent")
            assert r1["fallback"] is True
            r2 = await tool_search("fail query", mode="intent")
            assert mock_llm.call_count == 2


# ---------------------------------------------------------------------------
# ToolHelp
# ---------------------------------------------------------------------------

class TestToolHelp:

    @pytest.mark.asyncio
    async def test_help_with_mocked_llm(self):
        with patch(
            "npl_mcp.meta_tools.help.chat_completion",
            new_callable=AsyncMock,
            return_value=_mock_llm_response(
                "Use `ToMarkdown` with `source` param set to the URL."
            ),
        ):
            result = await tool_help("ToMarkdown", "convert a webpage to markdown")
            assert result["tool"] == "ToMarkdown"
            assert result["category"] == "Browser"
            assert result["task"] == "convert a webpage to markdown"
            assert "instructions" in result
            assert "ToMarkdown" in result["instructions"]
            assert "status" not in result

    @pytest.mark.asyncio
    async def test_help_unknown_tool(self):
        result = await tool_help("nonexistent_xyz", "do something")
        assert result["status"] == "error"
        assert "not found" in result["message"]

    @pytest.mark.asyncio
    async def test_help_caches_successful_result(self):
        with patch(
            "npl_mcp.meta_tools.help.chat_completion",
            new_callable=AsyncMock,
            return_value=_mock_llm_response("Step 1: do this."),
        ) as mock_llm:
            r1 = await tool_help("Ping", "check if site is up")
            r2 = await tool_help("Ping", "check if site is up")
            assert mock_llm.call_count == 1
            assert r1["instructions"] == r2["instructions"]

    @pytest.mark.asyncio
    async def test_help_different_verbose_not_cached_together(self):
        with patch(
            "npl_mcp.meta_tools.help.chat_completion",
            new_callable=AsyncMock,
            return_value=_mock_llm_response("Instructions here."),
        ) as mock_llm:
            await tool_help("Ping", "check site", verbose=1)
            await tool_help("Ping", "check site", verbose=3)
            assert mock_llm.call_count == 2

    @pytest.mark.asyncio
    async def test_help_llm_failure(self):
        with patch(
            "npl_mcp.meta_tools.help.chat_completion",
            new_callable=AsyncMock,
            side_effect=httpx.TimeoutException("timeout"),
        ):
            result = await tool_help("Ping", "check site")
            assert result["status"] == "error"
            assert "TimeoutException" in result["message"]

    @pytest.mark.asyncio
    async def test_help_failure_not_cached(self):
        with patch(
            "npl_mcp.meta_tools.help.chat_completion",
            new_callable=AsyncMock,
            side_effect=httpx.TimeoutException("timeout"),
        ) as mock_llm:
            await tool_help("Ping", "check site fail")
            await tool_help("Ping", "check site fail")
            assert mock_llm.call_count == 2

    @pytest.mark.asyncio
    async def test_help_verbose_clamped(self):
        """Verbose values outside 1-3 should be clamped."""
        with patch(
            "npl_mcp.meta_tools.help.chat_completion",
            new_callable=AsyncMock,
            return_value=_mock_llm_response("Brief help."),
        ):
            r1 = await tool_help("Ping", "check", verbose=0)
            assert r1["verbose"] == 1
            r2 = await tool_help("Ping", "check", verbose=99)
            assert r2["verbose"] == 3

    @pytest.mark.asyncio
    async def test_help_hidden_tool_accessible(self):
        """ToolHelp works for any catalog tool, not just MCP-registered ones."""
        with patch(
            "npl_mcp.meta_tools.help.chat_completion",
            new_callable=AsyncMock,
            return_value=_mock_llm_response("Click the element using selector."),
        ):
            result = await tool_help("browser_click", "click a button")
            assert result["tool"] == "browser_click"
            assert "instructions" in result


# ---------------------------------------------------------------------------
# Image description caching
# ---------------------------------------------------------------------------

class TestImageDescriptions:

    def test_cache_roundtrip(self, tmp_path):
        from npl_mcp.markdown.image_descriptions import ImageDescriptionCache

        cache_file = tmp_path / "img_cache.yaml"
        cache = ImageDescriptionCache(cache_file)

        assert cache.get("https://example.com/img.png", "openai/gpt-5-mini") is None

        cache.set("https://example.com/img.png", "openai/gpt-5-mini", "A cat sitting on a mat.")
        assert cache.get("https://example.com/img.png", "openai/gpt-5-mini") == "A cat sitting on a mat."

        # Different model = different key
        assert cache.get("https://example.com/img.png", "other-model") is None

    def test_cache_persists_to_yaml(self, tmp_path):
        from npl_mcp.markdown.image_descriptions import ImageDescriptionCache

        cache_file = tmp_path / "img_cache.yaml"
        cache1 = ImageDescriptionCache(cache_file)
        cache1.set("https://example.com/img.png", "m1", "description1")

        # New instance reads from same file
        cache2 = ImageDescriptionCache(cache_file)
        assert cache2.get("https://example.com/img.png", "m1") == "description1"

    @pytest.mark.asyncio
    async def test_inject_with_mocked_llm(self, tmp_path):
        from npl_mcp.markdown.image_descriptions import inject_image_descriptions

        md = "# Hello\n\n![logo](https://example.com/logo.png)\n\nSome text."

        with patch(
            "npl_mcp.markdown.image_descriptions.describe_image",
            new_callable=AsyncMock,
            return_value="Company logo with blue text",
        ) as mock_describe:
            result = await inject_image_descriptions(
                md, model="test-model", cache_file=tmp_path / "cache.yaml"
            )
            mock_describe.assert_called_once_with(
                "https://example.com/logo.png", model="test-model"
            )

        assert "![logo](https://example.com/logo.png)" in result
        assert "> **Image**: Company logo with blue text" in result

    @pytest.mark.asyncio
    async def test_inject_uses_cache_on_second_call(self, tmp_path):
        from npl_mcp.markdown.image_descriptions import inject_image_descriptions

        md = "![img](https://example.com/a.png)"
        cache_file = tmp_path / "cache.yaml"

        with patch(
            "npl_mcp.markdown.image_descriptions.describe_image",
            new_callable=AsyncMock,
            return_value="First call result",
        ) as mock_describe:
            await inject_image_descriptions(md, model="m1", cache_file=cache_file)
            assert mock_describe.call_count == 1

            # Second call should use cache, not call LLM
            await inject_image_descriptions(md, model="m1", cache_file=cache_file)
            assert mock_describe.call_count == 1  # Still 1, cache hit

    @pytest.mark.asyncio
    async def test_inject_no_images_unchanged(self, tmp_path):
        from npl_mcp.markdown.image_descriptions import inject_image_descriptions

        md = "# No images here\n\nJust text."
        result = await inject_image_descriptions(
            md, cache_file=tmp_path / "cache.yaml"
        )
        assert result == md

    @pytest.mark.asyncio
    async def test_inject_graceful_on_llm_failure(self, tmp_path):
        from npl_mcp.markdown.image_descriptions import inject_image_descriptions

        md = "![broken](https://example.com/fail.png)"

        with patch(
            "npl_mcp.markdown.image_descriptions.describe_image",
            new_callable=AsyncMock,
            side_effect=httpx.TimeoutException("timeout"),
        ):
            result = await inject_image_descriptions(
                md, cache_file=tmp_path / "cache.yaml"
            )
            # Image preserved, no description injected
            assert "![broken](https://example.com/fail.png)" in result
            assert "**Image**" not in result
