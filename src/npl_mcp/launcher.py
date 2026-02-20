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
from typing import Any, Optional
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
    """Create the FastMCP app with discovery tools and NPLSpec.

    MCP-visible tools are registered with @mcp.tool() + @discoverable(mcp_registered=True).
    Hidden tools are registered via discoverable_tools module.
    Stub tools come from stub_catalog.py.
    """
    from npl_mcp.meta_tools.catalog import discoverable, init_catalog
    from npl_mcp.convention_formatter import NPLDefinition, ComponentSpec

    mcp = FastMCP("npl-mcp")

    # ------------------------------------------------------------------
    # NPLSpec tool (MCP-visible)
    # ------------------------------------------------------------------

    @mcp.tool(name="NPLSpec")
    @discoverable(category="NPL", name="NPLSpec", mcp_registered=True,
                  description="Noizu Prompt Lingua specification generation and formatting")
    def npl_spec(
        components: list[ComponentSpec] = [],
        rendered: list[ComponentSpec] = [],
        component_priority: int = 0,
        example_priority: int = 0,
        extension: bool = False,
        concise: bool = True,
        xml: bool = False,
    ) -> str:
        """Generate an NPL definition or extension block.

        Args:
            components: List of component specs to include. Empty list includes all conventions.
            rendered: List of component specs already rendered elsewhere.
                     These are excluded from output but treated as known for example selection.
                     Empty list means nothing pre-rendered.
            component_priority: Default max component priority to include.
            example_priority: Default max example priority to include.
            extension: If True, wraps in extend markers instead of definition markers.
            concise: If True, use brief descriptions (default True).
            xml: If True, use XML tags for examples instead of fenced code blocks.
        """
        npl = NPLDefinition()
        return npl.format(
            components=components or None,
            rendered=rendered or None,
            component_priority=component_priority,
            example_priority=example_priority,
            extension=extension,
            flags={"concise": concise, "xml": xml},
        )

    # ------------------------------------------------------------------
    # Discovery tools (5 MCP-visible)
    # ------------------------------------------------------------------

    @mcp.tool(name="ToolSummary")
    @discoverable(category="Discovery", name="ToolSummary", mcp_registered=True,
                  description="Tool discovery: search, browse, and inspect registered tools")
    async def tool_summary(filter: Optional[str] = None) -> dict:
        """List available tools, or drill into a catalog category.

        Without filter: returns all non-Discovery tools grouped by category.

        With filter: expands that catalog category to show tool
        definitions and subcategories. Use dot notation to drill deeper
        (e.g. "Browser.Screenshots").

        With Category#ToolName: returns a single tool's full definition
        (e.g. "Browser.Screenshots#screenshot_capture").

        Args:
            filter: Category path to expand, or Category#Tool for a single tool.
                      Omit to see all tools.
        """
        from npl_mcp.meta_tools.summary import tool_summary as _summary
        return await _summary(filter=filter)

    @mcp.tool(name="ToolSearch")
    @discoverable(category="Discovery", name="ToolSearch", mcp_registered=True)
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
    @discoverable(category="Discovery", name="ToolDefinition", mcp_registered=True)
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
        return await _definition(tools)

    @mcp.tool(name="ToolHelp")
    @discoverable(category="Discovery", name="ToolHelp", mcp_registered=True)
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
    @discoverable(category="Discovery", name="ToolCall", mcp_registered=True)
    async def tool_call(tool: str, arguments: dict[str, Any] | None = None) -> Any:
        """Invoke a discoverable tool by name.

        Discoverable tools are hidden from the MCP tools/list but can be found
        via ToolSummary / ToolSearch / ToolDefinition and called here.

        Args:
            tool: Name of the discoverable tool to call.
            arguments: Arguments to pass as a JSON object.
        """
        from npl_mcp.meta_tools.catalog import call_tool, get_tool_by_name

        if arguments is None:
            arguments = {}

        entry = await get_tool_by_name(tool)
        if entry is None:
            return {"tool": tool, "status": "error", "message": f"Tool '{tool}' not found in catalog."}

        try:
            return await call_tool(tool, arguments)
        except KeyError:
            # Tool exists in catalog (maybe stub or MCP-registered) but not in discoverable registry
            return {
                "tool": tool,
                "status": "stub",
                "message": f"Tool '{tool}' is in the catalog but has no implementation via ToolCall.",
            }
        except TypeError as exc:
            return {"tool": tool, "status": "error", "message": f"Invalid arguments: {exc}"}
        except Exception as exc:
            return {"tool": tool, "status": "error", "message": f"{type(exc).__name__}: {exc}"}

    # ------------------------------------------------------------------
    # ToolSession tools (2 MCP-visible)
    # ------------------------------------------------------------------

    @mcp.tool(name="ToolSession.Generate")
    @discoverable(category="ToolSessions", name="ToolSession.Generate", mcp_registered=True,
                  description="Agent session tracking: generate, retrieve, and manage tool sessions keyed by agent/task pairs")
    async def tool_session_generate_handler(
        agent: str,
        brief: str,
        task: str,
        project: str,
        parent: Optional[str] = None,
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
            project: Project name for scoping (e.g. from $NPL_PROJECT).
            parent: Optional parent session UUID for hierarchy.
            notes: Optional notes to append to the session.
        """
        from npl_mcp.tool_sessions.tool_sessions import tool_session_generate as _gen
        return await _gen(agent=agent, brief=brief, task=task, project=project, parent=parent, notes=notes)

    @mcp.tool(name="ToolSession")
    @discoverable(category="ToolSessions", name="ToolSession", mcp_registered=True)
    async def tool_session_handler(
        uuid: str,
        verbose: bool = False,
    ) -> dict:
        """Retrieve session info by UUID.

        Default returns agent, brief, and project name.  Verbose mode returns
        all fields including task, notes, parent, and timestamps.

        Args:
            uuid: Session UUID.
            verbose: If True, return all fields (default False).
        """
        from npl_mcp.tool_sessions.tool_sessions import tool_session as _session
        return await _session(uuid=uuid, verbose=verbose)

    # ------------------------------------------------------------------
    # Instructions tools (3 MCP-visible)
    # ------------------------------------------------------------------

    @mcp.tool(name="Instructions")
    @discoverable(category="Instructions", name="Instructions", mcp_registered=True,
                  description="Versioned instruction documents: create, retrieve, update, rollback, list versions, and search")
    async def instructions_handler(
        uuid: str,
        session: str,
        version: Optional[int] = None,
        json: bool = False,
    ) -> dict | str:
        """Retrieve instruction body by UUID.

        Gets the active version by default, or a specific version if specified.

        Args:
            uuid: Instruction UUID.
            session: A valid tool-session UUID (required for access gating).
            version: Specific version number (active version if omitted).
            json: If True, return full metadata as JSON. Default returns markdown.
        """
        from npl_mcp.instructions.instructions import instructions_get as _get
        return await _get(uuid=uuid, version=version, json=json, session=session)

    @mcp.tool(name="Instructions.Create")
    @discoverable(category="Instructions", name="Instructions.Create", mcp_registered=True)
    async def instructions_create_handler(
        title: str,
        description: str,
        tags: list[str],
        body: str,
        session: str,
    ) -> dict:
        """Create a new instruction document with its first version (v1).

        Args:
            title: Instruction title.
            description: Instruction description.
            tags: List of string tags for categorization.
            body: Instruction body content.
            session: A valid tool-session UUID to link this instruction to.
        """
        from npl_mcp.instructions.instructions import instructions_create as _create
        return await _create(title=title, description=description, tags=tags, body=body, session=session)

    @mcp.tool(name="Instructions.List")
    @discoverable(category="Instructions", name="Instructions.List", mcp_registered=True)
    async def instructions_list_handler(
        session: str,
        query: Optional[str] = None,
        mode: str = "text",
        tags: Optional[list[str]] = None,
        limit: int = 20,
    ) -> dict:
        """Search and list instruction documents.

        Modes:
        - "text": ILIKE search on title, description, tags, and embedding labels
        - "intent": Embed query, cosine similarity search against instruction embeddings
        - "all": Return all instructions (no search filter)

        Args:
            session: A valid tool-session UUID (required for access gating).
            query: Search query string (required for text/intent modes).
            mode: Search mode: "text", "intent", or "all" (default: "text").
            tags: Optional tag filter (AND logic -- instruction must have all listed tags).
            limit: Maximum results to return (default 20, max 100).
        """
        from npl_mcp.instructions.instructions import instructions_list as _list
        return await _list(session=session, query=query, mode=mode, tags=tags, limit=limit)

    # ------------------------------------------------------------------
    # Initialize catalog and register discoverable tools
    # ------------------------------------------------------------------

    # Register implemented-but-hidden tools
    import npl_mcp.meta_tools.discoverable_tools  # noqa: F401

    # Initialize catalog with MCP reference for introspection
    init_catalog(mcp)

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
