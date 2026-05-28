"""Tests for the standalone hello-world MCP server in src/mcp.py."""

from __future__ import annotations

import importlib.util
from pathlib import Path

from fastapi.testclient import TestClient


def _load_minimal_mcp_module():
    path = Path(__file__).resolve().parents[1] / "src" / "mcp.py"
    spec = importlib.util.spec_from_file_location("minimal_mcp", path)
    assert spec is not None
    assert spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_minimal_mcp_asgi_app_serves_website() -> None:
    module = _load_minimal_mcp_module()
    client = TestClient(module.create_asgi_app())

    response = client.get("/")

    assert response.status_code == 200
    assert "Hello World MCP" in response.text
    assert "/sse" in response.text


def test_minimal_mcp_health_endpoint_reports_sse() -> None:
    module = _load_minimal_mcp_module()
    client = TestClient(module.create_asgi_app())

    response = client.get("/health")

    assert response.status_code == 200
    assert response.json()["status"] == "ok"
    assert response.json()["sse_endpoint"] == "/sse"


def test_minimal_mcp_mounts_sse_service() -> None:
    module = _load_minimal_mcp_module()
    app = module.create_asgi_app()

    mounted_paths = {getattr(route, "path", None) for route in app.routes}

    assert "/sse" in mounted_paths
