"""Async LiteLLM proxy client for intent search and image descriptions."""

import base64
import mimetypes
import os
from pathlib import Path
from typing import Any

import httpx

LITELLM_BASE_URL = os.environ.get("NPL_LITELLM_URL", "http://localhost:4111/v1")
LITELLM_API_KEY = os.environ.get("NPL_LITELLM_KEY", "sk-litellm-master-key-12345")
LITELLM_MODEL = os.environ.get("NPL_LITELLM_MODEL", "groq/openai/gpt-oss-120b")


async def chat_completion(
    messages: list[dict[str, str]],
    temperature: float = 0.3,
    max_tokens: int = 2000,
    timeout: float = 30.0,
) -> dict[str, Any]:
    """Call LiteLLM-compatible chat completions endpoint.

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
            f"{LITELLM_BASE_URL}/chat/completions",
            headers={
                "Authorization": f"Bearer {LITELLM_API_KEY}",
                "Content-Type": "application/json",
            },
            json={
                "model": LITELLM_MODEL,
                "messages": messages,
                "temperature": temperature,
                "max_tokens": max_tokens,
            },
        )
        response.raise_for_status()
        return response.json()


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
    model: str = "openai/GPT5.2",
    timeout: float = 30.0,
) -> str:
    """Describe an image using a multi-modal LLM.

    Args:
        image_uri: URL, local file path, or data URI of the image.
        model: Multi-modal model name routed through LiteLLM.
        timeout: Request timeout in seconds.

    Returns:
        Text description of the image.
    """
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
            f"{LITELLM_BASE_URL}/chat/completions",
            headers={
                "Authorization": f"Bearer {LITELLM_API_KEY}",
                "Content-Type": "application/json",
            },
            json={
                "model": model,
                "messages": messages,
                "max_tokens": 500,
            },
        )
        response.raise_for_status()
        data = response.json()
        return data["choices"][0]["message"]["content"]
