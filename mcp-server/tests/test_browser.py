"""Tests for browser automation module.

These tests require playwright browsers to be installed:
    playwright install chromium
"""

import pytest
import pytest_asyncio
import base64
from pathlib import Path
from io import BytesIO

from PIL import Image

# Skip all tests if playwright is not installed
pytest.importorskip("playwright")


@pytest.fixture
def sample_png_bytes():
    """Generate a simple PNG for testing."""
    img = Image.new("RGBA", (100, 100), (255, 0, 0, 255))
    buffer = BytesIO()
    img.save(buffer, format="PNG")
    return buffer.getvalue()


@pytest.fixture
def sample_png_bytes_different():
    """Generate a different PNG for diff testing."""
    img = Image.new("RGBA", (100, 100), (0, 255, 0, 255))
    buffer = BytesIO()
    img.save(buffer, format="PNG")
    return buffer.getvalue()


@pytest.fixture
def sample_png_bytes_similar():
    """Generate a similar PNG (slight difference) for diff testing."""
    img = Image.new("RGBA", (100, 100), (255, 0, 0, 255))
    # Add a small change
    img.putpixel((50, 50), (0, 255, 0, 255))
    buffer = BytesIO()
    img.save(buffer, format="PNG")
    return buffer.getvalue()


class TestViewportParsing:
    """Test viewport string parsing."""

    def test_parse_desktop_preset(self):
        from npl_mcp.browser.capture import parse_viewport
        width, height, preset = parse_viewport("desktop")
        assert width == 1280
        assert height == 720
        assert preset == "desktop"

    def test_parse_mobile_preset(self):
        from npl_mcp.browser.capture import parse_viewport
        width, height, preset = parse_viewport("mobile")
        assert width == 375
        assert height == 667
        assert preset == "mobile"

    def test_parse_custom_dimensions(self):
        from npl_mcp.browser.capture import parse_viewport
        width, height, preset = parse_viewport("800x600")
        assert width == 800
        assert height == 600
        assert preset is None

    def test_parse_case_insensitive(self):
        from npl_mcp.browser.capture import parse_viewport
        width, height, preset = parse_viewport("DESKTOP")
        assert width == 1280
        assert preset == "desktop"

    def test_parse_invalid_falls_back_to_desktop(self):
        from npl_mcp.browser.capture import parse_viewport
        width, height, preset = parse_viewport("invalid")
        assert width == 1280
        assert height == 720
        assert preset == "desktop"


class TestDiffStatus:
    """Test diff status classification."""

    def test_classify_identical(self):
        from npl_mcp.browser.diff import classify_diff, DiffStatus
        assert classify_diff(0) == DiffStatus.IDENTICAL

    def test_classify_minor(self):
        from npl_mcp.browser.diff import classify_diff, DiffStatus
        assert classify_diff(0.5) == DiffStatus.MINOR
        assert classify_diff(0.99) == DiffStatus.MINOR

    def test_classify_moderate(self):
        from npl_mcp.browser.diff import classify_diff, DiffStatus
        assert classify_diff(1.5) == DiffStatus.MODERATE
        assert classify_diff(4.99) == DiffStatus.MODERATE

    def test_classify_major(self):
        from npl_mcp.browser.diff import classify_diff, DiffStatus
        assert classify_diff(5.1) == DiffStatus.MAJOR
        assert classify_diff(50) == DiffStatus.MAJOR


class TestPixelmatch:
    """Test pixelmatch algorithm."""

    def test_identical_images(self, sample_png_bytes):
        """Identical images should have 0 diff."""
        from npl_mcp.browser.diff import compare_screenshots, DiffStatus

        result = compare_screenshots(sample_png_bytes, sample_png_bytes)

        assert result.diff_percentage == 0
        assert result.diff_pixels == 0
        assert result.status == DiffStatus.IDENTICAL
        assert result.dimensions_match is True

    def test_completely_different_images(self, sample_png_bytes, sample_png_bytes_different):
        """Completely different images should have high diff."""
        from npl_mcp.browser.diff import compare_screenshots, DiffStatus

        result = compare_screenshots(sample_png_bytes, sample_png_bytes_different)

        assert result.diff_percentage > 50  # Most pixels should differ
        assert result.status == DiffStatus.MAJOR
        assert result.dimensions_match is True

    def test_similar_images(self, sample_png_bytes, sample_png_bytes_similar):
        """Similar images should have small diff."""
        from npl_mcp.browser.diff import compare_screenshots, DiffStatus

        result = compare_screenshots(sample_png_bytes, sample_png_bytes_similar)

        assert result.diff_percentage < 1  # Only a few pixels differ
        assert result.status in (DiffStatus.IDENTICAL, DiffStatus.MINOR)
        assert result.dimensions_match is True

    def test_dimension_mismatch(self, sample_png_bytes):
        """Different dimensions should report mismatch."""
        from npl_mcp.browser.diff import compare_screenshots, DiffStatus

        # Create image with different dimensions
        img = Image.new("RGBA", (200, 200), (255, 0, 0, 255))
        buffer = BytesIO()
        img.save(buffer, format="PNG")
        different_size = buffer.getvalue()

        result = compare_screenshots(sample_png_bytes, different_size)

        assert result.dimensions_match is False
        assert result.diff_percentage == 100
        assert result.status == DiffStatus.MAJOR

    def test_diff_image_generated(self, sample_png_bytes, sample_png_bytes_different):
        """Diff should generate a valid PNG image."""
        from npl_mcp.browser.diff import compare_screenshots

        result = compare_screenshots(sample_png_bytes, sample_png_bytes_different)

        # Verify diff image is valid PNG
        diff_img = Image.open(BytesIO(result.diff_image))
        assert diff_img.mode == "RGBA"
        assert diff_img.size == (100, 100)


class TestColorDistance:
    """Test color distance calculations."""

    def test_identical_colors_zero_distance(self):
        from npl_mcp.browser.diff import color_distance_yiq
        distance = color_distance_yiq(255, 0, 0, 255, 0, 0)
        assert distance == 0

    def test_different_colors_nonzero_distance(self):
        from npl_mcp.browser.diff import color_distance_yiq
        # Red vs Green
        distance = color_distance_yiq(255, 0, 0, 0, 255, 0)
        assert distance > 0

    def test_black_vs_white_large_distance(self):
        from npl_mcp.browser.diff import color_distance_yiq
        # Black vs White should have large distance
        distance = color_distance_yiq(0, 0, 0, 255, 255, 255)
        assert distance > 10000  # Large Y difference


class TestBrowserSession:
    """Test browser session management."""

    @pytest.mark.asyncio
    async def test_get_or_create_session(self):
        """Test session creation."""
        from npl_mcp.browser.interact import get_or_create_session, close_session

        session = await get_or_create_session("test-session-1")
        assert session.session_id == "test-session-1"

        # Same ID should return same session
        session2 = await get_or_create_session("test-session-1")
        assert session2 is session

        # Different ID should return different session
        session3 = await get_or_create_session("test-session-2")
        assert session3 is not session

        # Cleanup
        await close_session("test-session-1")
        await close_session("test-session-2")

    @pytest.mark.asyncio
    async def test_list_sessions(self):
        """Test listing sessions."""
        from npl_mcp.browser.interact import (
            get_or_create_session,
            list_sessions,
            close_session
        )

        await get_or_create_session("list-test-1")
        await get_or_create_session("list-test-2")

        sessions = await list_sessions()
        assert "list-test-1" in sessions
        assert "list-test-2" in sessions

        await close_session("list-test-1")
        sessions = await list_sessions()
        assert "list-test-1" not in sessions
        assert "list-test-2" in sessions

        await close_session("list-test-2")


# Integration tests that require actual browser
# These are marked with slow marker for optional running
@pytest.mark.slow
class TestBrowserIntegration:
    """Integration tests requiring real browser.

    Run with: pytest -m slow
    """

    @pytest.mark.asyncio
    async def test_capture_screenshot_of_data_url(self):
        """Test capturing screenshot of a data URL page."""
        from npl_mcp.browser.capture import capture_screenshot

        # Use a simple data URL to avoid network dependency
        data_url = "data:text/html,<html><body><h1>Test</h1></body></html>"

        result = await capture_screenshot(
            url=data_url,
            viewport="desktop",
            theme="light",
            full_page=False,
        )

        assert result.image_bytes is not None
        assert len(result.image_bytes) > 0
        assert result.viewport_preset == "desktop"

        # Verify it's a valid PNG
        img = Image.open(BytesIO(result.image_bytes))
        assert img.format == "PNG"

    @pytest.mark.asyncio
    async def test_browser_navigate_and_screenshot(self):
        """Test navigating and taking screenshot."""
        from npl_mcp.browser.interact import get_or_create_session, close_session

        session = await get_or_create_session("nav-test")

        try:
            # Navigate to data URL
            result = await session.navigate(
                "data:text/html,<html><body><h1>Hello</h1></body></html>"
            )
            assert result.success

            # Get state
            state = await session.get_page_state()
            assert "Hello" in state.title or state.url.startswith("data:")

            # Take screenshot
            screenshot = await session.screenshot(full_page=False)
            assert len(screenshot) > 0

            # Verify valid PNG
            img = Image.open(BytesIO(screenshot))
            assert img.format == "PNG"

        finally:
            await close_session("nav-test")

    @pytest.mark.asyncio
    async def test_browser_click_and_fill(self):
        """Test clicking and filling form elements."""
        from npl_mcp.browser.interact import get_or_create_session, close_session

        session = await get_or_create_session("form-test")

        try:
            # Create a page with a form
            html = """
            <html>
            <body>
                <input id="name" type="text" />
                <button id="submit" onclick="document.getElementById('result').innerText='Submitted'">Submit</button>
                <div id="result"></div>
            </body>
            </html>
            """
            await session.navigate(f"data:text/html,{html}")

            # Fill the input
            fill_result = await session.fill("#name", "Test Value")
            assert fill_result.success

            # Click the button
            click_result = await session.click("#submit")
            assert click_result.success

            # Verify result
            text = await session.get_text("#result")
            assert text == "Submitted"

        finally:
            await close_session("form-test")

    @pytest.mark.asyncio
    async def test_browser_evaluate_js(self):
        """Test evaluating JavaScript in page context."""
        from npl_mcp.browser.interact import get_or_create_session, close_session

        session = await get_or_create_session("eval-test")

        try:
            await session.navigate("data:text/html,<html><body></body></html>")

            # Evaluate simple expression
            result = await session.evaluate("2 + 2")
            assert result == 4

            # Evaluate with DOM
            result = await session.evaluate("document.body.tagName")
            assert result == "BODY"

        finally:
            await close_session("eval-test")

    @pytest.mark.asyncio
    async def test_dark_mode_theme(self):
        """Test dark mode color scheme."""
        from npl_mcp.browser.capture import capture_screenshot

        html = """
        <html>
        <style>
            @media (prefers-color-scheme: dark) {
                body { background: black; color: white; }
            }
            @media (prefers-color-scheme: light) {
                body { background: white; color: black; }
            }
        </style>
        <body><h1>Theme Test</h1></body>
        </html>
        """

        # Capture in light mode
        light_result = await capture_screenshot(
            url=f"data:text/html,{html}",
            theme="light",
            full_page=False,
        )

        # Capture in dark mode
        dark_result = await capture_screenshot(
            url=f"data:text/html,{html}",
            theme="dark",
            full_page=False,
        )

        # Screenshots should be different
        assert light_result.image_bytes != dark_result.image_bytes
        assert light_result.theme == "light"
        assert dark_result.theme == "dark"
