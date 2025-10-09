"""Main MCP server implementation."""

import base64
from pathlib import Path
from typing import Optional, List
from fastmcp import FastMCP

from .storage import Database
from .artifacts.manager import ArtifactManager
from .artifacts.reviews import ReviewManager
from .chat import ChatManager
from . import scripts


# Initialize MCP server
mcp = FastMCP("npl-mcp", dependencies=["fastmcp", "pyyaml", "pillow", "aiosqlite"])

# Global state (initialized on startup)
db: Optional[Database] = None
artifact_manager: Optional[ArtifactManager] = None
review_manager: Optional[ReviewManager] = None
chat_manager: Optional[ChatManager] = None


@mcp.lifespan()
async def app_lifespan():
    """Initialize and cleanup resources."""
    global db, artifact_manager, review_manager, chat_manager

    # Initialize database
    db = Database()
    await db.connect()

    # Initialize managers
    artifact_manager = ArtifactManager(db)
    review_manager = ReviewManager(db)
    chat_manager = ChatManager(db)

    yield  # Server runs

    # Cleanup
    await db.disconnect()


# ============================================================================
# Script Tools
# ============================================================================

@mcp.tool()
async def dump_files(path: str, glob_filter: Optional[str] = None) -> str:
    """Dump contents of files in a directory respecting .gitignore.

    Args:
        path: Directory path to dump files from
        glob_filter: Optional glob pattern to filter files (e.g., "*.md")

    Returns:
        Concatenated file contents with headers
    """
    return await scripts.dump_files(path, glob_filter)


@mcp.tool()
async def git_tree(path: str = ".") -> str:
    """Display directory tree respecting .gitignore.

    Args:
        path: Directory path to show tree for (default: current directory)

    Returns:
        Directory tree output
    """
    return await scripts.git_tree(path)


@mcp.tool()
async def git_tree_depth(path: str) -> str:
    """List directories with nesting depth information.

    Args:
        path: Directory path to analyze

    Returns:
        Directory listing with depth numbers
    """
    return await scripts.git_tree_depth(path)


@mcp.tool()
async def npl_load(
    resource_type: str,
    items: str,
    skip: Optional[str] = None
) -> str:
    """Load NPL components, metadata, or style guides.

    Args:
        resource_type: Type of resource - 'c' (component), 'm' (meta), or 's' (style)
        items: Comma-separated list of items to load (supports wildcards)
        skip: Optional comma-separated list of patterns to skip

    Returns:
        Loaded NPL content with tracking flags
    """
    return await scripts.npl_load(resource_type, items, skip)


# ============================================================================
# Artifact Management Tools
# ============================================================================

@mcp.tool()
async def create_artifact(
    name: str,
    artifact_type: str,
    file_content_base64: str,
    filename: str,
    created_by: Optional[str] = None,
    purpose: Optional[str] = None
) -> dict:
    """Create a new artifact with initial revision.

    Args:
        name: Unique name for the artifact
        artifact_type: Type (document, image, code, data, etc.)
        file_content_base64: Base64-encoded file content
        filename: Original filename
        created_by: Persona slug of creator
        purpose: Purpose/description of the artifact

    Returns:
        Dict with artifact_id, revision_id, and paths
    """
    file_content = base64.b64decode(file_content_base64)
    return await artifact_manager.create_artifact(
        name=name,
        artifact_type=artifact_type,
        file_content=file_content,
        filename=filename,
        created_by=created_by,
        purpose=purpose
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
    """Add a new revision to an artifact.

    Args:
        artifact_id: ID of the artifact
        file_content_base64: Base64-encoded file content
        filename: Filename for this revision
        created_by: Persona slug of creator
        purpose: Purpose of this revision
        notes: Additional notes

    Returns:
        Dict with revision_id, revision_num, and paths
    """
    file_content = base64.b64decode(file_content_base64)
    result = await artifact_manager.add_revision(
        artifact_id=artifact_id,
        file_content=file_content,
        filename=filename,
        created_by=created_by,
        purpose=purpose,
        notes=notes
    )

    # Update current revision
    await db.execute(
        "UPDATE artifacts SET current_revision_id = ? WHERE id = ?",
        (result["revision_id"], artifact_id)
    )

    return result


@mcp.tool()
async def get_artifact(
    artifact_id: int,
    revision: Optional[int] = None
) -> dict:
    """Get artifact and its revision content.

    Args:
        artifact_id: ID of the artifact
        revision: Specific revision number (None for current)

    Returns:
        Dict with artifact info and base64-encoded file content
    """
    return await artifact_manager.get_artifact(artifact_id, revision)


@mcp.tool()
async def list_artifacts() -> list:
    """List all artifacts.

    Returns:
        List of artifact dicts
    """
    return await artifact_manager.list_artifacts()


@mcp.tool()
async def get_artifact_history(artifact_id: int) -> list:
    """Get revision history for an artifact.

    Args:
        artifact_id: ID of the artifact

    Returns:
        List of revision dicts
    """
    return await artifact_manager.get_artifact_history(artifact_id)


# ============================================================================
# Review System Tools
# ============================================================================

@mcp.tool()
async def create_review(
    artifact_id: int,
    revision_id: int,
    reviewer_persona: str
) -> dict:
    """Start a new review for an artifact revision.

    Args:
        artifact_id: ID of the artifact
        revision_id: ID of the specific revision to review
        reviewer_persona: Persona slug of the reviewer

    Returns:
        Dict with review_id and metadata
    """
    return await review_manager.create_review(artifact_id, revision_id, reviewer_persona)


@mcp.tool()
async def add_inline_comment(
    review_id: int,
    location: str,
    comment: str,
    persona: str
) -> dict:
    """Add an inline comment to a review.

    Args:
        review_id: ID of the review
        location: Location string (e.g., "line:58" for text, "@x:100,y:200" for images)
        comment: Comment text
        persona: Persona slug making the comment

    Returns:
        Dict with comment_id and metadata
    """
    return await review_manager.add_inline_comment(review_id, location, comment, persona)


@mcp.tool()
async def add_overlay_annotation(
    review_id: int,
    x: int,
    y: int,
    comment: str,
    persona: str
) -> dict:
    """Add an image overlay annotation.

    Args:
        review_id: ID of the review
        x: X coordinate of annotation
        y: Y coordinate of annotation
        comment: Comment text
        persona: Persona slug making the annotation

    Returns:
        Dict with annotation details
    """
    return await review_manager.add_overlay_annotation(review_id, x, y, comment, persona)


@mcp.tool()
async def get_review(review_id: int) -> dict:
    """Get a review with all its comments.

    Args:
        review_id: ID of the review

    Returns:
        Dict with review data and comments
    """
    return await review_manager.get_review(review_id)


@mcp.tool()
async def generate_annotated_artifact(
    artifact_id: int,
    revision_id: int
) -> dict:
    """Generate an annotated version of an artifact with all review comments as footnotes.

    Args:
        artifact_id: ID of the artifact
        revision_id: ID of the revision

    Returns:
        Dict with annotated content and per-reviewer files
    """
    return await review_manager.generate_annotated_artifact(artifact_id, revision_id)


@mcp.tool()
async def complete_review(
    review_id: int,
    overall_comment: Optional[str] = None
) -> dict:
    """Mark a review as completed.

    Args:
        review_id: ID of the review
        overall_comment: Optional overall review comment

    Returns:
        Dict with updated review status
    """
    return await review_manager.complete_review(review_id, overall_comment)


# ============================================================================
# Chat System Tools
# ============================================================================

@mcp.tool()
async def create_chat_room(
    name: str,
    members: List[str],
    description: Optional[str] = None
) -> dict:
    """Create a new chat room.

    Args:
        name: Unique name for the room
        members: List of persona slugs
        description: Optional room description

    Returns:
        Dict with room_id and metadata
    """
    return await chat_manager.create_chat_room(name, members, description)


@mcp.tool()
async def send_message(
    room_id: int,
    persona: str,
    message: str,
    reply_to_id: Optional[int] = None
) -> dict:
    """Send a message to a chat room.

    Args:
        room_id: ID of the chat room
        persona: Persona slug sending the message
        message: Message content (supports @mentions)
        reply_to_id: Optional ID of event being replied to

    Returns:
        Dict with event_id and notifications created
    """
    return await chat_manager.send_message(room_id, persona, message, reply_to_id)


@mcp.tool()
async def react_to_message(
    event_id: int,
    persona: str,
    emoji: str
) -> dict:
    """Add an emoji reaction to a message.

    Args:
        event_id: ID of the event to react to
        persona: Persona slug adding the reaction
        emoji: Emoji string

    Returns:
        Dict with reaction event_id
    """
    return await chat_manager.react_to_message(event_id, persona, emoji)


@mcp.tool()
async def share_artifact(
    room_id: int,
    persona: str,
    artifact_id: int,
    revision: Optional[int] = None
) -> dict:
    """Share an artifact in a chat room.

    Args:
        room_id: ID of the chat room
        persona: Persona slug sharing the artifact
        artifact_id: ID of the artifact
        revision: Optional specific revision number

    Returns:
        Dict with event_id and notifications
    """
    return await chat_manager.share_artifact(room_id, persona, artifact_id, revision)


@mcp.tool()
async def create_todo(
    room_id: int,
    persona: str,
    description: str,
    assigned_to: Optional[str] = None
) -> dict:
    """Create a shared todo item in a chat room.

    Args:
        room_id: ID of the chat room
        persona: Persona slug creating the todo
        description: Todo description
        assigned_to: Optional persona slug to assign to

    Returns:
        Dict with event_id and notification
    """
    return await chat_manager.create_todo(room_id, persona, description, assigned_to)


@mcp.tool()
async def get_chat_feed(
    room_id: int,
    since: Optional[str] = None,
    limit: int = 50
) -> list:
    """Get chat event feed for a room.

    Args:
        room_id: ID of the chat room
        since: Optional ISO timestamp to get events after
        limit: Maximum number of events to return (default: 50)

    Returns:
        List of event dicts in chronological order
    """
    return await chat_manager.get_chat_feed(room_id, since, limit)


@mcp.tool()
async def get_notifications(
    persona: str,
    unread_only: bool = True
) -> list:
    """Get notifications for a persona.

    Args:
        persona: Persona slug
        unread_only: If True, only return unread notifications

    Returns:
        List of notification dicts with event details
    """
    return await chat_manager.get_notifications(persona, unread_only)


@mcp.tool()
async def mark_notification_read(notification_id: int) -> dict:
    """Mark a notification as read.

    Args:
        notification_id: ID of the notification

    Returns:
        Dict with updated notification status
    """
    return await chat_manager.mark_notification_read(notification_id)


def main():
    """Entry point for the MCP server."""
    mcp.run()


if __name__ == "__main__":
    main()
