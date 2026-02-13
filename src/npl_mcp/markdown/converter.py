"""Markdown converter - convert URLs, files, and images to markdown."""

import base64
import os
from pathlib import Path
from typing import Optional

import httpx
import html2text
import pdfplumber

from .cache import MarkdownCache


def _parse_sse_stream(lines: list[str]) -> str:
    """Parse Server-Sent Events lines and return the last complete data payload.

    Jina streams progressive chunks; the final ``data:`` payload is the most
    complete rendering of the page.
    """
    last_data: list[str] = []
    current: list[str] = []

    for line in lines:
        if line.startswith("data: "):
            current.append(line[6:])
        elif line == "":
            # Blank line marks end of an event
            if current:
                last_data = current
                current = []
    # Handle stream that doesn't end with a blank line
    if current:
        last_data = current

    return "\n".join(last_data)


class MarkdownConverter:
    """Convert various sources to markdown."""

    def __init__(self, cache: MarkdownCache):
        self.cache = cache

    async def convert(
        self,
        source: str,
        force_refresh: bool = False,
        timeout: int = 30,
        no_cache: bool = False,
        fallback_parser: bool = False,
    ) -> str:
        """Convert source to markdown with caching.

        Args:
            source: URL, file path, or image path to convert
            force_refresh: Skip cache and force fresh conversion
            timeout: Request timeout in seconds for URLs
            no_cache: Skip both reading from and writing to cache
            fallback_parser: If True, fall back to direct html2text when Jina fails.
                If False (default), use Jina only.

        Returns:
            Formatted markdown with YAML metadata header
        """

        # Check cache first (unless no_cache or force_refresh)
        if not force_refresh and not no_cache:
            cached = await self.cache.get_cached(source)
            if cached:
                return self._format_response(source, cached, cached=True)

        # Determine source type and convert
        if source.startswith(("http://", "https://")):
            content = await self._convert_url(source, timeout, fallback_parser=fallback_parser)
        elif source.endswith((".png", ".jpg", ".jpeg", ".gif", ".svg")):
            content = await self._convert_image(source)
        elif source.endswith(".pdf"):
            content = await self._convert_pdf(source, timeout)
        elif source.endswith((".docx", ".doc")):
            content = await self._convert_docx(source)
        elif source.endswith((".html", ".htm")):
            content = await self._convert_html(source)
        else:
            # Assume it's already markdown or text
            content = Path(source).read_text()

        # Save to cache (unless no_cache)
        if not no_cache:
            await self.cache.save_cache(source, content)

        return self._format_response(source, content, cached=False)

    async def _convert_url(self, url: str, timeout: int, *, fallback_parser: bool = False) -> str:
        """Convert URL to markdown via Jina Reader.

        Uses Jina Reader with SSE streaming. Only falls back to direct
        httpx + html2text when ``fallback_parser=True`` and Jina fails.

        Args:
            url: Full URL to convert
            timeout: Request timeout in seconds
            fallback_parser: Allow direct html2text fallback on Jina failure.

        Returns:
            Markdown content from URL
        """
        try:
            content = await self._convert_url_jina(url, timeout)
            if content and content.strip():
                return content
        except Exception:
            pass

        if fallback_parser:
            try:
                return await self._convert_url_direct(url, timeout)
            except Exception:
                pass

        return ""

    async def _convert_url_jina(self, url: str, timeout: int) -> str:
        """Fetch URL content via Jina Reader API using SSE streaming.

        Streaming mode waits longer for JS-heavy pages to render and
        returns progressively more complete content. The final data
        chunk contains the most complete result.
        """
        jina_api_key = os.environ.get("JINA_API_KEY", "")
        jina_url = f"https://r.jina.ai/{url}"

        headers = {
            "Accept": "text/event-stream",
            "X-With-Shadow-Dom": "true",
        }
        if jina_api_key:
            headers["Authorization"] = f"Bearer {jina_api_key}"

        async with httpx.AsyncClient(timeout=timeout) as client:
            async with client.stream("GET", jina_url, headers=headers) as response:
                response.raise_for_status()
                return _parse_sse_stream(
                    [line async for line in response.aiter_lines()]
                )

    async def _convert_url_direct(self, url: str, timeout: int) -> str:
        """Fetch URL and convert HTML to markdown with html2text."""
        async with httpx.AsyncClient(
            timeout=timeout, follow_redirects=True
        ) as client:
            response = await client.get(url)
            response.raise_for_status()

        h = html2text.HTML2Text()
        h.ignore_links = False
        h.ignore_images = False
        h.ignore_emphasis = False
        h.body_width = 0
        h.protect_links = False

        return h.handle(response.text).strip()

    async def _convert_html(self, file_path: str) -> str:
        """Convert HTML file to markdown using Jina API or local converter.

        Args:
            file_path: Path to HTML file

        Returns:
            Markdown content from HTML
        """
        try:
            # Try using Jina API first (better formatting)
            jina_api_key = os.environ.get("JINA_API_KEY", "")
            if jina_api_key:
                return await self._convert_html_via_jina(file_path, jina_api_key)

            # Fallback to local html2text conversion
            return await self._convert_html_local(file_path)
        except Exception as e:
            # If Jina fails, fall back to local conversion
            if jina_api_key:
                try:
                    return await self._convert_html_local(file_path)
                except Exception as local_e:
                    raise RuntimeError(f"Failed to convert HTML {file_path}: Jina error: {e}, Local error: {local_e}")
            raise RuntimeError(f"Failed to convert HTML {file_path}: {e}")

    async def _convert_html_via_jina(self, file_path: str, api_key: str) -> str:
        """Convert HTML using Jina API (requires temporary HTTP server).

        Args:
            file_path: Path to HTML file
            api_key: Jina API key

        Returns:
            Markdown content from Jina
        """
        # For local files, Jina would need a public URL or file upload.
        # Since we don't have that, we skip this and use local converter
        raise NotImplementedError("Jina HTML conversion requires public URL or file upload support")

    async def _convert_html_local(self, file_path: str) -> str:
        """Convert HTML file to markdown using local html2text library.

        Args:
            file_path: Path to HTML file

        Returns:
            Markdown content from HTML
        """
        html_content = Path(file_path).read_text(encoding='utf-8')

        # Configure html2text converter
        h = html2text.HTML2Text()
        h.ignore_links = False
        h.ignore_images = False
        h.ignore_emphasis = False
        h.body_width = 0  # Don't wrap text
        h.protect_links = False

        markdown = h.handle(html_content)
        return markdown.strip()

    async def _convert_pdf(self, file_path: str, timeout: int = 60) -> str:
        """Convert PDF to markdown using Jina API or local converter.

        Args:
            file_path: Path to PDF file
            timeout: Request timeout in seconds for Jina API

        Returns:
            Markdown content from PDF
        """
        jina_api_key = os.environ.get("JINA_API_KEY", "")

        # Use Jina API when available (better structure preservation)
        if jina_api_key:
            try:
                return await self._convert_pdf_via_jina(file_path, jina_api_key, timeout)
            except Exception as e:
                # Log warning but fall back to local conversion
                import sys
                print(f"Warning: Jina PDF conversion failed, falling back to local: {e}", file=sys.stderr)

        # Fallback to local pdfplumber conversion
        try:
            return await self._convert_pdf_local(file_path)
        except Exception as e:
            raise RuntimeError(f"Failed to convert PDF {file_path}: {e}")

    async def _convert_pdf_via_jina(self, file_path: str, api_key: str, timeout: int = 60) -> str:
        """Convert PDF using Jina Reader API with base64-encoded content.

        Args:
            file_path: Path to PDF file
            api_key: Jina API key
            timeout: Request timeout in seconds

        Returns:
            Markdown content from Jina
        """
        # Read and base64 encode the PDF
        pdf_bytes = Path(file_path).read_bytes()
        pdf_base64 = base64.standard_b64encode(pdf_bytes).decode('utf-8')

        headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
            "Accept": "application/json",
            "X-Return-Format": "markdown",
        }

        # Jina Reader API accepts pdf as base64 in JSON body
        payload = {
            "url": f"file://{Path(file_path).name}",
            "pdf": pdf_base64,
        }

        async with httpx.AsyncClient(timeout=timeout) as client:
            response = await client.post(
                "https://r.jina.ai/",
                headers=headers,
                json=payload,
            )
            response.raise_for_status()

            # Parse JSON response and extract content
            data = response.json()
            if data.get("code") == 200 and "data" in data:
                return data["data"].get("content", "")
            else:
                raise RuntimeError(f"Jina API error: {data}")

    async def _convert_pdf_local(self, file_path: str) -> str:
        """Convert PDF to markdown using local pdfplumber library.

        Args:
            file_path: Path to PDF file

        Returns:
            Markdown content from PDF
        """
        text_content = []
        with pdfplumber.open(file_path) as pdf:
            # Extract text from each page
            for page_num, page in enumerate(pdf.pages, 1):
                text = page.extract_text()
                if text:
                    # Add page marker for structure
                    text_content.append(f"## Page {page_num}\n")
                    text_content.append(text)
                    text_content.append("")

        result = "\n".join(text_content)
        # If no text was extracted, raise an error
        if not result.strip():
            raise ValueError("No text content could be extracted from PDF")
        return result

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
