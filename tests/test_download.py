"""Tests for the Download tool (browser/download.py).

Mocks httpx for URL downloads. Uses real filesystem for file copies.
"""

import io
from pathlib import Path
from unittest.mock import AsyncMock, MagicMock, patch

import httpx
import pytest

from npl_mcp.browser.download import download, _copy_file, _derive_filename


# ---------------------------------------------------------------------------
# File copy tests (no network needed)
# ---------------------------------------------------------------------------

class TestCopyFile:

    def test_copy_existing_file(self, tmp_path):
        src = tmp_path / "source.txt"
        src.write_text("hello world")
        dest = tmp_path / "dest.txt"

        _copy_file(str(src), dest)
        assert dest.read_text() == "hello world"

    def test_copy_preserves_metadata(self, tmp_path):
        src = tmp_path / "source.txt"
        src.write_text("data")
        dest = tmp_path / "dest.txt"

        _copy_file(str(src), dest)
        assert dest.stat().st_size == src.stat().st_size

    def test_copy_nonexistent_raises(self, tmp_path):
        dest = tmp_path / "dest.txt"
        with pytest.raises(FileNotFoundError, match="Source file not found"):
            _copy_file("/nonexistent/file.txt", dest)


# ---------------------------------------------------------------------------
# download() integration tests
# ---------------------------------------------------------------------------

def _mock_stream_response(content: bytes, status_code: int = 200):
    """Build a mock httpx stream response."""
    response = AsyncMock()
    response.status_code = status_code
    response.raise_for_status = MagicMock()
    if status_code >= 400:
        response.raise_for_status.side_effect = httpx.HTTPStatusError(
            "error", request=MagicMock(), response=MagicMock(status_code=status_code)
        )

    async def aiter_bytes(chunk_size=65536):
        yield content

    response.aiter_bytes = aiter_bytes

    # Make it work as async context manager
    response.__aenter__ = AsyncMock(return_value=response)
    response.__aexit__ = AsyncMock(return_value=False)
    return response


class TestDownload:

    @pytest.mark.asyncio
    async def test_download_url(self, tmp_path):
        out_file = tmp_path / "output.bin"
        content = b"file content here"
        mock_resp = _mock_stream_response(content)

        mock_client = AsyncMock()
        mock_client.stream = MagicMock(return_value=mock_resp)
        mock_client.__aenter__ = AsyncMock(return_value=mock_client)
        mock_client.__aexit__ = AsyncMock(return_value=False)

        with patch("npl_mcp.browser.download.httpx.AsyncClient", return_value=mock_client):
            result = await download("https://example.com/file.bin", str(out_file))

        assert result["source"] == "https://example.com/file.bin"
        assert result["source_type"] == "url"
        assert result["output_file"] == str(out_file)
        assert result["size_bytes"] == len(content)
        assert "error" not in result
        assert out_file.read_bytes() == content

    @pytest.mark.asyncio
    async def test_download_local_file(self, tmp_path):
        src = tmp_path / "source.txt"
        src.write_text("local content")
        out_file = tmp_path / "dest.txt"

        result = await download(str(src), str(out_file))

        assert result["source_type"] == "file"
        assert result["output_file"] == str(out_file)
        assert result["size_bytes"] == len("local content")
        assert "error" not in result
        assert out_file.read_text() == "local content"

    @pytest.mark.asyncio
    async def test_creates_parent_directories(self, tmp_path):
        src = tmp_path / "source.txt"
        src.write_text("data")
        deep_path = tmp_path / "a" / "b" / "c" / "dest.txt"

        result = await download(str(src), str(deep_path))

        assert deep_path.exists()
        assert deep_path.read_text() == "data"
        assert "error" not in result

    @pytest.mark.asyncio
    async def test_file_not_found_returns_error(self, tmp_path):
        out_file = tmp_path / "dest.txt"

        result = await download("/nonexistent/path/file.txt", str(out_file))

        assert "error" in result
        assert "FileNotFoundError" in result["error"]

    @pytest.mark.asyncio
    async def test_url_error_returns_error(self, tmp_path):
        out_file = tmp_path / "output.bin"

        with patch(
            "npl_mcp.browser.download.httpx.AsyncClient",
            side_effect=httpx.ConnectError("connection refused"),
        ):
            result = await download("https://example.com/fail", str(out_file))

        assert "error" in result
        assert "ConnectError" in result["error"]

    @pytest.mark.asyncio
    async def test_overwrite_existing_file(self, tmp_path):
        src = tmp_path / "source.txt"
        src.write_text("new content")
        out_file = tmp_path / "dest.txt"
        out_file.write_text("old content")

        result = await download(str(src), str(out_file))

        assert out_file.read_text() == "new content"
        assert "error" not in result


class TestDeriveFilename:

    def test_url_with_filename(self):
        assert _derive_filename("https://example.com/docs/file.pdf") == "file.pdf"

    def test_url_root_path(self):
        assert _derive_filename("https://example.com/") == "download"

    def test_url_no_path(self):
        assert _derive_filename("https://example.com") == "download"

    def test_local_file(self):
        assert _derive_filename("/home/user/docs/report.txt") == "report.txt"


class TestDownloadInline:
    """Test download returning content inline when out is omitted."""

    @pytest.mark.asyncio
    async def test_url_inline_returns_content(self):
        mock_response = MagicMock()
        mock_response.text = "<svg>content</svg>"
        mock_response.status_code = 200
        mock_response.raise_for_status = MagicMock()

        mock_client = AsyncMock()
        mock_client.get = AsyncMock(return_value=mock_response)
        mock_client.__aenter__ = AsyncMock(return_value=mock_client)
        mock_client.__aexit__ = AsyncMock(return_value=False)

        with patch("npl_mcp.browser.download.httpx.AsyncClient", return_value=mock_client):
            result = await download("https://example.com/logo.svg")

        assert result["source_type"] == "url"
        assert result["content"] == "<svg>content</svg>"
        assert result["content_length"] == 18
        assert "output_file" not in result

    @pytest.mark.asyncio
    async def test_file_inline_returns_content(self, tmp_path):
        src = tmp_path / "data.txt"
        src.write_text("inline text content")

        result = await download(str(src))

        assert result["source_type"] == "file"
        assert result["content"] == "inline text content"
        assert result["content_length"] == 19
        assert "output_file" not in result

    @pytest.mark.asyncio
    async def test_empty_out_treated_as_inline(self, tmp_path):
        src = tmp_path / "data.txt"
        src.write_text("content")

        result = await download(str(src), out="")

        assert "content" in result
        assert "output_file" not in result
