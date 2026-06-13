"""Front proxy for run-claude.

Always-on reverse proxy sitting between Claude Code (:4443) and LiteLLM (:4444).
Provides routing, auth handling, and a consistent layer for logging/transforms.

In PASSTHROUGH mode (claude-plan profile):
  - Anthropic models → forward to api.anthropic.com with original OAuth auth
  - Non-Anthropic models → swap auth to LiteLLM master key, forward to LiteLLM
  - Non-inference paths → forward to api.anthropic.com

In STANDARD mode (all other profiles):
  - Everything → forward to LiteLLM (client already has master key as auth)
"""

from __future__ import annotations

import asyncio
import json
import logging
import os
import signal
import sys
from pathlib import Path
from typing import Any

from datetime import datetime, timezone

try:
    import httpx
except ImportError:
    httpx = None  # type: ignore[assignment]

logger = logging.getLogger("run_claude.front_proxy")


def _get_error_logger() -> logging.Logger:
    """Get or create a file logger for non-2xx upstream responses."""
    err_logger = logging.getLogger("run_claude.front_proxy.errors")
    if err_logger.handlers:
        return err_logger

    xdg_state = os.environ.get("XDG_STATE_HOME")
    state_dir = Path(xdg_state) / "run-claude" if xdg_state else Path.home() / ".local" / "state" / "run-claude"
    state_dir.mkdir(parents=True, exist_ok=True)
    log_path = state_dir / "front-proxy-errors.log"

    handler = logging.FileHandler(log_path)
    handler.setFormatter(logging.Formatter("%(message)s"))
    err_logger.addHandler(handler)
    err_logger.setLevel(logging.INFO)
    err_logger.propagate = False
    return err_logger

ANTHROPIC_API = "https://api.anthropic.com"
DEFAULT_LITELLM_URL = "http://127.0.0.1:4444"
DEFAULT_PORT = 4443

ANTHROPIC_MODEL_PREFIXES = ("claude-",)

HOP_BY_HOP = frozenset({
    "host", "connection", "keep-alive", "transfer-encoding",
    "te", "trailer", "upgrade",
})

STRIP_RESPONSE_HEADERS = frozenset({
    "content-encoding", "content-length", "transfer-encoding",
})


MAX_CONCURRENT_REQUESTS = 1000
MAX_CONNECTIONS = 1100
MAX_KEEPALIVE = 200


class FrontProxy:
    def __init__(
        self,
        master_key: str,
        litellm_url: str = DEFAULT_LITELLM_URL,
        port: int = DEFAULT_PORT,
    ):
        self.master_key = master_key
        self.litellm_url = litellm_url.rstrip("/")
        self.port = port
        self._client: httpx.AsyncClient | None = None
        self._semaphore = asyncio.Semaphore(MAX_CONCURRENT_REQUESTS)

    async def _get_client(self) -> httpx.AsyncClient:
        if self._client is None or self._client.is_closed:
            limits = httpx.Limits(
                max_connections=MAX_CONNECTIONS,
                max_keepalive_connections=MAX_KEEPALIVE,
                keepalive_expiry=1800,
            )
            self._client = httpx.AsyncClient(
                timeout=httpx.Timeout(600, connect=30),
                limits=limits,
            )
        return self._client

    def _route(self, path: str, body: bytes) -> tuple[str, bool]:
        """Decide target and whether to swap auth for LiteLLM.

        Returns (target_base_url, use_litellm_auth).
        use_litellm_auth=True: strip client OAuth, inject LiteLLM master key.
        use_litellm_auth=False: keep original headers (passthrough to Anthropic).
        """
        if path.startswith("/v1/messages") and not path.endswith("/count_tokens"):
            model = self._extract_model(body)
            if model and not model.startswith(ANTHROPIC_MODEL_PREFIXES):
                return self.litellm_url, True
            return ANTHROPIC_API, False

        return ANTHROPIC_API, False

    @staticmethod
    def _extract_model(body: bytes) -> str:
        if not body:
            return ""
        try:
            return json.loads(body).get("model", "")
        except (json.JSONDecodeError, UnicodeDecodeError):
            return ""

    def _log_error(self, method: str, url: str, status: int, body: bytes | None = None) -> None:
        """Log non-2xx responses to the error log file."""
        err_logger = _get_error_logger()
        model = self._extract_model(body) if body else ""
        entry = json.dumps({
            "ts": datetime.now(timezone.utc).isoformat(),
            "method": method,
            "url": url,
            "status": status,
            "model": model or None,
        }, default=str)
        err_logger.info(entry)

    def _prepare_headers(self, headers: dict[str, str], use_litellm_auth: bool) -> dict[str, str]:
        """Build forwarding headers, swapping auth when routing to LiteLLM."""
        fwd = {k: v for k, v in headers.items() if k.lower() not in HOP_BY_HOP}
        if use_litellm_auth:
            fwd["authorization"] = f"Bearer {self.master_key}"
        return fwd

    async def handle_request(
        self, method: str, path: str, headers: dict[str, str],
        body: bytes, query: str,
    ) -> tuple[int, dict[str, str], bytes]:
        """Route and forward a single request. Returns (status, headers, body)."""
        target_base, use_litellm_auth = self._route(path, body)
        fwd_headers = self._prepare_headers(headers, use_litellm_auth)

        url = f"{target_base}{path}"
        if query:
            url += f"?{query}"

        async with self._semaphore:
            try:
                client = await self._get_client()
                resp = await client.request(method=method, url=url, headers=fwd_headers, content=body)
            except httpx.PoolTimeout:
                logger.error("Connection pool exhausted for %s %s", method, url)
                self._log_error(method, url, 503, body)
                return 503, {"content-type": "application/json"}, b'{"type":"error","error":{"type":"overloaded_error","message":"front-proxy connection pool exhausted"}}'
            except httpx.ConnectError as exc:
                logger.error("Connect error for %s %s: %s", method, url, exc)
                self._log_error(method, url, 502, body)
                return 502, {"content-type": "application/json"}, b'{"type":"error","error":{"type":"api_error","message":"upstream connection failed"}}'
            except httpx.TimeoutException as exc:
                logger.error("Timeout for %s %s: %s", method, url, exc)
                self._log_error(method, url, 504, body)
                return 504, {"content-type": "application/json"}, b'{"type":"error","error":{"type":"timeout_error","message":"upstream request timed out"}}'

        if resp.status_code >= 300:
            self._log_error(method, url, resp.status_code, body)

        resp_headers = {k: v for k, v in resp.headers.items() if k.lower() not in HOP_BY_HOP and k.lower() not in STRIP_RESPONSE_HEADERS}
        return resp.status_code, resp_headers, resp.content

    async def handle_streaming_request(
        self, method: str, path: str, headers: dict[str, str],
        body: bytes, query: str,
    ):
        """Route and stream a single request. Yields (status, headers) then chunks."""
        target_base, use_litellm_auth = self._route(path, body)
        fwd_headers = self._prepare_headers(headers, use_litellm_auth)

        url = f"{target_base}{path}"
        if query:
            url += f"?{query}"

        await self._semaphore.acquire()
        try:
            client = await self._get_client()
            async with client.stream(method=method, url=url, headers=fwd_headers, content=body) as resp:
                if resp.status_code >= 300:
                    self._log_error(method, url, resp.status_code, body)
                resp_headers = {k: v for k, v in resp.headers.items() if k.lower() not in HOP_BY_HOP and k.lower() not in STRIP_RESPONSE_HEADERS}
                yield resp.status_code, resp_headers
                async for chunk in resp.aiter_bytes():
                    yield chunk
        except httpx.PoolTimeout:
            logger.error("Connection pool exhausted (stream) for %s %s", method, url)
            self._log_error(method, url, 503, body)
            yield 503, {"content-type": "application/json"}
            yield b'{"type":"error","error":{"type":"overloaded_error","message":"front-proxy connection pool exhausted"}}'
        except httpx.ConnectError as exc:
            logger.error("Connect error (stream) for %s %s: %s", method, url, exc)
            self._log_error(method, url, 502, body)
            yield 502, {"content-type": "application/json"}
            yield b'{"type":"error","error":{"type":"api_error","message":"upstream connection failed"}}'
        except httpx.TimeoutException as exc:
            logger.error("Timeout (stream) for %s %s: %s", method, url, exc)
            self._log_error(method, url, 504, body)
            yield 504, {"content-type": "application/json"}
            yield b'{"type":"error","error":{"type":"timeout_error","message":"upstream request timed out"}}'
        finally:
            self._semaphore.release()

    async def close(self):
        if self._client and not self._client.is_closed:
            await self._client.aclose()


def _build_app(proxy: FrontProxy) -> Any:
    """Build a Starlette app wrapping the proxy."""
    from starlette.applications import Starlette
    from starlette.requests import Request
    from starlette.responses import Response, StreamingResponse
    from starlette.routing import Route

    async def health(request: Request) -> Response:
        return Response(content='{"status":"ok"}', media_type="application/json")

    async def handle(request: Request) -> Response:
        path = request.url.path
        query = request.url.query.decode() if isinstance(request.url.query, bytes) else (request.url.query or "")
        headers = dict(request.headers)
        body = await request.body()
        method = request.method

        is_stream = "text/event-stream" in headers.get("accept", "")

        if is_stream:
            gen = proxy.handle_streaming_request(method, path, headers, body, query)
            first = await gen.__anext__()
            status_code, resp_headers = first

            async def stream():
                async for chunk in gen:
                    yield chunk

            return StreamingResponse(stream(), status_code=status_code, headers=resp_headers)

        status_code, resp_headers, resp_body = await proxy.handle_request(
            method, path, headers, body, query,
        )
        return Response(content=resp_body, status_code=status_code, headers=resp_headers)

    app = Starlette(routes=[
        Route("/health", health, methods=["GET"]),
        Route("/{path:path}", handle, methods=["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"]),
    ])
    return app


def run_server(
    master_key: str,
    port: int = DEFAULT_PORT,
    litellm_url: str = DEFAULT_LITELLM_URL,
) -> None:
    """Run the front proxy server (blocking). Intended to be called in a subprocess."""
    import uvicorn

    proxy = FrontProxy(
        master_key=master_key,
        litellm_url=litellm_url,
        port=port,
    )
    app = _build_app(proxy)

    print(f"[front-proxy] Starting on 127.0.0.1:{port}", file=sys.stderr)
    uvicorn.run(app, host="127.0.0.1", port=port, log_level="warning")


def main():
    """CLI entry point for running the front proxy standalone."""
    import argparse
    parser = argparse.ArgumentParser(description="run-claude front proxy")
    parser.add_argument("--master-key", required=True)
    parser.add_argument("--port", type=int, default=DEFAULT_PORT)
    parser.add_argument("--litellm-url", default=DEFAULT_LITELLM_URL)
    args = parser.parse_args()
    run_server(
        master_key=args.master_key,
        port=args.port,
        litellm_url=args.litellm_url,
    )


if __name__ == "__main__":
    main()
