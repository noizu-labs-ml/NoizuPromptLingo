"""Image description injection with YAML caching.

Parses markdown for image references, describes them via multi-modal LLM,
and caches descriptions in a YAML file keyed by image URI + model.
"""

import re
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional

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


async def inject_image_descriptions(
    markdown: str,
    model: str = "openai/GPT5.2",
    cache_file: Optional[Path] = None,
) -> str:
    """Parse markdown for images and inject LLM descriptions after each one.

    Args:
        markdown: Input markdown text with ``![alt](uri)`` references.
        model: Multi-modal LLM model name for descriptions.
        cache_file: Override cache file path (default .tmp/cache/image_descriptions.yaml).

    Returns:
        Markdown with descriptions injected after each image reference.
    """
    cache = ImageDescriptionCache(cache_file or DEFAULT_CACHE_FILE)

    parts: list[str] = []
    last_end = 0

    for match in _IMAGE_RE.finditer(markdown):
        image_uri = match.group(2)

        # Check cache first
        description = cache.get(image_uri, model)

        if description is None:
            # Call LLM for description
            try:
                description = await describe_image(image_uri, model=model)
                cache.set(image_uri, model, description)
            except Exception:
                # Skip description on LLM failure (don't break the document)
                parts.append(markdown[last_end:match.end()])
                last_end = match.end()
                continue

        # Append text before image + image + description block
        parts.append(markdown[last_end:match.end()])
        parts.append(f"\n\n> **Image**: {description}\n")
        last_end = match.end()

    # Remaining text after last image
    parts.append(markdown[last_end:])
    return "".join(parts)
