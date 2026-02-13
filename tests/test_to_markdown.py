"""Tests for the ToMarkdown tool (browser/to_markdown.py)."""

from pathlib import Path
from unittest.mock import AsyncMock, patch, MagicMock

import httpx
import pytest

from npl_mcp.browser.to_markdown import (
    _classify_source,
    _resolve_source,
    _strip_metadata_header,
    to_markdown,
)


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

SAMPLE_MARKDOWN = """\
# Welcome

Introduction paragraph.

## API Reference

API details here.

### Endpoints

- GET /users
- POST /users

## FAQ

Common questions.
"""

CONVERTER_RESPONSE = """\
success: true
source: https://example.com
source_type: url
cached: false
cache_file: .tmp/cache/markdown/example.com.index.abc123.md
content_length: 100
---
# Example Page

Some content here.

![logo](https://example.com/logo.png)
"""


# ---------------------------------------------------------------------------
# _strip_metadata_header
# ---------------------------------------------------------------------------


class TestStripMetadataHeader:
    def test_strips_yaml_header(self):
        result = _strip_metadata_header(CONVERTER_RESPONSE)
        assert result.startswith("# Example Page")
        assert "success: true" not in result

    def test_no_header(self):
        plain = "# Just markdown\n\nContent."
        result = _strip_metadata_header(plain)
        assert result == plain

    def test_preserves_content_after_separator(self):
        result = _strip_metadata_header(CONVERTER_RESPONSE)
        assert "![logo]" in result


# ---------------------------------------------------------------------------
# _classify_source
# ---------------------------------------------------------------------------


class TestClassifySource:
    def test_url(self):
        assert _classify_source("https://example.com", "") == "url"
        assert _classify_source("http://localhost:8080/page", "") == "url"

    def test_raw_markdown(self):
        assert _classify_source("# Hello World", "") == "raw_markdown"
        assert _classify_source("Some plain text", "") == "raw_markdown"

    def test_file(self, tmp_path):
        f = tmp_path / "test.md"
        f.write_text("# Test")
        assert _classify_source(str(f), "") == "file"


# ---------------------------------------------------------------------------
# _resolve_source - raw markdown
# ---------------------------------------------------------------------------


class TestResolveSourceRaw:
    async def test_raw_string_passthrough(self):
        result = await _resolve_source("# Hello\n\nWorld")
        assert result == "# Hello\n\nWorld"

    async def test_non_existent_path_treated_as_raw(self):
        result = await _resolve_source("This is just text, not a path")
        assert result == "This is just text, not a path"


# ---------------------------------------------------------------------------
# _resolve_source - local files
# ---------------------------------------------------------------------------


class TestResolveSourceFile:
    async def test_markdown_file_read_directly(self, tmp_path):
        f = tmp_path / "doc.md"
        f.write_text(SAMPLE_MARKDOWN)
        result = await _resolve_source(str(f))
        assert "# Welcome" in result
        assert "## API Reference" in result

    async def test_txt_file_read_directly(self, tmp_path):
        f = tmp_path / "notes.txt"
        f.write_text("plain text content")
        result = await _resolve_source(str(f))
        assert result == "plain text content"

    async def test_html_file_goes_through_converter(self, tmp_path):
        f = tmp_path / "page.html"
        f.write_text("<h1>Title</h1><p>Body</p>")

        with patch(
            "npl_mcp.browser.to_markdown.MarkdownConverter"
        ) as MockConverter:
            mock_instance = MagicMock()
            mock_instance.convert = AsyncMock(
                return_value="meta: data\n---\n# Title\n\nBody"
            )
            MockConverter.return_value = mock_instance
            result = await _resolve_source(str(f))

        assert "# Title" in result
        assert "meta: data" not in result

    async def test_pdf_file_goes_through_converter(self, tmp_path):
        f = tmp_path / "doc.pdf"
        f.write_bytes(b"fake pdf content")

        with patch(
            "npl_mcp.browser.to_markdown.MarkdownConverter"
        ) as MockConverter:
            mock_instance = MagicMock()
            mock_instance.convert = AsyncMock(
                return_value="meta: x\n---\n## Page 1\n\nPDF text"
            )
            MockConverter.return_value = mock_instance
            result = await _resolve_source(str(f))

        assert "## Page 1" in result


# ---------------------------------------------------------------------------
# _resolve_source - URLs
# ---------------------------------------------------------------------------


class TestResolveSourceURL:
    async def test_url_goes_through_converter(self):
        with patch(
            "npl_mcp.browser.to_markdown.MarkdownConverter"
        ) as MockConverter:
            mock_instance = MagicMock()
            mock_instance.convert = AsyncMock(return_value=CONVERTER_RESPONSE)
            MockConverter.return_value = mock_instance
            result = await _resolve_source("https://example.com")

        assert "# Example Page" in result
        assert "success: true" not in result


# ---------------------------------------------------------------------------
# to_markdown - basic conversion
# ---------------------------------------------------------------------------


class TestToMarkdownBasic:
    async def test_raw_markdown_passthrough(self):
        result = await to_markdown(SAMPLE_MARKDOWN)
        assert result["source_type"] == "raw_markdown"
        assert result["content"] == SAMPLE_MARKDOWN
        assert result["content_length"] == len(SAMPLE_MARKDOWN)
        assert "output_file" not in result

    async def test_file_source(self, tmp_path):
        f = tmp_path / "doc.md"
        f.write_text(SAMPLE_MARKDOWN)
        result = await to_markdown(str(f))
        assert result["source_type"] == "file"
        assert "# Welcome" in result["content"]

    async def test_url_source(self):
        with patch(
            "npl_mcp.browser.to_markdown.MarkdownConverter"
        ) as MockConverter:
            mock_instance = MagicMock()
            mock_instance.convert = AsyncMock(return_value=CONVERTER_RESPONSE)
            MockConverter.return_value = mock_instance
            result = await to_markdown("https://example.com")

        assert result["source_type"] == "url"
        assert "# Example Page" in result["content"]


# ---------------------------------------------------------------------------
# to_markdown - filtering
# ---------------------------------------------------------------------------


class TestToMarkdownFilter:
    async def test_filter_section(self):
        result = await to_markdown(SAMPLE_MARKDOWN, filter="API Reference")
        content = result["content"]
        # In context mode (filtered_only=False), all sections present
        # but non-matched are collapsed
        assert "API Reference" in content

    async def test_filter_bare_mode(self):
        result = await to_markdown(
            SAMPLE_MARKDOWN, filter="API Reference", filtered_only=True
        )
        content = result["content"]
        assert "API Reference" in content
        # In bare mode, only the matched section appears
        assert "# Welcome" not in content
        assert "## FAQ" not in content

    async def test_filter_nonexistent_section(self):
        result = await to_markdown(SAMPLE_MARKDOWN, filter="Nonexistent")
        content = result["content"]
        assert "not found" in content.lower() or "error" in content.lower()


# ---------------------------------------------------------------------------
# to_markdown - collapsing
# ---------------------------------------------------------------------------


class TestToMarkdownCollapse:
    async def test_collapse_depth(self):
        result = await to_markdown(SAMPLE_MARKDOWN, collapsed_depth=1)
        content = result["content"]
        # Level 1 should be expanded, level 2+ collapsed
        assert "# Welcome" in content
        # Level 2 headings should have collapse marker
        assert "\U0001F4E6" in content  # 📦

    async def test_collapse_depth_2(self):
        result = await to_markdown(SAMPLE_MARKDOWN, collapsed_depth=2)
        content = result["content"]
        # Level 1 and 2 expanded, level 3+ collapsed
        assert "## API Reference" in content
        assert "### Endpoints \U0001F4E6" in content


# ---------------------------------------------------------------------------
# to_markdown - output to file
# ---------------------------------------------------------------------------


class TestToMarkdownOutput:
    async def test_write_to_file(self, tmp_path):
        out = tmp_path / "output.md"
        result = await to_markdown(SAMPLE_MARKDOWN, output=str(out))
        assert result["output_file"] == str(out)
        assert "content" not in result
        assert out.read_text() == SAMPLE_MARKDOWN

    async def test_write_creates_parent_dirs(self, tmp_path):
        out = tmp_path / "deep" / "nested" / "output.md"
        result = await to_markdown(SAMPLE_MARKDOWN, output=str(out))
        assert out.exists()
        assert out.read_text() == SAMPLE_MARKDOWN

    async def test_write_with_filter(self, tmp_path):
        out = tmp_path / "filtered.md"
        result = await to_markdown(
            SAMPLE_MARKDOWN, filter="API Reference", filtered_only=True, output=str(out)
        )
        content = out.read_text()
        assert "API Reference" in content
        assert "# Welcome" not in content


# ---------------------------------------------------------------------------
# to_markdown - image descriptions
# ---------------------------------------------------------------------------


class TestToMarkdownImageDescriptions:
    async def test_image_injection(self):
        md_with_image = "# Page\n\n![logo](https://example.com/logo.png)\n\nText."

        async def mock_inject(markdown, model="openai/gpt-5-mini", **kwargs):
            return markdown.replace(
                "![logo](https://example.com/logo.png)",
                "![logo](https://example.com/logo.png)\n\n> **Image**: A company logo",
            )

        with patch(
            "npl_mcp.markdown.image_descriptions.inject_image_descriptions",
            side_effect=mock_inject,
        ):
            result = await to_markdown(md_with_image, with_image_descriptions=True)

        assert result["image_descriptions"] is True
        assert "> **Image**: A company logo" in result["content"]

    async def test_image_model_passthrough(self):
        md = "# Page\n\n![img](pic.png)"
        captured = []

        async def mock_inject(markdown, model="openai/gpt-5-mini", **kwargs):
            captured.append({"model": model, "base_url": kwargs.get("base_url")})
            return markdown

        with patch(
            "npl_mcp.markdown.image_descriptions.inject_image_descriptions",
            side_effect=mock_inject,
        ):
            await to_markdown(md, with_image_descriptions=True, image_model="custom/model")

        assert captured[0]["model"] == "custom/model"

    async def test_image_base_url_passed_for_urls(self):
        """Relative image URIs should be resolved against the source URL."""
        md = "![logo](images/logo.png)"
        captured = []

        async def mock_inject(markdown, model="openai/gpt-5-mini", **kwargs):
            captured.append(kwargs.get("base_url"))
            return markdown

        with patch(
            "npl_mcp.browser.to_markdown._resolve_source",
            new_callable=AsyncMock,
            return_value=md,
        ), patch(
            "npl_mcp.markdown.image_descriptions.inject_image_descriptions",
            side_effect=mock_inject,
        ):
            await to_markdown(
                "https://example.com/page",
                with_image_descriptions=True,
            )

        assert captured[0] == "https://example.com/page"


# ---------------------------------------------------------------------------
# MCP registration
# ---------------------------------------------------------------------------


class TestToMarkdownRegistration:
    def test_tool_registered_in_launcher(self):
        from npl_mcp.launcher import create_app
        mcp = create_app()
        tool_names = set(mcp._tool_manager._tools.keys())
        assert "ToMarkdown" in tool_names
