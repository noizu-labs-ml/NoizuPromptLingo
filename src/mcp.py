#!/usr/bin/env python3
"""Simple FastMCP hello world server.

This script creates a minimal FastMCP server exposing a single tool
`hello` that returns a greeting string. The server is served over Server-
Sent Events (SSE) using FastMCP's built‑in HTTP integration and runs via
Uvicorn.

Run the server with:
    python -m src.mcp   # or python src/mcp.py

The SSE endpoint will be available at http://127.0.0.1:8765/sse.
"""

from fastmcp import FastMCP
import uvicorn


def create_app() -> FastMCP:
    """Create a FastMCP instance with a hello world tool."""
    mcp = FastMCP("npl-mcp")

    @mcp.tool(name="hello-world")
    async def hello_world() -> str:
        """Return a greeting message."""
        return "hello"

    return mcp


def main() -> None:
    """Start the FastMCP server using Uvicorn.

    The FastMCP HTTP app is mounted at the root path ("/") and uses the
    "sse" transport, which provides an SSE endpoint at "/sse".
    """
    mcp = create_app()
    # FastMCP can expose an ASGI app; we request the SSE transport.
    app = mcp.http_app(path="/", transport="sse")
    uvicorn.run(app, host="127.0.0.1", port=8765)


if __name__ == "__main__":
    main()
