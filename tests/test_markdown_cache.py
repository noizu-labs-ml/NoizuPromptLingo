"""Tests for markdown cache module."""

import tempfile
import time
from pathlib import Path

import pytest

from npl_mcp.markdown.cache import MarkdownCache


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
    Path(path).unlink()


class TestMarkdownCachePath:
    """Test cache path generation."""

    def test_local_file_cache_path(self, cache):
        """Test cache path for local files."""
        path = cache.get_cache_path("my-file.pdf")
        assert str(path).endswith("my-file.pdf.md")

    def test_local_markdown_file_cache_path(self, cache):
        """Test cache path for markdown files."""
        path = cache.get_cache_path("document.md")
        assert str(path).endswith("document.md.md")

    def test_url_cache_path(self, cache):
        """Test cache path for URLs."""
        path = cache.get_cache_path("https://example.com/docs")
        assert path.parent == cache.cache_dir
        assert "example.com" in str(path)

    def test_url_with_port_cache_path(self, cache):
        """Test cache path for URL with port."""
        path = cache.get_cache_path("http://localhost:8080/api/docs")
        assert path.parent == cache.cache_dir
        assert "localhost_8080" in str(path)

    def test_url_hash_consistency(self, cache):
        """Test that same URL always produces same cache path."""
        url = "https://example.com/page"
        path1 = cache.get_cache_path(url)
        path2 = cache.get_cache_path(url)
        assert path1 == path2

    def test_similar_urls_different_paths(self, cache):
        """Test that similar URLs produce different cache paths."""
        path1 = cache.get_cache_path("https://example.com/page1")
        path2 = cache.get_cache_path("https://example.com/page2")
        assert path1 != path2


class TestMarkdownCacheStorage:
    """Test cache storage and retrieval."""

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
    async def test_cache_expiry_for_urls(self, cache):
        """Test cache expiry for URLs."""
        url = "https://example.com/doc"
        content = "# Old Content"

        await cache.save_cache(url, content)
        cache_path = cache.get_cache_path(url)

        # Manually set mtime to old timestamp
        old_time = time.time() - 7200  # 2 hours ago
        Path(cache_path).touch()
        Path(cache_path).stat()  # Trigger read to ensure written
        import os

        os.utime(cache_path, (old_time, old_time))

        # Should be expired with 1 hour max_age
        cached = await cache.get_cached(url, max_age=3600)
        assert cached is None

    @pytest.mark.asyncio
    async def test_no_expiry_for_local_files(self, cache, temp_file):
        """Test that local file caches don't expire."""
        content = "# File Content"

        await cache.save_cache(temp_file, content)
        cache_path = cache.get_cache_path(temp_file)

        # Manually set mtime to old timestamp
        old_time = time.time() - 86400  # 1 day ago
        import os

        os.utime(cache_path, (old_time, old_time))

        # Should still be cached (no expiry for local files)
        cached = await cache.get_cached(temp_file, max_age=3600)
        assert cached == content

    @pytest.mark.asyncio
    async def test_missing_cache_returns_none(self, cache):
        """Test that missing cache returns None."""
        cached = await cache.get_cached("https://example.com/nonexistent")
        assert cached is None


class TestMarkdownCacheCreatesDirs:
    """Test that cache creates necessary directories."""

    @pytest.mark.asyncio
    async def test_create_cache_dir_for_url(self, cache):
        """Test that cache dir is created if it doesn't exist."""
        # Remove the cache_dir to test creation
        import shutil

        shutil.rmtree(cache.cache_dir)
        assert not cache.cache_dir.exists()

        # Saving should create it
        url = "https://example.com/doc"
        await cache.save_cache(url, "test content")

        assert cache.cache_dir.exists()
        cached = await cache.get_cached(url)
        assert cached == "test content"
