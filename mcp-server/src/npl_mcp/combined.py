"""Combined MCP + Web server entry point.

This module runs both:
1. The MCP server (on stdio for Claude integration)
2. The web server (on HTTP for browser access)

The web server runs in a background thread while the MCP server
handles the main stdio communication.
"""

import asyncio
import os
import sys
import threading
from contextlib import asynccontextmanager
from typing import Optional

import uvicorn
from fastmcp import FastMCP

from .storage import Database
from .artifacts.manager import ArtifactManager
from .artifacts.reviews import ReviewManager
from .chat import ChatManager
from .sessions import SessionManager
from .web import WebServer


# Configuration from environment
WEB_HOST = os.environ.get("NPL_MCP_WEB_HOST", "127.0.0.1")
WEB_PORT = int(os.environ.get("NPL_MCP_WEB_PORT", "8765"))
DATA_DIR = os.environ.get("NPL_MCP_DATA_DIR", "./data")


class CombinedServer:
    """Runs MCP and Web servers with shared database."""

    def __init__(self):
        self.db: Optional[Database] = None
        self.artifact_manager: Optional[ArtifactManager] = None
        self.review_manager: Optional[ReviewManager] = None
        self.chat_manager: Optional[ChatManager] = None
        self.session_manager: Optional[SessionManager] = None
        self.web_server: Optional[WebServer] = None
        self.web_thread: Optional[threading.Thread] = None

    async def initialize(self):
        """Initialize database and managers."""
        self.db = Database()
        await self.db.connect()

        self.artifact_manager = ArtifactManager(self.db)
        self.review_manager = ReviewManager(self.db)
        self.chat_manager = ChatManager(self.db)
        self.session_manager = SessionManager(self.db)
        self.web_server = WebServer(self.db)

    async def cleanup(self):
        """Cleanup resources."""
        if self.db:
            await self.db.disconnect()

    def start_web_server(self):
        """Start web server in background thread."""
        def run_web():
            config = uvicorn.Config(
                self.web_server.app,
                host=WEB_HOST,
                port=WEB_PORT,
                log_level="warning",  # Reduce log noise
                access_log=False
            )
            server = uvicorn.Server(config)
            asyncio.run(server.serve())

        self.web_thread = threading.Thread(target=run_web, daemon=True)
        self.web_thread.start()
        print(f"Web server started at http://{WEB_HOST}:{WEB_PORT}", file=sys.stderr)


# Global server instance
_server: Optional[CombinedServer] = None


@asynccontextmanager
async def lifespan(mcp: FastMCP):
    """Initialize combined server resources."""
    global _server

    _server = CombinedServer()
    await _server.initialize()

    # Start web server in background
    _server.start_web_server()

    yield {
        "db": _server.db,
        "artifact_manager": _server.artifact_manager,
        "review_manager": _server.review_manager,
        "chat_manager": _server.chat_manager,
        "session_manager": _server.session_manager
    }

    await _server.cleanup()


# Create MCP server with combined lifespan
mcp = FastMCP("npl-mcp", lifespan=lifespan)


# Import and register all tools from server module
# We need to re-register them to use our lifespan's managers
import base64
from typing import List


@mcp.tool()
async def dump_files(path: str, glob_filter: Optional[str] = None) -> str:
    """Dump contents of files in a directory respecting .gitignore."""
    from . import scripts
    return await scripts.dump_files(path, glob_filter)


@mcp.tool()
async def git_tree(path: str = ".") -> str:
    """Display directory tree respecting .gitignore."""
    from . import scripts
    return await scripts.git_tree(path)


@mcp.tool()
async def git_tree_depth(path: str) -> str:
    """List directories with nesting depth information."""
    from . import scripts
    return await scripts.git_tree_depth(path)


@mcp.tool()
async def npl_load(resource_type: str, items: str, skip: Optional[str] = None) -> str:
    """Load NPL components, metadata, or style guides."""
    from . import scripts
    return await scripts.npl_load(resource_type, items, skip)


@mcp.tool()
async def create_artifact(
    name: str,
    artifact_type: str,
    file_content_base64: str,
    filename: str,
    created_by: Optional[str] = None,
    purpose: Optional[str] = None
) -> dict:
    """Create a new artifact with initial revision."""
    file_content = base64.b64decode(file_content_base64)
    return await _server.artifact_manager.create_artifact(
        name=name, artifact_type=artifact_type, file_content=file_content,
        filename=filename, created_by=created_by, purpose=purpose
    )


@mcp.tool()
async def add_revision(
    artifact_id: int,
    file_content_base64: str,
    filename: str,
    created_by: Optional[str] = None,
    purpose: Optional[str] = None,
    notes: Optional[str] = None
) -> dict:
    """Add a new revision to an artifact."""
    file_content = base64.b64decode(file_content_base64)
    result = await _server.artifact_manager.add_revision(
        artifact_id=artifact_id, file_content=file_content, filename=filename,
        created_by=created_by, purpose=purpose, notes=notes
    )
    await _server.db.execute(
        "UPDATE artifacts SET current_revision_id = ? WHERE id = ?",
        (result["revision_id"], artifact_id)
    )
    return result


@mcp.tool()
async def get_artifact(artifact_id: int, revision: Optional[int] = None) -> dict:
    """Get artifact and its revision content."""
    return await _server.artifact_manager.get_artifact(artifact_id, revision)


@mcp.tool()
async def list_artifacts() -> list:
    """List all artifacts."""
    return await _server.artifact_manager.list_artifacts()


@mcp.tool()
async def get_artifact_history(artifact_id: int) -> list:
    """Get revision history for an artifact."""
    return await _server.artifact_manager.get_artifact_history(artifact_id)


@mcp.tool()
async def create_review(artifact_id: int, revision_id: int, reviewer_persona: str) -> dict:
    """Start a new review for an artifact revision."""
    return await _server.review_manager.create_review(artifact_id, revision_id, reviewer_persona)


@mcp.tool()
async def add_inline_comment(review_id: int, location: str, comment: str, persona: str) -> dict:
    """Add an inline comment to a review."""
    return await _server.review_manager.add_inline_comment(review_id, location, comment, persona)


@mcp.tool()
async def add_overlay_annotation(review_id: int, x: int, y: int, comment: str, persona: str) -> dict:
    """Add an image overlay annotation."""
    return await _server.review_manager.add_overlay_annotation(review_id, x, y, comment, persona)


@mcp.tool()
async def get_review(review_id: int) -> dict:
    """Get a review with all its comments."""
    return await _server.review_manager.get_review(review_id)


@mcp.tool()
async def generate_annotated_artifact(artifact_id: int, revision_id: int) -> dict:
    """Generate an annotated version of an artifact with all review comments as footnotes."""
    return await _server.review_manager.generate_annotated_artifact(artifact_id, revision_id)


@mcp.tool()
async def complete_review(review_id: int, overall_comment: Optional[str] = None) -> dict:
    """Mark a review as completed."""
    return await _server.review_manager.complete_review(review_id, overall_comment)


# Session tools
@mcp.tool()
async def create_session(title: Optional[str] = None, session_id: Optional[str] = None) -> dict:
    """Create a new session to group chat rooms and artifacts.

    Sessions provide a way to organize related activities. The returned
    session_id can be shared with users so they can view the session
    in the web interface.
    """
    result = await _server.session_manager.create_session(title=title, session_id=session_id)
    result["web_url"] = f"http://{WEB_HOST}:{WEB_PORT}/session/{result['session_id']}"
    return result


@mcp.tool()
async def get_session(session_id: str) -> dict:
    """Get session details and contents."""
    result = await _server.session_manager.get_session_contents(session_id)
    result["web_url"] = f"http://{WEB_HOST}:{WEB_PORT}/session/{session_id}"
    return result


@mcp.tool()
async def list_sessions(status: Optional[str] = None, limit: int = 20) -> list:
    """List recent sessions."""
    sessions = await _server.session_manager.list_sessions(status=status, limit=limit)
    for s in sessions:
        s["web_url"] = f"http://{WEB_HOST}:{WEB_PORT}/session/{s['id']}"
    return sessions


@mcp.tool()
async def update_session(session_id: str, title: Optional[str] = None, status: Optional[str] = None) -> dict:
    """Update session metadata."""
    result = await _server.session_manager.update_session(session_id, title=title, status=status)
    result["web_url"] = f"http://{WEB_HOST}:{WEB_PORT}/session/{session_id}"
    return result


# Chat tools
@mcp.tool()
async def create_chat_room(
    name: str,
    members: List[str],
    description: Optional[str] = None,
    session_id: Optional[str] = None,
    session_title: Optional[str] = None
) -> dict:
    """Create a new chat room.

    Args:
        name: Unique name for the room
        members: List of persona slugs
        description: Optional room description
        session_id: Optional session ID to associate with (creates new session if not found)
        session_title: Optional title for new session (only used if creating new session)
    """
    actual_session_id = None
    if session_id or session_title:
        session = await _server.session_manager.get_or_create_session(
            session_id=session_id, title=session_title
        )
        actual_session_id = session["session_id"]

    result = await _server.chat_manager.create_chat_room(
        name, members, description, session_id=actual_session_id
    )

    if actual_session_id:
        await _server.session_manager.touch_session(actual_session_id)
        result["web_url"] = f"http://{WEB_HOST}:{WEB_PORT}/session/{actual_session_id}/room/{result['room_id']}"
    else:
        result["web_url"] = f"http://{WEB_HOST}:{WEB_PORT}/room/{result['room_id']}"

    return result


@mcp.tool()
async def send_message(
    room_id: int,
    persona: str,
    message: str,
    reply_to_id: Optional[int] = None
) -> dict:
    """Send a message to a chat room."""
    return await _server.chat_manager.send_message(room_id, persona, message, reply_to_id)


@mcp.tool()
async def react_to_message(event_id: int, persona: str, emoji: str) -> dict:
    """Add an emoji reaction to a message."""
    return await _server.chat_manager.react_to_message(event_id, persona, emoji)


@mcp.tool()
async def share_artifact(
    room_id: int,
    persona: str,
    artifact_id: int,
    revision: Optional[int] = None
) -> dict:
    """Share an artifact in a chat room."""
    return await _server.chat_manager.share_artifact(room_id, persona, artifact_id, revision)


@mcp.tool()
async def create_todo(
    room_id: int,
    persona: str,
    description: str,
    assigned_to: Optional[str] = None
) -> dict:
    """Create a shared todo item in a chat room."""
    return await _server.chat_manager.create_todo(room_id, persona, description, assigned_to)


@mcp.tool()
async def get_chat_feed(room_id: int, since: Optional[str] = None, limit: int = 50) -> list:
    """Get chat event feed for a room."""
    return await _server.chat_manager.get_chat_feed(room_id, since, limit)


@mcp.tool()
async def get_notifications(persona: str, unread_only: bool = True) -> list:
    """Get notifications for a persona."""
    return await _server.chat_manager.get_notifications(persona, unread_only)


@mcp.tool()
async def mark_notification_read(notification_id: int) -> dict:
    """Mark a notification as read."""
    return await _server.chat_manager.mark_notification_read(notification_id)


def main():
    """Entry point for combined MCP + Web server."""
    print(f"Starting NPL MCP Server with Web UI on port {WEB_PORT}", file=sys.stderr)
    mcp.run()


if __name__ == "__main__":
    main()
