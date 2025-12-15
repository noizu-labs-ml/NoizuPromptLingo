#!/usr/bin/env python3
"""Launcher for NPL MCP unified server with singleton support.

This launcher ensures the unified SSE server is running, starting it if needed.
Claude Code connects directly to the SSE endpoint - no stdio proxy required.

Usage:
    npl-mcp              # Start server (or report if already running)
    npl-mcp --status     # Check server status
    npl-mcp --stop       # Stop the server
    npl-mcp --config     # Show Claude Code MCP config
    npl-mcp --test       # Test server connectivity via SSE client

Environment variables:
    NPL_MCP_HOST: Server host (default: 127.0.0.1)
    NPL_MCP_PORT: Server port (default: 8765)
    NPL_MCP_DATA_DIR: Data directory (default: ./data)
    NPL_MCP_FORCE: Force restart server (default: false)
"""

import os
import subprocess
import sys
import time
from pathlib import Path

import httpx


HOST = os.environ.get("NPL_MCP_HOST", "127.0.0.1")
PORT = int(os.environ.get("NPL_MCP_PORT", "8765"))
DATA_DIR = Path(os.environ.get("NPL_MCP_DATA_DIR", "./data"))
SERVER_URL = f"http://{HOST}:{PORT}"
MCP_URL = f"{SERVER_URL}/sse"
LOG_FILE = DATA_DIR / "server.log"
PID_FILE = DATA_DIR / ".npl-mcp.pid"


def is_server_running() -> bool:
    """Check if server is already running and responding."""
    try:
        with httpx.Client(timeout=2.0) as client:
            response = client.get(f"{SERVER_URL}/")
            return response.status_code == 200
    except (httpx.ConnectError, httpx.TimeoutException):
        return False


def get_server_pid() -> int | None:
    """Get PID of running server from PID file."""
    if PID_FILE.exists():
        try:
            return int(PID_FILE.read_text().strip())
        except (ValueError, OSError):
            pass
    return None


def stop_server():
    """Stop the running server."""
    pid = get_server_pid()
    if pid:
        try:
            import signal
            os.kill(pid, signal.SIGTERM)
            print(f"Stopped server (PID {pid})", file=sys.stderr)
            time.sleep(0.5)
        except ProcessLookupError:
            pass
    if PID_FILE.exists():
        PID_FILE.unlink()


def start_server() -> bool:
    """Start the unified server in the background.

    Returns:
        True if server started successfully
    """
    DATA_DIR.mkdir(parents=True, exist_ok=True)

    env = os.environ.copy()
    env["NPL_MCP_HOST"] = HOST
    env["NPL_MCP_PORT"] = str(PORT)
    env["NPL_MCP_DATA_DIR"] = str(DATA_DIR.absolute())

    with open(LOG_FILE, "a") as log:
        log.write(f"\n\n=== Starting server at {time.strftime('%Y-%m-%d %H:%M:%S')} ===\n")

        process = subprocess.Popen(
            [sys.executable, "-m", "npl_mcp.unified"],
            stdout=log,
            stderr=log,
            env=env,
            start_new_session=True,  # Detach from parent
        )

        # Write PID file
        PID_FILE.write_text(str(process.pid))

    # Wait for server to start
    for i in range(50):  # 5 seconds max
        time.sleep(0.1)
        if is_server_running():
            return True

    return False


def print_status():
    """Print server status information."""
    running = is_server_running()
    pid = get_server_pid()

    print(f"NPL MCP Server Status")
    print(f"  URL: {SERVER_URL}")
    print(f"  SSE Endpoint: {MCP_URL}")
    print(f"  Running: {'Yes' if running else 'No'}")
    if pid:
        print(f"  PID: {pid}")
    print(f"  Data Dir: {DATA_DIR.absolute()}")
    print(f"  Log File: {LOG_FILE.absolute()}")

    if running:
        print(f"\nClaude Code MCP Configuration:")
        print(f'''
{{
  "mcpServers": {{
    "npl-mcp": {{
      "url": "{MCP_URL}"
    }}
  }}
}}
''')


def print_claude_config():
    """Print Claude Code configuration snippet."""
    print(f"""
Add to your Claude Code MCP configuration:

{{
  "mcpServers": {{
    "npl-mcp": {{
      "url": "{MCP_URL}"
    }}
  }}
}}

Web UI available at: {SERVER_URL}
""")


async def run_test():
    """Test server connectivity via SSE client."""
    from fastmcp import Client
    from fastmcp.client.transports import SSETransport

    print(f"Connecting to {MCP_URL}...")
    client = Client(SSETransport(MCP_URL))

    async with client:
        # List available tools
        tools = await client.list_tools()
        print(f"\n✓ Connected! Available tools: {len(tools)}")
        print("\nFirst 10 tools:")
        for tool in tools[:10]:
            print(f"  - {tool.name}")

        # Test git_tree
        print("\nTesting git_tree('.')...")
        result = await client.call_tool("git_tree", {"path": "."})
        if result.content:
            output = result.content[0].text
            lines = output.split('\n')[:10]
            print('\n'.join(lines))
            if len(output.split('\n')) > 10:
                print("  ...")

        # Test list_sessions
        print("\nTesting list_sessions...")
        result = await client.call_tool("list_sessions", {"limit": 3})
        if result.content:
            print(result.content[0].text[:500])

    print("\n✓ All tests passed!")


def test_server():
    """Run the async test."""
    import asyncio

    if not is_server_running():
        print("Server not running. Start it first with: npl-mcp", file=sys.stderr)
        sys.exit(1)

    asyncio.run(run_test())


def main():
    """Main entry point."""
    # Handle --status flag
    if "--status" in sys.argv:
        print_status()
        return

    # Handle --stop flag
    if "--stop" in sys.argv:
        if is_server_running():
            stop_server()
            print("Server stopped", file=sys.stderr)
        else:
            print("Server not running", file=sys.stderr)
        return

    # Handle --config flag
    if "--config" in sys.argv:
        print_claude_config()
        return

    # Handle --test flag
    if "--test" in sys.argv:
        test_server()
        return

    force = os.environ.get("NPL_MCP_FORCE", "false").lower() == "true"

    if force and is_server_running():
        print("Stopping existing server...", file=sys.stderr)
        stop_server()
        time.sleep(0.5)

    if is_server_running():
        print(f"✓ Server already running at {SERVER_URL}", file=sys.stderr)
        print(f"  SSE endpoint: {MCP_URL}", file=sys.stderr)
        print(f"  Web UI: {SERVER_URL}/", file=sys.stderr)
    else:
        print(f"Starting NPL MCP server...", file=sys.stderr)
        if start_server():
            print(f"✓ Server started at {SERVER_URL}", file=sys.stderr)
            print(f"  SSE endpoint: {MCP_URL}", file=sys.stderr)
            print(f"  Web UI: {SERVER_URL}/", file=sys.stderr)
            print(f"  Log file: {LOG_FILE}", file=sys.stderr)
        else:
            print(f"✗ Failed to start server. Check {LOG_FILE}", file=sys.stderr)
            sys.exit(1)


if __name__ == "__main__":
    main()
