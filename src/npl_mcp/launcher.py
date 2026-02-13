#!/usr/bin/env python3
"""Launcher for the NPL MCP server.

This is a minimal launcher that starts the FastMCP server directly with a Next.js frontend.

Usage:
    npl-mcp                  # Start server
    npl-mcp --status         # Check if server running
    npl-mcp --port PORT      # Use custom port (default 8765)
    npl-mcp --host HOST      # Use custom host (default 127.0.0.1)
    npl-mcp --no-frontend    # Start server without frontend build
    npl-mcp --reload         # Auto-reload on file changes
"""

import subprocess
import sys
from pathlib import Path

import uvicorn
from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse, FileResponse
from fastapi.staticfiles import StaticFiles
from fastmcp import FastMCP
from starlette.middleware.base import BaseHTTPMiddleware


HOST = "127.0.0.1"
PORT = "8765"

# Paths
REPO_ROOT = Path(__file__).parent.parent.parent
FRONTEND_DIR = REPO_ROOT / "frontend"
DIST_DIR = Path(__file__).parent.resolve() / "web" / "static"


def build_frontend() -> bool:
    """Build the Next.js frontend if needed.

    Returns:
        True if build succeeded or already exists, False otherwise
    """
    # Check if dist directory exists and has content
    if DIST_DIR.exists() and (DIST_DIR / "index.html").exists():
        return True

    # Check if frontend directory exists
    if not FRONTEND_DIR.exists():
        print("Warning: Frontend directory not found. Starting without frontend.")
        return False

    print("Building Next.js frontend...")
    try:
        result = subprocess.run(
            ["npm", "run", "build"],
            cwd=str(FRONTEND_DIR),
            check=True,
            capture_output=True,
            text=True,
        )
        print("Frontend build completed successfully.")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Warning: Frontend build failed: {e}")
        print("Starting server without frontend.")
        if e.stdout:
            print(f"stdout: {e.stdout}")
        if e.stderr:
            print(f"stderr: {e.stderr}")
        return False
    except FileNotFoundError:
        print("Warning: npm not found. Skipping frontend build.")
        print("To build frontend, install Node.js and run: cd frontend && npm install && npm run build")
        return False


def create_app() -> "FastMCP":
    """Create the FastMCP app with discovery tools.

    ToolSummary, ToolSearch, ToolDefinition, ToolHelp, and ToolCall
    are visible at startup. All catalog tools are callable via ToolCall.
    """
    from typing import Optional

    mcp = FastMCP("npl-mcp")

    @mcp.tool(name="ToolSummary")
    async def tool_summary(filter: Optional[str] = None) -> dict:
        """List available tools, or drill into a catalog category.

        Without filter: returns the discovery tools with descriptions.

        With filter: expands that catalog category to show tool
        definitions and subcategories. Use dot notation to drill deeper
        (e.g. "Browser.Screenshots").

        With Category#ToolName: returns a single tool's full definition
        (e.g. "Browser.Screenshots#screenshot_capture").

        Args:
            filter: Category path to expand, or Category#Tool for a single tool.
                      Omit to see exposed tools.
        """
        from npl_mcp.meta_tools.summary import tool_summary as _summary
        return await _summary(filter=filter)

    @mcp.tool(name="ToolSearch")
    async def tool_search(
        query: str,
        mode: str = "text",
        limit: int = 10,
        verbose: bool = False,
    ) -> dict:
        """Search for tools by name/description or by intent.

        Two search modes:
        - "text": Fast substring matching against tool names and descriptions.
        - "intent": LLM-powered semantic search that explains HOW tools can
          fulfill your goal, including multi-tool workflow suggestions.

        Args:
            query: Search text (tool name for text mode, natural language for intent mode).
            mode: "text" or "intent" (default: "text").
            limit: Maximum results (default: 10).
            verbose: If True, include full parameter definitions in each match.

        Returns:
            JSON with matches including tool name, description,
            and (for intent mode) relevance and usage explanation.
        """
        from npl_mcp.meta_tools.search import tool_search as _search
        return await _search(query, mode=mode, limit=limit, verbose=verbose)

    @mcp.tool(name="ToolDefinition")
    async def tool_definition(tools: list[str]) -> dict:
        """Get full definitions for one or more catalog tools by name.

        Returns complete tool info including all parameters. Use this
        after ToolSearch or ToolSummary to get parameter details.

        Args:
            tools: List of tool names to look up (e.g. ["ToMarkdown", "Ping"]).

        Returns:
            JSON with full tool definitions including parameters,
            and any names that were not found.
        """
        from npl_mcp.meta_tools.definition import tool_definition as _definition
        return _definition(tools)

    @mcp.tool(name="ToolHelp")
    async def tool_help(tool: str, task: str, verbose: int = 2) -> dict:
        """Get LLM-driven instructions on how to use a tool for a specific task.

        Returns actionable guidance tailored to your task, with detail level
        controlled by verbose.

        Args:
            tool: Name of the catalog tool (e.g. "ToMarkdown").
            task: What you are trying to accomplish.
            verbose: Detail level: 1=brief, 2=standard, 3=detailed with examples.

        Returns:
            JSON with tool name, task, and generated instructions.
        """
        from npl_mcp.meta_tools.help import tool_help as _help
        return await _help(tool, task, verbose=verbose)

    @mcp.tool(name="ToolCall")
    async def tool_call(tool: str, arguments: dict = None) -> dict:
        """Call any catalog tool by name, whether pinned or not.

        Dispatches to the tool's implementation with the provided arguments.
        Returns the tool's result directly, or an error if the tool is not
        found or has no implementation.

        Args:
            tool: Name of the catalog tool to call (e.g. "Ping").
            arguments: Arguments to pass to the tool as a JSON object (default: {}).
        """
        from npl_mcp.meta_tools.catalog import get_tool_by_name
        from npl_mcp.meta_tools.tool_registry import get_implementation

        if arguments is None:
            arguments = {}

        entry = get_tool_by_name(tool)
        if entry is None:
            return {"tool": tool, "status": "error", "message": f"Tool '{tool}' not found in catalog."}

        impl = get_implementation(tool)
        if impl is None:
            return {
                "tool": tool,
                "status": "stub",
                "message": f"Tool '{tool}' is in the catalog but has no implementation yet.",
            }

        try:
            return await impl(**arguments)
        except TypeError as exc:
            return {"tool": tool, "status": "error", "message": f"Invalid arguments: {exc}"}
        except Exception as exc:
            return {"tool": tool, "status": "error", "message": f"{type(exc).__name__}: {exc}"}

    # ------------------------------------------------------------------
    # ToolSession tools (2 registered)
    # ------------------------------------------------------------------

    @mcp.tool(name="ToolSession.Generate")
    async def tool_session_generate_handler(
        agent: str,
        brief: str,
        task: str,
        notes: Optional[str] = None,
    ) -> dict:
        """Generate or look up a session UUID by (agent, task) pair.

        If a session already exists for this agent/task pair, returns its UUID.
        If notes are provided and not already present, appends them.
        If no session exists, creates a new one.

        Args:
            agent: Agent identifier.
            brief: Brief description of the session purpose.
            task: Task identifier (unique per agent).
            notes: Optional notes to append to the session.
        """
        from npl_mcp.tool_sessions.tool_sessions import tool_session_generate as _gen
        return await _gen(agent=agent, brief=brief, task=task, notes=notes)

    @mcp.tool(name="ToolSession")
    async def tool_session_handler(
        uuid: str,
        verbose: bool = False,
    ) -> dict:
        """Retrieve session info by UUID.

        Default returns agent and brief.  Verbose mode returns all fields
        including task, notes, and timestamps.

        Args:
            uuid: Session UUID.
            verbose: If True, return all fields (default False).
        """
        from npl_mcp.tool_sessions.tool_sessions import tool_session as _session
        return await _session(uuid=uuid, verbose=verbose)

    # ------------------------------------------------------------------
    # Instructions tools (2 registered)
    # ------------------------------------------------------------------

    @mcp.tool(name="Instructions")
    async def instructions_handler(
        uuid: str,
        version: Optional[int] = None,
    ) -> dict:
        """Retrieve instruction body by UUID.

        Gets the active version by default, or a specific version if specified.

        Args:
            uuid: Instruction UUID.
            version: Specific version number (active version if omitted).
        """
        from npl_mcp.instructions.instructions import instructions_get as _get
        return await _get(uuid=uuid, version=version)

    @mcp.tool(name="Instructions.Create")
    async def instructions_create_handler(
        title: str,
        description: str,
        tags: list[str],
        body: str,
    ) -> dict:
        """Create a new instruction document with its first version (v1).

        Args:
            title: Instruction title.
            description: Instruction description.
            tags: List of string tags for categorization.
            body: Instruction body content.
        """
        from npl_mcp.instructions.instructions import instructions_create as _create
        return await _create(title=title, description=description, tags=tags, body=body)

    return mcp


def create_asgi_app() -> FastAPI:
    """Build the full ASGI app (MCP + frontend).

    Extracted as a factory so uvicorn --reload can re-import it.
    """
    mcp = create_app()
    mcp_sse_app = mcp.http_app(path="/", transport="sse")

    api = FastAPI(title="NPL MCP Server")
    api.mount("/sse", mcp_sse_app)

    if DIST_DIR.exists() and (DIST_DIR / "index.html").exists():
        try:
            api.mount("/_next", StaticFiles(directory=str(DIST_DIR / "_next")), name="next-static")

            class FrontendFallbackMiddleware(BaseHTTPMiddleware):
                async def dispatch(self, request: Request, call_next):
                    response = await call_next(request)
                    if response.status_code == 404 and request.method == "GET":
                        path = request.url.path.lstrip("/")
                        file_path = DIST_DIR / path
                        if file_path.is_file():
                            return FileResponse(file_path)
                        index_path = DIST_DIR / "index.html"
                        if index_path.exists():
                            return FileResponse(index_path)
                    return response

            api.add_middleware(FrontendFallbackMiddleware)
        except Exception:
            serve_fallback(api)
    else:
        serve_fallback(api)

    return api


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

    # Parse args
    no_frontend = "--no-frontend" in args
    i = 0
    while i < len(args):
        if args[i] == "--port" and i + 1 < len(args):
            PORT = args[i + 1]
            i += 2
        elif args[i] == "--host" and i + 1 < len(args):
            HOST = args[i + 1]
            i += 2
        elif args[i] in ("--no-frontend", "--reload"):
            i += 1
        else:
            i += 1

    # Build frontend unless explicitly disabled
    frontend_built = False
    if not no_frontend:
        frontend_built = build_frontend()

    reload = "--reload" in args

    if reload:
        # With --reload, uvicorn needs an import string to re-import on changes
        uvicorn.run(
            "npl_mcp.launcher:create_asgi_app",
            factory=True,
            host=HOST,
            port=int(PORT),
            reload=True,
            reload_dirs=[str(Path(__file__).parent)],
        )
    else:
        api = create_asgi_app()
        uvicorn.run(api, host=HOST, port=int(PORT))


def serve_fallback(api: FastAPI) -> None:
    """Serve simple fallback page when frontend is not available."""

    @api.get("/")
    async def fallback_root():
        return HTMLResponse("""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NPL MCP Server</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            line-height: 1.6;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: #eee;
            min-height: 100vh;
        }
        h1 {
            background: linear-gradient(to right, #4f8cff, #9c27b0);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            font-size: 2.5rem;
        }
        .status {
            color: #4caf50;
            font-weight: bold;
        }
        code {
            background: #0a0a0f;
            padding: 2px 6px;
            border-radius: 4px;
            font-family: monospace;
            color: #4f8cff;
        }
    </style>
</head>
<body>
    <h1>NPL MCP Server</h1>
    <p class="status">● Server running</p>
    <p>The MCP SSE endpoint is available at <code>/sse</code></p>
    <p>To enable the web UI, build the frontend:</p>
    <pre><code>cd frontend
npm install
npm run build</code></pre>
</body>
</html>
""")

    @api.get("/health")
    async def health():
        return {"status": "ok", "sse_endpoint": "/sse"}


if __name__ == "__main__":
    main()