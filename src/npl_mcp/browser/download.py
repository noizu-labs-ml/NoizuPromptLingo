"""Download tool – download a URL or copy a local file to a destination path.

Supports HTTP(S) URLs via httpx and local file copies via shutil.
Creates parent directories automatically.
"""

import shutil
from pathlib import Path
from typing import Any, Optional
from urllib.parse import urlparse

import httpx


def _derive_filename(source: str) -> str:
    """Derive a filename from a URL or file path for auto-naming."""
    if source.startswith(("http://", "https://")):
        parsed = urlparse(source)
        name = Path(parsed.path).name
        return name if name else "download"
    return Path(source).name


async def download(
    file: str,
    out: Optional[str] = None,
    timeout: float = 60.0,
) -> dict[str, Any]:
    """Download a URL or copy a local file.

    Args:
        file: URL or local file path to download/copy from.
        out: Local file path to save to. If omitted, returns content
            in the response payload instead of writing to disk.
        timeout: Request timeout in seconds for URL downloads (default 60).

    Returns:
        Dict with source, source_type, and either ``output_file`` + ``size_bytes``
        (when ``out`` is given) or ``content`` + ``content_length`` (when ``out`` is omitted).
    """
    result: dict[str, Any] = {"source": file}
    write_to_file = bool(out and out.strip())

    try:
        if file.startswith(("http://", "https://")):
            result["source_type"] = "url"
            if write_to_file:
                out_path = Path(out)
                if out_path.is_dir():
                    out_path = out_path / _derive_filename(file)
                out_path.parent.mkdir(parents=True, exist_ok=True)
                await _download_url(file, out_path, timeout)
                result["output_file"] = str(out_path)
                result["size_bytes"] = out_path.stat().st_size
            else:
                content = await _fetch_url(file, timeout)
                result["content"] = content
                result["content_length"] = len(content)
        else:
            result["source_type"] = "file"
            src_path = Path(file)
            if not src_path.is_file():
                raise FileNotFoundError(f"Source file not found: {file}")
            if write_to_file:
                out_path = Path(out)
                if out_path.is_dir():
                    out_path = out_path / _derive_filename(file)
                out_path.parent.mkdir(parents=True, exist_ok=True)
                _copy_file(file, out_path)
                result["output_file"] = str(out_path)
                result["size_bytes"] = out_path.stat().st_size
            else:
                content = src_path.read_text(encoding="utf-8", errors="replace")
                result["content"] = content
                result["content_length"] = len(content)
    except Exception as exc:
        result["error"] = f"{type(exc).__name__}: {exc}"

    return result


async def _download_url(url: str, dest: Path, timeout: float) -> None:
    """Stream-download a URL to a local file."""
    async with httpx.AsyncClient(timeout=timeout, follow_redirects=True) as client:
        async with client.stream("GET", url) as response:
            response.raise_for_status()
            with dest.open("wb") as f:
                async for chunk in response.aiter_bytes(chunk_size=65536):
                    f.write(chunk)


async def _fetch_url(url: str, timeout: float) -> str:
    """Fetch URL content and return as text."""
    async with httpx.AsyncClient(timeout=timeout, follow_redirects=True) as client:
        response = await client.get(url)
        response.raise_for_status()
        return response.text


def _copy_file(src: str, dest: Path) -> None:
    """Copy a local file to destination."""
    src_path = Path(src)
    if not src_path.is_file():
        raise FileNotFoundError(f"Source file not found: {src}")
    shutil.copy2(str(src_path), str(dest))
