"""ToMarkdown tool – convert URL/file to markdown with filter, collapse, and image descriptions.

Orchestrates MarkdownConverter, MarkdownViewer, and ImageDescriptionCache
into a single tool callable from MCP.
"""

from pathlib import Path
from typing import Any, Optional

from npl_mcp.markdown.cache import MarkdownCache
from npl_mcp.markdown.converter import MarkdownConverter
from npl_mcp.markdown.viewer import MarkdownViewer


async def to_markdown(
    source: str,
    filter: Optional[str] = None,
    collapsed_depth: Optional[int] = None,
    filtered_only: bool = False,
    output: Optional[str] = None,
    with_image_descriptions: bool = False,
    image_model: str = "openai/gpt-5-mini",
    fallback_parser: bool = False,
) -> dict[str, Any]:
    """Convert a URL, file, or raw markdown string to filtered/collapsed markdown.

    Args:
        source: URL, file path, or raw markdown content string.
        filter: Heading/CSS/XPath filter selector (e.g. ``"API Reference"``,
            ``"Overview > API"``, ``"css:#main"``).
        collapsed_depth: Collapse headings below this depth (1-6).
        filtered_only: If True, extract only matched sections (bare mode).
            If False (default), show full document with context.
        output: File path to write result. If omitted, returned in payload.
        with_image_descriptions: Inject LLM-generated image descriptions.
        image_model: Multi-modal model for image descriptions.
        fallback_parser: If True, fall back to html2text when Jina fails.
            Default False (Jina only).

    Returns:
        Dict with ``source``, ``content`` (or ``output_file``), ``content_length``,
        and metadata about conversion.
    """
    result: dict[str, Any] = {"source": source}

    # --- Step 1: Get markdown content ---
    raw_markdown = await _resolve_source(source, fallback_parser=fallback_parser)
    result["source_type"] = _classify_source(source, raw_markdown)

    # --- Step 2: Image descriptions (before filtering) ---
    if with_image_descriptions:
        from npl_mcp.markdown.image_descriptions import inject_image_descriptions
        # Pass source as base_url so relative image URIs get resolved
        base_url = source if source.startswith(("http://", "https://")) else None
        raw_markdown = await inject_image_descriptions(
            raw_markdown, model=image_model, base_url=base_url
        )
        result["image_descriptions"] = True

    # --- Step 3: Filter and/or collapse ---
    viewer = MarkdownViewer()
    processed = viewer.view(
        raw_markdown,
        filter=filter,
        bare=filtered_only,
        depth=collapsed_depth,
    )
    result["content_length"] = len(processed)

    # --- Step 4: Output ---
    if output:
        out_path = Path(output)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(processed, encoding="utf-8")
        result["output_file"] = str(out_path)
    else:
        result["content"] = processed

    return result


async def _resolve_source(source: str, *, fallback_parser: bool = False) -> str:
    """Resolve source to raw markdown content.

    Handles URLs, local files (with conversion), and raw markdown strings.
    """
    # URL → convert via MarkdownConverter (Jina/local)
    if source.startswith(("http://", "https://")):
        cache = MarkdownCache()
        converter = MarkdownConverter(cache)
        full_response = await converter.convert(source, fallback_parser=fallback_parser)
        # Strip the YAML metadata header from converter response
        return _strip_metadata_header(full_response)

    # Local file → check if it needs conversion
    path = Path(source)
    if path.is_file():
        suffix = path.suffix.lower()

        if suffix in (".md", ".markdown", ".txt"):
            # Already markdown/text, read directly
            return path.read_text(encoding="utf-8")

        # Other file types go through converter
        cache = MarkdownCache()
        converter = MarkdownConverter(cache)
        full_response = await converter.convert(source)
        return _strip_metadata_header(full_response)

    # Not a URL and not an existing file → treat as raw markdown string
    return source


def _classify_source(source: str, resolved: str) -> str:
    """Classify the source type for metadata."""
    if source.startswith(("http://", "https://")):
        return "url"
    # Multi-line strings or markdown-looking content → raw markdown
    if "\n" in source or source.startswith("#"):
        return "raw_markdown"
    path = Path(source)
    if path.is_file():
        return "file"
    # Single-line, looks like a file path but doesn't exist
    if "/" in source or "\\" in source or path.suffix:
        return "file_not_found"
    return "raw_markdown"


def _strip_metadata_header(response: str) -> str:
    """Strip metadata headers from MarkdownConverter output.

    Handles two layers of metadata:
    1. Internal YAML header from MarkdownConverter._format_response:
           success: true
           source: ...
           ---
           <content>
    2. Jina Reader API metadata prepended to the content:
           Title: ...
           URL Source: ...
           Markdown Content:
           <actual markdown>
    """
    # Strip internal YAML metadata header
    marker = "\n---\n"
    idx = response.find(marker)
    if idx != -1:
        response = response[idx + len(marker):]

    # Strip Jina Reader metadata header
    response = _strip_jina_header(response)

    return response


def _strip_jina_header(content: str) -> str:
    """Strip Jina Reader API metadata from the beginning of content.

    Jina Reader prepends lines like:
        Title: Page Title
        URL Source: https://example.com
        Markdown Content:
        <actual content>

    This strips everything up to and including 'Markdown Content:'.
    """
    jina_marker = "Markdown Content:"
    idx = content.find(jina_marker)
    if idx != -1:
        # Verify this is at the start (only metadata lines before it)
        prefix = content[:idx]
        lines = prefix.strip().split("\n")
        # Jina metadata lines are key: value pairs like "Title:", "URL Source:"
        looks_like_jina = all(
            ":" in line for line in lines if line.strip()
        )
        if looks_like_jina:
            after = content[idx + len(jina_marker):]
            # Strip leading newlines after the marker
            return after.lstrip("\n")
    return content
