"""Markdown cache manager with hybrid strategy.

- Local files: cache next to source (my-file.pdf.md)
- URLs: cache in .tmp/cache/markdown/ (domain.path.hash.md)
"""

import hashlib
import time
from pathlib import Path
from typing import Optional
from urllib.parse import urlparse


class MarkdownCache:
    """Hybrid caching: local files next to source, URLs in .tmp/cache/markdown/"""

    def __init__(self, cache_dir: Optional[Path] = None):
        self.cache_dir = cache_dir or Path(".tmp/cache/markdown")
        self.cache_dir.mkdir(parents=True, exist_ok=True)

    def get_cache_path(self, source: str) -> Path:
        """Get cache path based on source type.

        Args:
            source: URL, file path, or other source identifier

        Returns:
            Path where cached markdown should be stored
        """
        if source.startswith(("http://", "https://")):
            # URL: cache in .tmp/cache/markdown/
            # Example: https://example.com/page.html → .tmp/cache/markdown/example.com.page.abc123.md
            return self._url_cache_path(source)
        else:
            # Local file: cache next to source
            # Example: my-file.pdf → my-file.pdf.md
            return Path(source).with_suffix(Path(source).suffix + ".md")

    def _url_cache_path(self, url: str) -> Path:
        """Generate cache path for URL.

        Args:
            url: Full URL to cache

        Returns:
            Path for cached URL content
        """
        parsed = urlparse(url)
        domain = parsed.netloc.replace(":", "_")
        path_part = Path(parsed.path).stem or "index"
        url_hash = hashlib.md5(url.encode()).hexdigest()[:8]

        return self.cache_dir / f"{domain}.{path_part}.{url_hash}.md"

    async def get_cached(self, source: str, max_age: int = 3600) -> Optional[str]:
        """Retrieve cached content if valid.

        Args:
            source: Source identifier (URL or file path)
            max_age: Maximum age in seconds for URL caches (default: 1 hour)
                     Local file caches never expire

        Returns:
            Cached content string if valid, None otherwise
        """
        cache_path = self.get_cache_path(source)

        if not cache_path.exists():
            return None

        # Check age for URL caches only
        if source.startswith(("http://", "https://")):
            age = time.time() - cache_path.stat().st_mtime
            if age > max_age:
                return None

        return cache_path.read_text()

    async def save_cache(self, source: str, content: str) -> None:
        """Save content to cache.

        Args:
            source: Source identifier (URL or file path)
            content: Markdown content to cache
        """
        cache_path = self.get_cache_path(source)
        cache_path.parent.mkdir(parents=True, exist_ok=True)
        cache_path.write_text(content)
