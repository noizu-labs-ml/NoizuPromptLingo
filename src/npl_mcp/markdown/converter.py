"""Markdown converter - convert URLs, files, and images to markdown."""

import os
from pathlib import Path
from typing import Optional

import httpx

from .cache import MarkdownCache


class MarkdownConverter:
    """Convert various sources to markdown."""

    def __init__(self, cache: MarkdownCache):
        self.cache = cache

    async def convert(
        self,
        source: str,
        force_refresh: bool = False,
        timeout: int = 30
    ) -> str:
        """Convert source to markdown with caching.

        Args:
            source: URL, file path, or image path to convert
            force_refresh: Skip cache and force fresh conversion
            timeout: Request timeout in seconds for URLs

        Returns:
            Formatted markdown with YAML metadata header
        """

        # Check cache first
        if not force_refresh:
            cached = await self.cache.get_cached(source)
            if cached:
                return self._format_response(source, cached, cached=True)

        # Determine source type and convert
        if source.startswith(("http://", "https://")):
            content = await self._convert_url(source, timeout)
        elif source.endswith((".png", ".jpg", ".jpeg", ".gif", ".svg")):
            content = await self._convert_image(source)
        elif source.endswith(".pdf"):
            content = await self._convert_pdf(source)
        elif source.endswith((".docx", ".doc")):
            content = await self._convert_docx(source)
        else:
            # Assume it's already markdown or text
            content = Path(source).read_text()

        # Save to cache
        await self.cache.save_cache(source, content)

        return self._format_response(source, content, cached=False)

    async def _convert_url(self, url: str, timeout: int) -> str:
        """Convert URL to markdown using Jina API.

        Args:
            url: Full URL to convert
            timeout: Request timeout in seconds

        Returns:
            Markdown content from URL
        """
        jina_api_key = os.environ.get("JINA_API_KEY", "")
        jina_url = f"https://r.jina.ai/{url}"

        headers = {}
        if jina_api_key:
            headers["Authorization"] = f"Bearer {jina_api_key}"

        async with httpx.AsyncClient(timeout=timeout) as client:
            response = await client.get(jina_url, headers=headers)
            response.raise_for_status()
            return response.text

    async def _convert_pdf(self, file_path: str) -> str:
        """Convert PDF to markdown using Jina API.

        Args:
            file_path: Path to PDF file

        Returns:
            Markdown content from PDF
        """
        # Jina supports PDF URLs, so upload to temp endpoint or use local reader
        # For now, stub out - will use Jina's document reader API
        raise NotImplementedError("PDF conversion coming soon")

    async def _convert_docx(self, file_path: str) -> str:
        """Convert DOCX to markdown.

        Args:
            file_path: Path to DOCX file

        Returns:
            Markdown content from DOCX
        """
        raise NotImplementedError("DOCX conversion coming soon")

    async def _convert_image(self, image_path: str) -> str:
        """Convert image to markdown using visual analysis.

        Args:
            image_path: Path to image file

        Returns:
            Markdown description of image
        """
        # Future: Use Claude vision API to analyze image
        # Prompt: "Describe this image in markdown format with LaTeX formulas and SVG diagrams where appropriate"
        raise NotImplementedError("Image conversion coming soon - will use vision API")

    def _format_response(self, source: str, content: str, cached: bool) -> str:
        """Format response with metadata header.

        Args:
            source: Source identifier
            content: Markdown content
            cached: Whether this came from cache

        Returns:
            Formatted response with YAML metadata header
        """
        cache_path = self.cache.get_cache_path(source)
        source_type = "url" if source.startswith("http") else "file"

        return f"""success: true
source: {source}
source_type: {source_type}
cached: {str(cached).lower()}
cache_file: {cache_path}
content_length: {len(content)}
---
{content}"""
