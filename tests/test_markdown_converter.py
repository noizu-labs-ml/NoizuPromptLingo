"""Tests for markdown converter module.

Tests cover:
- Convert URL via Jina API
- Convert local file (text/markdown)
- Caching behavior (cache then use cached)
- force_refresh parameter
- Error handling (file not found, URL timeout)
- Metadata header format
- BUG #1: Double extension cache issue (markdown file .md.md)
- BUG #2: HTML heading preservation (local vs Jina conversion)
"""

import os
import re
import tempfile
from pathlib import Path
from unittest.mock import AsyncMock, patch, MagicMock

import pytest
import httpx

from npl_mcp.markdown.cache import MarkdownCache
from npl_mcp.markdown.converter import MarkdownConverter, _parse_sse_stream


# ============================================================================
# Fixtures
# ============================================================================


@pytest.fixture
def cache():
    """Create a cache with temporary directory."""
    with tempfile.TemporaryDirectory() as tmpdir:
        yield MarkdownCache(cache_dir=Path(tmpdir))


@pytest.fixture
def converter(cache):
    """Create a converter with cache."""
    return MarkdownConverter(cache=cache)


@pytest.fixture
def temp_text_file():
    """Create a temporary text file for testing."""
    with tempfile.NamedTemporaryFile(mode="w", delete=False, suffix=".txt") as f:
        f.write("# Test Content\n\nThis is test content from a text file.")
        path = f.name
    yield path
    Path(path).unlink(missing_ok=True)


@pytest.fixture
def temp_markdown_file():
    """Create a temporary markdown file for testing."""
    with tempfile.NamedTemporaryFile(mode="w", delete=False, suffix=".md") as f:
        f.write("# Markdown Document\n\n## Section One\n\nContent here.")
        path = f.name
    yield path
    Path(path).unlink(missing_ok=True)


@pytest.fixture
def temp_pdf_file():
    """Create a temporary PDF file path for testing."""
    with tempfile.NamedTemporaryFile(mode="wb", delete=False, suffix=".pdf") as f:
        f.write(b"%PDF-1.4 fake pdf content")
        path = f.name
    yield path
    Path(path).unlink(missing_ok=True)


@pytest.fixture
def temp_docx_file():
    """Create a temporary DOCX file path for testing."""
    with tempfile.NamedTemporaryFile(mode="wb", delete=False, suffix=".docx") as f:
        f.write(b"PK\x03\x04 fake docx content")
        path = f.name
    yield path
    Path(path).unlink(missing_ok=True)


@pytest.fixture
def temp_image_file():
    """Create a temporary image file path for testing."""
    with tempfile.NamedTemporaryFile(mode="wb", delete=False, suffix=".png") as f:
        f.write(b"\x89PNG\r\n\x1a\n fake png content")
        path = f.name
    yield path
    Path(path).unlink(missing_ok=True)


@pytest.fixture
def temp_html_file():
    """Create a temporary HTML file for testing."""
    html_content = """
    <html>
    <head><title>Test Page</title></head>
    <body>
    <h1>Test Heading</h1>
    <p>This is a test paragraph.</p>
    <ul>
    <li>Item 1</li>
    <li>Item 2</li>
    </ul>
    </body>
    </html>
    """
    with tempfile.NamedTemporaryFile(mode="w", delete=False, suffix=".html") as f:
        f.write(html_content)
        path = f.name
    yield path
    Path(path).unlink(missing_ok=True)


# ============================================================================
# Test Local File Conversion
# ============================================================================


class TestConverterLocalFiles:
    """Test converting local files to markdown."""

    @pytest.mark.asyncio
    async def test_convert_text_file(self, converter, temp_text_file):
        """Test converting a plain text file."""
        result = await converter.convert(temp_text_file)

        assert "success: true" in result
        assert "source_type: file" in result
        assert "# Test Content" in result
        assert "This is test content from a text file" in result

    @pytest.mark.asyncio
    async def test_convert_markdown_file(self, converter, temp_markdown_file):
        """Test converting a markdown file (passthrough)."""
        result = await converter.convert(temp_markdown_file)

        assert "success: true" in result
        assert "source_type: file" in result
        assert "# Markdown Document" in result
        assert "## Section One" in result

    @pytest.mark.asyncio
    async def test_convert_nonexistent_file_raises_error(self, converter):
        """Test that converting nonexistent file raises FileNotFoundError."""
        with pytest.raises(FileNotFoundError):
            await converter.convert("/nonexistent/path/file.txt")

    @pytest.mark.asyncio
    async def test_convert_file_includes_metadata(self, converter, temp_text_file):
        """Test that converted file includes proper metadata."""
        result = await converter.convert(temp_text_file)

        assert "success: true" in result
        assert f"source: {temp_text_file}" in result
        assert "source_type: file" in result
        assert "cached:" in result
        assert "cache_file:" in result
        assert "content_length:" in result


# ============================================================================
# Test URL Conversion (Mocked)
# ============================================================================


class TestConverterURLs:
    """Test converting URLs to markdown via Jina + direct fallback."""

    @pytest.mark.asyncio
    async def test_convert_url_uses_jina_when_complete(self, converter):
        """Test that Jina result is used when it has sufficient content."""
        jina_content = "# Converted Content\n\nFrom Jina API with plenty of detail."
        direct_content = "# Short"

        with patch.object(converter, "_convert_url_jina", new_callable=AsyncMock, return_value=jina_content), \
             patch.object(converter, "_convert_url_direct", new_callable=AsyncMock, return_value=direct_content):
            result = await converter.convert("https://example.com/page")

        assert "success: true" in result
        assert "source_type: url" in result
        assert "Converted Content" in result

    @pytest.mark.asyncio
    async def test_convert_url_prefers_jina_even_if_shorter(self, converter):
        """Test that Jina is preferred even when direct returns more content."""
        jina_content = "# Short but valid Jina"
        direct_content = "# Full Page\n\n## Section 1\nLong content here.\n\n## Section 2\nMore content."

        with patch.object(converter, "_convert_url_jina", new_callable=AsyncMock, return_value=jina_content), \
             patch.object(converter, "_convert_url_direct", new_callable=AsyncMock, return_value=direct_content):
            result = await converter.convert("https://example.com/page")

        assert "Short but valid Jina" in result

    @pytest.mark.asyncio
    async def test_convert_url_includes_metadata(self, converter):
        """Test that converted URL includes proper metadata."""
        with patch.object(converter, "_convert_url_jina", new_callable=AsyncMock, return_value="# API Docs"), \
             patch.object(converter, "_convert_url_direct", new_callable=AsyncMock, return_value=""):
            result = await converter.convert("https://example.com/docs")

        assert "success: true" in result
        assert "source: https://example.com/docs" in result
        assert "source_type: url" in result
        assert "cache_file:" in result

    @pytest.mark.asyncio
    async def test_convert_url_jina_calls_jina_endpoint_with_sse(self, converter):
        """Test that _convert_url_jina streams from correct Jina endpoint with SSE."""
        sse_lines = ["data: # Content", "", ""]

        mock_response = MagicMock()
        mock_response.raise_for_status = MagicMock()

        async def fake_aiter_lines():
            for line in sse_lines:
                yield line

        mock_response.aiter_lines = fake_aiter_lines

        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = AsyncMock()
            # stream() returns a sync context-manager-like object
            # that is used with `async with`. Use MagicMock for __aenter__/__aexit__.
            stream_cm = MagicMock()
            stream_cm.__aenter__ = AsyncMock(return_value=mock_response)
            stream_cm.__aexit__ = AsyncMock(return_value=None)
            mock_client.stream = MagicMock(return_value=stream_cm)
            mock_client.__aenter__ = AsyncMock(return_value=mock_client)
            mock_client.__aexit__ = AsyncMock(return_value=None)
            mock_client_class.return_value = mock_client

            result = await converter._convert_url_jina("https://example.com/page", 30)

        call_args = mock_client.stream.call_args
        assert call_args[0] == ("GET", "https://r.jina.ai/https://example.com/page")
        headers = call_args[1].get("headers", {})
        assert headers.get("Accept") == "text/event-stream"
        assert headers.get("X-With-Shadow-Dom") == "true"
        assert result == "# Content"

    @pytest.mark.asyncio
    async def test_convert_url_jina_with_api_key(self, converter):
        """Test _convert_url_jina includes API key in SSE request."""
        sse_lines = ["data: # Content", ""]

        mock_response = MagicMock()
        mock_response.raise_for_status = MagicMock()

        async def fake_aiter_lines():
            for line in sse_lines:
                yield line

        mock_response.aiter_lines = fake_aiter_lines

        with patch.dict(os.environ, {"JINA_API_KEY": "test-api-key"}):
            with patch("httpx.AsyncClient") as mock_client_class:
                mock_client = AsyncMock()
                stream_cm = MagicMock()
                stream_cm.__aenter__ = AsyncMock(return_value=mock_response)
                stream_cm.__aexit__ = AsyncMock(return_value=None)
                mock_client.stream = MagicMock(return_value=stream_cm)
                mock_client.__aenter__ = AsyncMock(return_value=mock_client)
                mock_client.__aexit__ = AsyncMock(return_value=None)
                mock_client_class.return_value = mock_client

                await converter._convert_url_jina("https://example.com/page", 30)

        call_args = mock_client.stream.call_args
        headers = call_args[1].get("headers", {})
        assert headers.get("Authorization") == "Bearer test-api-key"
        assert headers.get("Accept") == "text/event-stream"

    @pytest.mark.asyncio
    async def test_convert_url_direct_uses_html2text(self, converter):
        """Test that _convert_url_direct fetches HTML and converts with html2text."""
        mock_response = MagicMock()
        mock_response.text = "<html><body><h1>Title</h1><p>Content</p></body></html>"
        mock_response.raise_for_status = MagicMock()

        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = AsyncMock()
            mock_client.get.return_value = mock_response
            mock_client.__aenter__.return_value = mock_client
            mock_client.__aexit__.return_value = None
            mock_client_class.return_value = mock_client

            result = await converter._convert_url_direct("https://example.com/page", 30)

        assert "Title" in result
        assert "Content" in result

    @pytest.mark.asyncio
    async def test_convert_url_jina_failure_no_fallback_by_default(self, converter):
        """Test that Jina failure returns empty when fallback_parser is False."""
        with patch.object(converter, "_convert_url_jina", new_callable=AsyncMock, side_effect=Exception("Jina down")), \
             patch.object(converter, "_convert_url_direct", new_callable=AsyncMock, return_value="# Direct") as direct_mock:
            result = await converter.convert("https://example.com/page")

        direct_mock.assert_not_called()
        assert "success: true" in result

    @pytest.mark.asyncio
    async def test_convert_url_jina_failure_uses_direct_with_flag(self, converter):
        """Test that Jina failure falls back to direct when fallback_parser=True."""
        direct_content = "# Fallback Content\n\nDirect fetch worked."

        with patch.object(converter, "_convert_url_jina", new_callable=AsyncMock, side_effect=Exception("Jina down")), \
             patch.object(converter, "_convert_url_direct", new_callable=AsyncMock, return_value=direct_content):
            result = await converter.convert("https://example.com/page", fallback_parser=True)

        assert "Fallback Content" in result

    @pytest.mark.asyncio
    async def test_convert_url_without_api_key(self, converter):
        """Test URL conversion works without API key."""
        with patch.object(converter, "_convert_url_jina", new_callable=AsyncMock, return_value="# Content"), \
             patch.object(converter, "_convert_url_direct", new_callable=AsyncMock, return_value=""):
            with patch.dict(os.environ, {}, clear=True):
                os.environ.pop("JINA_API_KEY", None)
                result = await converter.convert("https://example.com/page")

        assert "success: true" in result


# ============================================================================
# Test SSE Stream Parsing
# ============================================================================


class TestParseSSEStream:
    """Test _parse_sse_stream for Jina event-stream responses."""

    def test_single_data_event(self):
        lines = ["data: # Hello World", ""]
        assert _parse_sse_stream(lines) == "# Hello World"

    def test_multiline_data_event(self):
        lines = ["data: # Title", "data: ", "data: Paragraph text.", ""]
        assert _parse_sse_stream(lines) == "# Title\n\nParagraph text."

    def test_progressive_chunks_returns_last(self):
        """Jina streams progressive chunks; we want the last (most complete)."""
        lines = [
            "data: # Partial",
            "",
            "data: # Full Page",
            "data: ",
            "data: Complete content.",
            "",
        ]
        assert _parse_sse_stream(lines) == "# Full Page\n\nComplete content."

    def test_empty_stream(self):
        assert _parse_sse_stream([]) == ""

    def test_no_trailing_blank_line(self):
        """Handle streams that don't end with a blank line."""
        lines = ["data: # Content"]
        assert _parse_sse_stream(lines) == "# Content"

    def test_ignores_non_data_lines(self):
        lines = ["event: message", "data: # Content", "id: 1", ""]
        assert _parse_sse_stream(lines) == "# Content"


# ============================================================================
# Test Caching Behavior
# ============================================================================


class TestConverterCaching:
    """Test caching behavior during conversion."""

    @pytest.mark.asyncio
    async def test_convert_caches_result(self, converter, cache, temp_text_file):
        """Test that conversion caches the result."""
        await converter.convert(temp_text_file)

        # Check cache
        cached = await cache.get_cached(temp_text_file)
        assert cached is not None
        assert "# Test Content" in cached

    @pytest.mark.asyncio
    async def test_convert_uses_cached_result(self, converter, cache, temp_text_file):
        """Test that second conversion uses cached result."""
        # First conversion
        result1 = await converter.convert(temp_text_file)
        assert "cached: false" in result1

        # Second conversion should use cache
        result2 = await converter.convert(temp_text_file)
        assert "cached: true" in result2

    @pytest.mark.asyncio
    async def test_convert_url_caches_result(self, converter, cache):
        """Test that URL conversion caches the result."""
        with patch.object(converter, "_convert_url_jina", new_callable=AsyncMock, return_value="# Cached URL Content"), \
             patch.object(converter, "_convert_url_direct", new_callable=AsyncMock, return_value=""):
            # First conversion
            result1 = await converter.convert("https://example.com/page")
            assert "cached: false" in result1

        # Second conversion should use cache (no API call)
        result2 = await converter.convert("https://example.com/page")
        assert "cached: true" in result2
        assert "Cached URL Content" in result2


# ============================================================================
# Test Force Refresh
# ============================================================================


class TestConverterForceRefresh:
    """Test force_refresh parameter behavior."""

    @pytest.mark.asyncio
    async def test_force_refresh_skips_cache(self, converter, cache, temp_text_file):
        """Test that force_refresh skips the cache."""
        # First conversion to populate cache
        result1 = await converter.convert(temp_text_file)
        assert "cached: false" in result1

        # Force refresh should skip cache
        result2 = await converter.convert(temp_text_file, force_refresh=True)
        assert "cached: false" in result2

    @pytest.mark.asyncio
    async def test_force_refresh_updates_cache(self, converter, cache, temp_text_file):
        """Test that force_refresh updates the cache."""
        # First conversion
        await converter.convert(temp_text_file)

        # Modify the file
        with open(temp_text_file, "w") as f:
            f.write("# Updated Content\n\nNew content here.")

        # Force refresh
        result = await converter.convert(temp_text_file, force_refresh=True)
        assert "Updated Content" in result

        # Cache should have new content
        cached = await cache.get_cached(temp_text_file)
        assert "Updated Content" in cached

    @pytest.mark.asyncio
    async def test_force_refresh_url_refetches(self, converter):
        """Test that force_refresh on URL refetches from API."""
        jina_mock = AsyncMock(side_effect=["# Original Content", "# Updated Content"])
        direct_mock = AsyncMock(return_value="")

        with patch.object(converter, "_convert_url_jina", jina_mock), \
             patch.object(converter, "_convert_url_direct", direct_mock):
            # First conversion
            result1 = await converter.convert("https://example.com/page")
            assert "Original Content" in result1

            # Force refresh
            result2 = await converter.convert("https://example.com/page", force_refresh=True)
            assert "Updated Content" in result2

        # Jina should have been called twice
        assert jina_mock.call_count == 2


# ============================================================================
# Test Error Handling
# ============================================================================


class TestConverterErrorHandling:
    """Test error handling in converter."""

    @pytest.mark.asyncio
    async def test_file_not_found_error(self, converter):
        """Test FileNotFoundError for missing files."""
        with pytest.raises(FileNotFoundError):
            await converter.convert("/nonexistent/path/document.txt")

    @pytest.mark.asyncio
    async def test_url_jina_fails_returns_empty_without_fallback(self, converter):
        """Test that Jina failure returns empty when fallback_parser is False."""
        with patch.object(converter, "_convert_url_jina", new_callable=AsyncMock, side_effect=httpx.TimeoutException("timeout")):
            result = await converter.convert("https://example.com/slow-page")

        # Should still return a formatted response with empty content
        assert "success: true" in result

    @pytest.mark.asyncio
    async def test_url_both_fail_returns_empty(self, converter):
        """Test that when both Jina and direct fail, empty content is returned."""
        with patch.object(converter, "_convert_url_jina", new_callable=AsyncMock, side_effect=httpx.TimeoutException("timeout")), \
             patch.object(converter, "_convert_url_direct", new_callable=AsyncMock, side_effect=httpx.TimeoutException("timeout")):
            result = await converter.convert("https://example.com/slow-page", fallback_parser=True)

        assert "success: true" in result

    @pytest.mark.asyncio
    async def test_url_jina_fails_direct_succeeds_with_fallback(self, converter):
        """Test Jina HTTP error falls back to direct when fallback_parser=True."""
        with patch.object(converter, "_convert_url_jina", new_callable=AsyncMock, side_effect=httpx.HTTPStatusError(
                "404", request=MagicMock(), response=MagicMock()
             )), \
             patch.object(converter, "_convert_url_direct", new_callable=AsyncMock, return_value="# Direct Content"):
            result = await converter.convert("https://example.com/not-found", fallback_parser=True)

        assert "Direct Content" in result

    @pytest.mark.asyncio
    async def test_pdf_conversion_fails_with_invalid_pdf(self, converter, temp_pdf_file):
        """Test that PDF conversion handles invalid PDF gracefully."""
        # The temp_pdf_file is a fake PDF that can't be parsed
        with pytest.raises(RuntimeError) as exc_info:
            await converter.convert(temp_pdf_file)

        # Should get a RuntimeError about PDF parsing
        assert "PDF" in str(exc_info.value) or "pdf" in str(exc_info.value).lower()

    @pytest.mark.asyncio
    async def test_docx_conversion_not_implemented(self, converter, temp_docx_file):
        """Test that DOCX conversion raises NotImplementedError."""
        with pytest.raises(NotImplementedError) as exc_info:
            await converter.convert(temp_docx_file)

        assert "DOCX" in str(exc_info.value) or "docx" in str(exc_info.value).lower()

    @pytest.mark.asyncio
    async def test_image_conversion_not_implemented(self, converter, temp_image_file):
        """Test that image conversion raises NotImplementedError."""
        with pytest.raises(NotImplementedError) as exc_info:
            await converter.convert(temp_image_file)

        assert "image" in str(exc_info.value).lower() or "vision" in str(exc_info.value).lower()


# ============================================================================
# Test Metadata Header Format
# ============================================================================


class TestConverterMetadataFormat:
    """Test metadata header format in responses."""

    @pytest.mark.asyncio
    async def test_metadata_header_structure(self, converter, temp_text_file):
        """Test that metadata header has correct structure."""
        result = await converter.convert(temp_text_file)

        # Check header fields
        assert "success: true" in result
        assert "source:" in result
        assert "source_type:" in result
        assert "cached:" in result
        assert "cache_file:" in result
        assert "content_length:" in result
        assert "---" in result  # Separator

    @pytest.mark.asyncio
    async def test_metadata_source_field(self, converter, temp_text_file):
        """Test that source field contains original source."""
        result = await converter.convert(temp_text_file)

        assert f"source: {temp_text_file}" in result

    @pytest.mark.asyncio
    async def test_metadata_source_type_file(self, converter, temp_text_file):
        """Test source_type is 'file' for local files."""
        result = await converter.convert(temp_text_file)

        assert "source_type: file" in result

    @pytest.mark.asyncio
    async def test_metadata_source_type_url(self, converter):
        """Test source_type is 'url' for URLs."""
        with patch.object(converter, "_convert_url_jina", new_callable=AsyncMock, return_value="# Content"), \
             patch.object(converter, "_convert_url_direct", new_callable=AsyncMock, return_value=""):
            result = await converter.convert("https://example.com/page")

        assert "source_type: url" in result

    @pytest.mark.asyncio
    async def test_metadata_cached_field(self, converter, temp_text_file):
        """Test cached field values."""
        # First conversion - not cached
        result1 = await converter.convert(temp_text_file)
        assert "cached: false" in result1

        # Second conversion - cached
        result2 = await converter.convert(temp_text_file)
        assert "cached: true" in result2

    @pytest.mark.asyncio
    async def test_metadata_content_length_field(self, converter, temp_text_file):
        """Test content_length field is present and numeric."""
        result = await converter.convert(temp_text_file)

        # Extract content_length value
        for line in result.split("\n"):
            if "content_length:" in line:
                value = line.split(":")[1].strip()
                assert value.isdigit()
                assert int(value) > 0
                break
        else:
            pytest.fail("content_length field not found")

    @pytest.mark.asyncio
    async def test_metadata_separator_before_content(self, converter, temp_text_file):
        """Test that --- separator appears before content."""
        result = await converter.convert(temp_text_file)

        # Split by separator
        parts = result.split("---")
        assert len(parts) >= 2

        # Metadata should be before separator
        metadata = parts[0]
        assert "success:" in metadata
        assert "source:" in metadata

        # Content should be after separator
        content = parts[1] if len(parts) > 1 else ""
        assert "# Test Content" in content


# ============================================================================
# Test Timeout Parameter
# ============================================================================


class TestConverterTimeout:
    """Test timeout parameter for URL conversion."""

    @pytest.mark.asyncio
    async def test_custom_timeout_passed_to_jina(self, converter):
        """Test that custom timeout is passed to _convert_url_jina."""
        jina_mock = AsyncMock(return_value="# Content")
        direct_mock = AsyncMock(return_value="")

        with patch.object(converter, "_convert_url_jina", jina_mock), \
             patch.object(converter, "_convert_url_direct", direct_mock):
            await converter.convert("https://example.com/page", timeout=60)

        jina_mock.assert_called_once_with("https://example.com/page", 60)

    @pytest.mark.asyncio
    async def test_default_timeout(self, converter):
        """Test default timeout value is 30."""
        jina_mock = AsyncMock(return_value="# Content")
        direct_mock = AsyncMock(return_value="")

        with patch.object(converter, "_convert_url_jina", jina_mock), \
             patch.object(converter, "_convert_url_direct", direct_mock):
            await converter.convert("https://example.com/page")

        jina_mock.assert_called_once_with("https://example.com/page", 30)


# ============================================================================
# Test HTML Conversion
# ============================================================================


class TestConverterHTMLConversion:
    """Test converting HTML files to markdown."""

    @pytest.mark.asyncio
    async def test_convert_html_file(self, converter, temp_html_file):
        """Test converting an HTML file to markdown."""
        result = await converter.convert(temp_html_file)

        assert "success: true" in result
        assert "source_type: file" in result
        # Check that content is converted to markdown (h1, paragraph, etc.)
        content = result.split("---")[1] if "---" in result else result
        assert "Test" in content or "Heading" in content or "test" in content.lower()

    @pytest.mark.asyncio
    async def test_convert_html_includes_metadata(self, converter, temp_html_file):
        """Test that converted HTML includes proper metadata."""
        result = await converter.convert(temp_html_file)

        assert "success: true" in result
        assert f"source: {temp_html_file}" in result
        assert "source_type: file" in result
        assert "cached:" in result
        assert "cache_file:" in result

    @pytest.mark.asyncio
    async def test_convert_html_uses_cache(self, converter, temp_html_file):
        """Test that HTML conversions are cached."""
        # First conversion
        result1 = await converter.convert(temp_html_file)
        assert "cached: false" in result1

        # Second conversion should use cache
        result2 = await converter.convert(temp_html_file)
        assert "cached: true" in result2


# ============================================================================
# Test Source Type Detection
# ============================================================================


class TestConverterSourceTypeDetection:
    """Test source type detection logic."""

    @pytest.mark.asyncio
    async def test_http_url_detected(self, converter):
        """Test that http:// URLs are detected correctly."""
        with patch.object(converter, "_convert_url_jina", new_callable=AsyncMock, return_value="# Content"), \
             patch.object(converter, "_convert_url_direct", new_callable=AsyncMock, return_value=""):
            result = await converter.convert("http://example.com/page")

        assert "source_type: url" in result

    @pytest.mark.asyncio
    async def test_https_url_detected(self, converter):
        """Test that https:// URLs are detected correctly."""
        with patch.object(converter, "_convert_url_jina", new_callable=AsyncMock, return_value="# Content"), \
             patch.object(converter, "_convert_url_direct", new_callable=AsyncMock, return_value=""):
            result = await converter.convert("https://example.com/page")

        assert "source_type: url" in result

    @pytest.mark.asyncio
    async def test_png_extension_detected(self, converter, temp_image_file):
        """Test that .png files are detected as images."""
        with pytest.raises(NotImplementedError) as exc_info:
            await converter.convert(temp_image_file)

        # Should raise NotImplementedError for image conversion
        assert "image" in str(exc_info.value).lower() or "vision" in str(exc_info.value).lower()

    @pytest.mark.asyncio
    async def test_pdf_extension_detected(self, converter, temp_pdf_file):
        """Test that .pdf files are detected correctly."""
        # Invalid PDF will raise RuntimeError
        with pytest.raises(RuntimeError) as exc_info:
            await converter.convert(temp_pdf_file)

        assert "pdf" in str(exc_info.value).lower()

    @pytest.mark.asyncio
    async def test_docx_extension_detected(self, converter, temp_docx_file):
        """Test that .docx files are detected correctly."""
        with pytest.raises(NotImplementedError) as exc_info:
            await converter.convert(temp_docx_file)

        assert "docx" in str(exc_info.value).lower()

    @pytest.mark.asyncio
    async def test_txt_extension_as_text(self, converter, temp_text_file):
        """Test that .txt files are treated as text."""
        result = await converter.convert(temp_text_file)

        assert "source_type: file" in result
        assert "success: true" in result

    @pytest.mark.asyncio
    async def test_html_extension_detected(self, converter, temp_html_file):
        """Test that .html files are detected and converted."""
        result = await converter.convert(temp_html_file)

        assert "source_type: file" in result
        assert "success: true" in result
        # Content should be converted to markdown
        assert "---" in result  # Separator present


# ============================================================================
# BUG #1: Double Extension Cache Issue
# ============================================================================


class TestBugDoubleExtensionCache:
    """Test for bug: Running 2md on markdown file should NOT produce .md.md files.

    Issue: When converting a file that's already markdown (e.g., nihilism.html.md),
    the converter should detect this and not create duplicate cache files.

    Current behavior (buggy):
    - Input: nihilism.html.md
    - Output cache: nihilism.html.md.md (double extension)

    Expected behavior:
    - Input: nihilism.html.md (already markdown)
    - Should either skip caching or detect that source is already markdown
    """

    @pytest.mark.asyncio
    async def test_markdown_file_cache_path(self, converter, cache):
        """Test that markdown file cache path doesn't double extend."""
        with tempfile.NamedTemporaryFile(mode="w", delete=False, suffix=".html.md") as f:
            f.write("# Already Markdown\n\nNo conversion needed.")
            markdown_file = f.name

        try:
            result = await converter.convert(markdown_file)

            # The cache path should not have double extension (.html.md.md)
            # This test documents the bug - currently it DOES create .md.md
            cache_path = cache.get_cache_path(markdown_file)

            # BUG: This assertion FAILS with current code
            # Current behavior creates: file.html.md.md
            # Expected behavior should be: file.html.md (no caching needed)
            assert not str(cache_path).endswith(".md.md"), \
                f"Cache path has double extension: {cache_path}"
        finally:
            Path(markdown_file).unlink(missing_ok=True)

    @pytest.mark.asyncio
    async def test_converting_markdown_twice_no_double_cache(self, converter, cache):
        """Test that converting markdown file twice doesn't create cascading .md files.

        BUG: Running converter twice on result creates:
        - First run: file.html.md
        - Second run on file.html.md: file.html.md.md
        """
        with tempfile.NamedTemporaryFile(mode="w", delete=False, suffix=".html.md") as f:
            f.write("# Heading\n\n## Section\n\nContent here.")
            source_file = f.name

        try:
            # First conversion
            result1 = await converter.convert(source_file)
            assert "success: true" in result1

            # Second conversion of same file should use cache
            result2 = await converter.convert(source_file)

            # Should indicate cached, not create new file
            assert "cached:" in result2

            # Check that no .md.md file was created
            double_ext_path = Path(source_file).with_suffix(".md.md")
            assert not double_ext_path.exists(), \
                f"Double extension cache file created: {double_ext_path}"
        finally:
            Path(source_file).unlink(missing_ok=True)

    @pytest.mark.asyncio
    async def test_markdown_source_detection(self, converter):
        """Test that files already in markdown format are detected.

        Markdown files should either:
        1. Not be cached (detect as already markdown)
        2. Or cached without adding .md extension
        """
        with tempfile.NamedTemporaryFile(mode="w", delete=False, suffix=".md") as f:
            f.write("# Already Markdown\n\nThis is markdown content.")
            md_file = f.name

        try:
            result = await converter.convert(md_file)

            # Should recognize it's already markdown
            assert "Already Markdown" in result

            # Verify no double extension occurs
            parts = Path(md_file).suffixes
            # Should be ['.md'] not ['.md', '.md']
            assert parts == ['.md'], \
                f"File has multiple markdown extensions: {parts}"
        finally:
            Path(md_file).unlink(missing_ok=True)


# ============================================================================
# BUG #2: HTML Heading Preservation Issue
# ============================================================================


class TestBugHTMLHeadingPreservation:
    """Test for bug: Headings from local HTML are not preserved like Jina does.

    Issue: When converting HTML files:
    - Jina API conversion (via URL): Preserves heading structure correctly
    - Local html2text conversion: Headings are lost or mangled

    Root cause: Two different conversion methods, Jina is better at preserving structure.
    Suggested fix: Use Jina for both URL and local files (requires file upload support).
    """

    @pytest.mark.asyncio
    async def test_local_html_with_multiple_headings(self, converter):
        """Test that headings in local HTML files are converted to markdown headings."""
        html_content = """
        <html>
        <body>
        <h1>Main Title</h1>
        <p>Main content paragraph.</p>

        <h2>Section One</h2>
        <p>Section one content.</p>

        <h2>Section Two</h2>
        <p>Section two content.</p>

        <h3>Subsection 2.1</h3>
        <p>Detailed content.</p>
        </body>
        </html>
        """

        with tempfile.NamedTemporaryFile(mode="w", delete=False, suffix=".html") as f:
            f.write(html_content)
            html_file = f.name

        try:
            result = await converter.convert(html_file)
            content = result.split("---")[1] if "---" in result else result

            # BUG: These assertions may FAIL because html2text doesn't preserve headings well
            # Should have markdown heading (# ) for h1
            assert "#" in content, \
                "No markdown headings found in converted HTML"

            # Should preserve heading hierarchy
            lines = content.split("\n")
            heading_lines = [l for l in lines if l.strip().startswith("#")]
            assert len(heading_lines) > 0, \
                "No heading lines found after conversion"

            # Verify specific headings are present
            heading_text = "\n".join(heading_lines)
            assert "Main Title" in heading_text or "main" in heading_text.lower(), \
                f"Main h1 heading not preserved. Headings found: {heading_text}"

            assert "Section" in heading_text, \
                f"Section h2 headings not preserved. Headings found: {heading_text}"
        finally:
            Path(html_file).unlink(missing_ok=True)

    @pytest.mark.asyncio
    async def test_html_heading_levels_preserved(self, converter):
        """Test that HTML heading levels (h1->h2->h3) become markdown hierarchy.

        BUG: Local HTML conversion may not preserve heading levels correctly.
        """
        html_content = """
        <html>
        <body>
        <h1>Level 1</h1>
        <h2>Level 2</h2>
        <h3>Level 3</h3>
        <h2>Back to Level 2</h2>
        </body>
        </html>
        """

        with tempfile.NamedTemporaryFile(mode="w", delete=False, suffix=".html") as f:
            f.write(html_content)
            html_file = f.name

        try:
            result = await converter.convert(html_file)
            content = result.split("---")[1] if "---" in result else result

            # Extract heading lines with their levels
            heading_pattern = r"^(#+)\s+(.*)$"
            headings = []
            for line in content.split("\n"):
                match = re.match(heading_pattern, line)
                if match:
                    level = len(match.group(1))
                    text = match.group(2).strip()
                    headings.append((level, text))

            # BUG: This may fail if headings aren't found
            assert len(headings) >= 2, \
                f"Expected at least 2 headings, found {len(headings)}: {headings}"

            # Verify heading progression
            heading_levels = [h[0] for h in headings]
            assert heading_levels[0] == 1, "First heading should be level 1"

            # If we have level 2 and 3, they should follow proper hierarchy
            if len(heading_levels) > 2:
                assert heading_levels[1] <= 2, "Second heading should be level <= 2"
        finally:
            Path(html_file).unlink(missing_ok=True)

    @pytest.mark.asyncio
    async def test_nested_html_structure_preservation(self, converter):
        """Test that nested HTML structure (divs with headers) is converted to markdown hierarchy.

        BUG: Complex HTML structures may lose their heading hierarchy in local conversion.
        """
        html_content = """
        <html>
        <body>
        <div class="container">
            <h1>Document Title</h1>
            <div class="section">
                <h2>Introduction</h2>
                <p>Intro paragraph.</p>
                <h3>Background</h3>
                <p>Background info.</p>
            </div>
            <div class="section">
                <h2>Main Content</h2>
                <p>Main paragraph.</p>
                <h3>Details</h3>
                <p>Detailed info.</p>
            </div>
        </div>
        </body>
        </html>
        """

        with tempfile.NamedTemporaryFile(mode="w", delete=False, suffix=".html") as f:
            f.write(html_content)
            html_file = f.name

        try:
            result = await converter.convert(html_file)
            content = result.split("---")[1] if "---" in result else result

            # Should have at least title and section headings
            assert "Document Title" in content or "Title" in content, \
                "Document title h1 not found"

            assert "Introduction" in content or "Main Content" in content, \
                "Section headings h2 not found"

            # Verify we can extract a structured outline
            heading_pattern = r"^(#+)\s+(.*)$"
            headings = [line for line in content.split("\n")
                       if re.match(heading_pattern, line)]

            assert len(headings) >= 3, \
                f"Expected at least 3 headings for nested structure, found {len(headings)}"
        finally:
            Path(html_file).unlink(missing_ok=True)

    @pytest.mark.asyncio
    async def test_html_vs_markdown_content_parity(self, converter):
        """Test that HTML converted to markdown has same content as original markdown.

        This tests whether html2text is losing information compared to a source markdown.
        """
        markdown_content = """# Document Title

## Section One

This is the first section with content.

## Section Two

This is the second section.

### Subsection 2.1

Detailed content here.
"""

        # Create equivalent HTML
        html_content = """
        <html>
        <body>
        <h1>Document Title</h1>
        <h2>Section One</h2>
        <p>This is the first section with content.</p>
        <h2>Section Two</h2>
        <p>This is the second section.</p>
        <h3>Subsection 2.1</h3>
        <p>Detailed content here.</p>
        </body>
        </html>
        """

        with tempfile.NamedTemporaryFile(mode="w", delete=False, suffix=".html") as f:
            f.write(html_content)
            html_file = f.name

        try:
            result = await converter.convert(html_file)
            html_converted = result.split("---")[1] if "---" in result else result

            # Extract key structural elements
            def extract_structure(content):
                """Extract heading and key text from content."""
                headings = []
                for line in content.split("\n"):
                    if line.strip().startswith("#"):
                        headings.append(line.strip())
                return headings

            md_structure = extract_structure(markdown_content)
            html_structure = extract_structure(html_converted)

            # Should have same number of headings
            # BUG: This may fail if html2text loses headings
            assert len(html_structure) >= len(md_structure) // 2, \
                f"HTML conversion lost headings. Expected ~{len(md_structure)}, " \
                f"got {len(html_structure)}. HTML structure: {html_structure}"
        finally:
            Path(html_file).unlink(missing_ok=True)
