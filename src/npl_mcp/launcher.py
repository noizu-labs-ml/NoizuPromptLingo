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

    @mcp.tool()
    async def get_story(story_id: str) -> str:
        """Load a user story by ID from project-management/user-stories/.

        Args:
            story_id: User story ID (e.g., "US-001")

        Returns:
            Story content from matching file

        Implementation Note:
            This is a stub that directs to the local file structure.
            In a future phase, this will read from:
            ./project-management/user-stories/{story_id}-*.md or .yaml
        """
        import glob

        stories_dir = Path("./project-management/user-stories")
        if not stories_dir.exists():
            return f"📋 Load user story by ID\n\nTo load story '{story_id}', read from:\n./project-management/user-stories/{story_id}-*.md\n\nDirectory does not exist yet."

        # Search for matching story file
        pattern = str(stories_dir / f"{story_id}-*.md") + " " + str(stories_dir / f"{story_id}-*.yaml")
        matches = glob.glob(str(stories_dir / f"{story_id}-*.*"))

        if matches:
            return f"📋 Found story file: {matches[0]}\n\nRead from this path to load the complete user story."

        return f"📋 Load user story by ID\n\nUser story '{story_id}' not found in ./project-management/user-stories/\n\nTo create it, add a file: {story_id}-{story_id.lower()}.yaml"

    @mcp.tool()
    async def edit_story(story_id: str, field: str, value: str) -> str:
        """Edit a user story field by ID.

        Args:
            story_id: User story ID (e.g., "US-001")
            field: Field to update (e.g., "title", "description", "acceptance_criteria")
            value: New value for the field

        Returns:
            Confirmation message

        Implementation Note:
            This is a stub that directs to the local file structure.
            To edit story '{story_id}', modify the corresponding file:
            ./project-management/user-stories/{story_id}-*.yaml
        """
        stories_dir = Path("./project-management/user-stories")

        return f"✏️ Edit User Story\n\nTo update field '{field}' in story '{story_id}':\n\n1. Locate file: ./project-management/user-stories/{story_id}-*.yaml\n2. Edit the '{field}' field with value: {value}\n3. Update corresponding index.yaml if relationships changed"

    @mcp.tool()
    async def update_story(story_id: str, metadata_key: str, metadata_value: str) -> str:
        """Update user story metadata by ID.

        Args:
            story_id: User story ID (e.g., "US-001")
            metadata_key: Metadata field (e.g., "status", "priority", "related_personas")
            metadata_value: New metadata value

        Returns:
            Confirmation message

        Implementation Note:
            This is a stub that directs to the YAML index structure.
            To update story '{story_id}' metadata:
            1. Edit ./project-management/user-stories/index.yaml
            2. Find the entry with id: {story_id}
            3. Update {metadata_key}: {metadata_value}
        """
        return f"🔄 Update Story Metadata\n\nTo update story '{story_id}' metadata:\n\n1. Edit: ./project-management/user-stories/index.yaml\n2. Find entry with id: {story_id}\n3. Set {metadata_key}: {metadata_value}\n4. Use yq to ensure YAML validity"

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