#!/usr/bin/env python3
"""Launcher for NPL MCP unified server with singleton support.

This launcher ensures the unified HTTP server is running, starting it if needed.
Claude Code connects directly to the HTTP endpoint - no stdio proxy required.

Usage:
    # Ensure server is running, start if not
    python -m npl_mcp.launcher

    # Force start new server (stops existing if running)
    NPL_MCP_FORCE=true python -m npl_mcp.launcher

    # Just check status
    python -m npl_mcp.launcher --status

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
MCP_URL = f"{SERVER_URL}/mcp"
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
    print(f"  MCP Endpoint: {MCP_URL}")
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

    force = os.environ.get("NPL_MCP_FORCE", "false").lower() == "true"

    if force and is_server_running():
        print("Stopping existing server...", file=sys.stderr)
        stop_server()
        time.sleep(0.5)

    if is_server_running():
        print(f"✓ Server already running at {SERVER_URL}", file=sys.stderr)
        print(f"  MCP endpoint: {MCP_URL}", file=sys.stderr)
        print(f"  Web UI: {SERVER_URL}/", file=sys.stderr)
    else:
        print(f"Starting NPL MCP server...", file=sys.stderr)
        if start_server():
            print(f"✓ Server started at {SERVER_URL}", file=sys.stderr)
            print(f"  MCP endpoint: {MCP_URL}", file=sys.stderr)
            print(f"  Web UI: {SERVER_URL}/", file=sys.stderr)
            print(f"  Log file: {LOG_FILE}", file=sys.stderr)
        else:
            print(f"✗ Failed to start server. Check {LOG_FILE}", file=sys.stderr)
            sys.exit(1)


if __name__ == "__main__":
    main()
