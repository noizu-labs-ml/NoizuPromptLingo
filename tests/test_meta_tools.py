"""Tests for meta tools: ToolSummary and ToolSearch."""

import json
from unittest.mock import AsyncMock, patch

import httpx
import pytest

from npl_mcp.meta_tools.catalog import CATEGORIES, TOOL_CATALOG, EXPOSED_TOOL_NAMES
from npl_mcp.meta_tools.summary import tool_summary
from npl_mcp.meta_tools.search import tool_search


# ---------------------------------------------------------------------------
# Catalog integrity
# ---------------------------------------------------------------------------

class TestCatalogIntegrity:
    """Verify the full catalog is well-formed."""

    def test_categories_not_empty(self):
        assert len(CATEGORIES) >= 9

    def test_every_category_has_fields(self):
        for cat in CATEGORIES:
            assert "name" in cat
            assert "description" in cat
            assert "tool_count" in cat
            assert cat["tool_count"] > 0

    def test_catalog_not_empty(self):
        assert len(TOOL_CATALOG) > 0

    def test_every_tool_has_required_fields(self):
        for tool in TOOL_CATALOG:
            assert "name" in tool and tool["name"], f"Tool missing name: {tool}"
            assert "category" in tool and tool["category"], f"Tool {tool['name']} missing category"
            assert "description" in tool and tool["description"], f"Tool {tool['name']} missing description"
            assert "parameters" in tool, f"Tool {tool['name']} missing parameters"

    def test_every_tool_has_valid_category(self):
        category_names = {c["name"] for c in CATEGORIES}
        for tool in TOOL_CATALOG:
            assert tool["category"] in category_names, (
                f"Tool {tool['name']} has unknown category {tool['category']!r}. "
                f"Valid: {category_names}"
            )

    def test_category_tool_counts_match(self):
        actual_counts = {}
        for tool in TOOL_CATALOG:
            actual_counts[tool["category"]] = actual_counts.get(tool["category"], 0) + 1

        # For parent categories (like Browser), sum their subcategories
        parent_sums: dict[str, int] = {}
        for cat_name, count in actual_counts.items():
            root = cat_name.split(".")[0]
            if root != cat_name:
                parent_sums[root] = parent_sums.get(root, 0) + count

        for cat in CATEGORIES:
            name = cat["name"]
            if name in parent_sums and name not in actual_counts:
                actual = parent_sums[name]
            elif name in parent_sums and name in actual_counts:
                actual = actual_counts[name] + parent_sums[name]
            else:
                actual = actual_counts.get(name, 0)
            assert actual == cat["tool_count"], (
                f"Category {name!r}: declared {cat['tool_count']} tools but catalog has {actual}"
            )

    def test_no_duplicate_tool_names(self):
        names = [t["name"] for t in TOOL_CATALOG]
        assert len(names) == len(set(names)), f"Duplicate names: {[n for n in names if names.count(n) > 1]}"

    def test_parameters_well_formed(self):
        for tool in TOOL_CATALOG:
            for param in tool["parameters"]:
                assert "name" in param, f"Tool {tool['name']} has param without name"
                assert "type" in param, f"Tool {tool['name']} param {param.get('name')} missing type"
                assert "required" in param, f"Tool {tool['name']} param {param['name']} missing required"
                assert "description" in param, f"Tool {tool['name']} param {param['name']} missing description"

    def test_exposed_tools_exist_in_catalog(self):
        catalog_names = {t["name"] for t in TOOL_CATALOG}
        for name in EXPOSED_TOOL_NAMES:
            assert name in catalog_names, f"Exposed tool {name!r} not in catalog"

    def test_exposed_tools_are_expected(self):
        assert EXPOSED_TOOL_NAMES == {"ToMarkdown", "Ping", "Download", "Screenshot"}

    def test_exposed_tools_under_browser_category(self):
        for tool in TOOL_CATALOG:
            if tool["name"] in EXPOSED_TOOL_NAMES:
                assert tool["category"] == "Browser", (
                    f"Exposed tool {tool['name']} should be in Browser category, "
                    f"got {tool['category']!r}"
                )

    def test_ping_has_url_param(self):
        ping = next(t for t in TOOL_CATALOG if t["name"] == "Ping")
        param_names = {p["name"] for p in ping["parameters"]}
        assert "url" in param_names

    def test_screenshot_has_resolution_param(self):
        ss = next(t for t in TOOL_CATALOG if t["name"] == "Screenshot")
        param_names = {p["name"] for p in ss["parameters"]}
        assert "resolution" in param_names

    def test_tomarkdown_has_image_params(self):
        tm = next(t for t in TOOL_CATALOG if t["name"] == "ToMarkdown")
        param_names = {p["name"] for p in tm["parameters"]}
        assert "with_image_descriptions" in param_names
        assert "image_model" in param_names
        assert "output" in param_names


# ---------------------------------------------------------------------------
# ToolSummary - default (exposed tools only)
# ---------------------------------------------------------------------------

class TestToolSummary:

    @pytest.mark.asyncio
    async def test_returns_dict(self):
        result = await tool_summary()
        assert isinstance(result, dict)
        assert "total_tools" in result
        assert "tools" in result

    @pytest.mark.asyncio
    async def test_lists_only_exposed_tools(self):
        result = await tool_summary()
        assert result["total_tools"] == len(EXPOSED_TOOL_NAMES)
        tool_names = {t["name"] for t in result["tools"]}
        assert tool_names == EXPOSED_TOOL_NAMES

    @pytest.mark.asyncio
    async def test_exposed_tools_have_parameters(self):
        result = await tool_summary()
        for tool in result["tools"]:
            assert "name" in tool
            assert "description" in tool
            assert "parameters" in tool

    @pytest.mark.asyncio
    async def test_does_not_list_hidden_tools(self):
        result = await tool_summary()
        tool_names = {t["name"] for t in result["tools"]}
        assert "browser_click" not in tool_names
        assert "create_artifact" not in tool_names


# ---------------------------------------------------------------------------
# ToolSummary - category drill-down
# ---------------------------------------------------------------------------

class TestToolSummaryCategory:

    @pytest.mark.asyncio
    async def test_expand_scripts(self):
        result = await tool_summary(category="Scripts")
        assert result["category"] == "Scripts"
        assert result["tool_count"] == 5
        assert "tools" in result

    @pytest.mark.asyncio
    async def test_expand_browser_root(self):
        result = await tool_summary(category="Browser")
        assert result["category"] == "Browser"
        assert result["tool_count"] == 36
        assert "subcategories" in result
        # 4 exposed tools are direct under Browser
        assert "tools" in result
        direct_names = {t["name"] for t in result["tools"]}
        assert EXPOSED_TOOL_NAMES.issubset(direct_names)

    @pytest.mark.asyncio
    async def test_expand_browser_subcategory(self):
        result = await tool_summary(category="Browser.Screenshots")
        assert result["category"] == "Browser.Screenshots"
        assert result["tool_count"] == 3
        assert "tools" in result

    @pytest.mark.asyncio
    async def test_expand_system(self):
        """System category no longer exists."""
        result = await tool_summary(category="System")
        assert "error" in result

    @pytest.mark.asyncio
    async def test_tool_lookup_by_hash(self):
        result = await tool_summary(category="Browser.Screenshots#screenshot_capture")
        assert result["name"] == "screenshot_capture"
        assert result["category"] == "Browser.Screenshots"
        assert "parameters" in result

    @pytest.mark.asyncio
    async def test_tool_lookup_by_hash_exposed(self):
        result = await tool_summary(category="Browser#ToMarkdown")
        assert result["name"] == "ToMarkdown"
        assert "parameters" in result

    @pytest.mark.asyncio
    async def test_tool_lookup_not_found(self):
        result = await tool_summary(category="Scripts#nonexistent_tool")
        assert "error" in result

    @pytest.mark.asyncio
    async def test_unknown_category(self):
        result = await tool_summary(category="Nonexistent")
        assert "error" in result


# ---------------------------------------------------------------------------
# ToolSearch - text mode
# ---------------------------------------------------------------------------

class TestTextSearch:

    @pytest.mark.asyncio
    async def test_exact_name_match(self):
        result = json.loads(await tool_search("ToMarkdown", mode="text"))
        assert result["mode"] == "text"
        assert result["total_matches"] >= 1
        assert result["matches"][0]["name"] == "ToMarkdown"

    @pytest.mark.asyncio
    async def test_substring_match(self):
        result = json.loads(await tool_search("download", mode="text"))
        assert result["total_matches"] >= 1
        for match in result["matches"]:
            assert match["name"] in EXPOSED_TOOL_NAMES

    @pytest.mark.asyncio
    async def test_no_results(self):
        result = json.loads(await tool_search("zzz_nonexistent_zzz", mode="text"))
        assert result["total_matches"] == 0
        assert result["matches"] == []

    @pytest.mark.asyncio
    async def test_hidden_tools_not_returned(self):
        result = json.loads(await tool_search("browser", mode="text"))
        for match in result["matches"]:
            assert match["name"] in EXPOSED_TOOL_NAMES

    @pytest.mark.asyncio
    async def test_limit(self):
        result = json.loads(await tool_search("a", mode="text", limit=1))
        assert len(result["matches"]) <= 1

    @pytest.mark.asyncio
    async def test_ping_searchable(self):
        result = json.loads(await tool_search("Ping", mode="text"))
        assert result["total_matches"] >= 1
        assert any(m["name"] == "Ping" for m in result["matches"])

    @pytest.mark.asyncio
    async def test_screenshot_searchable(self):
        result = json.loads(await tool_search("Screenshot", mode="text"))
        assert result["total_matches"] >= 1
        assert any(m["name"] == "Screenshot" for m in result["matches"])


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
            result = json.loads(await tool_search("view a doc", mode="intent"))
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
            result = json.loads(await tool_search("ToMarkdown", mode="intent"))
            assert result["mode"] == "intent"
            assert result["fallback"] is True

    @pytest.mark.asyncio
    async def test_intent_fallback_on_invalid_json(self):
        with patch(
            "npl_mcp.meta_tools.search.chat_completion",
            new_callable=AsyncMock,
            return_value=_mock_llm_response("not valid json {{{"),
        ):
            result = json.loads(await tool_search("test", mode="intent"))
            assert result["fallback"] is True

    @pytest.mark.asyncio
    async def test_intent_strips_markdown_fences(self):
        llm_result = '```json\n{"matches": []}\n```'
        with patch(
            "npl_mcp.meta_tools.search.chat_completion",
            new_callable=AsyncMock,
            return_value=_mock_llm_response(llm_result),
        ):
            result = json.loads(await tool_search("nothing", mode="intent"))
            assert result["mode"] == "intent"
            assert result["total_matches"] == 0
            assert "fallback" not in result


# ---------------------------------------------------------------------------
# MCP registration
# ---------------------------------------------------------------------------

class TestMCPRegistration:

    def test_only_discovery_tools_registered(self):
        from npl_mcp.launcher import create_app
        mcp = create_app()
        tool_names = set(mcp._tool_manager._tools.keys())
        assert tool_names == {"ToolSummary", "ToolSearch"}


# ---------------------------------------------------------------------------
# Image description caching
# ---------------------------------------------------------------------------

class TestImageDescriptions:

    def test_cache_roundtrip(self, tmp_path):
        from npl_mcp.markdown.image_descriptions import ImageDescriptionCache

        cache_file = tmp_path / "img_cache.yaml"
        cache = ImageDescriptionCache(cache_file)

        assert cache.get("https://example.com/img.png", "openai/GPT5.2") is None

        cache.set("https://example.com/img.png", "openai/GPT5.2", "A cat sitting on a mat.")
        assert cache.get("https://example.com/img.png", "openai/GPT5.2") == "A cat sitting on a mat."

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
