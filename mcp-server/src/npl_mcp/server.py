"""Main MCP server implementation."""

import base64
import os
from contextlib import asynccontextmanager
from pathlib import Path
from typing import Optional, List
from fastmcp import FastMCP

from .storage import Database
from .artifacts.manager import ArtifactManager
from .artifacts.reviews import ReviewManager
from .chat import ChatManager
from .sessions import SessionManager
from .executors import TaskerManager, fabric as tasker_fabric
from . import scripts
from .browser import (
    capture_screenshot as browser_capture_screenshot,
    compare_screenshots,
    capture_checkpoint as browser_capture_checkpoint,
    list_checkpoints as browser_list_checkpoints,
    get_checkpoint as browser_get_checkpoint,
    compare_checkpoints as browser_compare_checkpoints,
    CaptureResult,
    DiffResult,
    CheckpointManifest,
    ComparisonResult,
)


# Global managers (initialized via lifespan)
_db: Optional[Database] = None
_artifact_manager: Optional[ArtifactManager] = None
_review_manager: Optional[ReviewManager] = None
_chat_manager: Optional[ChatManager] = None
_session_manager: Optional[SessionManager] = None
_tasker_manager: Optional[TaskerManager] = None

# Web server port (set via environment)
WEB_PORT = int(os.environ.get("NPL_MCP_WEB_PORT", "8765"))


@asynccontextmanager
async def lifespan(server: FastMCP):
    """Initialize and cleanup resources."""
    global _db, _artifact_manager, _review_manager, _chat_manager, _session_manager, _tasker_manager

    # Initialize database
    _db = Database()
    await _db.connect()

    # Initialize managers
    _artifact_manager = ArtifactManager(_db)
    _review_manager = ReviewManager(_db)
    _chat_manager = ChatManager(_db)
    _session_manager = SessionManager(_db)
    _tasker_manager = TaskerManager(_db, chat_manager=_chat_manager)

    # Start tasker lifecycle monitor
    await _tasker_manager.start_lifecycle_monitor()

    yield {
        "db": _db,
        "artifact_manager": _artifact_manager,
        "review_manager": _review_manager,
        "chat_manager": _chat_manager,
        "session_manager": _session_manager,
        "tasker_manager": _tasker_manager
    }

    # Cleanup
    await _tasker_manager.stop_lifecycle_monitor()
    await _db.disconnect()


# Initialize MCP server with lifespan
mcp = FastMCP("npl-mcp", lifespan=lifespan)


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
# Screenshot Tools
# ============================================================================

@mcp.tool()
async def screenshot_capture(
    url: str,
    name: str,
    viewport: str = "desktop",
    theme: str = "light",
    full_page: bool = True,
    wait_for: Optional[str] = None,
    wait_timeout: int = 5000,
    session_id: Optional[str] = None
) -> dict:
    """Capture screenshot of a web page and store as artifact.

    Args:
        url: Full URL to capture
        name: Name for the screenshot artifact
        viewport: "desktop" (1280x720), "mobile" (375x667), "tablet", "4k", or "WxH"
        theme: "light" or "dark" (sets browser colorScheme)
        full_page: Capture entire scrollable page
        wait_for: CSS selector to wait for before capture
        wait_timeout: Milliseconds to wait for selector
        session_id: Optional session ID to associate artifact with

    Returns:
        Dict with artifact_id, file_path, and capture metadata
    """
    # Capture screenshot using browser module
    result: CaptureResult = await browser_capture_screenshot(
        url=url,
        viewport=viewport,
        theme=theme,
        full_page=full_page,
        wait_for=wait_for,
        wait_timeout=wait_timeout,
    )

    # Generate filename
    filename = f"{name}-{viewport}-{theme}.png"

    # Store as artifact
    artifact = await _artifact_manager.create_artifact(
        name=name,
        artifact_type="screenshot",
        file_content=result.image_bytes,
        filename=filename,
        purpose=f"Screenshot of {url}"
    )

    # Associate with session if provided
    if session_id:
        await _session_manager.associate_artifact(session_id, artifact["artifact_id"])

    return {
        "artifact_id": artifact["artifact_id"],
        "file_path": artifact["file_path"],
        "metadata": {
            "url": result.url,
            "viewport": result.viewport_preset or f"{result.width}x{result.height}",
            "theme": result.theme,
            "dimensions": {"width": result.width, "height": result.height},
            "full_page": result.full_page,
            "captured_at": result.captured_at,
        }
    }


@mcp.tool()
async def screenshot_diff(
    baseline_artifact_id: int,
    comparison_artifact_id: int,
    threshold: float = 0.1,
    session_id: Optional[str] = None
) -> dict:
    """Generate visual diff between two screenshot artifacts.

    Args:
        baseline_artifact_id: Artifact ID of baseline screenshot
        comparison_artifact_id: Artifact ID of comparison screenshot
        threshold: Diff sensitivity 0.0-1.0 (lower = more sensitive)
        session_id: Optional session ID to associate diff artifact with

    Returns:
        Dict with diff_artifact_id, diff_percentage, status, and comparison details
    """
    # Load baseline and comparison images
    baseline = await _artifact_manager.get_artifact(baseline_artifact_id)
    comparison = await _artifact_manager.get_artifact(comparison_artifact_id)

    baseline_bytes = base64.b64decode(baseline["file_content"])
    comparison_bytes = base64.b64decode(comparison["file_content"])

    # Generate diff
    result: DiffResult = compare_screenshots(
        baseline_bytes=baseline_bytes,
        comparison_bytes=comparison_bytes,
        threshold=threshold,
    )

    # Store diff as artifact
    diff_name = f"diff-{baseline_artifact_id}-vs-{comparison_artifact_id}"
    diff_artifact = await _artifact_manager.create_artifact(
        name=diff_name,
        artifact_type="screenshot_diff",
        file_content=result.diff_image,
        filename=f"{diff_name}.png",
        purpose=f"Visual diff: artifact {baseline_artifact_id} vs {comparison_artifact_id}"
    )

    # Associate with session if provided
    if session_id:
        await _session_manager.associate_artifact(session_id, diff_artifact["artifact_id"])

    return {
        "diff_artifact_id": diff_artifact["artifact_id"],
        "diff_percentage": result.diff_percentage,
        "diff_pixels": result.diff_pixels,
        "total_pixels": result.total_pixels,
        "dimensions_match": result.dimensions_match,
        "status": result.status.value,
        "baseline": {
            "artifact_id": baseline_artifact_id,
            "dimensions": {"width": result.baseline_dimensions[0], "height": result.baseline_dimensions[1]}
        },
        "comparison": {
            "artifact_id": comparison_artifact_id,
            "dimensions": {"width": result.comparison_dimensions[0], "height": result.comparison_dimensions[1]}
        }
    }


@mcp.tool()
async def screenshot_checkpoint(
    name: str,
    urls: List[dict],
    base_url: str,
    description: str = "",
    viewports: Optional[List[str]] = None,
    themes: Optional[List[str]] = None,
) -> dict:
    """Capture a complete checkpoint of multiple pages across viewports and themes.

    Creates a named checkpoint with screenshots organized by page/viewport/theme.
    Captures git commit and branch information automatically.

    Args:
        name: Human-readable checkpoint name (e.g., "after-button-fix")
        urls: List of page configs, each with:
            - name: Page identifier (e.g., "dashboard")
            - url: Relative URL path (e.g., "/dashboard")
            - description: Optional page description
            - requires_auth: Whether page needs authentication
            - wait_for: CSS selector to wait for before capture
        base_url: Base URL for relative paths (e.g., "http://localhost:4000")
        description: Optional checkpoint description
        viewports: Viewports to capture (default: ["desktop", "mobile"])
        themes: Themes to capture (default: ["light", "dark"])

    Returns:
        Dict with checkpoint_slug, total_screenshots, and manifest details
    """
    manifest: CheckpointManifest = await browser_capture_checkpoint(
        name=name,
        urls=urls,
        base_url=base_url,
        description=description,
        viewports=viewports,
        themes=themes,
    )

    return {
        "checkpoint_slug": manifest.slug,
        "name": manifest.name,
        "description": manifest.description,
        "timestamp": manifest.timestamp,
        "git_commit": manifest.git_commit,
        "git_branch": manifest.git_branch,
        "base_url": manifest.base_url,
        "viewports": manifest.viewports,
        "themes": manifest.themes,
        "pages": len(manifest.pages),
        "total_screenshots": manifest.total_screenshots,
    }


@mcp.tool()
async def screenshot_list_checkpoints() -> list:
    """List all available screenshot checkpoints.

    Returns:
        List of checkpoint summaries with slug, name, timestamp, and git info
    """
    return await browser_list_checkpoints()


@mcp.tool()
async def screenshot_get_checkpoint(slug: str) -> dict:
    """Get detailed information about a specific checkpoint.

    Args:
        slug: Checkpoint slug (e.g., "after-button-fix-20251210-143000")

    Returns:
        Full checkpoint manifest with all screenshot paths
    """
    manifest = await browser_get_checkpoint(slug)
    if manifest is None:
        raise ValueError(f"Checkpoint '{slug}' not found")

    return manifest.to_dict()


@mcp.tool()
async def screenshot_compare(
    baseline_checkpoint: str,
    comparison_checkpoint: str,
    threshold: float = 0.1,
) -> dict:
    """Compare two checkpoints and generate visual diffs.

    Compares all matching page/viewport/theme combinations between two checkpoints.
    Generates diff images showing pixel-level differences.

    Args:
        baseline_checkpoint: Slug of the baseline checkpoint
        comparison_checkpoint: Slug of the comparison checkpoint
        threshold: Diff sensitivity 0.0-1.0 (lower = more sensitive, default 0.1)

    Returns:
        Dict with comparison_id, summary counts by status, and per-page details
    """
    result: ComparisonResult = await browser_compare_checkpoints(
        baseline_slug=baseline_checkpoint,
        comparison_slug=comparison_checkpoint,
        threshold=threshold,
    )

    return result.to_dict()


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
    return await _artifact_manager.create_artifact(
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
    result = await _artifact_manager.add_revision(
        artifact_id=artifact_id,
        file_content=file_content,
        filename=filename,
        created_by=created_by,
        purpose=purpose,
        notes=notes
    )

    # Update current revision
    await _db.execute(
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
    return await _artifact_manager.get_artifact(artifact_id, revision)


@mcp.tool()
async def list_artifacts() -> list:
    """List all artifacts.

    Returns:
        List of artifact dicts
    """
    return await _artifact_manager.list_artifacts()


@mcp.tool()
async def get_artifact_history(artifact_id: int) -> list:
    """Get revision history for an artifact.

    Args:
        artifact_id: ID of the artifact

    Returns:
        List of revision dicts
    """
    return await _artifact_manager.get_artifact_history(artifact_id)


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
    return await _review_manager.create_review(artifact_id, revision_id, reviewer_persona)


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
    return await _review_manager.add_inline_comment(review_id, location, comment, persona)


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
    return await _review_manager.add_overlay_annotation(review_id, x, y, comment, persona)


@mcp.tool()
async def get_review(review_id: int) -> dict:
    """Get a review with all its comments.

    Args:
        review_id: ID of the review

    Returns:
        Dict with review data and comments
    """
    return await _review_manager.get_review(review_id)


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
    return await _review_manager.generate_annotated_artifact(artifact_id, revision_id)


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
    return await _review_manager.complete_review(review_id, overall_comment)


# ============================================================================
# Chat System Tools
# ============================================================================

@mcp.tool()
async def create_session(
    title: Optional[str] = None,
    session_id: Optional[str] = None
) -> dict:
    """Create a new session to group chat rooms and artifacts.

    Sessions provide a way to organize related activities. The returned
    session_id can be shared with users so they can view the session
    in the web interface at http://localhost:{WEB_PORT}/session/{session_id}

    Args:
        title: Optional human-readable title for the session
        session_id: Optional custom session ID (auto-generated if not provided)

    Returns:
        Dict with session_id, title, created_at, and web_url
    """
    result = await _session_manager.create_session(title=title, session_id=session_id)
    result["web_url"] = f"http://localhost:{WEB_PORT}/session/{result['session_id']}"
    return result


@mcp.tool()
async def get_session(session_id: str) -> dict:
    """Get session details and contents.

    Args:
        session_id: Session ID

    Returns:
        Dict with session info, chat_rooms, and artifacts
    """
    result = await _session_manager.get_session_contents(session_id)
    result["web_url"] = f"http://localhost:{WEB_PORT}/session/{session_id}"
    return result


@mcp.tool()
async def list_sessions(
    status: Optional[str] = None,
    limit: int = 20
) -> list:
    """List recent sessions.

    Args:
        status: Optional status filter ('active', 'archived')
        limit: Maximum number of sessions to return (default: 20)

    Returns:
        List of session dicts with summary info
    """
    sessions = await _session_manager.list_sessions(status=status, limit=limit)
    for s in sessions:
        s["web_url"] = f"http://localhost:{WEB_PORT}/session/{s['id']}"
    return sessions


@mcp.tool()
async def update_session(
    session_id: str,
    title: Optional[str] = None,
    status: Optional[str] = None
) -> dict:
    """Update session metadata.

    Args:
        session_id: Session ID
        title: New title (if provided)
        status: New status ('active' or 'archived')

    Returns:
        Updated session dict
    """
    result = await _session_manager.update_session(session_id, title=title, status=status)
    result["web_url"] = f"http://localhost:{WEB_PORT}/session/{session_id}"
    return result


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

    Returns:
        Dict with room_id, session_id, web_url, and metadata
    """
    # Handle session creation/lookup
    actual_session_id = None
    if session_id or session_title:
        session = await _session_manager.get_or_create_session(
            session_id=session_id,
            title=session_title
        )
        actual_session_id = session["session_id"]

    result = await _chat_manager.create_chat_room(
        name, members, description, session_id=actual_session_id
    )

    # Update session timestamp if we have one
    if actual_session_id:
        await _session_manager.touch_session(actual_session_id)
        result["web_url"] = f"http://localhost:{WEB_PORT}/session/{actual_session_id}/room/{result['room_id']}"
    else:
        result["web_url"] = f"http://localhost:{WEB_PORT}/room/{result['room_id']}"

    return result


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
    return await _chat_manager.send_message(room_id, persona, message, reply_to_id)


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
    return await _chat_manager.react_to_message(event_id, persona, emoji)


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
    return await _chat_manager.share_artifact(room_id, persona, artifact_id, revision)


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
    return await _chat_manager.create_todo(room_id, persona, description, assigned_to)


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
    return await _chat_manager.get_chat_feed(room_id, since, limit)


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
    return await _chat_manager.get_notifications(persona, unread_only)


@mcp.tool()
async def mark_notification_read(notification_id: int) -> dict:
    """Mark a notification as read.

    Args:
        notification_id: ID of the notification

    Returns:
        Dict with updated notification status
    """
    return await _chat_manager.mark_notification_read(notification_id)


# ============================================================================
# Tasker Tools (Ephemeral Executor Agents)
# ============================================================================

@mcp.tool()
async def spawn_tasker(
    task: str,
    chat_room_id: int,
    parent_agent_id: str = "primary",
    patterns: Optional[List[str]] = None,
    session_id: Optional[str] = None,
    timeout_minutes: int = 15,
    nag_minutes: int = 5
) -> dict:
    """Spawn an ephemeral tasker agent for executing commands and analyzing output.

    Taskers handle mundane operations (file checks, commands, web fetching) to preserve
    primary agent context. Raw output stays with the tasker; only distilled answers return.

    Args:
        task: Description of the task/topic for the tasker
        chat_room_id: ID of chat room to join for nag messages (required)
        parent_agent_id: Agent ID of spawning parent (default: "primary")
        patterns: Fabric patterns to apply for analysis (e.g., ["analyze_logs", "summarize"])
        session_id: Optional session to associate with
        timeout_minutes: Auto-dismiss timeout (default: 15)
        nag_minutes: Idle time before nagging parent (default: 5)

    Returns:
        Dict with tasker_id, status, and configuration
    """
    return await _tasker_manager.spawn_tasker(
        task=task,
        chat_room_id=chat_room_id,
        parent_agent_id=parent_agent_id,
        patterns=patterns,
        session_id=session_id,
        timeout_minutes=timeout_minutes,
        nag_minutes=nag_minutes
    )


@mcp.tool()
async def tasker_run(
    tasker_id: str,
    command: str,
    cwd: Optional[str] = None,
    analyze: bool = True,
    timeout: int = 120
) -> dict:
    """Execute a shell command through a tasker and return distilled results.

    The tasker runs the command, stores raw output in worklog, applies fabric analysis
    if enabled, and returns only the distilled answer to preserve context.

    Args:
        tasker_id: ID of the tasker instance
        command: Shell command to execute
        cwd: Working directory for command (default: current directory)
        analyze: Whether to apply fabric patterns (default: True)
        timeout: Command timeout in seconds (default: 120)

    Returns:
        Dict with distilled_result, success status, and worklog reference
    """
    import asyncio
    import subprocess

    # Touch tasker to update activity
    await _tasker_manager.touch_tasker(tasker_id)

    # Get tasker context for patterns
    tasker = await _tasker_manager.get_tasker(tasker_id)
    if not tasker:
        raise ValueError(f"Tasker '{tasker_id}' not found")

    # Execute command
    try:
        process = await asyncio.create_subprocess_shell(
            command,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
            cwd=cwd
        )

        stdout, stderr = await asyncio.wait_for(
            process.communicate(),
            timeout=timeout
        )

        raw_output = stdout.decode() + (f"\nSTDERR:\n{stderr.decode()}" if stderr else "")
        exit_code = process.returncode
        success = exit_code == 0

    except asyncio.TimeoutError:
        return {
            "success": False,
            "error": f"Command timed out after {timeout}s",
            "tasker_id": tasker_id
        }
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "tasker_id": tasker_id
        }

    # Apply fabric analysis if enabled
    analysis_result = None
    distilled_result = raw_output[:500] + "..." if len(raw_output) > 500 else raw_output

    if analyze and tasker.get('patterns'):
        analysis = await tasker_fabric.analyze_with_patterns(raw_output, tasker['patterns'])
        if analysis.get('success'):
            analysis_result = analysis['result']
            distilled_result = analysis_result
        else:
            # Fallback to truncated output
            distilled_result = f"[Analysis failed: {analysis.get('error')}]\n{distilled_result}"

    # Store context for follow-up queries
    await _tasker_manager.store_context(
        tasker_id=tasker_id,
        command=command,
        raw_output=raw_output,
        analysis=analysis_result,
        result=distilled_result[:500]
    )

    return {
        "success": success,
        "exit_code": exit_code,
        "distilled_result": distilled_result,
        "raw_output_lines": len(raw_output.split('\n')),
        "tasker_id": tasker_id,
        "analyzed": analyze and analysis_result is not None
    }


@mcp.tool()
async def tasker_fetch(
    tasker_id: str,
    url: str,
    question: Optional[str] = None,
    analyze: bool = True
) -> dict:
    """Fetch web content through a tasker and return distilled results.

    The tasker fetches the URL, stores raw content in worklog, applies fabric analysis
    if enabled, and returns a distilled answer focused on the question if provided.

    Args:
        tasker_id: ID of the tasker instance
        url: URL to fetch
        question: Specific question to answer about the content (optional)
        analyze: Whether to apply fabric patterns (default: True)

    Returns:
        Dict with distilled_result and worklog reference
    """
    import aiohttp

    # Touch tasker to update activity
    await _tasker_manager.touch_tasker(tasker_id)

    # Get tasker context
    tasker = await _tasker_manager.get_tasker(tasker_id)
    if not tasker:
        raise ValueError(f"Tasker '{tasker_id}' not found")

    # Fetch URL
    try:
        async with aiohttp.ClientSession() as session:
            async with session.get(url, timeout=aiohttp.ClientTimeout(total=60)) as response:
                content_type = response.headers.get('content-type', '')
                if 'text' in content_type or 'json' in content_type:
                    raw_content = await response.text()
                else:
                    return {
                        "success": False,
                        "error": f"Unsupported content type: {content_type}",
                        "tasker_id": tasker_id
                    }
                status = response.status
    except Exception as e:
        return {
            "success": False,
            "error": f"Fetch failed: {str(e)}",
            "tasker_id": tasker_id
        }

    # Apply fabric analysis
    analysis_result = None
    patterns = tasker.get('patterns', ['summarize'])
    distilled_result = raw_content[:1000] + "..." if len(raw_content) > 1000 else raw_content

    if analyze:
        analysis = await tasker_fabric.analyze_with_patterns(raw_content, patterns)
        if analysis.get('success'):
            analysis_result = analysis['result']
            distilled_result = analysis_result

    # If question provided, prepend it to result
    if question:
        distilled_result = f"Question: {question}\n\nAnswer:\n{distilled_result}"

    # Store context
    await _tasker_manager.store_context(
        tasker_id=tasker_id,
        command=f"fetch {url}",
        raw_output=raw_content,
        analysis=analysis_result,
        result=distilled_result[:500]
    )

    return {
        "success": status < 400,
        "status_code": status,
        "distilled_result": distilled_result,
        "raw_content_length": len(raw_content),
        "tasker_id": tasker_id,
        "analyzed": analyze and analysis_result is not None
    }


@mcp.tool()
async def tasker_query(
    tasker_id: str,
    question: str
) -> dict:
    """Ask a follow-up question to a tasker about previous outputs.

    The tasker retains context from previous commands. Use this to drill down
    into details without re-running commands.

    Args:
        tasker_id: ID of the tasker instance
        question: Question about previous command outputs

    Returns:
        Dict with answer based on retained context
    """
    # Touch tasker
    await _tasker_manager.touch_tasker(tasker_id)

    # Get context
    context = await _tasker_manager.get_context(tasker_id)
    if not context:
        raise ValueError(f"Tasker '{tasker_id}' not found or has no context")

    # Build context for analysis
    context_text = ""
    if context.get('last_analysis'):
        context_text = context['last_analysis']
    elif context.get('last_raw_output'):
        context_text = context['last_raw_output'][:5000]
    else:
        return {
            "success": False,
            "error": "No previous output to query",
            "tasker_id": tasker_id
        }

    # Use fabric to answer the question with context
    prompt = f"""Based on the following output, answer this question: {question}

Output:
{context_text}"""

    result = await tasker_fabric.apply_fabric_pattern(prompt, "summarize")

    return {
        "success": result.get('success', False),
        "answer": result.get('result', f"Based on context: {context_text[:500]}"),
        "tasker_id": tasker_id,
        "context_source": "analysis" if context.get('last_analysis') else "raw_output"
    }


@mcp.tool()
async def dismiss_tasker(
    tasker_id: str,
    reason: Optional[str] = None
) -> dict:
    """Dismiss/terminate a tasker explicitly.

    Args:
        tasker_id: ID of the tasker to dismiss
        reason: Optional reason for dismissal

    Returns:
        Dict with status and stats
    """
    return await _tasker_manager.dismiss_tasker(tasker_id, reason)


@mcp.tool()
async def list_taskers(
    status: Optional[str] = None,
    session_id: Optional[str] = None
) -> list:
    """List all taskers with optional filtering.

    Args:
        status: Filter by status ('active', 'idle', 'nagging', 'terminated')
        session_id: Filter by session

    Returns:
        List of tasker info dicts
    """
    return await _tasker_manager.list_taskers(status=status, session_id=session_id)


def main():
    """Entry point for the MCP server."""
    mcp.run()


if __name__ == "__main__":
    main()
