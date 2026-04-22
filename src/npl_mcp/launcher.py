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

import datetime
import subprocess
import sys
from typing import Any, Optional
from pathlib import Path

import uvicorn
from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse, FileResponse
from fastapi.staticfiles import StaticFiles
from fastmcp import FastMCP

# Module-level start time — captured once at import for uptime calculation.
_STARTED_AT: datetime.datetime = datetime.datetime.now(datetime.timezone.utc)

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

    MCP-visible tools are registered with ``@mcp_discoverable(mcp, ...)``, which
    stacks ``@mcp.tool()`` + ``@discoverable(..., mcp_registered=True)`` in one
    call and populates FastMCP-native ``tags`` / ``meta`` from the NPL category.
    Hidden tools are registered via the ``discoverable_tools`` module.
    Stub tools come from ``stub_catalog.py``.
    """
    from npl_mcp.meta_tools.catalog import init_catalog, mcp_discoverable
    from npl_mcp.convention_formatter import NPLDefinition, ComponentSpec

    mcp = FastMCP("npl-mcp")

    # ------------------------------------------------------------------
    # NPLSpec tool (MCP-visible)
    # ------------------------------------------------------------------

    @mcp_discoverable(
        mcp,
        name="NPLSpec",
        category="NPL",
        description="Noizu Prompt Lingua specification generation and formatting",
    )
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
    # NPLLoad tool (MCP-visible) — expression DSL for selective loading
    # ------------------------------------------------------------------

    @mcp_discoverable(
        mcp,
        name="NPLLoad",
        category="NPL",
        description="Load NPL components by expression DSL — agent-friendly alternative to NPLSpec",
    )
    def npl_load(
        expression: str,
        layout: str = "yaml_order",
        skip: Optional[list[str]] = None,
    ) -> str:
        """Load NPL components via expression DSL.

        Expression grammar (space-separated terms):
          - ``syntax`` — the entire syntax section
          - ``syntax#placeholder`` — a specific component
          - ``syntax#placeholder:+2`` — component plus examples with priority ≤ 2
          - ``syntax directives`` — multiple sections
          - ``syntax -syntax#literal`` — subtract specific component
          - ``pumps#chain-of-thought pumps#plan-of-action`` — multiple components

        Sections: syntax, declarations, directives, prefixes, prompt-sections,
        special-sections, pumps, fences.

        Args:
            expression: NPL loading expression as described above.
            layout: One of "yaml_order" (default, flat section order),
                    "classic" (grouped by first label), or "grouped" (by section).
            skip: Optional list of expression terms already loaded elsewhere —
                their components are excluded from this load. Same grammar as
                *expression* (without leading ``-``). Example:
                ``["syntax#placeholder", "pumps"]``.

        Returns:
            Markdown-formatted NPL components matching the expression.
        """
        from pathlib import Path
        from npl_mcp.npl.loader import load_npl
        from npl_mcp.npl.layout import LayoutStrategy

        layout_map = {
            "yaml_order": LayoutStrategy.YAML_ORDER,
            "classic": LayoutStrategy.CLASSIC,
            "grouped": LayoutStrategy.GROUPED,
        }
        strategy = layout_map.get(layout.lower(), LayoutStrategy.YAML_ORDER)

        # Locate conventions/ relative to project root (the parent of src/)
        conventions_dir = Path(__file__).resolve().parent.parent.parent / "conventions"

        return load_npl(expression, npl_dir=conventions_dir, layout=strategy, skip=skip)

    # ------------------------------------------------------------------
    # Discovery tools (5 MCP-visible)
    # ------------------------------------------------------------------

    @mcp_discoverable(
        mcp,
        name="ToolSummary",
        category="Discovery",
        description="Tool discovery: search, browse, and inspect registered tools",
    )
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

    @mcp_discoverable(mcp, name="ToolSearch", category="Discovery")
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

    @mcp_discoverable(mcp, name="ToolDefinition", category="Discovery")
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

    @mcp_discoverable(mcp, name="ToolHelp", category="Discovery")
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

    @mcp_discoverable(mcp, name="ToolCall", category="Discovery")
    async def tool_call(tool: str, arguments: dict[str, Any] | None = None) -> Any:
        """Invoke a discoverable tool by name.

        Discoverable tools are hidden from the MCP tools/list but can be found
        via ToolSummary / ToolSearch / ToolDefinition and called here.

        Status values in the response:
          * ``mcp`` — tool is MCP-registered; clients should call it directly
            via the MCP protocol rather than through ToolCall.
          * ``stub`` — tool is in the catalog but has no implementation.
          * ``error`` — tool not found or invocation failed.

        Args:
            tool: Name of the discoverable tool to call.
            arguments: Arguments to pass as a JSON object.
        """
        from npl_mcp.meta_tools.catalog import (
            _DISCOVERABLE_TOOLS,
            _MCP_TOOL_CATEGORIES,
            call_tool,
            get_tool_by_name,
        )

        if arguments is None:
            arguments = {}

        entry = await get_tool_by_name(tool)
        if entry is None:
            return {"tool": tool, "status": "error", "message": f"Tool '{tool}' not found in catalog."}

        # Hidden tools (in _DISCOVERABLE_TOOLS) dispatch via our own registry.
        if tool in _DISCOVERABLE_TOOLS:
            try:
                return await call_tool(tool, arguments)
            except TypeError as exc:
                return {"tool": tool, "status": "error", "message": f"Invalid arguments: {exc}"}
            except Exception as exc:
                return {"tool": tool, "status": "error", "message": f"{type(exc).__name__}: {exc}"}

        # MCP-registered tools should be called directly via the MCP protocol.
        if tool in _MCP_TOOL_CATEGORIES:
            return {
                "tool": tool,
                "status": "mcp",
                "message": (
                    f"Tool '{tool}' is registered with FastMCP. "
                    f"Call it directly via the MCP tools/call protocol."
                ),
            }

        # Otherwise it's in the catalog (a stub) but has no implementation.
        return {
            "tool": tool,
            "status": "stub",
            "message": f"Tool '{tool}' is in the catalog but has no implementation via ToolCall.",
        }

    # ------------------------------------------------------------------
    # ToolSession tools (2 MCP-visible)
    # ------------------------------------------------------------------

    @mcp_discoverable(
        mcp,
        name="ToolSession.Generate",
        category="ToolSessions",
        description="Agent session tracking: generate, retrieve, and manage tool sessions keyed by agent/task pairs",
    )
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

    @mcp_discoverable(mcp, name="ToolSession", category="ToolSessions")
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

    @mcp_discoverable(
        mcp,
        name="Instructions",
        category="Instructions",
        description="Versioned instruction documents: create, retrieve, update, rollback, list versions, and search",
    )
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

    @mcp_discoverable(mcp, name="Instructions.Create", category="Instructions")
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

    @mcp_discoverable(mcp, name="Instructions.List", category="Instructions")
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
    # Agents tools (2 MCP-visible) — US-086
    # ------------------------------------------------------------------

    @mcp_discoverable(
        mcp,
        name="Agent.List",
        category="Agents",
        description="List available agent definitions from agents/ directory",
    )
    async def agent_list() -> list[dict]:
        """Return metadata for all agent definitions.

        Returns a list of dicts with: name, display_name, description,
        model, allowed_tools, kind, path, body_length.
        Body is omitted for brevity — use Agent.Load to get the full spec.
        """
        from npl_mcp.agents.catalog import list_agents
        return await list_agents()

    @mcp_discoverable(
        mcp,
        name="Agent.Load",
        category="Agents",
        description="Load full agent specification (frontmatter + body) by name",
    )
    async def agent_load(name: str) -> dict:
        """Load an agent spec by name.

        Returns the full agent specification including the markdown body.

        Args:
            name: Agent name to load (e.g. "npl-tasker-fast").

        Returns:
            Dict with: name, display_name, description, model,
            allowed_tools, kind, path, body, body_length.
            On failure: {"status": "error", "message": "..."}.
        """
        from npl_mcp.agents.catalog import get_agent
        result = await get_agent(name)
        if result is None:
            return {"status": "error", "message": f"Agent '{name}' not found"}
        return result

    # ------------------------------------------------------------------
    # Tasks tools (4 MCP-visible) — PRD-005 MVP
    # ------------------------------------------------------------------

    @mcp_discoverable(
        mcp,
        name="Tasks.Create",
        category="Tasks",
        description="Create a task row in npl_tasks (flat MVP — no queue)",
    )
    async def tasks_create(
        title: str,
        description: Optional[str] = None,
        status: str = "pending",
        priority: int = 1,
        assigned_to: Optional[str] = None,
        notes: Optional[str] = None,
    ) -> dict:
        """Create a new task.

        Args:
            title: Required non-empty title.
            description: Optional longer body.
            status: One of pending|in_progress|blocked|review|done (default pending).
            priority: Integer priority (0=low, 3=urgent). Default 1.
            assigned_to: Optional assignee identifier.
            notes: Optional initial notes.

        Returns the created task fields alongside ``status: "ok"``.
        """
        from npl_mcp.tasks import task_create
        return await task_create(
            title=title,
            description=description,
            status=status,
            priority=priority,
            assigned_to=assigned_to,
            notes=notes,
        )

    @mcp_discoverable(
        mcp,
        name="Tasks.Get",
        category="Tasks",
        description="Fetch a task by integer id",
    )
    async def tasks_get(task_id: int) -> dict:
        """Get a single task.

        Returns ``{"status": "ok", ...}`` or ``{"status": "not_found", "id": N}``.
        """
        from npl_mcp.tasks import task_get
        return await task_get(task_id)

    @mcp_discoverable(
        mcp,
        name="Tasks.List",
        category="Tasks",
        description="List tasks, optionally filtered by status and/or assignee",
    )
    async def tasks_list(
        status: Optional[str] = None,
        assigned_to: Optional[str] = None,
        limit: int = 100,
    ) -> dict:
        """List tasks ordered by created_at desc.

        Args:
            status: Filter to this status if provided.
            assigned_to: Filter to this assignee if provided.
            limit: 1..500 (default 100).
        """
        from npl_mcp.tasks import task_list
        return await task_list(status=status, assigned_to=assigned_to, limit=limit)

    @mcp_discoverable(
        mcp,
        name="Tasks.UpdateStatus",
        category="Tasks",
        description="Update a task's status; optionally append a note",
    )
    async def tasks_update_status(
        task_id: int,
        status: str,
        notes: Optional[str] = None,
    ) -> dict:
        """Change a task's status.

        Args:
            task_id: Integer id.
            status: New status.
            notes: Optional note — substring-deduped against existing notes.
        """
        from npl_mcp.tasks import task_update_status
        return await task_update_status(task_id=task_id, status=status, notes=notes)

    # ------------------------------------------------------------------
    # Task queue and enhanced task tools (10 MCP-visible)
    # ------------------------------------------------------------------

    @mcp_discoverable(
        mcp,
        name="TaskQueue.Create",
        category="Tasks",
        description="Create a task queue",
    )
    async def task_queue_create_tool(
        name: str,
        description: Optional[str] = None,
        session_id: Optional[str] = None,
        chat_room_id: Optional[int] = None,
    ) -> dict:
        """Create a named task queue, optionally linked to a session or chat room."""
        from npl_mcp.tasks.tasks import task_queue_create
        return await task_queue_create(
            name=name, description=description,
            session_id=session_id, chat_room_id=chat_room_id,
        )

    @mcp_discoverable(
        mcp,
        name="TaskQueue.Get",
        category="Tasks",
        description="Get a task queue by ID with task counts",
    )
    async def task_queue_get_tool(queue_id: int) -> dict:
        """Get a task queue and its task status counts."""
        from npl_mcp.tasks.tasks import task_queue_get
        return await task_queue_get(queue_id)

    @mcp_discoverable(
        mcp,
        name="TaskQueue.List",
        category="Tasks",
        description="List task queues, optionally filtered by status",
    )
    async def task_queue_list_tool(
        status: Optional[str] = None,
        limit: int = 50,
    ) -> dict:
        """List task queues."""
        from npl_mcp.tasks.tasks import task_queue_list
        return await task_queue_list(status=status, limit=limit)

    @mcp_discoverable(
        mcp,
        name="Tasks.CreateInQueue",
        category="Tasks",
        description="Create a task within a queue with enhanced fields",
    )
    async def tasks_create_in_queue_tool(
        queue_id: int,
        title: str,
        description: Optional[str] = None,
        status: str = "pending",
        priority: int = 1,
        assigned_to: Optional[str] = None,
        acceptance_criteria: Optional[str] = None,
        deadline: Optional[str] = None,
        complexity: Optional[int] = None,
        complexity_notes: Optional[str] = None,
    ) -> dict:
        """Create a task within a specific queue.

        Args:
            queue_id: Queue to add the task to.
            title: Task title.
            description: Optional long description.
            status: pending|in_progress|blocked|done|cancelled (default pending).
            priority: 1-5 (default 1).
            assigned_to: Persona slug.
            acceptance_criteria: Definition of done.
            deadline: ISO-8601 deadline.
            complexity: Complexity score (e.g. 1-13 Fibonacci).
            complexity_notes: Rationale for complexity.
        """
        from npl_mcp.tasks.tasks import task_create_in_queue
        return await task_create_in_queue(
            queue_id=queue_id, title=title,
            description=description, status=status,
            priority=priority, assigned_to=assigned_to,
            acceptance_criteria=acceptance_criteria,
            deadline=deadline, complexity=complexity,
            complexity_notes=complexity_notes,
        )

    @mcp_discoverable(
        mcp,
        name="Tasks.AssignComplexity",
        category="Tasks",
        description="Assign a complexity score to a task",
    )
    async def tasks_assign_complexity_tool(
        task_id: int,
        complexity: int,
        notes: Optional[str] = None,
    ) -> dict:
        """Assign or update the complexity score on a task."""
        from npl_mcp.tasks.tasks import task_assign_complexity
        return await task_assign_complexity(
            task_id=task_id, complexity=complexity, notes=notes,
        )

    @mcp_discoverable(
        mcp,
        name="Tasks.AddArtifact",
        category="Tasks",
        description="Link an artifact or git branch to a task",
    )
    async def tasks_add_artifact_tool(
        task_id: int,
        artifact_type: str,
        artifact_id: Optional[int] = None,
        git_branch: Optional[str] = None,
        description: Optional[str] = None,
        created_by: Optional[str] = None,
    ) -> dict:
        """Attach an artifact reference (or git branch) to a task."""
        from npl_mcp.tasks.tasks import task_add_artifact
        return await task_add_artifact(
            task_id=task_id, artifact_type=artifact_type,
            artifact_id=artifact_id, git_branch=git_branch,
            description=description, created_by=created_by,
        )

    @mcp_discoverable(
        mcp,
        name="Tasks.ListArtifacts",
        category="Tasks",
        description="List artifacts linked to a task",
    )
    async def tasks_list_artifacts_tool(task_id: int) -> dict:
        """List all artifact links for a task."""
        from npl_mcp.tasks.tasks import task_list_artifacts
        return await task_list_artifacts(task_id=task_id)

    @mcp_discoverable(
        mcp,
        name="Tasks.Feed",
        category="Tasks",
        description="Get activity feed for a task",
    )
    async def tasks_feed_tool(
        task_id: int,
        since: Optional[str] = None,
        limit: int = 50,
    ) -> dict:
        """Return the event/activity feed for a single task."""
        from npl_mcp.tasks.tasks import task_feed
        return await task_feed(task_id=task_id, since=since, limit=limit)

    @mcp_discoverable(
        mcp,
        name="TaskQueue.Feed",
        category="Tasks",
        description="Get activity feed for a task queue",
    )
    async def task_queue_feed_tool(
        queue_id: int,
        since: Optional[str] = None,
        limit: int = 100,
    ) -> dict:
        """Return the event/activity feed for a task queue."""
        from npl_mcp.tasks.tasks import queue_feed
        return await queue_feed(queue_id=queue_id, since=since, limit=limit)

    # ------------------------------------------------------------------
    # Artifacts tools (5 MCP-visible) — PRD-002 MVP
    # ------------------------------------------------------------------

    @mcp_discoverable(
        mcp,
        name="Artifact.Create",
        category="Artifacts",
        description="Create a new text artifact with its initial revision",
    )
    async def artifact_create_tool(
        title: str,
        content: str = "",
        kind: str = "markdown",
        description: Optional[str] = None,
        created_by: Optional[str] = None,
        notes: Optional[str] = None,
        binary_content_b64: Optional[str] = None,
        mime_type: Optional[str] = None,
    ) -> dict:
        """Create a versioned artifact.

        For text artifacts pass ``content``.  For binary artifacts (image,
        video, audio, pdf, binary) pass ``binary_content_b64`` (base64
        encoded bytes) and ``mime_type``.

        Args:
            title: Non-empty human-readable title.
            content: Initial body (revision 1) — for text kinds.
            kind: markdown|json|yaml|code|text|other|image|video|audio|pdf|binary.
            description: Optional long description.
            created_by: Optional persona slug.
            notes: Optional notes attached to revision 1.
            binary_content_b64: Base64-encoded binary content (for media kinds).
            mime_type: MIME type (e.g. image/png) — required when binary_content_b64 set.
        """
        import base64
        from npl_mcp.artifacts import artifact_create
        binary_content = None
        if binary_content_b64:
            binary_content = base64.b64decode(binary_content_b64)
        return await artifact_create(
            title=title, content=content, kind=kind,
            description=description, created_by=created_by, notes=notes,
            binary_content=binary_content, mime_type=mime_type,
        )

    @mcp_discoverable(
        mcp,
        name="Artifact.AddRevision",
        category="Artifacts",
        description="Append a new revision to an existing artifact",
    )
    async def artifact_add_revision_tool(
        artifact_id: int,
        content: str = "",
        notes: Optional[str] = None,
        created_by: Optional[str] = None,
        binary_content_b64: Optional[str] = None,
        mime_type: Optional[str] = None,
    ) -> dict:
        """Add a new revision (N+1) to an artifact.

        For binary kinds pass ``binary_content_b64`` + ``mime_type``.
        """
        import base64
        from npl_mcp.artifacts import artifact_add_revision
        binary_content = None
        if binary_content_b64:
            binary_content = base64.b64decode(binary_content_b64)
        return await artifact_add_revision(
            artifact_id=artifact_id, content=content,
            notes=notes, created_by=created_by,
            binary_content=binary_content, mime_type=mime_type,
        )

    @mcp_discoverable(
        mcp,
        name="Artifact.Get",
        category="Artifacts",
        description="Fetch an artifact + one of its revisions",
    )
    async def artifact_get_tool(
        artifact_id: int,
        revision: Optional[int] = None,
    ) -> dict:
        """Get an artifact with its latest (or specific) revision body."""
        from npl_mcp.artifacts import artifact_get
        return await artifact_get(artifact_id=artifact_id, revision=revision)

    @mcp_discoverable(
        mcp,
        name="Artifact.List",
        category="Artifacts",
        description="List artifacts (optionally filtered by kind)",
    )
    async def artifact_list_tool(
        kind: Optional[str] = None,
        limit: int = 100,
    ) -> dict:
        """List artifact head rows (no revision bodies)."""
        from npl_mcp.artifacts import artifact_list
        return await artifact_list(kind=kind, limit=limit)

    @mcp_discoverable(
        mcp,
        name="Artifact.ListRevisions",
        category="Artifacts",
        description="List all revisions for an artifact (summaries only)",
    )
    async def artifact_list_revisions_tool(artifact_id: int) -> dict:
        """List revision summaries for an artifact."""
        from npl_mcp.artifacts import artifact_list_revisions
        return await artifact_list_revisions(artifact_id=artifact_id)

    @mcp_discoverable(
        mcp,
        name="Artifact.GetBinary",
        category="Artifacts",
        description="Fetch raw binary content of an artifact revision as base64",
    )
    async def artifact_get_binary_tool(
        artifact_id: int,
        revision: Optional[int] = None,
    ) -> dict:
        """Get binary content as base64 + mime_type.

        Returns ``{status, mime_type, content_b64, size_bytes}``.
        Only works for binary-kind artifacts (image/video/audio/pdf/binary).
        """
        import base64
        from npl_mcp.artifacts import artifact_get_binary
        result = await artifact_get_binary(artifact_id=artifact_id, revision=revision)
        if result.get("status") != "ok":
            return result
        raw = result["binary_content"]
        return {
            "status": "ok",
            "mime_type": result["mime_type"],
            "content_b64": base64.b64encode(raw).decode("ascii"),
            "size_bytes": len(raw),
            "title": result.get("title"),
            "revision": result.get("revision"),
        }

    # ------------------------------------------------------------------
    # Generic Sessions tools (4 MCP-visible) — PRD-004 MVP
    # Distinct from ToolSession which is per-agent-task; these group
    # arbitrary work (chat rooms + artifacts + tasks) under a logical session.
    # ------------------------------------------------------------------

    @mcp_discoverable(
        mcp,
        name="Session.Create",
        category="Sessions",
        description="Create a generic work session (distinct from ToolSession)",
    )
    async def session_create_tool(
        title: Optional[str] = None,
        description: Optional[str] = None,
        status: str = "active",
        created_by: Optional[str] = None,
    ) -> dict:
        """Create a generic session.

        Args:
            title: Optional title.
            description: Optional long description.
            status: active|paused|completed|archived (default active).
            created_by: Optional creator identifier.
        """
        from npl_mcp.sessions import session_create
        return await session_create(
            title=title, description=description,
            status=status, created_by=created_by,
        )

    @mcp_discoverable(
        mcp,
        name="Session.Get",
        category="Sessions",
        description="Fetch a generic session by uuid",
    )
    async def session_get_tool(session_id: str) -> dict:
        """Fetch one generic session."""
        from npl_mcp.sessions import session_get
        return await session_get(session_id)

    @mcp_discoverable(
        mcp,
        name="Session.List",
        category="Sessions",
        description="List generic sessions, optionally filtered by status",
    )
    async def session_list_tool(
        status: Optional[str] = None,
        limit: int = 50,
    ) -> dict:
        """List generic sessions."""
        from npl_mcp.sessions import session_list
        return await session_list(status=status, limit=limit)

    @mcp_discoverable(
        mcp,
        name="Session.Update",
        category="Sessions",
        description="Update title/status/description on a generic session",
    )
    async def session_update_tool(
        session_id: str,
        title: Optional[str] = None,
        status: Optional[str] = None,
        description: Optional[str] = None,
    ) -> dict:
        """Partial update of a generic session."""
        from npl_mcp.sessions import session_update
        return await session_update(
            session_id=session_id, title=title,
            status=status, description=description,
        )

    # ------------------------------------------------------------------
    # Sessions enhanced tools (2 MCP-visible)
    # ------------------------------------------------------------------

    @mcp_discoverable(
        mcp,
        name="Session.Contents",
        category="Sessions",
        description="Get aggregated session contents (chat rooms, artifacts)",
    )
    async def session_contents_tool(session_id: str) -> dict:
        """Return session details with associated chat rooms and artifacts."""
        from npl_mcp.sessions.sessions import session_get_contents
        return await session_get_contents(session_id)

    @mcp_discoverable(
        mcp,
        name="Session.Archive",
        category="Sessions",
        description="Archive a generic session",
    )
    async def session_archive_tool(session_id: str) -> dict:
        """Set a session's status to archived."""
        from npl_mcp.sessions.sessions import session_archive
        return await session_archive(session_id)

    # ------------------------------------------------------------------
    # Agent pipes (2 MCP-visible)
    # ------------------------------------------------------------------

    @mcp_discoverable(
        mcp,
        name="AgentInputPipe",
        category="Pipes",
        description="Pull incoming messages addressed to this agent (by UUID, handle, or group)",
    )
    async def agent_input_pipe_tool(
        agent: str,
        since: Optional[str] = None,
        full: bool = False,
        with_sections: Optional[list[str]] = None,
    ) -> dict:
        """Pull messages addressed to this agent from the pipe.

        Returns a YAML dashboard of all entries matching the agent's
        session UUID, agent handle, or group memberships.

        Args:
            agent: Session UUID (short or full) of the requesting agent.
            since: ISO-8601 UTC timestamp — only entries updated after this.
            full: If True, ignore ``since`` and return all entries.
            with_sections: Optional list of message_name values to include.
        """
        from npl_mcp.pipes import agent_input_pipe
        return await agent_input_pipe(
            agent=agent,
            since=since,
            full=full,
            with_sections=with_sections,
        )

    @mcp_discoverable(
        mcp,
        name="AgentOutputPipe",
        category="Pipes",
        description="Push structured YAML data to target agents or groups",
    )
    async def agent_output_pipe_tool(
        agent: str,
        body: str,
    ) -> dict:
        """Push structured YAML data to target agents/groups.

        ``body`` is a YAML mapping of message sections.  Each section has
        a ``target`` block (agent, agent-handle, group, group-handle) and
        a ``data`` block with the payload.  Entries are upserted — calling
        again with the same message name and target replaces the previous.

        Args:
            agent: Session UUID (short or full) of the sending agent.
            body: YAML string with message sections.
        """
        from npl_mcp.pipes import agent_output_pipe
        return await agent_output_pipe(agent=agent, body=body)

    # ------------------------------------------------------------------
    # Chat tools (5 MCP-visible)
    # ------------------------------------------------------------------

    @mcp_discoverable(
        mcp,
        name="Chat.ListRooms",
        category="Chat",
        description="List chat rooms",
    )
    async def chat_list_rooms(limit: int = 50) -> dict:
        """List chat rooms ordered by most recent activity."""
        from npl_mcp.chat.chat import room_list
        return await room_list(limit=limit)

    @mcp_discoverable(
        mcp,
        name="Chat.CreateRoom",
        category="Chat",
        description="Create a new chat room",
    )
    async def chat_create_room(name: str, description: Optional[str] = None) -> dict:
        """Create a chat room."""
        from npl_mcp.chat.chat import room_create
        return await room_create(name=name, description=description)

    @mcp_discoverable(
        mcp,
        name="Chat.GetRoom",
        category="Chat",
        description="Get a chat room by ID",
    )
    async def chat_get_room(room_id: int) -> dict:
        """Get a chat room's details."""
        from npl_mcp.chat.chat import room_get
        return await room_get(room_id=room_id)

    @mcp_discoverable(
        mcp,
        name="Chat.ListMessages",
        category="Chat",
        description="List messages in a chat room",
    )
    async def chat_list_messages(
        room_id: int,
        limit: int = 50,
        before_id: Optional[int] = None,
    ) -> dict:
        """List messages in a room, newest first. Use ``before_id`` for pagination."""
        from npl_mcp.chat.chat import message_list
        return await message_list(room_id=room_id, limit=limit, before_id=before_id)

    @mcp_discoverable(
        mcp,
        name="Chat.SendMessage",
        category="Chat",
        description="Send a message to a chat room",
    )
    async def chat_send_message(
        room_id: int,
        content: str,
        author: Optional[str] = None,
    ) -> dict:
        """Post a message to a chat room."""
        from npl_mcp.chat.chat import message_create
        return await message_create(room_id=room_id, content=content, author=author)

    # ------------------------------------------------------------------
    # Chat enhanced tools (9 MCP-visible)
    # ------------------------------------------------------------------

    @mcp_discoverable(
        mcp,
        name="Chat.AddMember",
        category="Chat",
        description="Add a persona to a chat room",
    )
    async def chat_add_member(room_id: int, persona_slug: str) -> dict:
        """Add a persona member to a chat room."""
        from npl_mcp.chat.chat import room_add_member
        return await room_add_member(room_id=room_id, persona_slug=persona_slug)

    @mcp_discoverable(
        mcp,
        name="Chat.ListMembers",
        category="Chat",
        description="List members of a chat room",
    )
    async def chat_list_members(room_id: int) -> dict:
        """List all persona members of a chat room."""
        from npl_mcp.chat.chat import room_list_members
        return await room_list_members(room_id=room_id)

    @mcp_discoverable(
        mcp,
        name="Chat.CreateEvent",
        category="Chat",
        description="Create a chat event in a room",
    )
    async def chat_create_event(
        room_id: int,
        event_type: str,
        persona: str,
        data: Optional[dict] = None,
    ) -> dict:
        """Create a structured chat event (message, action, todo, etc.)."""
        from npl_mcp.chat.chat import event_create
        return await event_create(
            room_id=room_id, event_type=event_type,
            persona=persona, data=data,
        )

    @mcp_discoverable(
        mcp,
        name="Chat.ListEvents",
        category="Chat",
        description="List chat events in a room",
    )
    async def chat_list_events(
        room_id: int,
        since: Optional[str] = None,
        limit: int = 50,
    ) -> dict:
        """List chat events for a room, optionally filtered by time."""
        from npl_mcp.chat.chat import event_list
        return await event_list(room_id=room_id, since=since, limit=limit)

    @mcp_discoverable(
        mcp,
        name="Chat.React",
        category="Chat",
        description="Add an emoji reaction to a chat event",
    )
    async def chat_react(event_id: int, persona: str, emoji: str) -> dict:
        """React to a chat event with an emoji."""
        from npl_mcp.chat.chat import react_to_event
        return await react_to_event(event_id=event_id, persona=persona, emoji=emoji)

    @mcp_discoverable(
        mcp,
        name="Chat.CreateTodo",
        category="Chat",
        description="Create a todo item in a chat room",
    )
    async def chat_create_todo(
        room_id: int,
        persona: str,
        description: str,
        assigned_to: Optional[str] = None,
    ) -> dict:
        """Create a todo item as a chat event."""
        from npl_mcp.chat.chat import create_todo
        return await create_todo(
            room_id=room_id, persona=persona,
            description=description, assigned_to=assigned_to,
        )

    @mcp_discoverable(
        mcp,
        name="Chat.ShareArtifact",
        category="Chat",
        description="Share an artifact in a chat room",
    )
    async def chat_share_artifact(
        room_id: int,
        persona: str,
        artifact_id: int,
        revision: Optional[int] = None,
    ) -> dict:
        """Share an artifact (optionally at a specific revision) in a chat room."""
        from npl_mcp.chat.chat import share_artifact
        return await share_artifact(
            room_id=room_id, persona=persona,
            artifact_id=artifact_id, revision=revision,
        )

    @mcp_discoverable(
        mcp,
        name="Chat.Notifications",
        category="Chat",
        description="List notifications for a persona",
    )
    async def chat_notifications(persona: str, unread_only: bool = True) -> dict:
        """List chat notifications for a persona."""
        from npl_mcp.chat.chat import notification_list
        return await notification_list(persona=persona, unread_only=unread_only)

    @mcp_discoverable(
        mcp,
        name="Chat.ReadNotification",
        category="Chat",
        description="Mark a notification as read",
    )
    async def chat_read_notification(notification_id: int) -> dict:
        """Mark a single chat notification as read."""
        from npl_mcp.chat.chat import notification_mark_read
        return await notification_mark_read(notification_id=notification_id)

    # ------------------------------------------------------------------
    # Orchestration tools (4 MCP-visible)
    # ------------------------------------------------------------------

    @mcp_discoverable(
        mcp,
        name="Orchestration.Trigger",
        category="Orchestration",
        description="Trigger the agent orchestration pipeline for a feature",
    )
    async def orchestration_trigger_tool(
        feature_description: str,
        agent: str = "npl-tdd-coder",
    ) -> dict:
        """Queue an orchestration run for a feature description.

        Creates a task tagged with the orchestration pipeline and returns
        a run_id for tracking.

        Args:
            feature_description: Natural-language description of the feature.
            agent: Agent to assign (default npl-tdd-coder).
        """
        import shortuuid
        from npl_mcp.tasks.tasks import task_create
        run_id = shortuuid.uuid()[:12]
        result = await task_create(
            title=f"[Orchestration] {feature_description}",
            description=f"run_id={run_id} agent={agent}\n\n{feature_description}",
            status="pending",
        )
        return {
            "run_id": run_id,
            "status": "queued",
            "task_id": result.get("id"),
            "created_at": result.get("created_at"),
        }

    @mcp_discoverable(
        mcp,
        name="Orchestration.Patterns",
        category="Orchestration",
        description="List registered orchestration patterns",
    )
    async def orchestration_patterns_tool() -> dict:
        """List all registered orchestration patterns.

        Returns pattern names and their class descriptions.
        """
        from npl_mcp.orchestration import PATTERN_REGISTRY
        return {
            "status": "ok",
            "patterns": [
                {
                    "name": name,
                    "class": cls.__name__,
                    "doc": (cls.__doc__ or "").strip().split("\n")[0],
                }
                for name, cls in PATTERN_REGISTRY.items()
            ],
            "count": len(PATTERN_REGISTRY),
        }

    @mcp_discoverable(
        mcp,
        name="Orchestration.Execute",
        category="Orchestration",
        description="Execute an orchestration pattern (e.g. pipeline) with initial context",
    )
    async def orchestration_execute_tool(
        pattern: str = "pipeline",
        feature_description: str = "",
        context: Optional[dict] = None,
    ) -> dict:
        """Execute a registered orchestration pattern.

        For the ``pipeline`` pattern, creates the standard TDD pipeline
        and runs it with the provided context.

        Args:
            pattern: Pattern name from the registry (default: "pipeline").
            feature_description: Feature description for TDD pipeline.
            context: Optional initial context dict passed to execute().

        Returns:
            Execution result including status and per-stage results.
        """
        from npl_mcp.orchestration import PATTERN_REGISTRY, create_tdd_pipeline

        if pattern not in PATTERN_REGISTRY:
            return {
                "status": "error",
                "message": f"Pattern '{pattern}' not found. Available: {list(PATTERN_REGISTRY.keys())}",
            }

        ctx = dict(context or {})
        if feature_description:
            ctx["feature_description"] = feature_description

        if pattern == "pipeline" and feature_description:
            instance = create_tdd_pipeline(feature_description)
        else:
            cls = PATTERN_REGISTRY[pattern]
            instance = cls()

        result = await instance.execute(ctx)
        result["run_id"] = instance.run_id
        return result

    @mcp_discoverable(
        mcp,
        name="Orchestration.Status",
        category="Orchestration",
        description="Get the status of an orchestration pattern instance",
    )
    async def orchestration_status_tool(
        pattern: str = "pipeline",
    ) -> dict:
        """Get status information for a pattern type.

        Note: In the MVP this returns pattern metadata rather than a
        specific run status (run tracking requires persistence).

        Args:
            pattern: Pattern name to query.
        """
        from npl_mcp.orchestration import PATTERN_REGISTRY

        if pattern not in PATTERN_REGISTRY:
            return {
                "status": "error",
                "message": f"Pattern '{pattern}' not found.",
            }
        cls = PATTERN_REGISTRY[pattern]
        return {
            "status": "ok",
            "pattern": pattern,
            "class": cls.__name__,
            "doc": (cls.__doc__ or "").strip(),
        }

    # ------------------------------------------------------------------
    # Session.Activity tool (1 MCP-visible)
    # ------------------------------------------------------------------

    @mcp_discoverable(
        mcp,
        name="Session.Activity",
        category="Sessions",
        description="Get the activity feed for a session (sub-sessions, errors)",
    )
    async def session_activity_tool(
        session_uuid: str,
        limit: int = 50,
    ) -> dict:
        """Return recent activity for a tool session.

        Includes child tool sessions and errors, merged and sorted by time.

        Args:
            session_uuid: Session UUID (short or full).
            limit: Max items to return (default 50).
        """
        from npl_mcp.tool_sessions.tool_sessions import session_activity
        return await session_activity(session_uuid, limit=limit)

    # ------------------------------------------------------------------
    # Skills tools (1 MCP-visible)
    # ------------------------------------------------------------------

    @mcp_discoverable(
        mcp,
        name="Skill.Validate",
        category="Skills",
        description="Validate a skill file's structure and content against NPL skill conventions",
    )
    async def skill_validate(content: str, filename: str = "") -> dict:
        """Validate a skill file.

        Checks frontmatter (YAML parse, required fields, field lengths),
        name/filename consistency, unknown fields, and body structure
        (headings, minimum length).

        Args:
            content: Full text of the skill markdown file (frontmatter + body).
            filename: Optional filename for filename/name-field cross-check.
        """
        from npl_mcp.skills.validator import validate_skill
        return await validate_skill(content, filename or None)

    @mcp_discoverable(
        mcp,
        name="Skill.Evaluate",
        category="Skills",
        description="Score a skill file across quality dimensions (description, examples, structure, completeness)",
    )
    async def skill_evaluate(content: str, filename: str = "") -> dict:
        """Evaluate a skill file's quality across heuristic dimensions.

        Returns a per-dimension score (0.0–1.0) plus an overall score and
        actionable suggestions.  Embeds the full US-119 validation result.

        Dimensions scored:
          - description: length and clarity of the frontmatter description field
          - examples:    number of fenced code blocks in the body
          - structure:   heading depth, sub-sections, and clear opener
          - completeness: ratio of required + recommended frontmatter fields set

        Args:
            content: Full text of the skill markdown file (frontmatter + body).
            filename: Optional filename for name/filename cross-check.
        """
        from npl_mcp.skills.validator import evaluate_skill
        return await evaluate_skill(content, filename or None)

    # ------------------------------------------------------------------
    # Review tools (5 MCP-visible)
    # ------------------------------------------------------------------

    @mcp_discoverable(
        mcp,
        name="Review.Create",
        category="Reviews",
        description="Start a review session for an artifact revision",
    )
    async def review_create_tool(
        artifact_id: int,
        revision_id: int,
        reviewer_persona: str,
    ) -> dict:
        """Create a new review for an artifact revision."""
        from npl_mcp.artifacts.reviews import review_create
        return await review_create(
            artifact_id=artifact_id, revision_id=revision_id,
            reviewer_persona=reviewer_persona,
        )

    @mcp_discoverable(
        mcp,
        name="Review.AddComment",
        category="Reviews",
        description="Add an inline comment to a review",
    )
    async def review_add_comment_tool(
        review_id: int,
        location: str,
        comment: str,
        persona: str,
    ) -> dict:
        """Add an inline comment to a review at a location (e.g. 'line:58')."""
        from npl_mcp.artifacts.reviews import review_add_comment
        return await review_add_comment(
            review_id=review_id, location=location,
            comment=comment, persona=persona,
        )

    @mcp_discoverable(
        mcp,
        name="Review.AddOverlay",
        category="Reviews",
        description="Add an image overlay annotation to a review",
    )
    async def review_add_overlay_tool(
        review_id: int,
        x: int,
        y: int,
        comment: str,
        persona: str,
    ) -> dict:
        """Add a coordinate-based overlay annotation to a review."""
        from npl_mcp.artifacts.reviews import review_add_overlay
        return await review_add_overlay(
            review_id=review_id, x=x, y=y,
            comment=comment, persona=persona,
        )

    @mcp_discoverable(
        mcp,
        name="Review.Get",
        category="Reviews",
        description="Fetch a review with optional inline comments",
    )
    async def review_get_tool(
        review_id: int,
        include_comments: bool = True,
    ) -> dict:
        """Get a review by ID, optionally including all inline comments."""
        from npl_mcp.artifacts.reviews import review_get
        return await review_get(review_id=review_id, include_comments=include_comments)

    @mcp_discoverable(
        mcp,
        name="Review.Complete",
        category="Reviews",
        description="Mark a review as completed",
    )
    async def review_complete_tool(
        review_id: int,
        overall_comment: Optional[str] = None,
    ) -> dict:
        """Complete a review with an optional overall comment."""
        from npl_mcp.artifacts.reviews import review_complete
        return await review_complete(review_id=review_id, overall_comment=overall_comment)

    # ------------------------------------------------------------------
    # Executor tools — Taskers (6 MCP-visible)
    # ------------------------------------------------------------------

    @mcp_discoverable(
        mcp,
        name="Tasker.Spawn",
        category="Executors",
        description="Spawn an ephemeral tasker for a sub-task",
    )
    async def tasker_spawn_tool(
        task: str,
        chat_room_id: int,
        parent_agent_id: str = "primary",
        patterns: Optional[list[str]] = None,
        session_id: Optional[str] = None,
        timeout_minutes: int = 15,
        nag_minutes: int = 5,
    ) -> dict:
        """Spawn an ephemeral tasker to handle a sub-task.

        Args:
            task: Description of the work to perform.
            chat_room_id: Chat room for tasker communication.
            parent_agent_id: ID of the spawning agent.
            patterns: Optional fabric patterns to apply.
            session_id: Optional session to associate with.
            timeout_minutes: Auto-terminate after this many idle minutes.
            nag_minutes: Send nag after this many idle minutes.
        """
        from npl_mcp.executors.manager import spawn_tasker
        return await spawn_tasker(
            task=task, chat_room_id=chat_room_id,
            parent_agent_id=parent_agent_id, patterns=patterns,
            session_id=session_id, timeout_minutes=timeout_minutes,
            nag_minutes=nag_minutes,
        )

    @mcp_discoverable(
        mcp,
        name="Tasker.Get",
        category="Executors",
        description="Get a tasker's current state",
    )
    async def tasker_get_tool(tasker_id: str) -> dict:
        """Fetch a tasker by ID."""
        from npl_mcp.executors.manager import get_tasker
        result = await get_tasker(tasker_id)
        if result is None:
            return {"status": "not_found", "tasker_id": tasker_id}
        return result

    @mcp_discoverable(
        mcp,
        name="Tasker.List",
        category="Executors",
        description="List taskers with optional status/session filters",
    )
    async def tasker_list_tool(
        status: Optional[str] = None,
        session_id: Optional[str] = None,
    ) -> dict:
        """List all taskers, optionally filtered by status or session."""
        from npl_mcp.executors.manager import list_taskers
        items = await list_taskers(status=status, session_id=session_id)
        return {"taskers": items, "count": len(items)}

    @mcp_discoverable(
        mcp,
        name="Tasker.Touch",
        category="Executors",
        description="Update a tasker's last activity timestamp",
    )
    async def tasker_touch_tool(tasker_id: str) -> dict:
        """Touch a tasker to reset its idle timer."""
        from npl_mcp.executors.manager import touch_tasker
        await touch_tasker(tasker_id)
        return {"status": "ok", "tasker_id": tasker_id}

    @mcp_discoverable(
        mcp,
        name="Tasker.Dismiss",
        category="Executors",
        description="Dismiss/terminate a tasker",
    )
    async def tasker_dismiss_tool(
        tasker_id: str,
        reason: Optional[str] = None,
    ) -> dict:
        """Explicitly dismiss a tasker."""
        from npl_mcp.executors.manager import dismiss_tasker
        return await dismiss_tasker(tasker_id=tasker_id, reason=reason)

    @mcp_discoverable(
        mcp,
        name="Tasker.KeepAlive",
        category="Executors",
        description="Respond to a nag by keeping a tasker alive",
    )
    async def tasker_keep_alive_tool(tasker_id: str) -> dict:
        """Keep a tasker alive in response to a nag."""
        from npl_mcp.executors.manager import keep_alive
        return await keep_alive(tasker_id)

    # ------------------------------------------------------------------
    # Executor tools — Fabric (3 MCP-visible)
    # ------------------------------------------------------------------

    @mcp_discoverable(
        mcp,
        name="Fabric.Apply",
        category="Executors",
        description="Apply a fabric pattern to content",
    )
    async def fabric_apply_tool(
        content: str,
        pattern: str,
        model: Optional[str] = None,
        timeout: int = 300,
    ) -> dict:
        """Apply a single fabric pattern to content."""
        from npl_mcp.executors.fabric import apply_fabric_pattern
        return await apply_fabric_pattern(
            content=content, pattern=pattern,
            model=model, timeout=timeout,
        )

    @mcp_discoverable(
        mcp,
        name="Fabric.Analyze",
        category="Executors",
        description="Apply multiple fabric patterns to content",
    )
    async def fabric_analyze_tool(
        content: str,
        patterns: list[str],
        combine_results: bool = True,
    ) -> dict:
        """Apply multiple fabric patterns and optionally combine results."""
        from npl_mcp.executors.fabric import analyze_with_patterns
        return await analyze_with_patterns(
            content=content, patterns=patterns,
            combine_results=combine_results,
        )

    @mcp_discoverable(
        mcp,
        name="Fabric.ListPatterns",
        category="Executors",
        description="List available fabric patterns",
    )
    async def fabric_list_patterns_tool() -> dict:
        """List available fabric CLI patterns."""
        from npl_mcp.executors.fabric import list_patterns
        return await list_patterns()

    # ------------------------------------------------------------------
    # Browser enhanced tools (10 MCP-visible)
    # ------------------------------------------------------------------

    @mcp_discoverable(
        mcp,
        name="Browser.Capture",
        category="Browser",
        description="Capture a screenshot of a web page",
    )
    async def browser_capture_tool(
        url: str,
        viewport: str = "desktop",
        theme: str = "light",
        full_page: bool = False,
        session_key: Optional[str] = None,
    ) -> dict:
        """Capture a screenshot and return base64-encoded PNG.

        Args:
            url: URL to capture.
            viewport: desktop|mobile|tablet|4k or WIDTHxHEIGHT.
            theme: light or dark.
            full_page: Capture entire scrollable page.
            session_key: Optional key for browser session persistence.
        """
        import base64
        from npl_mcp.browser.capture import capture_screenshot
        result = await capture_screenshot(
            url=url, viewport=viewport, theme=theme,
            full_page=full_page, session_key=session_key,
        )
        return {
            "status": "ok",
            "image_b64": base64.b64encode(result.image_bytes).decode("ascii"),
            "width": result.width,
            "height": result.height,
            "url": result.url,
            "viewport_preset": result.viewport_preset,
            "theme": result.theme,
            "captured_at": result.captured_at,
        }

    @mcp_discoverable(
        mcp,
        name="Browser.Interact.Navigate",
        category="Browser",
        description="Navigate a browser session to a URL",
    )
    async def browser_interact_navigate_tool(session_id: str, url: str) -> dict:
        """Navigate an interactive browser session to a URL."""
        from npl_mcp.browser.interact import get_or_create_session
        session = await get_or_create_session(session_id)
        result = await session.navigate(url)
        return {"success": result.success, "action": result.action, "message": result.message}

    @mcp_discoverable(
        mcp,
        name="Browser.Interact.Click",
        category="Browser",
        description="Click an element in a browser session",
    )
    async def browser_interact_click_tool(session_id: str, selector: str) -> dict:
        """Click a CSS-selected element in an interactive browser session."""
        from npl_mcp.browser.interact import get_or_create_session
        session = await get_or_create_session(session_id)
        result = await session.click(selector)
        return {"success": result.success, "action": result.action, "message": result.message}

    @mcp_discoverable(
        mcp,
        name="Browser.Interact.Fill",
        category="Browser",
        description="Fill a form field in a browser session",
    )
    async def browser_interact_fill_tool(session_id: str, selector: str, value: str) -> dict:
        """Fill a form field in an interactive browser session."""
        from npl_mcp.browser.interact import get_or_create_session
        session = await get_or_create_session(session_id)
        result = await session.fill(selector, value)
        return {"success": result.success, "action": result.action, "message": result.message}

    @mcp_discoverable(
        mcp,
        name="Browser.Interact.GetState",
        category="Browser",
        description="Get current page state of a browser session",
    )
    async def browser_interact_get_state_tool(session_id: str) -> dict:
        """Get the current URL, title, and page state of a browser session."""
        from npl_mcp.browser.interact import get_or_create_session
        session = await get_or_create_session(session_id)
        state = await session.get_page_state()
        return {
            "url": state.url,
            "title": state.title,
            "viewport": state.viewport,
            "has_focus": state.has_focus,
            "scroll_position": state.scroll_position,
        }

    @mcp_discoverable(
        mcp,
        name="Browser.ListSessions",
        category="Browser",
        description="List active browser session IDs",
    )
    async def browser_list_sessions_tool() -> dict:
        """List all active interactive browser sessions."""
        from npl_mcp.browser.interact import list_sessions
        ids = await list_sessions()
        return {"sessions": ids, "count": len(ids)}

    @mcp_discoverable(
        mcp,
        name="Browser.CloseSession",
        category="Browser",
        description="Close an interactive browser session",
    )
    async def browser_close_session_tool(session_id: str) -> dict:
        """Close and remove an interactive browser session."""
        from npl_mcp.browser.interact import close_session
        await close_session(session_id)
        return {"status": "ok", "session_id": session_id}

    @mcp_discoverable(
        mcp,
        name="Browser.Diff",
        category="Browser",
        description="Compare two screenshots and return diff statistics",
    )
    async def browser_diff_tool(
        baseline_bytes: str,
        comparison_bytes: str,
        threshold: float = 0.1,
    ) -> dict:
        """Compare two base64-encoded PNG screenshots.

        Args:
            baseline_bytes: Base64-encoded baseline PNG.
            comparison_bytes: Base64-encoded comparison PNG.
            threshold: Color sensitivity 0.0-1.0 (lower = more sensitive).
        """
        import base64
        from npl_mcp.browser.diff import compare_screenshots
        baseline = base64.b64decode(baseline_bytes)
        comparison = base64.b64decode(comparison_bytes)
        result = compare_screenshots(
            baseline_bytes=baseline,
            comparison_bytes=comparison,
            threshold=threshold,
        )
        diff_b64 = base64.b64encode(result.diff_image).decode("ascii") if result.diff_image else None
        return {
            "status": result.status.value if hasattr(result.status, 'value') else str(result.status),
            "diff_percentage": result.diff_percentage,
            "diff_pixels": result.diff_pixels,
            "total_pixels": result.total_pixels,
            "diff_image_b64": diff_b64,
            "baseline_dimensions": result.baseline_dimensions,
            "comparison_dimensions": result.comparison_dimensions,
        }

    @mcp_discoverable(
        mcp,
        name="Browser.Checkpoint",
        category="Browser",
        description="Capture a visual checkpoint of multiple URLs",
    )
    async def browser_checkpoint_tool(
        name: str,
        urls: list[str],
        base_url: Optional[str] = None,
        viewports: Optional[list[str]] = None,
        themes: Optional[list[str]] = None,
    ) -> dict:
        """Capture a checkpoint with screenshots across viewports and themes.

        Args:
            name: Human-readable checkpoint name.
            urls: List of URLs to capture (relative paths if base_url set).
            base_url: Base URL for relative paths.
            viewports: List of viewport names (default: desktop, mobile).
            themes: List of theme names (default: light, dark).
        """
        from npl_mcp.browser.checkpoint import capture_checkpoint
        url_configs = [{"name": u.split("/")[-1] or "root", "url": u} for u in urls]
        result = await capture_checkpoint(
            name=name, urls=url_configs,
            base_url=base_url or "",
            viewports=viewports, themes=themes,
        )
        return {
            "status": "ok",
            "slug": result.slug,
            "name": result.name,
            "total_screenshots": result.total_screenshots,
            "timestamp": result.timestamp,
        }

    @mcp_discoverable(
        mcp,
        name="Browser.ListCheckpoints",
        category="Browser",
        description="List all visual checkpoints",
    )
    async def browser_list_checkpoints_tool() -> dict:
        """List all captured visual checkpoints."""
        from npl_mcp.browser.checkpoint import list_checkpoints
        items = await list_checkpoints()
        return {"checkpoints": items, "count": len(items)}

    @mcp_discoverable(
        mcp,
        name="Browser.CompareCheckpoints",
        category="Browser",
        description="Compare two visual checkpoints for regressions",
    )
    async def browser_compare_checkpoints_tool(
        baseline_slug: str,
        comparison_slug: str,
        threshold: float = 0.1,
    ) -> dict:
        """Compare two checkpoints and return diff summary.

        Args:
            baseline_slug: Slug of the baseline checkpoint.
            comparison_slug: Slug of the comparison checkpoint.
            threshold: Diff sensitivity 0.0-1.0 (lower = more sensitive).
        """
        from npl_mcp.browser.checkpoint import compare_checkpoints
        result = await compare_checkpoints(
            baseline_slug=baseline_slug,
            comparison_slug=comparison_slug,
            threshold=threshold,
        )
        return {
            "status": "ok",
            "comparison_id": result.comparison_id,
            "baseline_checkpoint": result.baseline_checkpoint,
            "comparison_checkpoint": result.comparison_checkpoint,
            "summary": result.summary,
            "total_comparisons": len(result.details),
        }

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

    # Mount read-only REST API router
    from npl_mcp.api.router import router as api_router
    api.include_router(api_router)

    if DIST_DIR.exists() and (DIST_DIR / "index.html").exists():
        try:
            api.mount("/_next", StaticFiles(directory=str(DIST_DIR / "_next")), name="next-static")
            api.add_middleware(FrontendFallbackMiddleware, dist_dir=DIST_DIR)
        except Exception:
            serve_fallback(api)
    else:
        serve_fallback(api)

    return api


class FrontendFallbackMiddleware:
    """Pure-ASGI middleware that serves static files / index.html on 404 GETs.

    Implemented as a pure ASGI middleware (not ``BaseHTTPMiddleware``) because
    ``BaseHTTPMiddleware`` buffers response bodies, which breaks SSE/streaming
    endpoints. See https://github.com/encode/starlette/issues/1012.
    """

    def __init__(self, app, dist_dir: Path) -> None:
        self.app = app
        self.dist_dir = dist_dir

    async def __call__(self, scope, receive, send) -> None:
        # Only intercept HTTP GETs; pass everything else through untouched.
        if scope.get("type") != "http" or scope.get("method") != "GET":
            await self.app(scope, receive, send)
            return

        # We need to buffer the response.start so we can decide whether to
        # pass it through or replace the response with a file.
        start_message: Optional[dict] = None
        replaced = False

        async def send_wrapper(message: dict) -> None:
            nonlocal start_message, replaced

            if replaced:
                # A replacement response has already taken over; swallow
                # any remaining messages from the original app.
                return

            mtype = message.get("type")

            if mtype == "http.response.start":
                if message.get("status") == 404:
                    # Hold this — we might override it once we see the body.
                    start_message = message
                    return
                await send(message)
                return

            if mtype == "http.response.body" and start_message is not None:
                # Original response was a 404. Decide whether to substitute.
                path = scope.get("path", "").lstrip("/").rstrip("/")
                file_path = self.dist_dir / path if path else None
                if file_path and file_path.is_file():
                    await FileResponse(file_path)(scope, receive, send)
                    replaced = True
                    return
                # Next.js static export: try {path}.html for SSG routes
                if path:
                    html_path = self.dist_dir / f"{path}.html"
                    if html_path.is_file():
                        await FileResponse(html_path)(scope, receive, send)
                        replaced = True
                        return
                index_path = self.dist_dir / "index.html"
                if index_path.exists():
                    await FileResponse(index_path)(scope, receive, send)
                    replaced = True
                    return
                # No file available — flush the original 404 through.
                await send(start_message)
                start_message = None
                await send(message)
                return

            await send(message)

        await self.app(scope, receive, send_wrapper)


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
