"""Ping tool – HTTP connectivity check with optional sentinel validation.

Sentinel prefixes:
  xpath:<expr>   – Evaluate XPath against the HTML response body.
  regex:<pattern> – Run a regex search against the response body.
  llm:<condition> – Ask an LLM to evaluate <condition> against the response.
"""

import re
import time
from typing import Any, Optional

import httpx
from lxml import html as lxml_html


async def ping(
    url: str,
    sentinel: Optional[str] = None,
    timeout: float = 10.0,
) -> dict[str, Any]:
    """Check connectivity to a URL and optionally validate response content.

    Args:
        url: URL to ping.
        sentinel: Optional validation expression prefixed with
            ``xpath:``, ``regex:``, or ``llm:``.
        timeout: Request timeout in seconds.

    Returns:
        Dict with status_code, response_time_ms, and optional sentinel_result.
    """
    result: dict[str, Any] = {"url": url}

    # --- HTTP request ---
    needs_body = sentinel is not None
    try:
        async with httpx.AsyncClient(timeout=timeout, follow_redirects=True) as client:
            t0 = time.monotonic()
            if needs_body:
                response = await client.get(url)
            else:
                response = await client.head(url)
            elapsed_ms = round((time.monotonic() - t0) * 1000, 2)

        result["status_code"] = response.status_code
        result["response_time_ms"] = elapsed_ms
    except httpx.TimeoutException:
        result["status_code"] = None
        result["response_time_ms"] = None
        result["error"] = "timeout"
        return result
    except httpx.RequestError as exc:
        result["status_code"] = None
        result["response_time_ms"] = None
        result["error"] = f"{type(exc).__name__}: {exc}"
        return result

    # --- Sentinel check ---
    if sentinel is None:
        return result

    body = response.text
    sentinel_result = await _evaluate_sentinel(sentinel, body)
    result["sentinel"] = sentinel_result
    return result


async def _evaluate_sentinel(sentinel: str, body: str) -> dict[str, Any]:
    """Dispatch to the appropriate sentinel handler."""
    if sentinel.startswith("xpath:"):
        return _sentinel_xpath(sentinel[6:], body)
    if sentinel.startswith("regex:"):
        return _sentinel_regex(sentinel[6:], body)
    if sentinel.startswith("llm:"):
        return await _sentinel_llm(sentinel[4:], body)
    return {"error": f"Unknown sentinel prefix. Use xpath:, regex:, or llm:. Got: {sentinel!r}"}


def _sentinel_xpath(expr: str, body: str) -> dict[str, Any]:
    """Evaluate an XPath expression against the HTML body."""
    try:
        tree = lxml_html.fromstring(body)
    except Exception as exc:
        return {"type": "xpath", "pass": False, "error": f"HTML parse error: {exc}"}

    try:
        matches = tree.xpath(expr)
    except Exception as exc:
        return {"type": "xpath", "pass": False, "error": f"XPath error: {exc}"}

    # Normalize results: xpath can return elements, strings, booleans, numbers
    if isinstance(matches, bool):
        return {"type": "xpath", "pass": matches, "value": matches}
    if isinstance(matches, (int, float)):
        return {"type": "xpath", "pass": bool(matches), "value": matches}
    if isinstance(matches, str):
        return {"type": "xpath", "pass": bool(matches), "value": matches}
    if isinstance(matches, list):
        # Convert elements to their text content
        values = []
        for m in matches:
            if hasattr(m, "text_content"):
                values.append(m.text_content())
            else:
                values.append(str(m))
        return {"type": "xpath", "pass": len(values) > 0, "matches": values}

    return {"type": "xpath", "pass": False, "value": str(matches)}


def _sentinel_regex(pattern: str, body: str) -> dict[str, Any]:
    """Run a regex search against the response body."""
    try:
        compiled = re.compile(pattern)
    except re.error as exc:
        return {"type": "regex", "pass": False, "error": f"Invalid regex: {exc}"}

    all_matches = compiled.findall(body)
    return {
        "type": "regex",
        "pass": len(all_matches) > 0,
        "matches": all_matches[:50],  # cap to prevent huge payloads
        "total_matches": len(all_matches),
    }


async def _sentinel_llm(condition: str, body: str) -> dict[str, Any]:
    """Ask an LLM to evaluate a condition against the response body."""
    from npl_mcp.meta_tools.llm_client import chat_completion

    # Truncate body to avoid token limits
    max_chars = 12_000
    truncated = body[:max_chars]
    if len(body) > max_chars:
        truncated += f"\n\n[... truncated, {len(body)} total chars]"

    messages = [
        {
            "role": "system",
            "content": (
                "You are a response validator. The user will give you an HTTP response body "
                "and a condition to check. Respond with EXACTLY one line starting with "
                "TRUE or FALSE, followed by a concise explanation (under 100 words)."
            ),
        },
        {
            "role": "user",
            "content": f"Condition: {condition}\n\n---\nResponse body:\n{truncated}",
        },
    ]

    try:
        resp = await chat_completion(messages, temperature=0.0, max_tokens=200)
        answer = resp["choices"][0]["message"]["content"].strip()
        passed = answer.upper().startswith("TRUE")
        return {"type": "llm", "pass": passed, "detail": answer}
    except Exception as exc:
        return {"type": "llm", "pass": False, "error": f"LLM error: {exc}"}
