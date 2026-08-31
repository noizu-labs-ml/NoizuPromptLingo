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
OPENAI_LITELLM_PATHS = (
    "/v1/chat/completions",
    "/v1/completions",
    "/v1/embeddings",
    "/v1/images",
    "/v1/audio",
    "/v1/responses",
)

HOP_BY_HOP = frozenset({
    "host", "connection", "keep-alive", "transfer-encoding",
    "te", "trailer", "upgrade",
})

AUTH_PLACEHOLDER = "FILL_ME_IN"
AUTH_STATE_FILE = "front-proxy-auth-state.json"
DEFAULT_REQUEST_LOG_DIR = Path("/var/log/run-cluade")
REQUEST_LOG_FILE = "request-log.jsonl"
AUTH_HEADER_NAMES = frozenset({"authorization", "x-api-key", "anthropic-api-key"})

STRIP_RESPONSE_HEADERS = frozenset({
    "content-encoding", "content-length", "transfer-encoding",
})


MAX_CONCURRENT_REQUESTS = 1000
MAX_CONNECTIONS = 1100
MAX_KEEPALIVE = 200


def _get_state_dir() -> Path:
    xdg_state = os.environ.get("XDG_STATE_HOME")
    state_dir = Path(xdg_state) / "run-claude" if xdg_state else Path.home() / ".local" / "state" / "run-claude"
    state_dir.mkdir(parents=True, exist_ok=True)
    return state_dir


def _get_request_log_path() -> Path:
    configured = os.environ.get("RUN_CLAUDE_REQUEST_LOG")
    if configured:
        return Path(configured)

    try:
        DEFAULT_REQUEST_LOG_DIR.mkdir(parents=True, exist_ok=True)
        probe = DEFAULT_REQUEST_LOG_DIR / ".write-test"
        probe.touch(exist_ok=True)
        probe.unlink(missing_ok=True)
        return DEFAULT_REQUEST_LOG_DIR / REQUEST_LOG_FILE
    except (PermissionError, OSError):
        return _get_state_dir() / REQUEST_LOG_FILE


def _get_auth_state_path() -> Path:
    configured = os.environ.get("RUN_CLAUDE_AUTH_STATE")
    if configured:
        return Path(configured)
    return _get_state_dir() / AUTH_STATE_FILE


def _read_json_file(path: Path) -> dict[str, Any]:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (FileNotFoundError, json.JSONDecodeError, OSError):
        return {}


def _write_json_file(path: Path, data: dict[str, Any]) -> None:
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        tmp = path.with_suffix(path.suffix + ".tmp")
        tmp.write_text(json.dumps(data, indent=2, sort_keys=True), encoding="utf-8")
        tmp.replace(path)
    except OSError as exc:
        logger.warning("Could not persist front proxy auth state to %s: %s", path, exc)


def _append_jsonl(path: Path, entry: dict[str, Any]) -> None:
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("a", encoding="utf-8") as f:
            f.write(json.dumps(entry, sort_keys=True, default=str) + "\n")
    except OSError as exc:
        logger.warning("Could not write front proxy request log to %s: %s", path, exc)


def _split_auth_value(value: str) -> tuple[str, str]:
    stripped = value.strip()
    if not stripped:
        return "Bearer", ""
    scheme, sep, token = stripped.partition(" ")
    if sep:
        return scheme, token.strip()
    return "Bearer", stripped


class FrontProxy:
    def __init__(
        self,
        master_key: str,
        litellm_url: str = DEFAULT_LITELLM_URL,
        port: int = DEFAULT_PORT,
        auth_state_path: Path | None = None,
        request_log_path: Path | None = None,
    ):
        self.master_key = master_key
        self.litellm_url = litellm_url.rstrip("/")
        self.port = port
        self.auth_state_path = auth_state_path or _get_auth_state_path()
        self.request_log_path = request_log_path or _get_request_log_path()
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
        if path in OPENAI_LITELLM_PATHS or any(path.startswith(f"{p}/") for p in OPENAI_LITELLM_PATHS):
            return self.litellm_url, True

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

    def _load_auth_state(self) -> dict[str, Any]:
        state = _read_json_file(self.auth_state_path)
        if not isinstance(state.get("headers"), dict):
            state["headers"] = {}
        return state

    def _save_auth_state(self, state: dict[str, Any]) -> None:
        _write_json_file(self.auth_state_path, state)

    @staticmethod
    def _header_report(headers: dict[str, str]) -> dict[str, Any]:
        return {
            name.lower(): {
                "present": True,
                "value": value if name.lower() not in AUTH_HEADER_NAMES else "<redacted>",
            }
            for name, value in sorted(headers.items(), key=lambda item: item[0].lower())
        }

    def _record_request(
        self,
        method: str,
        path: str,
        query: str,
        headers: dict[str, str],
        body: bytes,
        target_base: str,
        use_litellm_auth: bool,
        auth_reused: bool,
        auth_persisted: bool,
    ) -> None:
        entry = {
            "ts": datetime.now(timezone.utc).isoformat(),
            "method": method,
            "path": path,
            "query": query or None,
            "target_base": target_base,
            "use_litellm_auth": use_litellm_auth,
            "model": self._extract_model(body) or None,
            "headers": self._header_report(headers),
            "auth": {
                "present": any(name.lower() in AUTH_HEADER_NAMES for name in headers),
                "reused_persisted_token": auth_reused,
                "persisted_new_token": auth_persisted,
            },
        }
        _append_jsonl(self.request_log_path, entry)

    def _track_headers_and_auth(self, headers: dict[str, str]) -> tuple[dict[str, str], bool, bool]:
        """Persist observed auth and header names, and fill blank/placeholder auth."""
        state = self._load_auth_state()
        now = datetime.now(timezone.utc).isoformat()
        header_stats = state["headers"]
        lower_to_original = {name.lower(): name for name in headers}

        for name, value in headers.items():
            lower_name = name.lower()
            stats = header_stats.setdefault(lower_name, {"count": 0})
            stats["count"] = int(stats.get("count", 0)) + 1
            stats["last_seen"] = now
            stats["last_value"] = value if lower_name not in AUTH_HEADER_NAMES else "<redacted>"

        auth_key = lower_to_original.get("authorization")
        auth_reused = False
        auth_persisted = False

        if auth_key is not None:
            scheme, token = _split_auth_value(headers.get(auth_key, ""))
            if token and token != AUTH_PLACEHOLDER:
                state["last_auth_scheme"] = scheme or "Bearer"
                state["last_auth_token"] = token
                state["last_auth_seen"] = now
                auth_persisted = True
            elif state.get("last_auth_token"):
                headers[auth_key] = f"{state.get('last_auth_scheme') or 'Bearer'} {state['last_auth_token']}"
                auth_reused = True
        elif state.get("last_auth_token"):
            headers["authorization"] = f"{state.get('last_auth_scheme') or 'Bearer'} {state['last_auth_token']}"
            auth_reused = True

        self._save_auth_state(state)
        return headers, auth_reused, auth_persisted

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
        headers, auth_reused, auth_persisted = self._track_headers_and_auth(dict(headers))
        self._record_request(
            method, path, query, headers, body, target_base, use_litellm_auth,
            auth_reused, auth_persisted,
        )
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
        headers, auth_reused, auth_persisted = self._track_headers_and_auth(dict(headers))
        self._record_request(
            method, path, query, headers, body, target_base, use_litellm_auth,
            auth_reused, auth_persisted,
        )
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

    async def bootstrap(request: Request) -> Response:
        """Claude CLI bootstrap: return available models from LiteLLM as additional_model_options."""
        model_options = None
        try:
            client = await proxy._get_client()
            resp = await client.get(
                f"{proxy.litellm_url}/model/info",
                headers={"Authorization": f"Bearer {proxy.master_key}"},
                timeout=5.0,
            )
            if resp.status_code == 200:
                data = resp.json()
                models = data.get("data", [])

                try:
                    from .profiles import load_model_definitions
                    model_defs = load_model_definitions()
                except Exception:
                    model_defs = {}

                options = []
                for m in models:
                    model_name = m.get("model_name", "")
                    if not model_name:
                        continue
                    model_def = model_defs.get(model_name)
                    description = (
                        model_def.metadata.description
                        if model_def and model_def.metadata.description
                        else "via run-claude proxy"
                    )
                    options.append({
                        "model": model_name,
                        "name": model_name,
                        "description": description,
                    })
                if options:
                    model_options = options
        except Exception:
            pass

        result = {"client_data": None, "additional_model_options": model_options}
        return Response(content=json.dumps(result), media_type="application/json")

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
        Route("/api/claude_cli/bootstrap", bootstrap, methods=["GET"]),
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
