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
    from pathlib import Path
    from typing import Optional

    mcp = FastMCP("npl-mcp")

    @mcp.tool(name="hello-world")
    async def hello_world() -> str:
        """Return a greeting message."""
        return "hello"

    @mcp.tool()
    async def echo(text: str) -> str:
        """Echo back the provided text."""
        return f"Echo: {text}"

    @mcp.tool()
    async def to_markdown(
        source: str,
        no_cache: bool = False,
        timeout: int = 30
    ) -> str:
        """Convert URL, file, or image to markdown with caching.

        Args:
            source: URL, file path, or image to convert
            no_cache: Disable caching (force fresh conversion)
            timeout: Request timeout in seconds for URLs

        Returns:
            Formatted markdown with metadata header

        Examples:
            await to_markdown("https://docs.python.org/3/library/pathlib.html")
            await to_markdown("report.pdf")
            await to_markdown("diagram.png")  # Uses vision API
        """
        from npl_mcp.markdown.converter import MarkdownConverter
        from npl_mcp.markdown.cache import MarkdownCache

        cache = MarkdownCache()
        converter = MarkdownConverter(cache)

        return await converter.convert(
            source,
            force_refresh=no_cache,
            timeout=timeout
        )

    @mcp.tool()
    async def view_markdown(
        source: str,
        filter: Optional[str] = None,
        collapsed_depth: Optional[int] = None,
        filtered_only: bool = False
    ) -> str:
        """View markdown with optional filtering and collapsing.

        Args:
            source: Markdown file path or markdown content string
            filter: Optional filter selector (e.g., "h2", "Overview > API", "css:#main")
            collapsed_depth: Collapse headings below this depth (1-6)
            filtered_only: Show only filtered sections (no collapsed headings)

        Returns:
            Filtered/collapsed markdown content

        Examples:
            # Filter to specific section
            await view_markdown("doc.md", filter="API Reference")

            # Collapse deep sections
            await view_markdown("doc.md", collapsed_depth=2)

            # Filter and show only matching sections
            await view_markdown("doc.md", filter="Installation", filtered_only=True)

            # CSS selector (Phase 2)
            await view_markdown("doc.md", filter="css:article.main")
        """
        from npl_mcp.markdown.viewer import MarkdownViewer

        # Determine if source is a file path or content
        if Path(source).exists():
            content = Path(source).read_text()
        else:
            # Assume it's markdown content directly
            content = source

        viewer = MarkdownViewer()
        return viewer.view(
            content,
            filter=filter,
            collapsed_depth=collapsed_depth,
            filtered_only=filtered_only
        )

    # =========================================================================
    # Project Management Tools (PRD-017)
    # =========================================================================

    @mcp.tool()
    async def get_story(story_id: str) -> str:
        """Load a user story by ID from project-management/user-stories/.

        Args:
            story_id: User story ID (e.g., "US-001", "001", or "1")

        Returns:
            JSON-formatted string containing:
            - id: Story ID (normalized to US-XXX format)
            - title: Story title
            - persona: Persona ID
            - persona_name: Persona display name
            - priority: critical/high/medium/low
            - status: draft/in-progress/documented/implemented/tested
            - prd_group: PRD group name
            - prds: List of linked PRD IDs
            - related_stories: List of related story IDs
            - related_personas: List of related persona IDs
            - content: Full markdown content
            - acceptance_criteria: Parsed acceptance criteria with completion status
        """
        from npl_mcp.pm_tools import get_story as pm_get_story
        return await pm_get_story(story_id)

    @mcp.tool()
    async def list_stories(
        status: Optional[str] = None,
        priority: Optional[str] = None,
        persona: Optional[str] = None,
        prd_group: Optional[str] = None,
        prd: Optional[str] = None,
        limit: int = 50,
        offset: int = 0
    ) -> str:
        """List and filter user stories.

        Args:
            status: Filter by status (draft, in-progress, documented, implemented, tested)
            priority: Filter by priority (critical, high, medium, low)
            persona: Filter by persona ID (e.g., "P-001")
            prd_group: Filter by PRD group (e.g., "mcp_tools", "npl_load")
            prd: Filter by linked PRD (e.g., "PRD-005")
            limit: Maximum stories to return (default 50)
            offset: Number of stories to skip (default 0)

        Returns:
            JSON-formatted string containing:
            - total_count: Total matching stories
            - returned_count: Stories in this response
            - offset: Current offset
            - stories: List of story summaries (sorted by priority)
        """
        from npl_mcp.pm_tools import list_stories as pm_list_stories
        return await pm_list_stories(
            status=status,
            priority=priority,
            persona=persona,
            prd_group=prd_group,
            prd=prd,
            limit=limit,
            offset=offset
        )

    @mcp.tool()
    async def update_story_metadata(
        story_id: str,
        key: str,
        value: str
    ) -> str:
        """Update user story metadata in index.yaml.

        Args:
            story_id: User story ID (e.g., "US-001")
            key: Metadata field (status, priority, prds, related_stories, related_personas)
            value: New value (string for scalar fields, comma-separated for arrays)

        Returns:
            JSON-formatted string containing:
            - success: Boolean indicating success
            - story_id: Updated story ID
            - updated_fields: List of fields that were updated
            - previous_values: Previous values for updated fields
            - current_entry: Current story entry after update
        """
        from npl_mcp.pm_tools import update_story_metadata as pm_update
        return await pm_update(story_id, key, value)

    @mcp.tool()
    async def get_prd(prd_id: str) -> str:
        """Load a PRD by ID from project-management/PRDs/.

        Args:
            prd_id: PRD ID (e.g., "PRD-017", "017", or "17")

        Returns:
            JSON-formatted string containing:
            - id: PRD ID (normalized)
            - title: PRD title
            - version: PRD version
            - status: PRD status
            - content: Full markdown content
            - supporting_directory: Path to supporting directory (if exists)
            - has_functional_requirements: Boolean
            - has_acceptance_tests: Boolean
            - functional_requirements_count: Number of FRs
            - acceptance_tests_count: Number of ATs
            - user_stories: List of referenced user story IDs
        """
        from npl_mcp.pm_tools import get_prd as pm_get_prd
        return await pm_get_prd(prd_id)

    @mcp.tool()
    async def get_prd_functional_requirement(
        prd_id: str,
        fr_id: str = "*"
    ) -> str:
        """Access PRD functional requirements.

        Args:
            prd_id: PRD ID (e.g., "PRD-017")
            fr_id: FR ID (e.g., "FR-001") or "*" to list all

        Returns:
            For specific FR: JSON with fr_id, title, content, status, priority
            For "*": JSON with total_count and functional_requirements list
        """
        from npl_mcp.pm_tools import get_prd_functional_requirement as pm_get_fr
        return await pm_get_fr(prd_id, fr_id)

    @mcp.tool()
    async def get_prd_acceptance_test(
        prd_id: str,
        at_id: str = "*",
        fr_id: Optional[str] = None
    ) -> str:
        """Access PRD acceptance tests.

        Args:
            prd_id: PRD ID (e.g., "PRD-017")
            at_id: AT ID (e.g., "AT-001") or "*" to list all
            fr_id: Optional FR ID to filter ATs by functional requirement

        Returns:
            For specific AT: JSON with at_id, title, content, preconditions, steps, expected_results
            For "*": JSON with total_count, implemented_count, coverage_percentage, acceptance_tests list
        """
        from npl_mcp.pm_tools import get_prd_acceptance_test as pm_get_at
        return await pm_get_at(prd_id, at_id, fr_id)

    @mcp.tool()
    async def get_persona(persona_id: str) -> str:
        """Load a persona by ID from project-management/personas/.

        Args:
            persona_id: Persona ID (e.g., "P-001" for core persona, "A-001" for agent)

        Returns:
            JSON-formatted string containing:
            - id: Persona ID
            - name: Persona name
            - category: Category (Core, Infrastructure, etc.)
            - tags: List of tags
            - related_stories: List of related story IDs
            - content: Full markdown content
            - demographics: Extracted demographic key-value pairs
            - goals: List of persona goals
            - pain_points: List of pain points
            - behaviors: List of behaviors
        """
        from npl_mcp.pm_tools import get_persona as pm_get_persona
        return await pm_get_persona(persona_id)

    @mcp.tool()
    async def list_personas(
        tags: Optional[str] = None,
        category: Optional[str] = None
    ) -> str:
        """List and filter personas.

        Args:
            tags: Comma-separated tags to filter by (OR logic)
            category: Category filter (e.g., "Core", "Infrastructure")

        Returns:
            JSON-formatted string containing:
            - total_count: Total matching personas
            - core_personas: Count of P-XXX personas
            - core_agents: Count of A-001 to A-016 agents
            - additional_agents: Count of A-017+ agents
            - personas: List of persona summaries
        """
        from npl_mcp.pm_tools import list_personas as pm_list_personas
        return await pm_list_personas(tags=tags, category=category)

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