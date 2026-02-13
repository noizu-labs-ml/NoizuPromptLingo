"""Image description injection with YAML caching.

Parses markdown for image references, describes them via multi-modal LLM,
and caches descriptions in a YAML file keyed by image URI + model.
"""

import asyncio
import re
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional
from urllib.parse import urljoin

import yaml

from npl_mcp.meta_tools.llm_client import describe_image

# Default cache location (project convention: .tmp/ for persistent temp files)
DEFAULT_CACHE_FILE = Path(".tmp/cache/image_descriptions.yaml")

# Regex for markdown image references: ![alt](uri)
_IMAGE_RE = re.compile(r"!\[([^\]]*)\]\(([^)]+)\)")


class ImageDescriptionCache:
    """YAML-based cache for LLM-generated image descriptions."""

    def __init__(self, cache_file: Path = DEFAULT_CACHE_FILE):
        self.cache_file = cache_file
        self._cache: dict = self._load()

    def _load(self) -> dict:
        if self.cache_file.exists():
            return yaml.safe_load(self.cache_file.read_text()) or {}
        return {}

    def _save(self) -> None:
        self.cache_file.parent.mkdir(parents=True, exist_ok=True)
        self.cache_file.write_text(yaml.dump(self._cache, sort_keys=False))

    @staticmethod
    def _key(image_uri: str, model: str) -> str:
        return f"{image_uri}::{model}"

    def get(self, image_uri: str, model: str) -> Optional[str]:
        """Return cached description or None."""
        entry = self._cache.get(self._key(image_uri, model))
        if isinstance(entry, dict):
            return entry.get("description")
        return None

    def set(self, image_uri: str, model: str, description: str) -> None:
        """Cache a description and persist to YAML."""
        self._cache[self._key(image_uri, model)] = {
            "description": description,
            "created_at": datetime.now(tz=timezone.utc).isoformat(),
        }
        self._save()


def _resolve_image_uri(uri: str, base_url: Optional[str] = None) -> str:
    """Resolve an image URI to an absolute URL if possible.

    Handles:
    - Absolute URLs (http/https) → returned as-is
    - Relative URIs with a base_url → resolved via urljoin
    - Local paths without base_url → returned as-is (for local files)
    """
    if uri.startswith(("http://", "https://", "data:")):
        return uri
    if base_url and base_url.startswith(("http://", "https://")):
        return urljoin(base_url, uri)
    return uri


async def inject_image_descriptions(
    markdown: str,
    model: str = "openai/gpt-5-mini",
    cache_file: Optional[Path] = None,
    base_url: Optional[str] = None,
) -> str:
    """Parse markdown for images and inject LLM descriptions after each one.

    Uncached images are described in parallel via asyncio.gather for speed.

    Args:
        markdown: Input markdown text with ``![alt](uri)`` references.
        model: Multi-modal LLM model name for descriptions.
        cache_file: Override cache file path (default .tmp/cache/image_descriptions.yaml).
        base_url: Base URL for resolving relative image URIs (e.g. source page URL).

    Returns:
        Markdown with descriptions injected after each image reference.
    """
    cache = ImageDescriptionCache(cache_file or DEFAULT_CACHE_FILE)

    # Collect all image matches with resolved URIs
    matches: list[tuple[re.Match, str]] = []
    for match in _IMAGE_RE.finditer(markdown):
        raw_uri = match.group(2)
        image_uri = _resolve_image_uri(raw_uri, base_url)
        matches.append((match, image_uri))

    if not matches:
        return markdown

    # Separate cached vs uncached
    descriptions: dict[str, Optional[str]] = {}
    errors: dict[str, str] = {}
    uncached: list[str] = []
    for _, image_uri in matches:
        if image_uri not in descriptions:
            cached_desc = cache.get(image_uri, model)
            descriptions[image_uri] = cached_desc
            if cached_desc is None:
                uncached.append(image_uri)

    # Fetch uncached descriptions in parallel
    if uncached:
        async def _describe(uri: str) -> tuple[str, Optional[str], Optional[str]]:
            try:
                desc = await describe_image(uri, model=model)
                return uri, desc, None
            except Exception as exc:
                return uri, None, f"{type(exc).__name__}: {exc}"

        results = await asyncio.gather(*[_describe(uri) for uri in uncached])
        for uri, desc, err in results:
            descriptions[uri] = desc
            if desc is not None:
                cache.set(uri, model, desc)
            elif err is not None:
                errors[uri] = err

    # Rebuild markdown with descriptions injected
    parts: list[str] = []
    last_end = 0

    for match, image_uri in matches:
        description = descriptions.get(image_uri)
        parts.append(markdown[last_end:match.end()])
        if description is not None:
            parts.append(f"\n\n> **Image**: {description}\n")
        elif image_uri in errors:
            parts.append(f"\n\n> **Image description failed**: {errors[image_uri]}\n")
        last_end = match.end()

    parts.append(markdown[last_end:])
    return "".join(parts)
