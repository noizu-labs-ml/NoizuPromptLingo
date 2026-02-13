"""Rest tool – full HTTP client with ``${secret.NAME}`` injection.

Supports GET, POST, PUT, PATCH, DELETE, HEAD, and OPTIONS.
Secret placeholders in headers and body are resolved via batch DB lookup
before the request is sent.
"""

import re
import time
from typing import Any, Optional

import httpx

from .secrets import get_secrets_batch

# Secret placeholder pattern: ${secret.NAME}
_SECRET_RE = re.compile(r"\$\{secret\.([a-zA-Z_][a-zA-Z0-9_]*)\}")

_ALLOWED_METHODS = frozenset({"GET", "POST", "PUT", "PATCH", "DELETE", "HEAD", "OPTIONS"})
_MAX_BODY_INPUT = 1_048_576   # 1 MB
_MAX_RESPONSE_BODY = 2_097_152  # 2 MB


def _collect_secret_refs(*texts: Optional[str]) -> list[str]:
    """Extract unique secret names from one or more text values."""
    names: set[str] = set()
    for text in texts:
        if text:
            names.update(_SECRET_RE.findall(text))
    return sorted(names)


def _inject_secrets(text: str, secrets: dict[str, str]) -> str:
    """Replace ``${secret.NAME}`` placeholders with resolved values."""
    def _replacer(m: re.Match) -> str:
        return secrets[m.group(1)]
    return _SECRET_RE.sub(_replacer, text)


async def rest(
    url: str,
    method: str = "GET",
    headers: Optional[dict[str, str]] = None,
    accept: Optional[str] = None,
    encoding: Optional[str] = None,
    body: Optional[str] = None,
    timeout: float = 30.0,
) -> dict[str, Any]:
    """Make an HTTP request with optional secret injection.

    Args:
        url: Request URL.
        method: HTTP method (GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS).
        headers: Optional request headers dict.
        accept: Default Accept header (won't override an explicit header).
        encoding: Default Accept-Encoding header (won't override explicit).
        body: Optional request body string.
        timeout: Request timeout in seconds (default 30).

    Returns:
        Dict with url, method, status_code, response_time_ms,
        response_headers, body, and optionally secrets_injected.
    """
    result: dict[str, Any] = {"url": url, "method": method.upper()}

    # --- Validate method ---
    method_upper = method.upper()
    if method_upper not in _ALLOWED_METHODS:
        result["status"] = "error"
        result["message"] = (
            f"Unsupported HTTP method: {method!r}. "
            f"Allowed: {', '.join(sorted(_ALLOWED_METHODS))}"
        )
        return result

    # --- Validate body size ---
    if body is not None and len(body) > _MAX_BODY_INPUT:
        result["status"] = "error"
        result["message"] = f"Request body exceeds {_MAX_BODY_INPUT} byte limit."
        return result

    # --- Build headers ---
    req_headers = dict(headers or {})
    if accept and "Accept" not in req_headers and "accept" not in req_headers:
        req_headers["Accept"] = accept
    if encoding and "Accept-Encoding" not in req_headers and "accept-encoding" not in req_headers:
        req_headers["Accept-Encoding"] = encoding

    # --- Collect and resolve secrets ---
    header_text = "\n".join(f"{k}: {v}" for k, v in req_headers.items()) if req_headers else None
    secret_names = _collect_secret_refs(header_text, body)

    if secret_names:
        secrets = await get_secrets_batch(secret_names)
        missing = [n for n in secret_names if n not in secrets]
        if missing:
            result["status"] = "error"
            result["message"] = (
                f"Missing secrets: {', '.join(missing)}. "
                "All referenced secrets must exist before making the request."
            )
            return result

        # Inject into headers
        if req_headers:
            req_headers = {
                k: _inject_secrets(v, secrets) for k, v in req_headers.items()
            }
        # Inject into body
        if body:
            body = _inject_secrets(body, secrets)

        result["secrets_injected"] = secret_names

    # --- Make request ---
    try:
        async with httpx.AsyncClient(timeout=timeout, follow_redirects=True) as client:
            t0 = time.monotonic()
            response = await client.request(
                method_upper,
                url,
                headers=req_headers or None,
                content=body.encode("utf-8") if body else None,
            )
            elapsed_ms = round((time.monotonic() - t0) * 1000, 2)
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

    # --- Build response ---
    result["status_code"] = response.status_code
    result["response_time_ms"] = elapsed_ms
    result["response_headers"] = dict(response.headers)

    resp_body = response.text
    truncated = False
    if len(resp_body) > _MAX_RESPONSE_BODY:
        resp_body = resp_body[:_MAX_RESPONSE_BODY]
        truncated = True

    result["body"] = resp_body
    if truncated:
        result["body_truncated"] = True

    return result
