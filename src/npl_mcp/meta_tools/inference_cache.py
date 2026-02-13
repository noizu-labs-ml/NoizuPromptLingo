"""In-memory LLM inference cache keyed by catalog content hash + query params.

The catalog MD5 is part of every cache key so that if TOOL_CATALOG changes
(e.g. after a code deploy), all cached results auto-invalidate.
"""

import hashlib
import json
from typing import Any, Optional

from .catalog import TOOL_CATALOG

# Lazily computed catalog content hash
_catalog_hash: Optional[str] = None


def _get_catalog_hash() -> str:
    """Return MD5 hex digest of the serialized TOOL_CATALOG.

    Computed once per process and cached in module state.
    """
    global _catalog_hash
    if _catalog_hash is None:
        raw = json.dumps(TOOL_CATALOG, sort_keys=True, separators=(",", ":"))
        _catalog_hash = hashlib.md5(raw.encode()).hexdigest()
    return _catalog_hash


def _invalidate_catalog_hash() -> None:
    """Force recomputation of catalog hash (for testing)."""
    global _catalog_hash
    _catalog_hash = None


# In-memory cache: full_key -> cached value
_cache: dict[str, Any] = {}


def cache_key(*parts: str) -> str:
    """Build a cache key from catalog hash + arbitrary string parts."""
    return "|".join([_get_catalog_hash(), *parts])


def cache_get(key: str) -> Optional[Any]:
    """Return cached value or None on miss."""
    return _cache.get(key)


def cache_set(key: str, value: Any) -> None:
    """Store a value in the cache."""
    _cache[key] = value


def cache_clear() -> None:
    """Clear all cached entries (for testing)."""
    _cache.clear()
