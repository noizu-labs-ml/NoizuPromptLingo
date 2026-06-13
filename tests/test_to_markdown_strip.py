"""Tests for ToMarkdown metadata stripping, image URI resolution, and SVG detection."""

import pytest

from npl_mcp.browser.to_markdown import _strip_metadata_header, _strip_jina_header
from npl_mcp.markdown.image_descriptions import _resolve_image_uri
from npl_mcp.meta_tools.llm_client import _is_svg


class TestStripMetadataHeader:

    def test_strips_yaml_header(self):
        response = "success: true\nsource: https://example.com\n---\n# Hello World"
        result = _strip_metadata_header(response)
        assert result == "# Hello World"

    def test_strips_both_yaml_and_jina(self):
        response = (
            "success: true\nsource: https://example.com\n---\n"
            "Title: Example Page\n\nURL Source: https://example.com\n\n"
            "Markdown Content:\n# Hello World\n\nSome content."
        )
        result = _strip_metadata_header(response)
        assert result == "# Hello World\n\nSome content."

    def test_no_headers_returns_original(self):
        content = "# Just markdown\n\nNo headers here."
        result = _strip_metadata_header(content)
        assert result == content

    def test_only_yaml_header(self):
        response = "cached: true\n---\n# Content"
        result = _strip_metadata_header(response)
        assert result == "# Content"


class TestStripJinaHeader:

    def test_strips_jina_metadata(self):
        content = (
            "Title: My Page\n\n"
            "URL Source: https://example.com\n\n"
            "Markdown Content:\n"
            "# Hello\n\nWorld."
        )
        result = _strip_jina_header(content)
        assert result == "# Hello\n\nWorld."

    def test_no_jina_header(self):
        content = "# Just markdown\n\nNo Jina here."
        result = _strip_jina_header(content)
        assert result == content

    def test_markdown_content_in_body_not_stripped(self):
        """'Markdown Content:' appearing mid-document should not be stripped."""
        content = (
            "# Guide\n\n"
            "Here is some text about Markdown Content: it is great.\n\n"
            "More text."
        )
        result = _strip_jina_header(content)
        # Should NOT strip because the prefix doesn't look like Jina metadata
        assert "# Guide" in result

    def test_strips_leading_newlines_after_marker(self):
        content = "Title: Test\n\nMarkdown Content:\n\n\n# Start"
        result = _strip_jina_header(content)
        assert result == "# Start"

    def test_jina_with_only_title(self):
        content = "Title: Test Page\n\nMarkdown Content:\n# Content here"
        result = _strip_jina_header(content)
        assert result == "# Content here"

    def test_jina_with_extra_metadata_fields(self):
        content = (
            "Title: Example\n\n"
            "URL Source: https://example.com/page\n\n"
            "Published Time: 2024-01-01\n\n"
            "Markdown Content:\n"
            "# Article\n\nText."
        )
        result = _strip_jina_header(content)
        assert result == "# Article\n\nText."


class TestResolveImageUri:

    def test_absolute_http_returned_as_is(self):
        uri = "https://example.com/logo.png"
        assert _resolve_image_uri(uri) == uri

    def test_absolute_https_returned_as_is(self):
        uri = "http://example.com/logo.png"
        assert _resolve_image_uri(uri) == uri

    def test_data_uri_returned_as_is(self):
        uri = "data:image/png;base64,iVBORw0KGgo="
        assert _resolve_image_uri(uri) == uri

    def test_relative_resolved_with_base_url(self):
        result = _resolve_image_uri(
            "images/logo.png", base_url="https://example.com/page"
        )
        assert result == "https://example.com/images/logo.png"

    def test_relative_with_leading_slash(self):
        result = _resolve_image_uri(
            "/images/logo.png", base_url="https://example.com/docs/page"
        )
        assert result == "https://example.com/images/logo.png"

    def test_relative_without_base_url(self):
        result = _resolve_image_uri("images/logo.png")
        assert result == "images/logo.png"

    def test_relative_with_non_url_base(self):
        result = _resolve_image_uri("images/logo.png", base_url="/local/path")
        assert result == "images/logo.png"

    def test_base_url_with_trailing_path(self):
        result = _resolve_image_uri(
            "logo.png", base_url="https://example.com/docs/guide/"
        )
        assert result == "https://example.com/docs/guide/logo.png"

    def test_dot_dot_relative(self):
        result = _resolve_image_uri(
            "../assets/img.jpg", base_url="https://example.com/docs/page"
        )
        assert result == "https://example.com/assets/img.jpg"


class TestIsSvg:

    def test_svg_url(self):
        assert _is_svg("https://example.com/logo.svg") is True

    def test_svg_url_uppercase(self):
        assert _is_svg("https://example.com/logo.SVG") is True

    def test_png_url(self):
        assert _is_svg("https://example.com/logo.png") is False

    def test_jpg_url(self):
        assert _is_svg("https://example.com/photo.jpg") is False

    def test_svg_local_path(self):
        assert _is_svg("/images/icon.svg") is True

    def test_svg_relative_path(self):
        assert _is_svg("images/logos/logo.svg") is True

    def test_svg_data_uri(self):
        assert _is_svg("data:image/svg+xml;base64,PHN2Zy8+") is True

    def test_png_data_uri(self):
        assert _is_svg("data:image/png;base64,iVBORw0=") is False

    def test_svg_with_query_params(self):
        assert _is_svg("https://example.com/icon.svg?v=2") is True
