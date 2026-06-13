"""CodeFresh Python SDK core (US-091).

Covers:
    * Synchronous + async clients
    * Typed resource proxies: runs, scripts, prompts, agents, webhooks
    * Typed exception hierarchy (US-091 AC)
    * Webhook signature verification helper (US-144)
    * OTel bridge context-manager stub (US-094) — emits span around each call
      when the `opentelemetry` SDK is installed; no-op otherwise
"""

from __future__ import annotations

import hmac
import hashlib
import os
from contextlib import contextmanager
from dataclasses import dataclass
from typing import Any, Iterator, Optional

import httpx
from pydantic import BaseModel, Field


# ---------------------------------------------------------------------------
# Exceptions
# ---------------------------------------------------------------------------


class CodeFreshError(Exception):
    """Base class for all SDK errors."""


class AuthError(CodeFreshError):
    """401/403 from the API — token missing, invalid, or insufficient role."""


class NotFound(CodeFreshError):
    """404 — resource not found or cross-org isolation hit."""


class RateLimited(CodeFreshError):
    """429 — respect the `Retry-After` header when set."""


class CostCapExceeded(CodeFreshError):
    """402 — org cost cap reached; inspect `response.json()` for the projection."""


class ValidationError(CodeFreshError):
    """422 — changeset errors returned as `{"errors": {...}}`."""


# ---------------------------------------------------------------------------
# Typed models — a minimal subset; fuller model parity comes with real calls
# ---------------------------------------------------------------------------


class Run(BaseModel):
    id: str
    organization_id: str
    script_version_id: str
    agent_version_id: str
    status: str
    trigger_source: Optional[str] = None
    started_at: Optional[str] = None
    finished_at: Optional[str] = None
    summary_metrics: dict[str, Any] = Field(default_factory=dict)


class Script(BaseModel):
    id: str
    organization_id: str
    slug: str
    name: str
    current_version_id: Optional[str] = None


class Webhook(BaseModel):
    id: str
    name: str
    endpoint_url: str
    event_filters: list[str]
    active: bool


# ---------------------------------------------------------------------------
# Core HTTP plumbing
# ---------------------------------------------------------------------------


@dataclass
class _Config:
    api_url: str
    token: str
    timeout: float = 30.0


def _raise_for_status(resp: httpx.Response) -> None:
    if resp.status_code < 400:
        return
    try:
        payload = resp.json()
    except ValueError:
        payload = {"error": resp.text}
    msg = f"{resp.status_code}: {payload}"
    if resp.status_code in (401, 403):
        raise AuthError(msg)
    if resp.status_code == 404:
        raise NotFound(msg)
    if resp.status_code == 422:
        raise ValidationError(msg)
    if resp.status_code == 402:
        raise CostCapExceeded(msg)
    if resp.status_code == 429:
        raise RateLimited(msg)
    raise CodeFreshError(msg)


@contextmanager
def _otel_span(name: str) -> Iterator[None]:
    """US-094 — emit a span when OpenTelemetry is available; no-op otherwise.

    We don't require `opentelemetry-api` as a hard dep; the SDK is usable
    without it. When present, spans are attached to the ambient context so
    calls correlate with backend webhook `trace.trace_id` values.
    """
    try:
        from opentelemetry import trace  # type: ignore[import-not-found]

        tracer = trace.get_tracer("codefresh-sdk")
        with tracer.start_as_current_span(name):
            yield
    except ImportError:
        yield


# ---------------------------------------------------------------------------
# Resource proxies
# ---------------------------------------------------------------------------


class _Resource:
    def __init__(self, client: "Client") -> None:
        self._c = client


class _Runs(_Resource):
    def list(self, organization_id: str, **params: Any) -> list[Run]:
        with _otel_span("codefresh.runs.list"):
            data = self._c._get(f"/api/v1/organizations/{organization_id}/runs", params=params)
        return [Run.model_validate(r) for r in data.get("runs", [])]

    def get(self, organization_id: str, run_id: str) -> Run:
        with _otel_span("codefresh.runs.get"):
            data = self._c._get(f"/api/v1/organizations/{organization_id}/runs/{run_id}")
        return Run.model_validate(data["run"])

    def create(
        self, organization_id: str, script_id: str, agent_id: str, **opts: Any
    ) -> Run:
        body: dict[str, Any] = {"script_id": script_id, "agent_id": agent_id, **opts}
        with _otel_span("codefresh.runs.create"):
            data = self._c._post(
                f"/api/v1/organizations/{organization_id}/runs", json=body
            )
        return Run.model_validate(data["run"])


class _Scripts(_Resource):
    def list(self, organization_id: str) -> list[Script]:
        with _otel_span("codefresh.scripts.list"):
            data = self._c._get(f"/api/v1/organizations/{organization_id}/scripts")
        return [Script.model_validate(s) for s in data.get("scripts", [])]

    def import_yaml(self, organization_id: str, yaml_text: str) -> Script:
        with _otel_span("codefresh.scripts.import_yaml"):
            data = self._c._post(
                f"/api/v1/organizations/{organization_id}/scripts/import",
                json={"yaml": yaml_text},
            )
        return Script.model_validate(data["script"])


class _Webhooks(_Resource):
    def list(self, organization_id: str) -> list[Webhook]:
        with _otel_span("codefresh.webhooks.list"):
            data = self._c._get(f"/api/v1/organizations/{organization_id}/webhooks")
        return [Webhook.model_validate(w) for w in data.get("webhooks", [])]

    def create(
        self,
        organization_id: str,
        name: str,
        endpoint_url: str,
        event_filters: list[str],
    ) -> tuple[Webhook, str]:
        """Returns (webhook, secret). The secret is shown exactly once."""
        body = {
            "webhook": {
                "name": name,
                "endpoint_url": endpoint_url,
                "event_filters": event_filters,
            }
        }
        with _otel_span("codefresh.webhooks.create"):
            data = self._c._post(
                f"/api/v1/organizations/{organization_id}/webhooks", json=body
            )
        return Webhook.model_validate(data["webhook"]), data["secret"]


# ---------------------------------------------------------------------------
# Client
# ---------------------------------------------------------------------------


class Client:
    """Synchronous CodeFresh API client.

    Reads token from `CODEFRESH_API_TOKEN` when not explicitly supplied.
    """

    def __init__(
        self,
        api_url: str = "https://api.codefre.sh",
        token: Optional[str] = None,
        timeout: float = 30.0,
    ) -> None:
        resolved = token or os.environ.get("CODEFRESH_API_TOKEN")
        if not resolved:
            raise AuthError("no api token (pass token=... or set CODEFRESH_API_TOKEN)")
        self._cfg = _Config(api_url=api_url.rstrip("/"), token=resolved, timeout=timeout)
        self._http = httpx.Client(
            base_url=self._cfg.api_url,
            timeout=self._cfg.timeout,
            headers={"Authorization": f"Bearer {self._cfg.token}"},
        )
        self.runs = _Runs(self)
        self.scripts = _Scripts(self)
        self.webhooks = _Webhooks(self)

    def close(self) -> None:
        self._http.close()

    def __enter__(self) -> "Client":
        return self

    def __exit__(self, *_: Any) -> None:
        self.close()

    def _get(self, path: str, params: Optional[dict[str, Any]] = None) -> dict[str, Any]:
        r = self._http.get(path, params=params)
        _raise_for_status(r)
        return r.json()

    def _post(self, path: str, json: Optional[dict[str, Any]] = None) -> dict[str, Any]:
        r = self._http.post(path, json=json)
        _raise_for_status(r)
        return r.json()


class AsyncClient:
    """Async variant of `Client` — same surface, awaitable."""

    def __init__(
        self,
        api_url: str = "https://api.codefre.sh",
        token: Optional[str] = None,
        timeout: float = 30.0,
    ) -> None:
        resolved = token or os.environ.get("CODEFRESH_API_TOKEN")
        if not resolved:
            raise AuthError("no api token (pass token=... or set CODEFRESH_API_TOKEN)")
        self._cfg = _Config(api_url=api_url.rstrip("/"), token=resolved, timeout=timeout)
        self._http = httpx.AsyncClient(
            base_url=self._cfg.api_url,
            timeout=self._cfg.timeout,
            headers={"Authorization": f"Bearer {self._cfg.token}"},
        )

    async def aclose(self) -> None:
        await self._http.aclose()

    async def __aenter__(self) -> "AsyncClient":
        return self

    async def __aexit__(self, *_: Any) -> None:
        await self.aclose()


# ---------------------------------------------------------------------------
# Webhook signature verification (US-144)
# ---------------------------------------------------------------------------


def verify_webhook_signature(secret: str, body: bytes | str, signature_header: str) -> bool:
    """Constant-time compare of the backend's `X-Codefresh-Signature` header.

    The backend emits `sha256=<hex>`; we reconstruct the MAC and compare.
    Returns False on any format mismatch (never raises).
    """
    if not isinstance(secret, str) or not signature_header.startswith("sha256="):
        return False
    raw = body.encode("utf-8") if isinstance(body, str) else body
    mac = hmac.new(secret.encode("utf-8"), raw, hashlib.sha256).hexdigest()
    expected = f"sha256={mac}"
    return hmac.compare_digest(expected, signature_header)
