"""Tests for the Screenshot tool (browser/screenshot.py).

Mocks Playwright entirely so tests run without installed browsers.
"""

import base64
import io
from unittest.mock import AsyncMock, MagicMock, patch

import pytest
from PIL import Image

from npl_mcp.browser.screenshot import screenshot, _resize


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _make_png(width: int = 1280, height: int = 720, color: str = "red") -> bytes:
    """Create a minimal PNG image of the given size."""
    img = Image.new("RGB", (width, height), color=color)
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    return buf.getvalue()


def _mock_playwright(png_bytes: bytes):
    """Build a nested mock that mimics the Playwright async API."""
    page = AsyncMock()
    page.goto = AsyncMock()
    page.screenshot = AsyncMock(return_value=png_bytes)

    browser = AsyncMock()
    browser.new_page = AsyncMock(return_value=page)
    browser.close = AsyncMock()

    pw = AsyncMock()
    pw.chromium.launch = AsyncMock(return_value=browser)
    pw.stop = AsyncMock()

    # async_playwright().start() returns the pw object
    starter = AsyncMock()
    starter.start = AsyncMock(return_value=pw)

    return starter, page


# ---------------------------------------------------------------------------
# _resize unit tests (no Playwright needed)
# ---------------------------------------------------------------------------

class TestResize:

    def test_no_constraints(self):
        png = _make_png(800, 600)
        out, w, h = _resize(png)
        assert w == 800
        assert h == 600

    def test_max_width_scales_down(self):
        png = _make_png(1000, 500)
        out, w, h = _resize(png, max_width=500)
        assert w == 500
        assert h == 250  # aspect ratio preserved

    def test_max_height_scales_down(self):
        png = _make_png(800, 1000)
        out, w, h = _resize(png, max_height=500)
        assert w == 400  # aspect ratio preserved
        assert h == 500

    def test_both_constraints_width_dominant(self):
        png = _make_png(2000, 1000)
        out, w, h = _resize(png, max_width=1000, max_height=800)
        # max_width: 2000→1000, 1000→500. 500 < 800, so width constraint dominates.
        assert w == 1000
        assert h == 500

    def test_both_constraints_height_dominant(self):
        png = _make_png(1000, 2000)
        out, w, h = _resize(png, max_width=800, max_height=500)
        # max_width: 1000→800, 2000→1600. 1600 > 500, so height constraint also applies.
        # max_height: 1600→500, 800→250
        assert h == 500
        assert w == 250

    def test_already_within_bounds(self):
        png = _make_png(100, 100)
        out, w, h = _resize(png, max_width=500, max_height=500)
        assert w == 100
        assert h == 100
        # Should return original bytes (no re-encode)
        assert out == png

    def test_output_is_valid_png(self):
        png = _make_png(1000, 1000)
        out, w, h = _resize(png, max_width=256)
        img = Image.open(io.BytesIO(out))
        assert img.format == "PNG"
        assert img.size == (256, 256)


# ---------------------------------------------------------------------------
# screenshot() integration tests (Playwright mocked)
# ---------------------------------------------------------------------------

class TestScreenshot:

    @pytest.mark.asyncio
    async def test_returns_base64_when_no_output(self):
        png = _make_png(1280, 720)
        starter, page = _mock_playwright(png)

        with patch("npl_mcp.browser.screenshot.async_playwright", return_value=starter):
            result = await screenshot("https://example.com")

        assert result["url"] == "https://example.com"
        assert "base64" in result
        assert "output_file" not in result
        assert result["width"] == 1280
        assert result["height"] == 720
        # Verify the base64 decodes to valid PNG
        decoded = base64.b64decode(result["base64"])
        img = Image.open(io.BytesIO(decoded))
        assert img.size == (1280, 720)

    @pytest.mark.asyncio
    async def test_saves_to_file(self, tmp_path):
        png = _make_png(800, 600)
        starter, page = _mock_playwright(png)
        out_file = tmp_path / "shot.png"

        with patch("npl_mcp.browser.screenshot.async_playwright", return_value=starter):
            result = await screenshot("https://example.com", output=str(out_file))

        assert result["output_file"] == str(out_file)
        assert "base64" not in result
        assert out_file.exists()
        img = Image.open(out_file)
        assert img.size == (800, 600)

    @pytest.mark.asyncio
    async def test_resize_with_max_width(self):
        png = _make_png(2000, 1000)
        starter, page = _mock_playwright(png)

        with patch("npl_mcp.browser.screenshot.async_playwright", return_value=starter):
            result = await screenshot("https://example.com", max_width=500)

        assert result["width"] == 500
        assert result["height"] == 250

    @pytest.mark.asyncio
    async def test_resize_with_max_height(self):
        png = _make_png(1000, 2000)
        starter, page = _mock_playwright(png)

        with patch("npl_mcp.browser.screenshot.async_playwright", return_value=starter):
            result = await screenshot("https://example.com", max_height=500)

        assert result["width"] == 250
        assert result["height"] == 500

    @pytest.mark.asyncio
    async def test_full_page_passed_to_playwright(self):
        png = _make_png(1280, 720)
        starter, page = _mock_playwright(png)

        with patch("npl_mcp.browser.screenshot.async_playwright", return_value=starter):
            await screenshot("https://example.com", full_page=True)

        page.screenshot.assert_called_once_with(full_page=True, type="png")

    @pytest.mark.asyncio
    async def test_viewport_only_by_default(self):
        png = _make_png(1280, 720)
        starter, page = _mock_playwright(png)

        with patch("npl_mcp.browser.screenshot.async_playwright", return_value=starter):
            await screenshot("https://example.com")

        page.screenshot.assert_called_once_with(full_page=False, type="png")

    @pytest.mark.asyncio
    async def test_creates_output_directories(self, tmp_path):
        png = _make_png(100, 100)
        starter, _ = _mock_playwright(png)
        deep_path = tmp_path / "a" / "b" / "c" / "shot.png"

        with patch("npl_mcp.browser.screenshot.async_playwright", return_value=starter):
            result = await screenshot("https://example.com", output=str(deep_path))

        assert deep_path.exists()

    @pytest.mark.asyncio
    async def test_browser_error_returns_error_dict(self):
        starter = AsyncMock()
        pw = AsyncMock()
        pw.chromium.launch = AsyncMock(side_effect=RuntimeError("Browsers not installed"))
        pw.stop = AsyncMock()
        starter.start = AsyncMock(return_value=pw)

        with patch("npl_mcp.browser.screenshot.async_playwright", return_value=starter):
            result = await screenshot("https://example.com")

        assert "error" in result
        assert "RuntimeError" in result["error"]
        assert "base64" not in result

    @pytest.mark.asyncio
    async def test_resize_and_save_to_file(self, tmp_path):
        png = _make_png(2000, 1000)
        starter, _ = _mock_playwright(png)
        out_file = tmp_path / "resized.png"

        with patch("npl_mcp.browser.screenshot.async_playwright", return_value=starter):
            result = await screenshot(
                "https://example.com",
                output=str(out_file),
                max_width=500,
                max_height=500,
            )

        assert result["width"] == 500
        assert result["height"] == 250
        img = Image.open(out_file)
        assert img.size == (500, 250)
