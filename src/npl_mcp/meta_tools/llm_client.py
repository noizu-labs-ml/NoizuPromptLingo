"""Async LLM API client for intent search and image descriptions.

Calls a model provider's OpenAI-compatible API directly (owner rule
2026-11-26: services use API inference, never the local run-claude/litellm
proxy). Default endpoint is DashScope; the legacy ``NPL_LITELLM_*``
variables are still honoured as fallbacks so existing set-ups keep working.
"""

import base64
import mimetypes
import os
from pathlib import Path
from typing import Any
from urllib.parse import urlparse

import httpx

# DashScope (Alibaba Cloud Model Studio) OpenAI-compatible endpoint.
DEFAULT_BASE_URL = "https://dashscope-intl.aliyuncs.com/compatible-mode/v1"
DEFAULT_CHAT_MODEL = "qwen3.8-flash"
DEFAULT_EMBED_MODEL = "text-embedding-v4"
DEFAULT_VISION_MODEL = "qwen3-vl-plus"


def _env(name: str) -> str:
    """Read an env var, trimmed; unset/blank counts as not set."""
    return os.environ.get(name, "").strip()


def get_base_url() -> str:
    """Resolve the OpenAI-compatible base URL.

    Precedence: ``NPL_LLM_BASE_URL``, then the legacy ``NPL_LITELLM_URL``,
    then the DashScope default.
    """
    return _env("NPL_LLM_BASE_URL") or _env("NPL_LITELLM_URL") or DEFAULT_BASE_URL


def get_api_key() -> str:
    """Resolve the API key.

    Precedence: ``NPL_LLM_API_KEY``, ``QWEN_API_KEY``, ``DASHSCOPE_API_KEY``,
    then the legacy ``NPL_LITELLM_KEY``; empty string when none is set.
    """
    return (
        _env("NPL_LLM_API_KEY")
        or _env("QWEN_API_KEY")
        or _env("DASHSCOPE_API_KEY")
        or _env("NPL_LITELLM_KEY")
    )


def get_chat_model() -> str:
    """Default chat model (``NPL_LLM_MODEL``, legacy ``NPL_LITELLM_MODEL``)."""
    return _env("NPL_LLM_MODEL") or _env("NPL_LITELLM_MODEL") or DEFAULT_CHAT_MODEL


def get_embed_model() -> str:
    """Default embedding model (``NPL_LLM_EMBED_MODEL``, legacy ``NPL_LITELLM_EMBED_MODEL``)."""
    return (
        _env("NPL_LLM_EMBED_MODEL")
        or _env("NPL_LITELLM_EMBED_MODEL")
        or DEFAULT_EMBED_MODEL
    )


def get_vision_model() -> str:
    """Default multimodal model for image descriptions (``NPL_LLM_VISION_MODEL``)."""
    return _env("NPL_LLM_VISION_MODEL") or DEFAULT_VISION_MODEL


def _auth_headers() -> dict[str, str]:
    return {
        "Authorization": f"Bearer {get_api_key()}",
        "Content-Type": "application/json",
    }


async def embed_texts(
    texts: list[str],
    model: str | None = None,
    timeout: float = 30.0,
) -> list[list[float]]:
    """Call the OpenAI-compatible embeddings endpoint.

    Args:
        texts: List of strings to embed.
        model: Override embedding model (default from env).
        timeout: Request timeout in seconds.

    Returns:
        List of embedding vectors (list of floats), one per input text,
        ordered to match the input list.

    Raises:
        httpx.HTTPStatusError: On non-2xx response.
        httpx.TimeoutException: On timeout.
    """
    use_model = model or get_embed_model()
    async with httpx.AsyncClient(timeout=timeout) as client:
        response = await client.post(
            f"{get_base_url()}/embeddings",
            headers=_auth_headers(),
            json={
                "model": use_model,
                "input": texts,
            },
        )
        response.raise_for_status()
        data = response.json()
        sorted_data = sorted(data["data"], key=lambda x: x["index"])
        return [item["embedding"] for item in sorted_data]


async def chat_completion(
    messages: list[dict[str, str]],
    temperature: float = 0.3,
    max_tokens: int = 2000,
    timeout: float = 30.0,
) -> dict[str, Any]:
    """Call the OpenAI-compatible chat completions endpoint.

    Args:
        messages: Chat messages in OpenAI format.
        temperature: Sampling temperature.
        max_tokens: Maximum response tokens.
        timeout: Request timeout in seconds.

    Returns:
        Parsed JSON response body.

    Raises:
        httpx.HTTPStatusError: On non-2xx response.
        httpx.TimeoutException: On timeout.
    """
    async with httpx.AsyncClient(timeout=timeout) as client:
        response = await client.post(
            f"{get_base_url()}/chat/completions",
            headers=_auth_headers(),
            json={
                "model": get_chat_model(),
                "messages": messages,
                "temperature": temperature,
                "max_tokens": max_tokens,
            },
        )
        response.raise_for_status()
        return response.json()


def _is_svg(uri: str) -> bool:
    """Check if a URI points to an SVG image."""
    if uri.startswith("data:"):
        return "image/svg" in uri
    parsed = urlparse(uri)
    return parsed.path.lower().endswith(".svg")


async def _rasterize_svg(svg_uri: str) -> str:
    """Render an SVG to a base64 PNG data URI via Playwright.

    Launches a headless browser, navigates to the SVG, screenshots it,
    and returns a ``data:image/png;base64,...`` string.
    """
    from playwright.async_api import async_playwright

    pw = await async_playwright().start()
    try:
        browser = await pw.chromium.launch()
        page = await browser.new_page(viewport={"width": 800, "height": 600})
        await page.goto(svg_uri, wait_until="networkidle", timeout=15_000)
        png_bytes = await page.screenshot(type="png")
        await browser.close()
    finally:
        await pw.stop()

    b64 = base64.b64encode(png_bytes).decode("ascii")
    return f"data:image/png;base64,{b64}"


def _image_uri_to_content(image_uri: str) -> dict:
    """Convert an image URI to an OpenAI vision content block.

    Handles URLs (http/https) and local file paths (base64-encoded).
    """
    if image_uri.startswith(("http://", "https://", "data:")):
        return {"type": "image_url", "image_url": {"url": image_uri}}

    # Local file: read, base64 encode, wrap in data URI
    path = Path(image_uri)
    mime_type = mimetypes.guess_type(str(path))[0] or "image/png"
    data = base64.b64encode(path.read_bytes()).decode()
    return {
        "type": "image_url",
        "image_url": {"url": f"data:{mime_type};base64,{data}"},
    }


async def describe_image(
    image_uri: str,
    model: str | None = None,
    timeout: float = 30.0,
) -> str:
    """Describe an image using a multi-modal LLM.

    SVG images are rasterized to PNG via Playwright before sending to the LLM.

    Args:
        image_uri: URL, local file path, or data URI of the image.
        model: Multi-modal model name (default from env).
        timeout: Request timeout in seconds.

    Returns:
        Text description of the image.
    """
    use_model = model or get_vision_model()
    # SVGs must be rasterized — LLMs can't process XML vector graphics
    if _is_svg(image_uri):
        image_uri = await _rasterize_svg(image_uri)

    messages = [
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": (
                        "Describe this image concisely for a markdown document. "
                        "Focus on key visual elements, layout, and content."
                    ),
                },
                _image_uri_to_content(image_uri),
            ],
        }
    ]

    async with httpx.AsyncClient(timeout=timeout) as client:
        response = await client.post(
            f"{get_base_url()}/chat/completions",
            headers=_auth_headers(),
            json={
                "model": use_model,
                "messages": messages,
                "max_tokens": 500,
            },
        )
        response.raise_for_status()
        data = response.json()
        return data["choices"][0]["message"]["content"]
