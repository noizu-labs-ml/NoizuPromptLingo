# FR-001: Hybrid Cache Manager

**Status**: Completed

## Description

Implement a caching strategy that stores converted markdown based on source type (local files next to source, URLs in cache directory).

## Interface

```python
class MarkdownCache:
    def __init__(self, cache_dir: Optional[Path] = None):
        """Initialize cache with optional custom directory for URL caches."""

    def get_cache_path(self, source: str) -> Path:
        """Get cache path based on source type."""

    async def get_cached(self, source: str, max_age: int = 3600) -> Optional[str]:
        """Retrieve cached content if valid."""

    async def save_cache(self, source: str, content: str) -> None:
        """Save content to cache."""
```

## Behavior

| Source Type | Cache Location | Expiry Policy |
|-------------|----------------|---------------|
| Local file (`/path/to/doc.pdf`) | `/path/to/doc.pdf.md` | Never expires |
| URL (`https://...`) | `.tmp/cache/markdown/{domain}.{path}.{hash}.md` | Configurable (default: 3600s) |

**Cache Path Generation for URLs**:
- Domain: Extract netloc, replace `:` with `_` for port handling
- Path: Extract stem of URL path, default to "index" for root
- Hash: MD5 of full URL, truncated to 8 characters
- Format: `{domain}.{path}.{hash}.md`

## Edge Cases

- Missing cache file: Return `None`
- Expired URL cache: Return `None`, trigger re-fetch
- Local file cache: Never check expiry (source file change triggers re-conversion)

## Related User Stories

- US-206: Convert Documentation Sources to Markdown
- US-207: Cache Converted Files with Hybrid Strategy
- US-208: Configure Cache Expiry for URL Caches

## Test Coverage

Expected test count: 12 tests
Target coverage: 100% for this FR
