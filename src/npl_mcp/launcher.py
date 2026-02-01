#!/usr/bin/env python3
"""Launcher for the NPL MCP server.

This is a minimal launcher that starts the FastMCP server directly.

Usage:
    npl-mcp                  # Start server
    npl-mcp --status         # Check if server running
    npl-mcp --port PORT      # Use custom port (default 8765)
    npl-mcp --host HOST      # Use custom host (default 127.0.0.1)
"""

import sys
import time
from contextlib import asynccontextmanager

import uvicorn
from fastmcp import FastMCP


HOST = "127.0.0.1"
PORT = "8765"


def create_app() -> "FastMCP":
    """Create the FastMCP app with tools."""
    mcp = FastMCP("npl-mcp")

    @mcp.tool(name="hello-world")
    async def hello_world() -> str:
        """Return a greeting message."""
        return "hello"

    @mcp.tool()
    async def echo(text: str) -> str:
        """Echo back the provided text."""
        return f"Echo: {text}"

    return mcp


def main() -> None:
    """Main entry point."""
    global HOST, PORT

    args = sys.argv[1:]

    if "--help" in args or "-h" in args:
        print(__doc__)
        return

    if "--status" in args:
        import httpx
        try:
            resp = httpx.get(f"http://{HOST}:{PORT}/", timeout=1.0)
            print(f"Server running at http://{HOST}:{PORT}")
        except Exception:
            print("Server not running")
        return

    # Parse host/port args
    i = 0
    while i < len(args):
        if args[i] == "--port" and i + 1 < len(args):
            PORT = args[i + 1]
            i += 2
        elif args[i] == "--host" and i + 1 < len(args):
            HOST = args[i + 1]
            i += 2
        else:
            i += 1

    print(f"Starting NPL MCP server at http://{HOST}:{PORT}/sse")
    mcp = create_app()
    # Create a minimal FastAPI app to mount the SSE endpoint at /sse
    from fastapi import FastAPI
    api = FastAPI()
    mcp_app = mcp.http_app(path="/", transport="sse")
    api.mount("/sse", mcp_app)

    # Add a simple health check at root
    @api.get("/")
    async def health():
        return {"status": "ok", "sse_endpoint": f"/sse"}

    uvicorn.run(api, host=HOST, port=int(PORT))


if __name__ == "__main__":
    main()