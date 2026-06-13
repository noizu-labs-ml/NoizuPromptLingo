#!/usr/bin/env python3
"""Library-level hello-world MCP server with an SSE service and website.

Run:
    uv run src/mcp.py --port 8777

Endpoints:
    http://127.0.0.1:8777/health
    http://127.0.0.1:8777/
    http://127.0.0.1:8777/sse
"""

from __future__ import annotations

import argparse
import datetime as dt
import sys
from pathlib import Path

import uvicorn
from fastapi import FastAPI
from fastapi.responses import HTMLResponse

# Running this file directly sets sys.path[0] to src/, where this file is
# named mcp.py. FastMCP imports the PyPI mcp package during startup, so remove
# that shadowing path before importing fastmcp.
_SCRIPT_DIR = str(Path(__file__).resolve().parent)
if sys.path and str(Path(sys.path[0]).resolve()) == _SCRIPT_DIR:
    sys.path.pop(0)

from fastmcp import FastMCP


def create_mcp_app() -> FastMCP:
    """Create the minimal FastMCP service."""
    mcp = FastMCP("hello-world-mcp")

    @mcp.tool(name="hello_world")
    async def hello_world(name: str = "world") -> str:
        """Return a greeting message."""
        return f"hello, {name}"

    @mcp.tool(name="echo")
    async def echo(message: str) -> str:
        """Return the provided message."""
        return message

    return mcp


def create_app() -> FastMCP:
    """Backward-compatible alias for the bare FastMCP app."""
    return create_mcp_app()


def create_asgi_app() -> FastAPI:
    """Create a tiny website plus the MCP SSE service mounted at /sse."""
    mcp = create_mcp_app()
    app = FastAPI(title="Hello World MCP")
    app.mount("/sse", mcp.http_app(path="/", transport="sse"))

    @app.get("/health")
    async def health() -> dict[str, str]:
        return {
            "status": "ok",
            "server": "hello-world-mcp",
            "sse_endpoint": "/sse",
            "ts": dt.datetime.now(dt.timezone.utc).isoformat(),
        }

    @app.get("/", response_class=HTMLResponse)
    async def index() -> str:
        return """<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Hello World MCP</title>
  <style>
    body {
      margin: 0;
      font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      background: #f7f8fb;
      color: #1f2937;
    }
    main {
      max-width: 760px;
      margin: 0 auto;
      padding: 56px 24px;
    }
    h1 {
      margin: 0 0 12px;
      font-size: 32px;
      line-height: 1.1;
    }
    p {
      color: #4b5563;
      font-size: 16px;
      line-height: 1.6;
    }
    dl {
      display: grid;
      grid-template-columns: max-content 1fr;
      gap: 12px 18px;
      margin-top: 28px;
      padding: 18px;
      border: 1px solid #d8dee9;
      border-radius: 8px;
      background: #fff;
    }
    dt {
      font-weight: 700;
    }
    dd {
      margin: 0;
      font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
      color: #111827;
    }
  </style>
</head>
<body>
  <main>
    <h1>Hello World MCP</h1>
    <p>A minimal FastMCP service mounted under Server-Sent Events with a website shell.</p>
    <dl>
      <dt>Status</dt><dd>running</dd>
      <dt>Health</dt><dd>/health</dd>
      <dt>MCP SSE</dt><dd>/sse</dd>
      <dt>Tools</dt><dd>hello_world, echo</dd>
    </dl>
  </main>
</body>
</html>"""

    return app


def main() -> None:
    """Start the hello-world MCP website and SSE service."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8765)
    args = parser.parse_args()
    uvicorn.run(create_asgi_app(), host=args.host, port=args.port)


if __name__ == "__main__":
    main()
