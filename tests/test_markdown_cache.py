"""Tests for markdown cache module.

Tests cover:
- Cache path generation for local files (should create .pdf.md suffix)
- Cache path generation for URLs (should use .tmp/cache/markdown/)
- cache_get with valid/expired/missing entries
- cache_save and persistence
- Deterministic cache paths (same URL = same path)
"""

import os
import tempfile
import time
from pathlib import Path

import pytest

from npl_mcp.markdown.cache import MarkdownCache


# ============================================================================
# Fixtures
# ============================================================================


@pytest.fixture
def cache():
    """Create a cache with temporary directory."""
    with tempfile.TemporaryDirectory() as tmpdir:
        yield MarkdownCache(cache_dir=Path(tmpdir))


@pytest.fixture
def temp_file():
    """Create a temporary file for testing."""
    with tempfile.NamedTemporaryFile(mode="w", delete=False, suffix=".pdf") as f:
        f.write("test content")
        path = f.name
    yield path
    Path(path).unlink(missing_ok=True)


@pytest.fixture
def temp_markdown_file():
    """Create a temporary markdown file for testing."""
    with tempfile.NamedTemporaryFile(mode="w", delete=False, suffix=".md") as f:
        f.write("# Test Content\n\nThis is a test.")
        path = f.name
    yield path
    Path(path).unlink(missing_ok=True)


# ============================================================================
# Test Cache Path Generation - Local Files
# ============================================================================


class TestCachePathLocalFiles:
    """Test cache path generation for local files."""

    def test_local_file_cache_path_appends_md_suffix(self, cache):
        """Test cache path for local files appends .md to existing extension."""
        path = cache.get_cache_path("my-file.pdf")
        assert str(path).endswith("my-file.pdf.md")

    def test_local_markdown_file_cache_path(self, cache):
        """Test cache path for markdown files results in .md.md suffix."""
        path = cache.get_cache_path("document.md")
        assert str(path).endswith("document.md.md")

    def test_local_file_absolute_path(self, cache):
        """Test cache path for absolute file paths preserves directory."""
        path = cache.get_cache_path("/home/user/docs/report.pdf")
        assert str(path) == "/home/user/docs/report.pdf.md"

    def test_local_file_relative_path(self, cache):
        """Test cache path for relative file paths."""
        path = cache.get_cache_path("./docs/report.pdf")
        assert str(path).endswith("docs/report.pdf.md")

    def test_local_file_no_extension(self, cache):
        """Test cache path for files without extension."""
        path = cache.get_cache_path("README")
        assert str(path).endswith("README.md")

    def test_local_file_multiple_dots(self, cache):
        """Test cache path for files with multiple dots in name."""
        path = cache.get_cache_path("file.name.with.dots.txt")
        assert str(path).endswith("file.name.with.dots.txt.md")


# ============================================================================
# Test Cache Path Generation - URLs
# ============================================================================


class TestCachePathURLs:
    """Test cache path generation for URLs."""

    def test_url_cache_path_in_cache_dir(self, cache):
        """Test cache path for URLs is in cache directory."""
        path = cache.get_cache_path("https://example.com/docs")
        assert path.parent == cache.cache_dir

    def test_url_cache_path_contains_domain(self, cache):
        """Test cache path for URLs contains domain."""
        path = cache.get_cache_path("https://example.com/docs")
        assert "example.com" in str(path)

    def test_url_with_port_replaces_colon(self, cache):
        """Test cache path for URL with port replaces colon with underscore."""
        path = cache.get_cache_path("http://localhost:8080/api/docs")
        assert "localhost_8080" in str(path)

    def test_url_hash_consistency(self, cache):
        """Test that same URL always produces same cache path."""
        url = "https://example.com/page"
        path1 = cache.get_cache_path(url)
        path2 = cache.get_cache_path(url)
        assert path1 == path2

    def test_similar_urls_produce_different_paths(self, cache):
        """Test that similar but different URLs produce different cache paths."""
        path1 = cache.get_cache_path("https://example.com/page1")
        path2 = cache.get_cache_path("https://example.com/page2")
        assert path1 != path2

    def test_url_root_path_uses_index(self, cache):
        """Test that URL with root path uses 'index' as stem."""
        path = cache.get_cache_path("https://example.com/")
        assert "index" in str(path)

    def test_url_no_path_uses_index(self, cache):
        """Test that URL without path uses 'index' as stem."""
        path = cache.get_cache_path("https://example.com")
        assert "index" in str(path)

    def test_url_path_extracts_stem(self, cache):
        """Test that URL path stem is extracted correctly."""
        path = cache.get_cache_path("https://example.com/docs/api-reference.html")
        assert "api-reference" in str(path)

    def test_http_and_https_produce_different_paths(self, cache):
        """Test that http and https versions produce different cache paths."""
        path_http = cache.get_cache_path("http://example.com/page")
        path_https = cache.get_cache_path("https://example.com/page")
        assert path_http != path_https

    def test_url_with_query_params_included_in_hash(self, cache):
        """Test that query parameters affect the cache path hash."""
        path1 = cache.get_cache_path("https://example.com/page?v=1")
        path2 = cache.get_cache_path("https://example.com/page?v=2")
        assert path1 != path2


# ============================================================================
# Test Cache Storage and Retrieval
# ============================================================================


class TestCacheStorage:
    """Test cache storage and retrieval operations."""

    @pytest.mark.asyncio
    async def test_save_and_retrieve_url_cache(self, cache):
        """Test saving and retrieving URL cache."""
        url = "https://example.com/doc"
        content = "# Test Content\n\nThis is a test."

        await cache.save_cache(url, content)
        cached = await cache.get_cached(url)

        assert cached == content

    @pytest.mark.asyncio
    async def test_save_and_retrieve_file_cache(self, cache, temp_file):
        """Test saving and retrieving file cache."""
        content = "# File Content\n\nFrom file."

        await cache.save_cache(temp_file, content)
        cached = await cache.get_cached(temp_file)

        assert cached == content

    @pytest.mark.asyncio
    async def test_save_overwrites_existing_cache(self, cache):
        """Test that saving to cache overwrites existing content."""
        url = "https://example.com/doc"
        content1 = "# Original Content"
        content2 = "# Updated Content"

        await cache.save_cache(url, content1)
        await cache.save_cache(url, content2)
        cached = await cache.get_cached(url)

        assert cached == content2

    @pytest.mark.asyncio
    async def test_save_creates_parent_directories(self, cache):
        """Test that save_cache creates parent directories if needed."""
        import shutil

        # Remove cache dir to test creation
        shutil.rmtree(cache.cache_dir)
        assert not cache.cache_dir.exists()

        url = "https://example.com/doc"
        await cache.save_cache(url, "test content")

        assert cache.cache_dir.exists()

    @pytest.mark.asyncio
    async def test_cache_preserves_unicode_content(self, cache):
        """Test that cache preserves unicode content correctly."""
        url = "https://example.com/doc"
        content = "# Unicode Test\n\nHello World in Japanese: \u3053\u3093\u306b\u3061\u306f\nEmoji: \U0001F600"

        await cache.save_cache(url, content)
        cached = await cache.get_cached(url)

        assert cached == content

    @pytest.mark.asyncio
    async def test_cache_preserves_empty_content(self, cache):
        """Test that cache can store and retrieve empty content."""
        url = "https://example.com/empty"
        content = ""

        await cache.save_cache(url, content)
        cached = await cache.get_cached(url)

        assert cached == content


# ============================================================================
# Test Cache Expiry
# ============================================================================


class TestCacheExpiry:
    """Test cache expiry behavior."""

    @pytest.mark.asyncio
    async def test_url_cache_expires_after_max_age(self, cache):
        """Test cache expiry for URLs after max_age seconds."""
        url = "https://example.com/doc"
        content = "# Old Content"

        await cache.save_cache(url, content)
        cache_path = cache.get_cache_path(url)

        # Manually set mtime to old timestamp (2 hours ago)
        old_time = time.time() - 7200
        os.utime(cache_path, (old_time, old_time))

        # Should be expired with 1 hour max_age
        cached = await cache.get_cached(url, max_age=3600)
        assert cached is None

    @pytest.mark.asyncio
    async def test_url_cache_valid_within_max_age(self, cache):
        """Test cache is valid within max_age seconds."""
        url = "https://example.com/doc"
        content = "# Recent Content"

        await cache.save_cache(url, content)
        cache_path = cache.get_cache_path(url)

        # Set mtime to 30 minutes ago
        recent_time = time.time() - 1800
        os.utime(cache_path, (recent_time, recent_time))

        # Should be valid with 1 hour max_age
        cached = await cache.get_cached(url, max_age=3600)
        assert cached == content

    @pytest.mark.asyncio
    async def test_local_file_cache_never_expires(self, cache, temp_file):
        """Test that local file caches don't expire regardless of age."""
        content = "# File Content"

        await cache.save_cache(temp_file, content)
        cache_path = cache.get_cache_path(temp_file)

        # Set mtime to 1 year ago
        old_time = time.time() - (365 * 24 * 3600)
        os.utime(cache_path, (old_time, old_time))

        # Should still be cached (no expiry for local files)
        cached = await cache.get_cached(temp_file, max_age=3600)
        assert cached == content

    @pytest.mark.asyncio
    async def test_custom_max_age_parameter(self, cache):
        """Test custom max_age parameter works correctly."""
        url = "https://example.com/doc"
        content = "# Content"

        await cache.save_cache(url, content)
        cache_path = cache.get_cache_path(url)

        # Set mtime to 5 minutes ago
        recent_time = time.time() - 300
        os.utime(cache_path, (recent_time, recent_time))

        # Should be valid with 10 minute max_age
        cached = await cache.get_cached(url, max_age=600)
        assert cached == content

        # Should be expired with 1 minute max_age
        cached = await cache.get_cached(url, max_age=60)
        assert cached is None


# ============================================================================
# Test Missing Cache
# ============================================================================


class TestMissingCache:
    """Test behavior when cache is missing."""

    @pytest.mark.asyncio
    async def test_missing_url_cache_returns_none(self, cache):
        """Test that missing URL cache returns None."""
        cached = await cache.get_cached("https://example.com/nonexistent")
        assert cached is None

    @pytest.mark.asyncio
    async def test_missing_file_cache_returns_none(self, cache):
        """Test that missing file cache returns None."""
        cached = await cache.get_cached("/nonexistent/path/file.pdf")
        assert cached is None


# ============================================================================
# Test Cache Directory Creation
# ============================================================================


class TestCacheDirectoryCreation:
    """Test that cache creates necessary directories."""

    def test_cache_dir_created_on_init(self):
        """Test that cache directory is created on initialization."""
        with tempfile.TemporaryDirectory() as tmpdir:
            cache_dir = Path(tmpdir) / "nested" / "cache" / "dir"
            assert not cache_dir.exists()

            cache = MarkdownCache(cache_dir=cache_dir)
            assert cache_dir.exists()

    @pytest.mark.asyncio
    async def test_create_cache_dir_for_url(self, cache):
        """Test that cache dir is created if it doesn't exist during save."""
        import shutil

        shutil.rmtree(cache.cache_dir)
        assert not cache.cache_dir.exists()

        url = "https://example.com/doc"
        await cache.save_cache(url, "test content")

        assert cache.cache_dir.exists()
        cached = await cache.get_cached(url)
        assert cached == "test content"

    def test_default_cache_dir(self):
        """Test default cache directory path."""
        cache = MarkdownCache()
        assert cache.cache_dir == Path(".tmp/cache/markdown")
