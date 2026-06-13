"""In-memory LLM inference cache keyed by catalog version + query params.

The catalog version counter is part of every cache key so that when the
catalog is invalidated (e.g. after dynamic tool registration), all cached
results auto-invalidate.
"""

from typing import Any, Optional


def _get_catalog_version() -> str:
    """Return current catalog version as a string for cache key generation."""
    from .catalog import _catalog_version
    return str(_catalog_version)


# In-memory cache: full_key -> cached value
_cache: dict[str, Any] = {}


def cache_key(*parts: str) -> str:
    """Build a cache key from catalog version + arbitrary string parts."""
    return "|".join([_get_catalog_version(), *parts])


def cache_get(key: str) -> Optional[Any]:
    """Return cached value or None on miss."""
    return _cache.get(key)


def cache_set(key: str, value: Any) -> None:
    """Store a value in the cache."""
    _cache[key] = value


def cache_clear() -> None:
    """Clear all cached entries (for testing)."""
    _cache.clear()
