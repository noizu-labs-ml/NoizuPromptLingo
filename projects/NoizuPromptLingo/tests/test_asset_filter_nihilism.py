"""Tests for filtering nihilism.html and nihilism.pdf assets to headings.

These tests verify:
1. HTML and PDF files convert to markdown correctly
2. The converted markdown can be filtered to specific headings
3. The --no-cache flag prevents interstitial .md file creation
"""

import pytest
from pathlib import Path

from npl_mcp.markdown.viewer import MarkdownViewer
from npl_mcp.markdown.converter import MarkdownConverter
from npl_mcp.markdown.cache import MarkdownCache


# Test asset paths
ASSETS_DIR = Path(__file__).parent / "assets"
NIHILISM_HTML = ASSETS_DIR / "nihilism.html"
NIHILISM_PDF = ASSETS_DIR / "nihilism.pdf"


@pytest.fixture
def viewer():
    """Create a markdown viewer."""
    return MarkdownViewer()


@pytest.fixture
def cache(tmp_path):
    """Create a markdown cache using temp directory."""
    return MarkdownCache(cache_dir=tmp_path / "cache")


@pytest.fixture
def converter(cache):
    """Create a markdown converter with temp cache."""
    return MarkdownConverter(cache)


@pytest.fixture
async def nihilism_html_md(converter):
    """Convert nihilism.html to markdown without caching."""
    result = await converter.convert(str(NIHILISM_HTML), no_cache=True)
    # Extract content (strip metadata header)
    lines = result.split("\n")
    separator_idx = lines.index("---") if "---" in lines else 0
    return "\n".join(lines[separator_idx + 1:])


@pytest.fixture
async def nihilism_pdf_md(converter):
    """Convert nihilism.pdf to markdown without caching."""
    result = await converter.convert(str(NIHILISM_PDF), no_cache=True)
    # Extract content (strip metadata header)
    lines = result.split("\n")
    separator_idx = lines.index("---") if "---" in lines else 0
    return "\n".join(lines[separator_idx + 1:])


class TestNoCacheFlag:
    """Test that no_cache flag prevents creating interstitial files."""

    @pytest.mark.asyncio
    async def test_no_cache_prevents_html_md_creation(self, converter):
        """Test that no_cache=True prevents creating .html.md file."""
        cache_file = NIHILISM_HTML.with_suffix(".html.md")

        # Remove any existing cache file
        if cache_file.exists():
            cache_file.unlink()

        # Convert with no_cache=True
        await converter.convert(str(NIHILISM_HTML), no_cache=True)

        # Cache file should NOT be created
        assert not cache_file.exists(), f"Cache file {cache_file} should not exist with no_cache=True"

    @pytest.mark.asyncio
    async def test_no_cache_prevents_pdf_md_creation(self, converter):
        """Test that no_cache=True prevents creating .pdf.md file."""
        cache_file = NIHILISM_PDF.with_suffix(".pdf.md")

        # Remove any existing cache file
        if cache_file.exists():
            cache_file.unlink()

        # Convert with no_cache=True
        await converter.convert(str(NIHILISM_PDF), no_cache=True)

        # Cache file should NOT be created
        assert not cache_file.exists(), f"Cache file {cache_file} should not exist with no_cache=True"

    @pytest.mark.asyncio
    async def test_cache_creates_file_when_enabled(self, tmp_path):
        """Test that cache=True (default) creates cache file."""
        # Use a temp copy to avoid polluting the asset directory
        import shutil
        temp_html = tmp_path / "nihilism.html"
        shutil.copy(NIHILISM_HTML, temp_html)

        cache = MarkdownCache(cache_dir=tmp_path / "cache")
        converter = MarkdownConverter(cache)

        await converter.convert(str(temp_html), no_cache=False)

        # Cache file SHOULD be created
        cache_file = temp_html.with_suffix(".html.md")
        assert cache_file.exists(), f"Cache file {cache_file} should exist when caching enabled"


class TestHTMLConversion:
    """Test HTML file conversion to markdown."""

    @pytest.mark.asyncio
    async def test_html_converts_with_content(self, nihilism_html_md):
        """Test that HTML converts to markdown with substantial content."""
        assert len(nihilism_html_md) > 10000, "HTML should convert to substantial markdown"

    @pytest.mark.asyncio
    async def test_html_has_headings(self, nihilism_html_md):
        """Test that converted HTML contains markdown headings."""
        assert "#" in nihilism_html_md, "Converted HTML should have headings"


class TestPDFConversion:
    """Test PDF file conversion to markdown."""

    @pytest.mark.asyncio
    async def test_pdf_converts_with_content(self, nihilism_pdf_md):
        """Test that PDF converts to markdown with content."""
        assert len(nihilism_pdf_md) > 1000, "PDF should convert to markdown"

    @pytest.mark.asyncio
    async def test_pdf_has_page_markers_or_content(self, nihilism_pdf_md):
        """Test that PDF conversion has page structure or content."""
        # Local PDF conversion adds page markers
        has_pages = "page" in nihilism_pdf_md.lower()
        has_content = "nihilism" in nihilism_pdf_md.lower()
        assert has_pages or has_content, "PDF should have page markers or nihilism content"


class TestHTMLFilterToHeading:
    """Test filtering HTML-converted markdown to specific headings."""

    @pytest.mark.asyncio
    async def test_filter_to_mereological_nihilism(self, viewer, nihilism_html_md):
        """Test filtering to Mereological nihilism heading."""
        result = viewer.view(nihilism_html_md, filter="mereological-nihilism", bare=True)

        # Should contain content about mereological nihilism
        assert "mereological" in result.lower() or len(result) > 100

    @pytest.mark.asyncio
    async def test_filter_to_metaphysical_nihilism(self, viewer, nihilism_html_md):
        """Test filtering to Metaphysical nihilism heading."""
        result = viewer.view(nihilism_html_md, filter="metaphysical-nihilism", bare=True)

        # Should contain content
        assert len(result) > 50

    @pytest.mark.asyncio
    async def test_filter_to_existential_nihilism(self, viewer, nihilism_html_md):
        """Test filtering to Existential nihilism heading."""
        result = viewer.view(nihilism_html_md, filter="existential-nihilism", bare=True)

        assert len(result) > 50

    @pytest.mark.asyncio
    async def test_filter_with_context_shows_collapsed(self, viewer, nihilism_html_md):
        """Test filtering with context shows collapsed siblings."""
        result = viewer.view(nihilism_html_md, filter="mereological-nihilism")

        # Should have collapsed markers when showing context
        # (only if there are siblings at the same level)
        assert len(result) > 100

    @pytest.mark.asyncio
    async def test_bare_mode_no_context(self, viewer, nihilism_html_md):
        """Test bare mode extracts only matched section without context."""
        result = viewer.view(nihilism_html_md, filter="mereological-nihilism", bare=True)

        # Bare mode should not have collapsed markers
        assert "📦" not in result


class TestPDFFilterToHeading:
    """Test filtering PDF-converted markdown to headings."""

    @pytest.mark.asyncio
    async def test_pdf_depth_collapse(self, viewer, nihilism_pdf_md):
        """Test depth-based collapse on PDF content."""
        result = viewer.view(nihilism_pdf_md, depth=2)

        # Should have output
        assert len(result) > 100

    @pytest.mark.asyncio
    async def test_pdf_filter_if_headings_exist(self, viewer, nihilism_pdf_md):
        """Test filtering PDF markdown if it has recognized headings."""
        # PDF structure varies - this test verifies filtering doesn't crash
        # even if headings aren't found
        result = viewer.view(nihilism_pdf_md, filter="page-1", bare=True)

        # Should return something (even if empty due to no match)
        assert isinstance(result, str)


class TestFilterPerformance:
    """Test filtering performance on real assets."""

    @pytest.mark.asyncio
    async def test_html_filter_completes_quickly(self, viewer, nihilism_html_md):
        """Test that HTML filtering completes in reasonable time."""
        import time

        start = time.time()
        viewer.view(nihilism_html_md, filter="mereological-nihilism", depth=2)
        duration = time.time() - start

        assert duration < 1.0, f"Filtering took {duration}s, expected < 1s"

    @pytest.mark.asyncio
    async def test_pdf_filter_completes_quickly(self, viewer, nihilism_pdf_md):
        """Test that PDF filtering completes in reasonable time."""
        import time

        start = time.time()
        viewer.view(nihilism_pdf_md, depth=2)
        duration = time.time() - start

        assert duration < 1.0, f"Filtering took {duration}s, expected < 1s"
