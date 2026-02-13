"""Screenshot tool – capture a URL with Playwright, optionally resize with Pillow.

Returns either a file path (if ``output`` is given) or inline base64 PNG data.
Images are resized down to fit within ``max_width`` / ``max_height`` while
preserving the original aspect ratio.
"""

import base64
import io
from pathlib import Path
from typing import Any, Optional

from PIL import Image
from playwright.async_api import async_playwright


async def screenshot(
    url: str,
    output: Optional[str] = None,
    max_width: Optional[int] = None,
    max_height: Optional[int] = None,
    full_page: bool = False,
) -> dict[str, Any]:
    """Capture a screenshot of a URL.

    Args:
        url: URL to screenshot.
        output: File path to save PNG. If omitted, returns base64 data.
        max_width: Maximum width in pixels (scales down preserving aspect ratio).
        max_height: Maximum height in pixels (scales down preserving aspect ratio).
        full_page: Capture full scrollable page instead of viewport only.

    Returns:
        Dict with url, dimensions, and either ``output_file`` or ``base64`` data.
    """
    result: dict[str, Any] = {"url": url}

    try:
        png_bytes = await _capture(url, full_page=full_page)
    except Exception as exc:
        result["error"] = f"{type(exc).__name__}: {exc}"
        return result

    # Resize if needed
    png_bytes, width, height = _resize(png_bytes, max_width, max_height)
    result["width"] = width
    result["height"] = height

    if output:
        out_path = Path(output)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_bytes(png_bytes)
        result["output_file"] = str(out_path)
    else:
        result["base64"] = base64.b64encode(png_bytes).decode("ascii")

    return result


async def _capture(url: str, full_page: bool = False) -> bytes:
    """Launch headless browser, navigate, and return PNG bytes."""
    pw = await async_playwright().start()
    try:
        browser = await pw.chromium.launch()
        page = await browser.new_page()
        await page.goto(url, wait_until="networkidle", timeout=30_000)
        png_bytes = await page.screenshot(full_page=full_page, type="png")
        await browser.close()
        return png_bytes
    finally:
        await pw.stop()


def _resize(
    png_bytes: bytes,
    max_width: Optional[int] = None,
    max_height: Optional[int] = None,
) -> tuple[bytes, int, int]:
    """Resize PNG bytes to fit within max dimensions, preserving aspect ratio.

    Returns (possibly new) PNG bytes and the final (width, height).
    """
    img = Image.open(io.BytesIO(png_bytes))
    orig_w, orig_h = img.size

    if max_width is None and max_height is None:
        return png_bytes, orig_w, orig_h

    new_w, new_h = orig_w, orig_h

    # Scale down to fit max_width
    if max_width is not None and new_w > max_width:
        scale = max_width / new_w
        new_w = max_width
        new_h = int(new_h * scale)

    # Scale down to fit max_height
    if max_height is not None and new_h > max_height:
        scale = max_height / new_h
        new_h = max_height
        new_w = int(new_w * scale)

    # Only resize if dimensions actually changed
    if (new_w, new_h) == (orig_w, orig_h):
        return png_bytes, orig_w, orig_h

    resized = img.resize((new_w, new_h), Image.LANCZOS)
    buf = io.BytesIO()
    resized.save(buf, format="PNG")
    return buf.getvalue(), new_w, new_h
