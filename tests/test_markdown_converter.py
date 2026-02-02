"""Tests for markdown converter module.

Tests cover:
- Convert URL via Jina API
- Convert local file (text/markdown)
- Caching behavior (cache then use cached)
- force_refresh parameter
- Error handling (file not found, URL timeout)
- Metadata header format
"""

import os
import tempfile
from pathlib import Path
from unittest.mock import AsyncMock, patch, MagicMock

import pytest
import httpx

from npl_mcp.markdown.cache import MarkdownCache
from npl_mcp.markdown.converter import MarkdownConverter


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
    """Test converting URLs to markdown via Jina API."""

    @pytest.mark.asyncio
    async def test_convert_url_via_jina(self, converter):
        """Test converting URL via Jina API (mocked)."""
        mock_response = MagicMock()
        mock_response.text = "# Converted Content\n\nFrom Jina API."
        mock_response.raise_for_status = MagicMock()

        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = AsyncMock()
            mock_client.get.return_value = mock_response
            mock_client.__aenter__.return_value = mock_client
            mock_client.__aexit__.return_value = None
            mock_client_class.return_value = mock_client

            result = await converter.convert("https://example.com/page")

        assert "success: true" in result
        assert "source_type: url" in result
        assert "Converted Content" in result
        mock_client.get.assert_called_once()

    @pytest.mark.asyncio
    async def test_convert_url_includes_metadata(self, converter):
        """Test that converted URL includes proper metadata."""
        mock_response = MagicMock()
        mock_response.text = "# API Docs"
        mock_response.raise_for_status = MagicMock()

        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = AsyncMock()
            mock_client.get.return_value = mock_response
            mock_client.__aenter__.return_value = mock_client
            mock_client.__aexit__.return_value = None
            mock_client_class.return_value = mock_client

            result = await converter.convert("https://example.com/docs")

        assert "success: true" in result
        assert "source: https://example.com/docs" in result
        assert "source_type: url" in result
        assert "cache_file:" in result

    @pytest.mark.asyncio
    async def test_convert_url_uses_jina_endpoint(self, converter):
        """Test that URL conversion calls correct Jina endpoint."""
        mock_response = MagicMock()
        mock_response.text = "# Content"
        mock_response.raise_for_status = MagicMock()

        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = AsyncMock()
            mock_client.get.return_value = mock_response
            mock_client.__aenter__.return_value = mock_client
            mock_client.__aexit__.return_value = None
            mock_client_class.return_value = mock_client

            await converter.convert("https://example.com/page")

        # Verify Jina URL format
        call_args = mock_client.get.call_args
        called_url = call_args[0][0]
        assert called_url == "https://r.jina.ai/https://example.com/page"

    @pytest.mark.asyncio
    async def test_convert_url_with_api_key(self, converter):
        """Test URL conversion includes API key when set."""
        mock_response = MagicMock()
        mock_response.text = "# Content"
        mock_response.raise_for_status = MagicMock()

        with patch.dict(os.environ, {"JINA_API_KEY": "test-api-key"}):
            with patch("httpx.AsyncClient") as mock_client_class:
                mock_client = AsyncMock()
                mock_client.get.return_value = mock_response
                mock_client.__aenter__.return_value = mock_client
                mock_client.__aexit__.return_value = None
                mock_client_class.return_value = mock_client

                await converter.convert("https://example.com/page")

        call_args = mock_client.get.call_args
        headers = call_args[1].get("headers", {})
        assert headers.get("Authorization") == "Bearer test-api-key"

    @pytest.mark.asyncio
    async def test_convert_url_without_api_key(self, converter):
        """Test URL conversion works without API key."""
        mock_response = MagicMock()
        mock_response.text = "# Content"
        mock_response.raise_for_status = MagicMock()

        with patch.dict(os.environ, {}, clear=True):
            # Ensure JINA_API_KEY is not set
            os.environ.pop("JINA_API_KEY", None)
            with patch("httpx.AsyncClient") as mock_client_class:
                mock_client = AsyncMock()
                mock_client.get.return_value = mock_response
                mock_client.__aenter__.return_value = mock_client
                mock_client.__aexit__.return_value = None
                mock_client_class.return_value = mock_client

                result = await converter.convert("https://example.com/page")

        assert "success: true" in result


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
        mock_response = MagicMock()
        mock_response.text = "# Cached URL Content"
        mock_response.raise_for_status = MagicMock()

        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = AsyncMock()
            mock_client.get.return_value = mock_response
            mock_client.__aenter__.return_value = mock_client
            mock_client.__aexit__.return_value = None
            mock_client_class.return_value = mock_client

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
        mock_response1 = MagicMock()
        mock_response1.text = "# Original Content"
        mock_response1.raise_for_status = MagicMock()

        mock_response2 = MagicMock()
        mock_response2.text = "# Updated Content"
        mock_response2.raise_for_status = MagicMock()

        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = AsyncMock()
            mock_client.get.side_effect = [mock_response1, mock_response2]
            mock_client.__aenter__.return_value = mock_client
            mock_client.__aexit__.return_value = None
            mock_client_class.return_value = mock_client

            # First conversion
            result1 = await converter.convert("https://example.com/page")
            assert "Original Content" in result1

            # Force refresh
            result2 = await converter.convert("https://example.com/page", force_refresh=True)
            assert "Updated Content" in result2

        # Should have been called twice
        assert mock_client.get.call_count == 2


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
    async def test_url_timeout_error(self, converter):
        """Test timeout error for URL conversion."""
        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = AsyncMock()
            mock_client.get.side_effect = httpx.TimeoutException("Request timed out")
            mock_client.__aenter__.return_value = mock_client
            mock_client.__aexit__.return_value = None
            mock_client_class.return_value = mock_client

            with pytest.raises(httpx.TimeoutException):
                await converter.convert("https://example.com/slow-page")

    @pytest.mark.asyncio
    async def test_url_http_error(self, converter):
        """Test HTTP error for URL conversion."""
        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = AsyncMock()
            mock_response = MagicMock()
            mock_response.raise_for_status.side_effect = httpx.HTTPStatusError(
                "404 Not Found",
                request=MagicMock(),
                response=MagicMock()
            )
            mock_client.get.return_value = mock_response
            mock_client.__aenter__.return_value = mock_client
            mock_client.__aexit__.return_value = None
            mock_client_class.return_value = mock_client

            with pytest.raises(httpx.HTTPStatusError):
                await converter.convert("https://example.com/not-found")

    @pytest.mark.asyncio
    async def test_pdf_conversion_not_implemented(self, converter, temp_pdf_file):
        """Test that PDF conversion raises NotImplementedError."""
        with pytest.raises(NotImplementedError) as exc_info:
            await converter.convert(temp_pdf_file)

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
        mock_response = MagicMock()
        mock_response.text = "# Content"
        mock_response.raise_for_status = MagicMock()

        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = AsyncMock()
            mock_client.get.return_value = mock_response
            mock_client.__aenter__.return_value = mock_client
            mock_client.__aexit__.return_value = None
            mock_client_class.return_value = mock_client

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
    async def test_custom_timeout_passed_to_client(self, converter):
        """Test that custom timeout is passed to HTTP client."""
        mock_response = MagicMock()
        mock_response.text = "# Content"
        mock_response.raise_for_status = MagicMock()

        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = AsyncMock()
            mock_client.get.return_value = mock_response
            mock_client.__aenter__.return_value = mock_client
            mock_client.__aexit__.return_value = None
            mock_client_class.return_value = mock_client

            await converter.convert("https://example.com/page", timeout=60)

        # Check timeout was passed to AsyncClient
        mock_client_class.assert_called_once_with(timeout=60)

    @pytest.mark.asyncio
    async def test_default_timeout(self, converter):
        """Test default timeout value."""
        mock_response = MagicMock()
        mock_response.text = "# Content"
        mock_response.raise_for_status = MagicMock()

        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = AsyncMock()
            mock_client.get.return_value = mock_response
            mock_client.__aenter__.return_value = mock_client
            mock_client.__aexit__.return_value = None
            mock_client_class.return_value = mock_client

            await converter.convert("https://example.com/page")

        # Default timeout should be 30
        mock_client_class.assert_called_once_with(timeout=30)


# ============================================================================
# Test Source Type Detection
# ============================================================================


class TestConverterSourceTypeDetection:
    """Test source type detection logic."""

    @pytest.mark.asyncio
    async def test_http_url_detected(self, converter):
        """Test that http:// URLs are detected correctly."""
        mock_response = MagicMock()
        mock_response.text = "# Content"
        mock_response.raise_for_status = MagicMock()

        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = AsyncMock()
            mock_client.get.return_value = mock_response
            mock_client.__aenter__.return_value = mock_client
            mock_client.__aexit__.return_value = None
            mock_client_class.return_value = mock_client

            result = await converter.convert("http://example.com/page")

        assert "source_type: url" in result

    @pytest.mark.asyncio
    async def test_https_url_detected(self, converter):
        """Test that https:// URLs are detected correctly."""
        mock_response = MagicMock()
        mock_response.text = "# Content"
        mock_response.raise_for_status = MagicMock()

        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = AsyncMock()
            mock_client.get.return_value = mock_response
            mock_client.__aenter__.return_value = mock_client
            mock_client.__aexit__.return_value = None
            mock_client_class.return_value = mock_client

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
        with pytest.raises(NotImplementedError) as exc_info:
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
