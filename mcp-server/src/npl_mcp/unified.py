"""Unified HTTP server: MCP over SSE + Web UI in one process.

This server:
1. Serves MCP protocol over SSE at /sse
2. Serves web UI at / and other routes
3. Can be configured to only start if not already running (singleton mode)
4. Shares a single database connection
"""

import asyncio
import os
import shutil
import socket
import subprocess
import sys
from contextlib import asynccontextmanager
from pathlib import Path
from typing import Optional

import uvicorn
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from starlette.routing import Mount

from .storage import Database
from .artifacts.manager import ArtifactManager
from .artifacts.reviews import ReviewManager
from .chat import ChatManager
from .sessions import SessionManager
from .tasks import TaskQueueManager
from .web.app import WebServer

# Try to import FastMCP
try:
    from fastmcp import FastMCP
except ImportError:
    FastMCP = None


# Configuration
HOST = os.environ.get("NPL_MCP_HOST", "127.0.0.1")
PORT = int(os.environ.get("NPL_MCP_PORT", "8765"))
DATA_DIR = os.environ.get("NPL_MCP_DATA_DIR", "./data")
PID_FILE = Path(DATA_DIR) / ".npl-mcp.pid"

# Frontend paths
BASE_DIR = Path(__file__).parent.parent.parent  # mcp-server/
FRONTEND_DIR = BASE_DIR / "frontend"
STATIC_DIR = FRONTEND_DIR / "out"


def build_frontend(skip_if_exists: bool = True) -> bool:
    """Build the Next.js frontend to static files.

    Args:
        skip_if_exists: If True, skip build if out/ already exists

    Returns:
        True if build succeeded or skipped, False on failure
    """
    if not FRONTEND_DIR.exists():
        print(f"Frontend directory not found: {FRONTEND_DIR}", file=sys.stderr)
        return False

    if skip_if_exists and STATIC_DIR.exists() and (STATIC_DIR / "index.html").exists():
        print("Frontend already built, skipping...", file=sys.stderr)
        return True

    print("Building frontend...", file=sys.stderr)

    # Check if npm is available
    if not shutil.which("npm"):
        print("npm not found, skipping frontend build", file=sys.stderr)
        return False

    try:
        # Install dependencies
        print("  Installing npm dependencies...", file=sys.stderr)
        subprocess.run(
            ["npm", "install"],
            cwd=FRONTEND_DIR,
            check=True,
            capture_output=True
        )

        # Build
        print("  Running next build...", file=sys.stderr)
        subprocess.run(
            ["npm", "run", "build"],
            cwd=FRONTEND_DIR,
            check=True,
            capture_output=True
        )

        if not STATIC_DIR.exists():
            print("Frontend build failed: output directory not created", file=sys.stderr)
            return False

        print("Frontend built successfully!", file=sys.stderr)
        return True

    except subprocess.CalledProcessError as e:
        print(f"Frontend build failed: {e}", file=sys.stderr)
        if e.stderr:
            print(e.stderr.decode(), file=sys.stderr)
        return False


def is_port_in_use(host: str, port: int) -> bool:
    """Check if a port is already in use."""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        try:
            s.bind((host, port))
            return False
        except OSError:
            return True


def check_singleton() -> bool:
    """Check if server is already running.

    Returns:
        True if we should start, False if already running
    """
    if is_port_in_use(HOST, PORT):
        print(f"Server already running on {HOST}:{PORT}", file=sys.stderr)
        return False
    return True


def write_pid_file():
    """Write PID file for tracking."""
    PID_FILE.parent.mkdir(parents=True, exist_ok=True)
    PID_FILE.write_text(str(os.getpid()))


def remove_pid_file():
    """Remove PID file on shutdown."""
    if PID_FILE.exists():
        PID_FILE.unlink()


# Global state
_db: Optional[Database] = None
_artifact_manager: Optional[ArtifactManager] = None
_review_manager: Optional[ReviewManager] = None
_chat_manager: Optional[ChatManager] = None
_session_manager: Optional[SessionManager] = None
_task_queue_manager: Optional[TaskQueueManager] = None


def create_mcp_server() -> "FastMCP":
    """Create MCP server with all tools."""
    import base64
    from typing import List

    mcp = FastMCP("npl-mcp")

    # Script tools
    @mcp.tool()
    async def dump_files(path: str, glob_filter: Optional[str] = None) -> str:
        """Dump contents of files in a directory respecting .gitignore.

        IMPORTANT: Caller must pass an absolute path (e.g., '/home/user/project'),
        not a relative path like '.' or './subdir'. Use pwd to get the current
        working directory if needed.
        """
        from . import scripts
        return await scripts.dump_files(path, glob_filter)

    @mcp.tool()
    async def git_tree(path: str = ".") -> str:
        """Display directory tree respecting .gitignore.

        IMPORTANT: Caller must pass an absolute path (e.g., '/home/user/project'),
        not a relative path like '.' or './subdir'. Use pwd to get the current
        working directory if needed.
        """
        from . import scripts
        return await scripts.git_tree(path)

    @mcp.tool()
    async def git_tree_depth(path: str) -> str:
        """List directories with nesting depth information.

        IMPORTANT: Caller must pass an absolute path (e.g., '/home/user/project'),
        not a relative path like '.' or './subdir'. Use pwd to get the current
        working directory if needed.
        """
        from . import scripts
        return await scripts.git_tree_depth(path)

    @mcp.tool()
    async def npl_load(resource_type: str, items: str, skip: Optional[str] = None) -> str:
        """Load NPL components, metadata, or style guides."""
        from . import scripts
        return await scripts.npl_load(resource_type, items, skip)

    @mcp.tool()
    async def web_to_md(url: str, timeout: int = 30) -> str:
        """Fetch a web page and return its content as markdown using Jina Reader.

        Args:
            url: The URL of the web page to fetch
            timeout: Request timeout in seconds (default 30)

        Returns:
            Formatted markdown string with success/failure status and content
        """
        import httpx
        import os
        import traceback

        jina_api_key = os.environ.get("JINA_API_KEY", "")
        jina_url = f"https://r.jina.ai/{url}"

        headers = {}
        if jina_api_key:
            headers["Authorization"] = f"Bearer {jina_api_key}"

        try:
            async with httpx.AsyncClient(timeout=timeout) as client:
                response = await client.get(jina_url, headers=headers)
                response.raise_for_status()

                content = response.text

                return f"""success: true
url: {url}
content_length: {len(content)}
---
{content}"""
        except httpx.TimeoutException:
            tb = traceback.format_exc()
            return f"""success: false
url: {url}
---
# Error
Request timed out after {timeout} seconds

## Traceback
```
{tb}
```"""
        except httpx.HTTPStatusError as e:
            tb = traceback.format_exc()
            return f"""success: false
url: {url}
---
# Error
HTTP {e.response.status_code}: {e.response.text[:500]}

## Traceback
```
{tb}
```"""
        except Exception as e:
            tb = traceback.format_exc()
            return f"""success: false
url: {url}
---
# Error
{str(e)}

## Traceback
```
{tb}
```"""

    # Artifact tools
    @mcp.tool()
    async def create_artifact(
        name: str, artifact_type: str, file_content_base64: str, filename: str,
        created_by: Optional[str] = None, purpose: Optional[str] = None
    ) -> dict:
        """Create a new artifact with initial revision."""
        file_content = base64.b64decode(file_content_base64)
        return await _artifact_manager.create_artifact(
            name=name, artifact_type=artifact_type, file_content=file_content,
            filename=filename, created_by=created_by, purpose=purpose
        )

    @mcp.tool()
    async def add_revision(
        artifact_id: int, file_content_base64: str, filename: str,
        created_by: Optional[str] = None, purpose: Optional[str] = None, notes: Optional[str] = None
    ) -> dict:
        """Add a new revision to an artifact."""
        file_content = base64.b64decode(file_content_base64)
        result = await _artifact_manager.add_revision(
            artifact_id=artifact_id, file_content=file_content, filename=filename,
            created_by=created_by, purpose=purpose, notes=notes
        )
        await _db.execute(
            "UPDATE artifacts SET current_revision_id = ? WHERE id = ?",
            (result["revision_id"], artifact_id)
        )
        return result

    @mcp.tool()
    async def get_artifact(artifact_id: int, revision: Optional[int] = None) -> dict:
        """Get artifact and its revision content."""
        return await _artifact_manager.get_artifact(artifact_id, revision)

    @mcp.tool()
    async def list_artifacts() -> list:
        """List all artifacts."""
        return await _artifact_manager.list_artifacts()

    @mcp.tool()
    async def get_artifact_history(artifact_id: int) -> list:
        """Get revision history for an artifact."""
        return await _artifact_manager.get_artifact_history(artifact_id)

    # Review tools
    @mcp.tool()
    async def create_review(artifact_id: int, revision_id: int, reviewer_persona: str) -> dict:
        """Start a new review for an artifact revision."""
        return await _review_manager.create_review(artifact_id, revision_id, reviewer_persona)

    @mcp.tool()
    async def add_inline_comment(review_id: int, location: str, comment: str, persona: str) -> dict:
        """Add an inline comment to a review."""
        return await _review_manager.add_inline_comment(review_id, location, comment, persona)

    @mcp.tool()
    async def add_overlay_annotation(review_id: int, x: int, y: int, comment: str, persona: str) -> dict:
        """Add an image overlay annotation."""
        return await _review_manager.add_overlay_annotation(review_id, x, y, comment, persona)

    @mcp.tool()
    async def get_review(review_id: int) -> dict:
        """Get a review with all its comments."""
        return await _review_manager.get_review(review_id)

    @mcp.tool()
    async def generate_annotated_artifact(artifact_id: int, revision_id: int) -> dict:
        """Generate an annotated version of an artifact with all review comments."""
        return await _review_manager.generate_annotated_artifact(artifact_id, revision_id)

    @mcp.tool()
    async def complete_review(review_id: int, overall_comment: Optional[str] = None) -> dict:
        """Mark a review as completed."""
        return await _review_manager.complete_review(review_id, overall_comment)

    # Session tools
    @mcp.tool()
    async def create_session(title: Optional[str] = None, session_id: Optional[str] = None) -> dict:
        """Create a new session to group chat rooms and artifacts."""
        result = await _session_manager.create_session(title=title, session_id=session_id)
        result["web_url"] = f"http://{HOST}:{PORT}/session/{result['session_id']}"
        return result

    @mcp.tool()
    async def get_session(session_id: str) -> dict:
        """Get session details and contents."""
        result = await _session_manager.get_session_contents(session_id)
        result["web_url"] = f"http://{HOST}:{PORT}/session/{session_id}"
        return result

    @mcp.tool()
    async def list_sessions(status: Optional[str] = None, limit: int = 20) -> list:
        """List recent sessions."""
        sessions = await _session_manager.list_sessions(status=status, limit=limit)
        for s in sessions:
            s["web_url"] = f"http://{HOST}:{PORT}/session/{s['id']}"
        return sessions

    @mcp.tool()
    async def update_session(session_id: str, title: Optional[str] = None, status: Optional[str] = None) -> dict:
        """Update session metadata."""
        result = await _session_manager.update_session(session_id, title=title, status=status)
        result["web_url"] = f"http://{HOST}:{PORT}/session/{session_id}"
        return result

    # Chat tools
    @mcp.tool()
    async def create_chat_room(
        name: str, members: List[str], description: Optional[str] = None,
        session_id: Optional[str] = None, session_title: Optional[str] = None
    ) -> dict:
        """Create a new chat room."""
        actual_session_id = None
        if session_id or session_title:
            session = await _session_manager.get_or_create_session(
                session_id=session_id, title=session_title
            )
            actual_session_id = session["session_id"]

        result = await _chat_manager.create_chat_room(
            name, members, description, session_id=actual_session_id
        )

        if actual_session_id:
            await _session_manager.touch_session(actual_session_id)
            result["web_url"] = f"http://{HOST}:{PORT}/session/{actual_session_id}/room/{result['room_id']}"
        else:
            result["web_url"] = f"http://{HOST}:{PORT}/room/{result['room_id']}"

        return result

    @mcp.tool()
    async def send_message(room_id: int, persona: str, message: str, reply_to_id: Optional[int] = None) -> dict:
        """Send a message to a chat room."""
        return await _chat_manager.send_message(room_id, persona, message, reply_to_id)

    @mcp.tool()
    async def react_to_message(event_id: int, persona: str, emoji: str) -> dict:
        """Add an emoji reaction to a message."""
        return await _chat_manager.react_to_message(event_id, persona, emoji)

    @mcp.tool()
    async def share_artifact(room_id: int, persona: str, artifact_id: int, revision: Optional[int] = None) -> dict:
        """Share an artifact in a chat room."""
        return await _chat_manager.share_artifact(room_id, persona, artifact_id, revision)

    @mcp.tool()
    async def create_todo(room_id: int, persona: str, description: str, assigned_to: Optional[str] = None) -> dict:
        """Create a shared todo item in a chat room."""
        return await _chat_manager.create_todo(room_id, persona, description, assigned_to)

    @mcp.tool()
    async def get_chat_feed(room_id: int, since: Optional[str] = None, limit: int = 50) -> list:
        """Get chat event feed for a room."""
        return await _chat_manager.get_chat_feed(room_id, since, limit)

    @mcp.tool()
    async def get_notifications(persona: str, unread_only: bool = True) -> list:
        """Get notifications for a persona."""
        return await _chat_manager.get_notifications(persona, unread_only)

    @mcp.tool()
    async def mark_notification_read(notification_id: int) -> dict:
        """Mark a notification as read."""
        return await _chat_manager.mark_notification_read(notification_id)

    # Browser/Screenshot tools
    @mcp.tool()
    async def screenshot_capture(
        url: str,
        name: str,
        viewport: str = "desktop",
        theme: str = "light",
        full_page: bool = True,
        wait_for: Optional[str] = None,
        wait_timeout: int = 5000,
        network_idle: bool = True,
        session_id: Optional[str] = None,
        created_by: Optional[str] = None,
    ) -> dict:
        """Capture screenshot of a web page and store as artifact.

        Args:
            url: URL of the webpage to screenshot
            name: Name for the screenshot artifact
            viewport: "desktop" (1280x720), "mobile" (375x667), or "WIDTHxHEIGHT"
            theme: "light" or "dark" (sets browser colorScheme)
            full_page: Capture entire scrollable page
            wait_for: CSS selector to wait for before capture
            wait_timeout: Milliseconds to wait for selector
            network_idle: Wait for network idle (False for ad-heavy sites)
            session_id: Optional session to associate artifact with
            created_by: Persona slug of creator

        Returns:
            Dict with artifact_id, file_path, and capture metadata
        """
        from .browser import capture_screenshot as do_capture

        # Capture screenshot
        result = await do_capture(
            url=url,
            viewport=viewport,
            theme=theme,
            full_page=full_page,
            wait_for=wait_for,
            wait_timeout=wait_timeout,
            network_idle=network_idle,
        )

        # Store as artifact
        filename = f"{name}.png"
        artifact = await _artifact_manager.create_artifact(
            name=name,
            artifact_type="screenshot",
            file_content=result.image_bytes,
            filename=filename,
            created_by=created_by,
            purpose=f"Screenshot of {url}",
        )

        # Associate with session if provided
        if session_id:
            await _db.execute(
                "UPDATE artifacts SET session_id = ? WHERE id = ?",
                (session_id, artifact["artifact_id"])
            )
            artifact["session_id"] = session_id
            artifact["web_url"] = f"http://{HOST}:{PORT}/session/{session_id}"

        # Add capture metadata
        artifact["metadata"] = {
            "url": result.url,
            "viewport": {
                "width": result.width,
                "height": result.height,
                "preset": result.viewport_preset,
            },
            "theme": result.theme,
            "full_page": result.full_page,
            "captured_at": result.captured_at,
        }

        return artifact

    @mcp.tool()
    async def screenshot_diff(
        baseline_artifact_id: int,
        comparison_artifact_id: int,
        threshold: float = 0.1,
        session_id: Optional[str] = None,
        created_by: Optional[str] = None,
    ) -> dict:
        """Generate visual diff between two screenshot artifacts.

        Args:
            baseline_artifact_id: Artifact ID of baseline screenshot
            comparison_artifact_id: Artifact ID of comparison screenshot
            threshold: Diff sensitivity 0.0-1.0 (default 0.1)
            session_id: Optional session to associate diff artifact with
            created_by: Persona slug of creator

        Returns:
            Dict with diff_artifact_id, diff_percentage, status, and comparison details
        """
        from .browser import compare_screenshots

        # Get both artifacts
        baseline = await _artifact_manager.get_artifact(baseline_artifact_id)
        comparison = await _artifact_manager.get_artifact(comparison_artifact_id)

        baseline_bytes = base64.b64decode(baseline["file_content"])
        comparison_bytes = base64.b64decode(comparison["file_content"])

        # Generate diff
        diff_result = compare_screenshots(
            baseline_bytes,
            comparison_bytes,
            threshold=threshold,
        )

        # Store diff as artifact
        baseline_name = baseline.get("artifact_name", f"artifact_{baseline_artifact_id}")
        comparison_name = comparison.get("artifact_name", f"artifact_{comparison_artifact_id}")
        diff_name = f"diff_{baseline_name}_vs_{comparison_name}"

        artifact = await _artifact_manager.create_artifact(
            name=diff_name,
            artifact_type="screenshot_diff",
            file_content=diff_result.diff_image,
            filename=f"{diff_name}.png",
            created_by=created_by,
            purpose=f"Visual diff: {baseline_name} vs {comparison_name}",
        )

        # Associate with session if provided
        if session_id:
            await _db.execute(
                "UPDATE artifacts SET session_id = ? WHERE id = ?",
                (session_id, artifact["artifact_id"])
            )

        return {
            "diff_artifact_id": artifact["artifact_id"],
            "diff_percentage": diff_result.diff_percentage,
            "diff_pixels": diff_result.diff_pixels,
            "total_pixels": diff_result.total_pixels,
            "dimensions_match": diff_result.dimensions_match,
            "status": diff_result.status.value,
            "baseline": {
                "artifact_id": baseline_artifact_id,
                "dimensions": {
                    "width": diff_result.baseline_dimensions[0],
                    "height": diff_result.baseline_dimensions[1],
                },
            },
            "comparison": {
                "artifact_id": comparison_artifact_id,
                "dimensions": {
                    "width": diff_result.comparison_dimensions[0],
                    "height": diff_result.comparison_dimensions[1],
                },
            },
            "file_path": artifact["file_path"],
        }

    @mcp.tool()
    async def browser_navigate(
        url: str,
        session_id: str = "default",
        wait_for: Optional[str] = None,
        timeout: int = 30000,
    ) -> dict:
        """Navigate browser to a URL.

        Args:
            url: URL to navigate to
            session_id: Browser session ID (creates if not exists)
            wait_for: Optional CSS selector to wait for
            timeout: Navigation timeout in milliseconds

        Returns:
            Dict with success status and page info
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        result = await session.navigate(url, wait_for=wait_for, timeout=timeout)

        state = await session.get_page_state()

        return {
            "success": result.success,
            "action": result.action,
            "message": result.message,
            "page": {
                "url": state.url,
                "title": state.title,
                "viewport": state.viewport,
            },
        }

    @mcp.tool()
    async def browser_click(
        selector: str,
        session_id: str = "default",
        timeout: int = 5000,
        screenshot_after: bool = False,
        artifact_name: Optional[str] = None,
    ) -> dict:
        """Click an element in the browser.

        Args:
            selector: CSS selector for element to click
            session_id: Browser session ID
            timeout: Wait timeout in milliseconds
            screenshot_after: Capture screenshot after click
            artifact_name: Name for screenshot artifact (required if screenshot_after=True)

        Returns:
            Dict with success status and optional screenshot artifact
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        result = await session.click(selector, timeout=timeout, capture_after=screenshot_after)

        response = {
            "success": result.success,
            "action": result.action,
            "target": result.target,
            "message": result.message,
        }

        if screenshot_after and result.screenshot and artifact_name:
            artifact = await _artifact_manager.create_artifact(
                name=artifact_name,
                artifact_type="screenshot",
                file_content=result.screenshot,
                filename=f"{artifact_name}.png",
                purpose=f"Screenshot after clicking {selector}",
            )
            response["screenshot_artifact_id"] = artifact["artifact_id"]

        return response

    @mcp.tool()
    async def browser_fill(
        selector: str,
        value: str,
        session_id: str = "default",
        timeout: int = 5000,
    ) -> dict:
        """Fill a form field in the browser.

        Args:
            selector: CSS selector for input element
            value: Value to fill
            session_id: Browser session ID
            timeout: Wait timeout in milliseconds

        Returns:
            Dict with success status
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        result = await session.fill(selector, value, timeout=timeout)

        return {
            "success": result.success,
            "action": result.action,
            "target": result.target,
            "message": result.message,
        }

    @mcp.tool()
    async def browser_type(
        selector: str,
        text: str,
        session_id: str = "default",
        delay: int = 50,
        timeout: int = 5000,
    ) -> dict:
        """Type text character by character (simulates real typing).

        Args:
            selector: CSS selector for input element
            text: Text to type
            session_id: Browser session ID
            delay: Delay between keystrokes in milliseconds
            timeout: Wait timeout in milliseconds

        Returns:
            Dict with success status
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        result = await session.type_text(selector, text, delay=delay, timeout=timeout)

        return {
            "success": result.success,
            "action": result.action,
            "target": result.target,
            "message": result.message,
        }

    @mcp.tool()
    async def browser_select(
        selector: str,
        value: str,
        session_id: str = "default",
        timeout: int = 5000,
    ) -> dict:
        """Select option from dropdown.

        Args:
            selector: CSS selector for select element
            value: Option value to select
            session_id: Browser session ID
            timeout: Wait timeout in milliseconds

        Returns:
            Dict with success status
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        result = await session.select(selector, value, timeout=timeout)

        return {
            "success": result.success,
            "action": result.action,
            "target": result.target,
            "message": result.message,
        }

    @mcp.tool()
    async def browser_scroll(
        direction: str = "down",
        amount: int = 500,
        selector: Optional[str] = None,
        session_id: str = "default",
    ) -> dict:
        """Scroll the page or an element.

        Args:
            direction: "up", "down", "left", "right"
            amount: Pixels to scroll
            selector: Optional element to scroll (scrolls page if None)
            session_id: Browser session ID

        Returns:
            Dict with success status
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        result = await session.scroll(direction=direction, amount=amount, selector=selector)

        return {
            "success": result.success,
            "action": result.action,
            "target": result.target,
            "message": result.message,
        }

    @mcp.tool()
    async def browser_wait_for(
        selector: str,
        state: str = "visible",
        session_id: str = "default",
        timeout: int = 10000,
    ) -> dict:
        """Wait for an element to reach a state.

        Args:
            selector: CSS selector for element
            state: "visible", "hidden", "attached", "detached"
            session_id: Browser session ID
            timeout: Wait timeout in milliseconds

        Returns:
            Dict with success status
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        result = await session.wait_for(selector, state=state, timeout=timeout)

        return {
            "success": result.success,
            "action": result.action,
            "target": result.target,
            "message": result.message,
        }

    @mcp.tool()
    async def browser_get_text(
        selector: str,
        session_id: str = "default",
        timeout: int = 5000,
    ) -> dict:
        """Get text content of an element.

        Args:
            selector: CSS selector for element
            session_id: Browser session ID
            timeout: Wait timeout in milliseconds

        Returns:
            Dict with text content
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        text = await session.get_text(selector, timeout=timeout)

        return {
            "selector": selector,
            "text": text,
        }

    @mcp.tool()
    async def browser_query_elements(
        selector: str,
        session_id: str = "default",
        limit: int = 10,
    ) -> dict:
        """Query multiple elements matching a selector.

        Args:
            selector: CSS selector
            session_id: Browser session ID
            limit: Maximum elements to return

        Returns:
            Dict with list of element info
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        elements = await session.query_elements(selector, limit=limit)

        return {
            "selector": selector,
            "count": len(elements),
            "elements": [
                {
                    "tag": el.tag,
                    "text": el.text[:100] if el.text else "",
                    "visible": el.visible,
                    "bounding_box": el.bounding_box,
                    "attributes": el.attributes,
                }
                for el in elements
            ],
        }

    @mcp.tool()
    async def browser_evaluate(
        expression: str,
        session_id: str = "default",
    ) -> dict:
        """Evaluate JavaScript expression in page context.

        Args:
            expression: JavaScript expression to evaluate
            session_id: Browser session ID

        Returns:
            Dict with result of expression
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        result = await session.evaluate(expression)

        return {
            "expression": expression[:100],
            "result": result,
        }

    @mcp.tool()
    async def browser_screenshot(
        name: str,
        session_id: str = "default",
        full_page: bool = False,
        selector: Optional[str] = None,
        created_by: Optional[str] = None,
    ) -> dict:
        """Capture screenshot of current browser page or element.

        Args:
            name: Name for the screenshot artifact
            session_id: Browser session ID
            full_page: Capture entire scrollable page
            selector: Optional element to screenshot
            created_by: Persona slug of creator

        Returns:
            Dict with artifact_id and file_path
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        screenshot_bytes = await session.screenshot(full_page=full_page, selector=selector)

        state = await session.get_page_state()

        artifact = await _artifact_manager.create_artifact(
            name=name,
            artifact_type="screenshot",
            file_content=screenshot_bytes,
            filename=f"{name}.png",
            created_by=created_by,
            purpose=f"Screenshot of {state.url}",
        )

        artifact["metadata"] = {
            "url": state.url,
            "title": state.title,
            "full_page": full_page,
            "selector": selector,
        }

        return artifact

    @mcp.tool()
    async def browser_get_state(
        session_id: str = "default",
    ) -> dict:
        """Get current browser page state.

        Args:
            session_id: Browser session ID

        Returns:
            Dict with URL, title, viewport, and scroll position
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        state = await session.get_page_state()

        return {
            "url": state.url,
            "title": state.title,
            "viewport": state.viewport,
            "scroll_position": state.scroll_position,
        }

    @mcp.tool()
    async def browser_close_session(
        session_id: str,
    ) -> dict:
        """Close a browser session.

        Args:
            session_id: Browser session ID to close

        Returns:
            Dict with success status
        """
        from .browser import close_session

        await close_session(session_id)

        return {
            "success": True,
            "message": f"Closed browser session: {session_id}",
        }

    @mcp.tool()
    async def browser_list_sessions() -> dict:
        """List active browser sessions.

        Returns:
            Dict with list of session IDs
        """
        from .browser import list_sessions

        sessions = await list_sessions()

        return {
            "sessions": sessions,
            "count": len(sessions),
        }

    # Additional generic browser interaction tools

    @mcp.tool()
    async def browser_press_key(
        key: str,
        session_id: str = "default",
        modifiers: Optional[List[str]] = None,
    ) -> dict:
        """Press a keyboard key.

        Args:
            key: Key to press (e.g., "Enter", "Tab", "Escape", "ArrowDown", "a", "F1")
            session_id: Browser session ID
            modifiers: Optional list of modifiers ["Control", "Shift", "Alt", "Meta"]

        Returns:
            Dict with success status
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        result = await session.press_key(key, modifiers=modifiers)

        return {
            "success": result.success,
            "action": result.action,
            "message": result.message,
        }

    @mcp.tool()
    async def browser_hover(
        selector: str,
        session_id: str = "default",
        timeout: int = 5000,
    ) -> dict:
        """Hover over an element.

        Args:
            selector: CSS selector for element
            session_id: Browser session ID
            timeout: Wait timeout in milliseconds

        Returns:
            Dict with success status
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        result = await session.hover(selector, timeout=timeout)

        return {
            "success": result.success,
            "action": result.action,
            "target": result.target,
            "message": result.message,
        }

    @mcp.tool()
    async def browser_focus(
        selector: str,
        session_id: str = "default",
        timeout: int = 5000,
    ) -> dict:
        """Focus on an element.

        Args:
            selector: CSS selector for element
            session_id: Browser session ID
            timeout: Wait timeout in milliseconds

        Returns:
            Dict with success status
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        result = await session.focus(selector, timeout=timeout)

        return {
            "success": result.success,
            "action": result.action,
            "target": result.target,
            "message": result.message,
        }

    @mcp.tool()
    async def browser_get_html(
        session_id: str = "default",
        selector: Optional[str] = None,
        outer: bool = True,
    ) -> dict:
        """Get HTML content of page or element.

        Args:
            session_id: Browser session ID
            selector: Optional CSS selector (entire page if None)
            outer: If True, include element's own tag (outerHTML vs innerHTML)

        Returns:
            Dict with HTML content
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        html = await session.get_html(selector=selector, outer=outer)

        return {
            "selector": selector,
            "html": html,
            "length": len(html),
        }

    @mcp.tool()
    async def browser_set_viewport(
        width: int,
        height: int,
        session_id: str = "default",
    ) -> dict:
        """Change browser viewport size.

        Args:
            width: Viewport width in pixels
            height: Viewport height in pixels
            session_id: Browser session ID

        Returns:
            Dict with success status
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        result = await session.set_viewport(width, height)

        return {
            "success": result.success,
            "action": result.action,
            "message": result.message,
        }

    @mcp.tool()
    async def browser_go_back(
        session_id: str = "default",
    ) -> dict:
        """Navigate back in browser history.

        Args:
            session_id: Browser session ID

        Returns:
            Dict with success status
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        result = await session.go_back()

        return {
            "success": result.success,
            "action": result.action,
            "message": result.message,
        }

    @mcp.tool()
    async def browser_go_forward(
        session_id: str = "default",
    ) -> dict:
        """Navigate forward in browser history.

        Args:
            session_id: Browser session ID

        Returns:
            Dict with success status
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        result = await session.go_forward()

        return {
            "success": result.success,
            "action": result.action,
            "message": result.message,
        }

    @mcp.tool()
    async def browser_reload(
        session_id: str = "default",
    ) -> dict:
        """Reload the current page.

        Args:
            session_id: Browser session ID

        Returns:
            Dict with success status
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        result = await session.reload()

        return {
            "success": result.success,
            "action": result.action,
            "message": result.message,
        }

    @mcp.tool()
    async def browser_inject_script(
        script: str,
        session_id: str = "default",
    ) -> dict:
        """Inject and execute JavaScript in the page via script tag.

        Args:
            script: JavaScript code to inject
            session_id: Browser session ID

        Returns:
            Dict with success status
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        result = await session.add_script(script)

        return {
            "success": result.success,
            "action": result.action,
            "message": result.message,
        }

    @mcp.tool()
    async def browser_inject_style(
        css: str,
        session_id: str = "default",
    ) -> dict:
        """Inject CSS styles into the page.

        Args:
            css: CSS code to inject
            session_id: Browser session ID

        Returns:
            Dict with success status
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        result = await session.add_style(css)

        return {
            "success": result.success,
            "action": result.action,
            "message": result.message,
        }

    @mcp.tool()
    async def browser_wait_network_idle(
        session_id: str = "default",
        timeout: int = 30000,
    ) -> dict:
        """Wait for network activity to become idle.

        Args:
            session_id: Browser session ID
            timeout: Maximum wait time in milliseconds

        Returns:
            Dict with success status
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        result = await session.wait_for_network_idle(timeout=timeout)

        return {
            "success": result.success,
            "action": result.action,
            "message": result.message,
        }

    @mcp.tool()
    async def browser_get_cookies(
        session_id: str = "default",
    ) -> dict:
        """Get all cookies for the current page.

        Args:
            session_id: Browser session ID

        Returns:
            Dict with list of cookies
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        cookies = await session.get_cookies()

        return {
            "cookies": cookies,
            "count": len(cookies),
        }

    @mcp.tool()
    async def browser_set_cookie(
        name: str,
        value: str,
        session_id: str = "default",
        domain: Optional[str] = None,
        path: str = "/",
    ) -> dict:
        """Set a cookie.

        Args:
            name: Cookie name
            value: Cookie value
            session_id: Browser session ID
            domain: Cookie domain (uses current page domain if None)
            path: Cookie path

        Returns:
            Dict with success status
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        result = await session.set_cookie(name, value, domain=domain, path=path)

        return {
            "success": result.success,
            "action": result.action,
            "target": result.target,
            "message": result.message,
        }

    @mcp.tool()
    async def browser_clear_cookies(
        session_id: str = "default",
    ) -> dict:
        """Clear all cookies for the browser session.

        Args:
            session_id: Browser session ID

        Returns:
            Dict with success status
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        result = await session.clear_cookies()

        return {
            "success": result.success,
            "action": result.action,
            "message": result.message,
        }

    @mcp.tool()
    async def browser_get_local_storage(
        session_id: str = "default",
        key: Optional[str] = None,
    ) -> dict:
        """Get localStorage value(s).

        Args:
            session_id: Browser session ID
            key: Specific key to get (all items if None)

        Returns:
            Dict with localStorage data
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        data = await session.get_local_storage(key=key)

        return {
            "key": key,
            "data": data,
        }

    @mcp.tool()
    async def browser_set_local_storage(
        key: str,
        value: str,
        session_id: str = "default",
    ) -> dict:
        """Set localStorage value.

        Args:
            key: Storage key
            value: Storage value
            session_id: Browser session ID

        Returns:
            Dict with success status
        """
        from .browser import get_or_create_session

        session = await get_or_create_session(session_id)
        result = await session.set_local_storage(key, value)

        return {
            "success": result.success,
            "action": result.action,
            "target": result.target,
            "message": result.message,
        }

    # ============================================================
    # Task Queue Tools
    # ============================================================

    @mcp.tool()
    async def create_task_queue(
        name: str,
        description: Optional[str] = None,
        session_id: Optional[str] = None,
        chat_room_id: Optional[int] = None,
    ) -> dict:
        """Create a new task queue for organizing work items.

        Args:
            name: Unique name for the queue
            description: Optional description of the queue's purpose
            session_id: Optional session to associate with
            chat_room_id: Optional chat room for Q&A about tasks

        Returns:
            Dict with queue_id, name, and metadata
        """
        result = await _task_queue_manager.create_task_queue(
            name=name,
            description=description,
            session_id=session_id,
            chat_room_id=chat_room_id,
        )
        result["web_url"] = f"http://{HOST}:{PORT}/tasks/{result['queue_id']}"
        return result

    @mcp.tool()
    async def get_task_queue(queue_id: int) -> dict:
        """Get task queue details with task counts.

        Args:
            queue_id: ID of the queue

        Returns:
            Dict with queue details and task statistics
        """
        result = await _task_queue_manager.get_task_queue(queue_id)
        result["web_url"] = f"http://{HOST}:{PORT}/tasks/{queue_id}"
        return result

    @mcp.tool()
    async def list_task_queues(
        status: Optional[str] = None,
        limit: int = 50
    ) -> list:
        """List task queues with summary stats.

        Args:
            status: Optional status filter ('active', 'archived')
            limit: Maximum queues to return

        Returns:
            List of queue dicts with task counts
        """
        queues = await _task_queue_manager.list_task_queues(status=status, limit=limit)
        for q in queues:
            q["web_url"] = f"http://{HOST}:{PORT}/tasks/{q['id']}"
        return queues

    @mcp.tool()
    async def create_task(
        queue_id: int,
        title: str,
        description: Optional[str] = None,
        acceptance_criteria: Optional[str] = None,
        priority: int = 1,
        deadline: Optional[str] = None,
        created_by: Optional[str] = None,
        assigned_to: Optional[str] = None,
    ) -> dict:
        """Create a new task in a queue.

        Args:
            queue_id: ID of the task queue
            title: Task title
            description: Task description
            acceptance_criteria: Criteria for task completion
            priority: Priority level (0=low, 1=normal, 2=high, 3=urgent)
            deadline: ISO timestamp deadline
            created_by: Persona who created the task
            assigned_to: Persona assigned to the task

        Returns:
            Dict with task_id and metadata
        """
        result = await _task_queue_manager.create_task(
            queue_id=queue_id,
            title=title,
            description=description,
            acceptance_criteria=acceptance_criteria,
            priority=priority,
            deadline=deadline,
            created_by=created_by,
            assigned_to=assigned_to,
        )
        result["web_url"] = f"http://{HOST}:{PORT}/tasks/{queue_id}/task/{result['task_id']}"
        return result

    @mcp.tool()
    async def get_task(task_id: int) -> dict:
        """Get task details with linked artifacts.

        Args:
            task_id: ID of the task

        Returns:
            Dict with task details and artifacts
        """
        result = await _task_queue_manager.get_task(task_id)
        result["web_url"] = f"http://{HOST}:{PORT}/tasks/{result['queue_id']}/task/{task_id}"
        return result

    @mcp.tool()
    async def list_tasks(
        queue_id: int,
        status: Optional[str] = None,
        assigned_to: Optional[str] = None,
        limit: int = 100,
    ) -> list:
        """List tasks in a queue.

        Args:
            queue_id: ID of the queue
            status: Optional status filter (pending, in_progress, blocked, review, done)
            assigned_to: Optional assignee filter
            limit: Maximum tasks to return

        Returns:
            List of task dicts ordered by priority and deadline
        """
        return await _task_queue_manager.list_tasks(
            queue_id=queue_id,
            status=status,
            assigned_to=assigned_to,
            limit=limit,
        )

    @mcp.tool()
    async def update_task_status(
        task_id: int,
        status: str,
        persona: Optional[str] = None,
        notes: Optional[str] = None,
    ) -> dict:
        """Update task status.

        Status flow: pending -> in_progress -> blocked -> review -> done
        Note: Only human operators can mark tasks as 'done'.

        Args:
            task_id: ID of the task
            status: New status (pending, in_progress, blocked, review, done)
            persona: Persona making the change
            notes: Optional notes about the status change

        Returns:
            Updated task dict
        """
        return await _task_queue_manager.update_task_status(
            task_id=task_id,
            status=status,
            persona=persona,
            notes=notes,
        )

    @mcp.tool()
    async def assign_task_complexity(
        task_id: int,
        complexity: int,
        notes: Optional[str] = None,
        persona: Optional[str] = None,
    ) -> dict:
        """Assign complexity score to a task (agent should call this after reviewing).

        Args:
            task_id: ID of the task
            complexity: Complexity score (1=trivial, 2=simple, 3=moderate, 4=complex, 5=very complex)
            notes: Notes about complexity assessment
            persona: Agent persona making the assessment

        Returns:
            Updated task dict
        """
        return await _task_queue_manager.assign_complexity(
            task_id=task_id,
            complexity=complexity,
            notes=notes,
            persona=persona,
        )

    @mcp.tool()
    async def update_task(
        task_id: int,
        title: Optional[str] = None,
        description: Optional[str] = None,
        acceptance_criteria: Optional[str] = None,
        priority: Optional[int] = None,
        deadline: Optional[str] = None,
        assigned_to: Optional[str] = None,
        persona: Optional[str] = None,
    ) -> dict:
        """Update task details.

        Args:
            task_id: ID of the task
            title: New title (optional)
            description: New description (optional)
            acceptance_criteria: New criteria (optional)
            priority: New priority (optional)
            deadline: New deadline (optional)
            assigned_to: New assignee (optional)
            persona: Persona making the change

        Returns:
            Updated task dict
        """
        return await _task_queue_manager.update_task(
            task_id=task_id,
            title=title,
            description=description,
            acceptance_criteria=acceptance_criteria,
            priority=priority,
            deadline=deadline,
            assigned_to=assigned_to,
            persona=persona,
        )

    @mcp.tool()
    async def add_task_artifact(
        task_id: int,
        artifact_type: str,
        artifact_id: Optional[int] = None,
        git_branch: Optional[str] = None,
        description: Optional[str] = None,
        created_by: Optional[str] = None,
    ) -> dict:
        """Link an artifact or git branch to a task.

        Args:
            task_id: ID of the task
            artifact_type: Type of artifact ('artifact', 'git_branch', 'file')
            artifact_id: ID of artifact if type is 'artifact'
            git_branch: Git branch name if type is 'git_branch'
            description: Description of the artifact
            created_by: Persona uploading the artifact

        Returns:
            Dict with task_artifact_id
        """
        return await _task_queue_manager.add_task_artifact(
            task_id=task_id,
            artifact_type=artifact_type,
            artifact_id=artifact_id,
            git_branch=git_branch,
            description=description,
            created_by=created_by,
        )

    @mcp.tool()
    async def add_task_message(
        task_id: int,
        persona: str,
        message: str,
    ) -> dict:
        """Add a message/question to a task's activity feed.

        Use this to ask questions, provide updates, or communicate about a task.

        Args:
            task_id: ID of the task
            persona: Persona sending the message
            message: Message content

        Returns:
            Dict with event_id
        """
        return await _task_queue_manager.add_task_message(
            task_id=task_id,
            persona=persona,
            message=message,
        )

    @mcp.tool()
    async def get_task_queue_feed(
        queue_id: int,
        since: Optional[str] = None,
        limit: int = 100,
    ) -> dict:
        """Get activity feed for a task queue (for polling).

        Use this to poll for updates. Pass the returned 'next_since' value
        in subsequent calls to only get new events.

        Args:
            queue_id: ID of the queue
            since: ISO timestamp to get events after (for polling)
            limit: Maximum events to return

        Returns:
            Dict with events list and next_since timestamp for polling
        """
        return await _task_queue_manager.get_queue_feed(
            queue_id=queue_id,
            since=since,
            limit=limit,
        )

    @mcp.tool()
    async def get_task_feed(
        task_id: int,
        since: Optional[str] = None,
        limit: int = 50,
    ) -> dict:
        """Get activity feed for a specific task.

        Args:
            task_id: ID of the task
            since: ISO timestamp to get events after
            limit: Maximum events to return

        Returns:
            Dict with events list and next_since timestamp
        """
        return await _task_queue_manager.get_task_feed(
            task_id=task_id,
            since=since,
            limit=limit,
        )

    return mcp


def create_unified_app() -> FastAPI:
    """Create unified FastAPI app with MCP and Web UI."""
    global _db, _artifact_manager, _review_manager, _chat_manager, _session_manager, _task_queue_manager

    @asynccontextmanager
    async def lifespan(app: FastAPI):
        global _db, _artifact_manager, _review_manager, _chat_manager, _session_manager, _task_queue_manager

        # Initialize database
        _db = Database()
        await _db.connect()

        # Initialize managers
        _artifact_manager = ArtifactManager(_db)
        _review_manager = ReviewManager(_db)
        _chat_manager = ChatManager(_db)
        _session_manager = SessionManager(_db)
        _task_queue_manager = TaskQueueManager(_db)

        # Store managers on app state for web routes to access
        app.state.db = _db
        app.state.session_manager = _session_manager
        app.state.chat_manager = _chat_manager
        app.state.artifact_manager = _artifact_manager
        app.state.task_queue_manager = _task_queue_manager

        write_pid_file()
        print(f"NPL MCP Server running at http://{HOST}:{PORT}", file=sys.stderr)
        print(f"  Web UI: http://{HOST}:{PORT}/", file=sys.stderr)
        print(f"  MCP SSE endpoint: http://{HOST}:{PORT}/sse", file=sys.stderr)

        yield

        remove_pid_file()
        await _db.disconnect()

    # Create main FastAPI app
    app = FastAPI(
        title="NPL MCP Server",
        description="MCP + Web UI unified server",
        lifespan=lifespan
    )

    # Add CORS middleware for development
    from fastapi.middleware.cors import CORSMiddleware
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["http://localhost:3000", "http://127.0.0.1:3000"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Create and mount MCP SSE app
    if FastMCP:
        mcp = create_mcp_server()
        mcp_app = mcp.http_app(path="/", transport="sse")
        app.mount("/sse", mcp_app)

    # Add web UI routes directly to main app
    # These use app.state to access db/managers after lifespan init
    from fastapi import Request
    from fastapi.responses import HTMLResponse, JSONResponse, RedirectResponse

    @app.get("/", response_class=HTMLResponse)
    async def index(request: Request):
        """Landing page - serve Next.js static export or fallback."""
        from fastapi.responses import FileResponse

        # Serve Next.js static index if available
        index_path = STATIC_DIR / "index.html"
        if index_path.exists():
            return FileResponse(index_path)

        # Fallback to Python-rendered page if no frontend built
        db = request.app.state.db
        session_manager = request.app.state.session_manager

        sessions = await session_manager.list_sessions(limit=20)
        rows = await db.fetchall(
            "SELECT * FROM chat_rooms WHERE session_id IS NULL ORDER BY created_at DESC LIMIT 10"
        )
        rooms_without_session = [dict(r) for r in rows]

        html = _render_index(sessions, rooms_without_session)
        return HTMLResponse(content=html)

    @app.get("/session/{session_id}", response_class=HTMLResponse)
    async def session_detail(request: Request, session_id: str):
        """Session detail page."""
        session_manager = request.app.state.session_manager

        try:
            session = await session_manager.get_session_contents(session_id)
        except ValueError:
            return HTMLResponse(content=_render_404("Session not found"), status_code=404)

        html = _render_session(session)
        return HTMLResponse(content=html)

    @app.get("/session/{session_id}/room/{room_id}", response_class=HTMLResponse)
    async def session_room(request: Request, session_id: str, room_id: int):
        """Chat room within a session."""
        chat_manager = request.app.state.chat_manager
        db = request.app.state.db

        room = await db.fetchone("SELECT * FROM chat_rooms WHERE id = ?", (room_id,))
        if not room:
            return HTMLResponse(content=_render_404("Chat room not found"), status_code=404)

        events = await chat_manager.get_chat_feed(room_id, limit=100)
        html = _render_chat_room(dict(room), events, session_id=session_id)
        return HTMLResponse(content=html)

    @app.get("/room/{room_id}", response_class=HTMLResponse)
    async def standalone_room(request: Request, room_id: int):
        """Standalone chat room (no session)."""
        chat_manager = request.app.state.chat_manager
        db = request.app.state.db

        room = await db.fetchone("SELECT * FROM chat_rooms WHERE id = ?", (room_id,))
        if not room:
            return HTMLResponse(content=_render_404("Chat room not found"), status_code=404)

        events = await chat_manager.get_chat_feed(room_id, limit=100)
        html = _render_chat_room(dict(room), events)
        return HTMLResponse(content=html)

    @app.post("/session/{session_id}/room/{room_id}/message")
    async def post_message_in_session(request: Request, session_id: str, room_id: int):
        """Post a message to a chat room."""
        chat_manager = request.app.state.chat_manager
        db = request.app.state.db
        form = await request.form()
        message = form.get("message", "")
        persona = form.get("persona", "human-operator")

        if message:
            # Auto-join room if not a member
            existing = await db.fetchone(
                "SELECT 1 FROM room_members WHERE room_id = ? AND persona_slug = ?",
                (room_id, persona)
            )
            if not existing:
                await db.execute(
                    "INSERT INTO room_members (room_id, persona_slug) VALUES (?, ?)",
                    (room_id, persona)
                )
            await chat_manager.send_message(room_id, persona, message)

        return RedirectResponse(
            url=f"/session/{session_id}/room/{room_id}",
            status_code=303
        )

    @app.post("/room/{room_id}/message")
    async def post_message_standalone(request: Request, room_id: int):
        """Post a message to a standalone chat room."""
        chat_manager = request.app.state.chat_manager
        db = request.app.state.db
        form = await request.form()
        message = form.get("message", "")
        persona = form.get("persona", "human-operator")

        if message:
            # Auto-join room if not a member
            existing = await db.fetchone(
                "SELECT 1 FROM room_members WHERE room_id = ? AND persona_slug = ?",
                (room_id, persona)
            )
            if not existing:
                await db.execute(
                    "INSERT INTO room_members (room_id, persona_slug) VALUES (?, ?)",
                    (room_id, persona)
                )
            await chat_manager.send_message(room_id, persona, message)

        return RedirectResponse(url=f"/room/{room_id}", status_code=303)

    @app.post("/session/{session_id}/room/{room_id}/todo")
    async def post_todo_in_session(request: Request, session_id: str, room_id: int):
        """Create a todo in a chat room."""
        chat_manager = request.app.state.chat_manager
        form = await request.form()
        description = form.get("description", "")
        persona = form.get("persona", "web-user")

        if description:
            await chat_manager.create_todo(room_id, persona, description)

        return RedirectResponse(
            url=f"/session/{session_id}/room/{room_id}",
            status_code=303
        )

    # API endpoints
    @app.get("/api/sessions")
    async def api_list_sessions(request: Request):
        """List sessions as JSON."""
        session_manager = request.app.state.session_manager
        sessions = await session_manager.list_sessions(limit=50)
        return JSONResponse(content={"sessions": sessions})

    @app.get("/api/session/{session_id}")
    async def api_get_session(request: Request, session_id: str):
        """Get session details as JSON."""
        session_manager = request.app.state.session_manager
        try:
            session = await session_manager.get_session_contents(session_id)
            return JSONResponse(content=session)
        except ValueError:
            return JSONResponse(content={"error": "Session not found"}, status_code=404)

    @app.get("/api/room/{room_id}/feed")
    async def api_chat_feed(request: Request, room_id: int, limit: int = 50):
        """Get chat feed as JSON."""
        chat_manager = request.app.state.chat_manager
        events = await chat_manager.get_chat_feed(room_id, limit=limit)
        return JSONResponse(content={"events": events})

    # Artifact view
    @app.get("/artifact/{artifact_id}", response_class=HTMLResponse)
    async def artifact_detail(request: Request, artifact_id: int):
        """Artifact detail page."""
        artifact_manager = request.app.state.artifact_manager

        try:
            artifact = await artifact_manager.get_artifact(artifact_id)
        except Exception:
            return HTMLResponse(content=_render_404("Artifact not found"), status_code=404)

        html = _render_artifact(artifact)
        return HTMLResponse(content=html)

    @app.get("/api/artifact/{artifact_id}")
    async def api_get_artifact(request: Request, artifact_id: int):
        """Get artifact details as JSON."""
        artifact_manager = request.app.state.artifact_manager
        try:
            artifact = await artifact_manager.get_artifact(artifact_id)
            return JSONResponse(content=artifact)
        except Exception as e:
            return JSONResponse(content={"error": str(e)}, status_code=404)

    # Screenshots gallery
    @app.get("/screenshots", response_class=HTMLResponse)
    async def screenshots_gallery(request: Request):
        """Gallery view of all screenshots."""
        artifact_manager = request.app.state.artifact_manager
        db = request.app.state.db

        # Get all screenshot artifacts
        rows = await db.fetchall("""
            SELECT a.id, a.name, a.type as artifact_type, a.created_at,
                   r.file_path, r.purpose
            FROM artifacts a
            JOIN revisions r ON a.current_revision_id = r.id
            WHERE a.type IN ('screenshot', 'screenshot_diff', 'image')
            ORDER BY a.created_at DESC
            LIMIT 100
        """)

        screenshots = [dict(r) for r in rows]
        html = _render_screenshots_gallery(screenshots)
        return HTMLResponse(content=html)

    @app.get("/api/screenshots")
    async def api_screenshots(request: Request):
        """List screenshot artifacts as JSON."""
        db = request.app.state.db

        rows = await db.fetchall("""
            SELECT a.id, a.name, a.type as artifact_type, a.created_at,
                   r.file_path, r.purpose
            FROM artifacts a
            JOIN revisions r ON a.current_revision_id = r.id
            WHERE a.type IN ('screenshot', 'screenshot_diff', 'image')
            ORDER BY a.created_at DESC
            LIMIT 100
        """)

        return JSONResponse(content={"screenshots": [dict(r) for r in rows]})

    # Comparison view for side-by-side diff analysis
    @app.get("/compare/{artifact_id}", response_class=HTMLResponse)
    async def compare_view(request: Request, artifact_id: int):
        """Side-by-side comparison view for diff artifacts."""
        artifact_manager = request.app.state.artifact_manager
        db = request.app.state.db

        try:
            artifact = await artifact_manager.get_artifact(artifact_id)
        except Exception:
            return HTMLResponse(content=_render_404("Artifact not found"), status_code=404)

        # Get related artifacts (baseline and comparison) from purpose/metadata
        purpose = artifact.get('purpose', '')
        related = []

        # Try to find related screenshots by name pattern
        artifact_name = artifact.get('artifact_name') or artifact.get('name', '')
        base_name = artifact_name.replace('_diff', '').replace('-diff', '')

        if base_name:
            rows = await db.fetchall("""
                SELECT a.id, a.name, a.artifact_type, r.file_content, r.file_path
                FROM artifacts a
                JOIN revisions r ON a.current_revision_id = r.id
                WHERE a.name LIKE ? AND a.id != ?
                ORDER BY a.created_at DESC
                LIMIT 10
            """, (f"%{base_name}%", artifact_id))
            related = [dict(r) for r in rows]

        html = _render_comparison_view(artifact, related)
        return HTMLResponse(content=html)

    # ============================================================
    # Task Queue Routes
    # ============================================================

    @app.get("/tasks", response_class=HTMLResponse)
    async def task_queues_list(request: Request):
        """Task queues list page."""
        task_queue_manager = request.app.state.task_queue_manager
        queues = await task_queue_manager.list_task_queues(limit=50)
        html = _render_task_queues_list(queues)
        return HTMLResponse(content=html)

    @app.get("/tasks/{queue_id}", response_class=HTMLResponse)
    async def task_queue_detail(request: Request, queue_id: int):
        """Task queue detail page with tasks."""
        task_queue_manager = request.app.state.task_queue_manager

        try:
            queue = await task_queue_manager.get_task_queue(queue_id)
            tasks = await task_queue_manager.list_tasks(queue_id, limit=100)
        except ValueError:
            return HTMLResponse(content=_render_404("Task queue not found"), status_code=404)

        html = _render_task_queue_detail(queue, tasks)
        return HTMLResponse(content=html)

    @app.get("/tasks/{queue_id}/task/{task_id}", response_class=HTMLResponse)
    async def task_detail(request: Request, queue_id: int, task_id: int):
        """Task detail page with activity feed."""
        task_queue_manager = request.app.state.task_queue_manager

        try:
            task = await task_queue_manager.get_task(task_id)
            feed = await task_queue_manager.get_task_feed(task_id, limit=50)
        except ValueError:
            return HTMLResponse(content=_render_404("Task not found"), status_code=404)

        html = _render_task_detail(task, feed, queue_id)
        return HTMLResponse(content=html)

    @app.post("/tasks/{queue_id}/task/{task_id}/message")
    async def post_task_message(request: Request, queue_id: int, task_id: int):
        """Post a message to a task."""
        task_queue_manager = request.app.state.task_queue_manager
        form = await request.form()
        message = form.get("message", "")
        persona = form.get("persona", "human-operator")

        if message:
            await task_queue_manager.add_task_message(task_id, persona, message)

        return RedirectResponse(
            url=f"/tasks/{queue_id}/task/{task_id}",
            status_code=303
        )

    @app.post("/tasks/{queue_id}/task/{task_id}/status")
    async def update_task_status_form(request: Request, queue_id: int, task_id: int):
        """Update task status from web form."""
        task_queue_manager = request.app.state.task_queue_manager
        form = await request.form()
        status = form.get("status", "")
        persona = form.get("persona", "human-operator")
        notes = form.get("notes", "")

        if status:
            await task_queue_manager.update_task_status(
                task_id, status, persona=persona, notes=notes if notes else None
            )

        return RedirectResponse(
            url=f"/tasks/{queue_id}/task/{task_id}",
            status_code=303
        )

    # Task Queue API endpoints
    @app.get("/api/tasks/queues")
    async def api_list_task_queues(request: Request, status: Optional[str] = None, limit: int = 50):
        """API: List task queues."""
        task_queue_manager = request.app.state.task_queue_manager
        queues = await task_queue_manager.list_task_queues(status=status, limit=limit)
        return JSONResponse(content=queues)

    @app.get("/api/tasks/queues/{queue_id}")
    async def api_get_task_queue(request: Request, queue_id: int):
        """API: Get task queue details."""
        task_queue_manager = request.app.state.task_queue_manager
        try:
            queue = await task_queue_manager.get_task_queue(queue_id)
            return JSONResponse(content=queue)
        except ValueError as e:
            return JSONResponse(content={"error": str(e)}, status_code=404)

    @app.get("/api/tasks/queues/{queue_id}/tasks")
    async def api_list_tasks(request: Request, queue_id: int, status: Optional[str] = None, limit: int = 100):
        """API: List tasks in a queue."""
        task_queue_manager = request.app.state.task_queue_manager
        tasks = await task_queue_manager.list_tasks(queue_id, status=status, limit=limit)
        return JSONResponse(content=tasks)

    @app.get("/api/tasks/{task_id}")
    async def api_get_task(request: Request, task_id: int):
        """API: Get task details."""
        task_queue_manager = request.app.state.task_queue_manager
        try:
            task = await task_queue_manager.get_task(task_id)
            return JSONResponse(content=task)
        except ValueError as e:
            return JSONResponse(content={"error": str(e)}, status_code=404)

    @app.get("/api/tasks/queues/{queue_id}/feed")
    async def api_queue_feed(
        request: Request,
        queue_id: int,
        since: Optional[str] = None,
        limit: int = 100
    ):
        """API: Get task queue activity feed (for polling).

        Pass the returned 'next_since' value in subsequent calls to only get new events.
        """
        task_queue_manager = request.app.state.task_queue_manager
        try:
            feed = await task_queue_manager.get_queue_feed(queue_id, since=since, limit=limit)
            return JSONResponse(content=feed)
        except ValueError as e:
            return JSONResponse(content={"error": str(e)}, status_code=404)

    @app.get("/api/tasks/{task_id}/feed")
    async def api_task_feed(
        request: Request,
        task_id: int,
        since: Optional[str] = None,
        limit: int = 50
    ):
        """API: Get task activity feed."""
        task_queue_manager = request.app.state.task_queue_manager
        try:
            feed = await task_queue_manager.get_task_feed(task_id, since=since, limit=limit)
            return JSONResponse(content=feed)
        except ValueError as e:
            return JSONResponse(content={"error": str(e)}, status_code=404)

    # SSE endpoint for real-time task queue updates
    from sse_starlette.sse import EventSourceResponse
    import json as json_module

    @app.get("/api/tasks/queues/{queue_id}/stream")
    async def task_queue_stream(request: Request, queue_id: int):
        """SSE endpoint for real-time task queue updates.

        Clients connect to this endpoint and receive events as they occur.
        """
        task_queue_manager = request.app.state.task_queue_manager

        async def event_generator():
            last_check = None
            while True:
                if await request.is_disconnected():
                    break

                try:
                    feed = await task_queue_manager.get_queue_feed(
                        queue_id, since=last_check, limit=50
                    )
                    events = feed.get("events", [])
                    if events:
                        for event in events:
                            yield {
                                "event": event.get("event_type", "update"),
                                "data": json_module.dumps(event)
                            }
                    last_check = feed.get("next_since")
                except Exception:
                    pass

                await asyncio.sleep(2)  # Poll every 2 seconds

        return EventSourceResponse(event_generator())

    # POST/PUT API endpoints for task management
    from pydantic import BaseModel

    class CreateQueueRequest(BaseModel):
        name: str
        description: Optional[str] = None
        session_id: Optional[str] = None

    class CreateTaskRequest(BaseModel):
        title: str
        description: Optional[str] = None
        acceptance_criteria: Optional[str] = None
        priority: int = 1
        deadline: Optional[str] = None
        assigned_to: Optional[str] = None
        created_by: Optional[str] = None

    class UpdateTaskStatusRequest(BaseModel):
        status: str
        notes: Optional[str] = None
        persona: Optional[str] = None

    class UpdateTaskRequest(BaseModel):
        title: Optional[str] = None
        description: Optional[str] = None
        acceptance_criteria: Optional[str] = None
        priority: Optional[int] = None
        deadline: Optional[str] = None
        assigned_to: Optional[str] = None

    class AddMessageRequest(BaseModel):
        message: str
        persona: str = "user"

    @app.post("/api/tasks/queues")
    async def api_create_task_queue(request: Request, body: CreateQueueRequest):
        """API: Create a task queue."""
        task_queue_manager = request.app.state.task_queue_manager
        try:
            queue = await task_queue_manager.create_task_queue(
                name=body.name,
                description=body.description,
                session_id=body.session_id
            )
            return JSONResponse(content=queue, status_code=201)
        except Exception as e:
            return JSONResponse(content={"error": str(e)}, status_code=400)

    @app.post("/api/tasks/queues/{queue_id}/tasks")
    async def api_create_task(request: Request, queue_id: int, body: CreateTaskRequest):
        """API: Create a task in a queue."""
        task_queue_manager = request.app.state.task_queue_manager
        try:
            task = await task_queue_manager.create_task(
                queue_id=queue_id,
                title=body.title,
                description=body.description,
                acceptance_criteria=body.acceptance_criteria,
                priority=body.priority,
                deadline=body.deadline,
                assigned_to=body.assigned_to,
                created_by=body.created_by
            )
            return JSONResponse(content=task, status_code=201)
        except ValueError as e:
            return JSONResponse(content={"error": str(e)}, status_code=404)
        except Exception as e:
            return JSONResponse(content={"error": str(e)}, status_code=400)

    @app.put("/api/tasks/{task_id}/status")
    async def api_update_task_status(request: Request, task_id: int, body: UpdateTaskStatusRequest):
        """API: Update task status."""
        task_queue_manager = request.app.state.task_queue_manager
        try:
            task = await task_queue_manager.update_task_status(
                task_id=task_id,
                status=body.status,
                persona=body.persona,
                notes=body.notes
            )
            return JSONResponse(content=task)
        except ValueError as e:
            return JSONResponse(content={"error": str(e)}, status_code=400)

    @app.put("/api/tasks/{task_id}")
    async def api_update_task(request: Request, task_id: int, body: UpdateTaskRequest):
        """API: Update task details."""
        task_queue_manager = request.app.state.task_queue_manager
        try:
            update_data = body.model_dump(exclude_none=True)
            if not update_data:
                return JSONResponse(content={"error": "No fields to update"}, status_code=400)

            task = await task_queue_manager.update_task(task_id=task_id, **update_data)
            return JSONResponse(content=task)
        except ValueError as e:
            return JSONResponse(content={"error": str(e)}, status_code=400)

    @app.post("/api/tasks/{task_id}/message")
    async def api_add_task_message(request: Request, task_id: int, body: AddMessageRequest):
        """API: Add a message to a task."""
        task_queue_manager = request.app.state.task_queue_manager
        try:
            result = await task_queue_manager.add_task_message(
                task_id=task_id,
                persona=body.persona,
                message=body.message
            )
            return JSONResponse(content=result, status_code=201)
        except ValueError as e:
            return JSONResponse(content={"error": str(e)}, status_code=404)

    # Static file serving for Next.js frontend
    # Must be added last to not override API routes
    if STATIC_DIR.exists():
        @app.get("/_next/{path:path}")
        async def serve_next_assets(path: str):
            """Serve Next.js static assets."""
            file_path = STATIC_DIR / "_next" / path
            if file_path.exists() and file_path.is_file():
                from fastapi.responses import FileResponse
                return FileResponse(file_path)
            return JSONResponse(content={"error": "Not found"}, status_code=404)

        # Catch-all for SPA routes - must be last
        @app.get("/{path:path}")
        async def serve_spa(path: str):
            """Serve SPA routes from Next.js static export."""
            from fastapi.responses import FileResponse

            # Don't serve /api or /sse routes as static
            if path.startswith("api/") or path.startswith("sse"):
                return JSONResponse(content={"error": "Not found"}, status_code=404)

            # Try exact file first
            file_path = STATIC_DIR / path
            if file_path.exists() and file_path.is_file():
                return FileResponse(file_path)

            # Try with .html extension (Next.js static export)
            if not path.endswith(".html") and "." not in path.split("/")[-1]:
                html_path = STATIC_DIR / f"{path}.html"
                if html_path.exists():
                    return FileResponse(html_path)

                # Try index.html in directory
                index_path = STATIC_DIR / path / "index.html"
                if index_path.exists():
                    return FileResponse(index_path)

            # Fallback to index.html for client-side routing
            index_path = STATIC_DIR / "index.html"
            if index_path.exists():
                return FileResponse(index_path)

            return JSONResponse(content={"error": "Not found"}, status_code=404)

    return app


def _escape_html(text: str) -> str:
    """Escape HTML special characters."""
    return (
        text.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
    )


def _base_html(title: str, content: str) -> str:
    """Generate base HTML template."""
    return f"""<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{_escape_html(title)} - NPL MCP</title>
    <style>
        :root {{
            --bg-primary: #1a1a2e;
            --bg-secondary: #16213e;
            --bg-tertiary: #0f3460;
            --text-primary: #e8e8e8;
            --text-secondary: #a8a8a8;
            --accent: #e94560;
            --accent-hover: #ff6b6b;
            --border: #2a2a4a;
        }}
        * {{ box-sizing: border-box; margin: 0; padding: 0; }}
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
            background: var(--bg-primary);
            color: var(--text-primary);
            line-height: 1.6;
            min-height: 100vh;
        }}
        .container {{ max-width: 1200px; margin: 0 auto; padding: 20px; }}
        header {{
            background: var(--bg-secondary);
            border-bottom: 1px solid var(--border);
            padding: 15px 0;
            margin-bottom: 30px;
        }}
        header .container {{ display: flex; justify-content: space-between; align-items: center; }}
        header h1 {{ font-size: 1.5rem; }}
        header h1 a {{ color: var(--accent); text-decoration: none; }}
        nav a {{ color: var(--text-secondary); text-decoration: none; margin-left: 20px; }}
        nav a:hover {{ color: var(--text-primary); }}
        .card {{
            background: var(--bg-secondary);
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
        }}
        .card h2 {{ color: var(--accent); margin-bottom: 15px; font-size: 1.2rem; }}
        .card h3 {{ color: var(--text-primary); margin-bottom: 10px; }}
        .list {{ list-style: none; }}
        .list li {{ padding: 12px; border-bottom: 1px solid var(--border); }}
        .list li:last-child {{ border-bottom: none; }}
        .list a {{ color: var(--text-primary); text-decoration: none; }}
        .list a:hover {{ color: var(--accent); }}
        .meta {{ color: var(--text-secondary); font-size: 0.85rem; margin-top: 5px; }}
        .badge {{
            display: inline-block;
            padding: 2px 8px;
            border-radius: 4px;
            font-size: 0.75rem;
            background: var(--bg-tertiary);
            color: var(--text-secondary);
        }}
        .badge.active {{ background: #1b4d3e; color: #4ade80; }}
        .message {{
            padding: 15px;
            margin-bottom: 10px;
            background: var(--bg-tertiary);
            border-radius: 8px;
        }}
        .message .author {{ font-weight: bold; color: var(--accent); }}
        .message .time {{ color: var(--text-secondary); font-size: 0.8rem; margin-left: 10px; }}
        .message .content {{ margin-top: 8px; white-space: pre-wrap; }}
        form {{ margin-top: 20px; }}
        input, textarea {{
            width: 100%;
            padding: 12px;
            background: var(--bg-tertiary);
            border: 1px solid var(--border);
            border-radius: 6px;
            color: var(--text-primary);
            font-size: 1rem;
            margin-bottom: 10px;
        }}
        input:focus, textarea:focus {{ outline: none; border-color: var(--accent); }}
        button {{
            background: var(--accent);
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 1rem;
        }}
        button:hover {{ background: var(--accent-hover); }}
        .empty {{ color: var(--text-secondary); text-align: center; padding: 40px; }}
        .breadcrumb {{ margin-bottom: 20px; color: var(--text-secondary); }}
        .breadcrumb a {{ color: var(--accent); text-decoration: none; }}
    </style>
</head>
<body>
    <header>
        <div class="container">
            <h1><a href="/">NPL MCP</a></h1>
            <nav>
                <a href="/">Sessions</a>
                <a href="/screenshots">Screenshots</a>
                <a href="/api/sessions">API</a>
            </nav>
        </div>
    </header>
    <main class="container">
        {content}
    </main>
</body>
</html>"""


def _render_index(sessions: list, rooms_without_session: list) -> str:
    """Render index page."""
    content = ""

    # Quick links section
    content += '''
    <div class="card">
        <h2>Quick Links</h2>
        <div style="display: flex; gap: 15px; flex-wrap: wrap;">
            <a href="/tasks" style="display: inline-block; padding: 10px 20px; background: var(--bg-tertiary); border-radius: 6px; text-decoration: none; color: var(--text-primary);">
                Task Queues
            </a>
            <a href="/screenshots" style="display: inline-block; padding: 10px 20px; background: var(--bg-tertiary); border-radius: 6px; text-decoration: none; color: var(--text-primary);">
                Screenshots
            </a>
        </div>
    </div>
    '''

    # Sessions section
    content += '<div class="card"><h2>Recent Sessions</h2>'
    if sessions:
        content += '<ul class="list">'
        for s in sessions:
            status_class = "active" if s.get("status") == "active" else ""
            content += f'''<li>
                <a href="/session/{s['id']}">{_escape_html(s.get('title') or s['id'])}</a>
                <span class="badge {status_class}">{s.get('status', 'active')}</span>
                <div class="meta">ID: {s['id']} | Created: {s.get('created_at', 'Unknown')}</div>
            </li>'''
        content += '</ul>'
    else:
        content += '<p class="empty">No sessions yet. Create one via MCP tools.</p>'
    content += '</div>'

    # Standalone rooms section
    if rooms_without_session:
        content += '<div class="card"><h2>Standalone Chat Rooms</h2><ul class="list">'
        for r in rooms_without_session:
            content += f'''<li>
                <a href="/room/{r['id']}">{_escape_html(r['name'])}</a>
                <div class="meta">{_escape_html(r.get('description') or 'No description')}</div>
            </li>'''
        content += '</ul></div>'

    return _base_html("Home", content)


def _render_session(session: dict) -> str:
    """Render session detail page."""
    content = f'''
    <div class="breadcrumb"><a href="/">Home</a> / Session</div>
    <div class="card">
        <h2>{_escape_html(session.get('title') or session['session_id'])}</h2>
        <div class="meta">
            <span class="badge">{session.get('status', 'active')}</span>
            ID: {session['session_id']} | Created: {session.get('created_at', 'Unknown')}
        </div>
    </div>
    '''

    # Chat rooms
    content += '<div class="card"><h3>Chat Rooms</h3>'
    rooms = session.get('chat_rooms', [])
    if rooms:
        content += '<ul class="list">'
        for r in rooms:
            content += f'''<li>
                <a href="/session/{session['session_id']}/room/{r['id']}">{_escape_html(r['name'])}</a>
                <div class="meta">{_escape_html(r.get('description') or 'No description')}</div>
            </li>'''
        content += '</ul>'
    else:
        content += '<p class="empty">No chat rooms in this session.</p>'
    content += '</div>'

    # Artifacts
    content += '<div class="card"><h3>Artifacts</h3>'
    artifacts = session.get('artifacts', [])
    if artifacts:
        content += '<ul class="list">'
        for a in artifacts:
            content += f'''<li>
                {_escape_html(a['name'])}
                <span class="badge">{a.get('artifact_type', 'unknown')}</span>
                <div class="meta">Created: {a.get('created_at', 'Unknown')}</div>
            </li>'''
        content += '</ul>'
    else:
        content += '<p class="empty">No artifacts in this session.</p>'
    content += '</div>'

    return _base_html(session.get('title') or session['session_id'], content)


def _render_chat_room(room: dict, events: list, session_id: str = None) -> str:
    """Render chat room page."""
    if session_id:
        breadcrumb = f'<a href="/">Home</a> / <a href="/session/{session_id}">Session</a> / Chat Room'
        form_action = f"/session/{session_id}/room/{room['id']}/message"
    else:
        breadcrumb = f'<a href="/">Home</a> / Chat Room'
        form_action = f"/room/{room['id']}/message"

    content = f'''
    <div class="breadcrumb">{breadcrumb}</div>
    <div class="card">
        <h2>{_escape_html(room['name'])}</h2>
        <div class="meta">{_escape_html(room.get('description') or 'No description')}</div>
    </div>
    <div class="card">
        <h3>Messages</h3>
    '''

    if events:
        for e in events:
            event_type = e.get('event_type', 'message')
            data = e.get('data', {}) or {}
            timestamp = e.get('timestamp', '') or e.get('created_at', '')
            persona = e.get('persona', 'Unknown')

            if event_type == 'message':
                content += f'''<div class="message">
                    <span class="author">{_escape_html(persona)}</span>
                    <span class="time">{timestamp}</span>
                    <div class="content">{_escape_html(data.get('message', ''))}</div>
                </div>'''
            elif event_type in ('todo', 'todo_create'):
                content += f'''<div class="message">
                    <span class="author">{_escape_html(persona)}</span>
                    <span class="time">{timestamp}</span>
                    <div class="content">📋 {_escape_html(data.get('description', ''))}</div>
                </div>'''
            elif event_type == 'emoji_reaction':
                emoji = data.get('emoji', '❓')
                content += f'''<div class="message" style="padding: 8px;">
                    <span class="author">{_escape_html(persona)}</span>
                    <span class="time">{timestamp}</span>
                    <span style="font-size: 1.2em; margin-left: 10px;">{emoji}</span>
                </div>'''
            elif event_type == 'persona_join':
                content += f'''<div class="message" style="padding: 8px; opacity: 0.7;">
                    <span class="author">{_escape_html(persona)}</span>
                    <span class="time">{timestamp}</span>
                    <span style="margin-left: 10px;">joined the room</span>
                </div>'''
            elif event_type == 'artifact_share':
                artifact_id = data.get('artifact_id', '?')
                content += f'''<div class="message" style="padding: 8px;">
                    <span class="author">{_escape_html(persona)}</span>
                    <span class="time">{timestamp}</span>
                    <span style="margin-left: 10px;">📎 shared <a href="/artifact/{artifact_id}" style="color: var(--accent);">artifact #{artifact_id}</a></span>
                </div>'''
    else:
        content += '<p class="empty">No messages yet.</p>'

    content += f'''
    </div>
    <div class="card">
        <h3>Send Message</h3>
        <form method="POST" action="{form_action}">
            <input type="text" name="persona" placeholder="Your name" value="human-operator">
            <textarea name="message" placeholder="Type your message..." rows="3"></textarea>
            <button type="submit">Send</button>
        </form>
    </div>
    '''

    return _base_html(room['name'], content)


def _render_artifact(artifact: dict) -> str:
    """Render artifact detail page."""
    import base64

    name = artifact.get('artifact_name') or artifact.get('name', 'Unknown')
    artifact_type = artifact.get('artifact_type') or artifact.get('type', 'unknown')
    created_at = artifact.get('created_at', 'Unknown')
    revision_num = artifact.get('revision_num', 1)
    purpose = artifact.get('purpose', '')
    file_content_base64 = artifact.get('file_content') or artifact.get('file_content_base64', '')
    file_path = artifact.get('file_path', '')
    # Extract filename from path or use artifact name
    filename = file_path.split('/')[-1] if file_path else f"{name}.txt"

    content = f'''
    <div class="breadcrumb"><a href="/">Home</a> / Artifact</div>
    <div class="card">
        <h2>{_escape_html(name)}</h2>
        <div class="meta">
            <span class="badge">{artifact_type}</span>
            Revision {revision_num} | Created: {created_at}
        </div>
        {f'<p style="margin-top: 10px;">{_escape_html(purpose)}</p>' if purpose else ''}
    </div>
    '''

    # Display content based on type
    if file_content_base64:
        try:
            file_bytes = base64.b64decode(file_content_base64)

            # Check if it's text or binary
            if artifact_type in ('document', 'code', 'text') or filename.endswith(('.md', '.txt', '.py', '.js', '.ts', '.json', '.yaml', '.yml', '.xml', '.html', '.css')):
                try:
                    text_content = file_bytes.decode('utf-8')
                    # Determine language for syntax highlighting hint
                    lang = ''
                    if filename.endswith('.py'):
                        lang = 'python'
                    elif filename.endswith(('.js', '.ts')):
                        lang = 'javascript'
                    elif filename.endswith('.json'):
                        lang = 'json'
                    elif filename.endswith(('.yaml', '.yml')):
                        lang = 'yaml'
                    elif filename.endswith('.md'):
                        lang = 'markdown'

                    content += f'''
                    <div class="card">
                        <h3>Content: {_escape_html(filename)}</h3>
                        <pre style="background: var(--bg-tertiary); padding: 15px; border-radius: 6px; overflow-x: auto; white-space: pre-wrap; word-wrap: break-word;"><code>{_escape_html(text_content)}</code></pre>
                    </div>
                    '''
                except UnicodeDecodeError:
                    content += '''
                    <div class="card">
                        <p class="empty">Binary content - cannot display as text</p>
                    </div>
                    '''
            elif artifact_type in ('image', 'screenshot', 'screenshot_diff') or filename.lower().endswith(('.png', '.jpg', '.jpeg', '.gif', '.webp', '.svg')):
                # Determine MIME type
                mime = 'image/png'
                if filename.lower().endswith('.jpg') or filename.lower().endswith('.jpeg'):
                    mime = 'image/jpeg'
                elif filename.lower().endswith('.gif'):
                    mime = 'image/gif'
                elif filename.lower().endswith('.webp'):
                    mime = 'image/webp'
                elif filename.lower().endswith('.svg'):
                    mime = 'image/svg+xml'

                content += f'''
                <div class="card">
                    <h3>Preview: {_escape_html(filename)}</h3>
                    <img src="data:{mime};base64,{file_content_base64}" style="max-width: 100%; border-radius: 6px;" alt="{_escape_html(name)}">
                </div>
                '''
            else:
                content += f'''
                <div class="card">
                    <h3>File: {_escape_html(filename)}</h3>
                    <p class="empty">Binary content ({len(file_bytes)} bytes)</p>
                </div>
                '''
        except Exception as e:
            content += f'''
            <div class="card">
                <p class="empty">Error loading content: {_escape_html(str(e))}</p>
            </div>
            '''
    else:
        content += '''
        <div class="card">
            <p class="empty">No content available</p>
        </div>
        '''

    return _base_html(name, content)


def _render_404(message: str) -> str:
    """Render 404 page."""
    return _base_html("Not Found", f'<div class="card"><p class="empty">{_escape_html(message)}</p></div>')


def _render_comparison_view(artifact: dict, related: list) -> str:
    """Render side-by-side comparison view for visual diff analysis."""
    import base64

    name = artifact.get('artifact_name') or artifact.get('name', 'Unknown')
    artifact_type = artifact.get('artifact_type') or artifact.get('type', 'unknown')
    purpose = artifact.get('purpose', '')
    file_content_base64 = artifact.get('file_content') or artifact.get('file_content_base64', '')

    content = f'''
    <div class="breadcrumb">
        <a href="/">Home</a> / <a href="/screenshots">Screenshots</a> / Compare
    </div>
    <style>
        .compare-container {{
            display: flex;
            flex-direction: column;
            gap: 20px;
        }}
        .compare-row {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 20px;
        }}
        .compare-panel {{
            background: var(--bg-secondary);
            border: 1px solid var(--border);
            border-radius: 8px;
            overflow: hidden;
        }}
        .compare-panel.baseline {{ border-top: 3px solid #3b82f6; }}
        .compare-panel.current {{ border-top: 3px solid #4ade80; }}
        .compare-panel.diff {{ border-top: 3px solid #f97316; }}
        .compare-header {{
            padding: 15px;
            background: var(--bg-tertiary);
            border-bottom: 1px solid var(--border);
        }}
        .compare-header h3 {{ margin: 0; font-size: 1rem; }}
        .compare-header .meta {{ font-size: 0.8rem; margin-top: 5px; }}
        .compare-image {{
            padding: 15px;
            text-align: center;
            background: repeating-conic-gradient(#333 0% 25%, #444 0% 50%) 50% / 20px 20px;
        }}
        .compare-image img {{
            max-width: 100%;
            border-radius: 4px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.3);
        }}
        .compare-controls {{
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }}
        .compare-controls button {{
            padding: 8px 16px;
            border: 1px solid var(--border);
            background: var(--bg-secondary);
            color: var(--text-primary);
            border-radius: 4px;
            cursor: pointer;
        }}
        .compare-controls button:hover {{ background: var(--bg-tertiary); }}
        .compare-controls button.active {{
            background: var(--accent);
            border-color: var(--accent);
        }}
        .slider-container {{
            position: relative;
            width: 100%;
            overflow: hidden;
            border-radius: 8px;
            display: none;
        }}
        .slider-container.active {{ display: block; }}
        .slider-overlay {{
            position: absolute;
            top: 0;
            left: 0;
            width: 50%;
            height: 100%;
            overflow: hidden;
            border-right: 2px solid #f97316;
        }}
        .slider-overlay img {{
            position: absolute;
            top: 0;
            left: 0;
        }}
        .slider-handle {{
            position: absolute;
            top: 0;
            width: 40px;
            height: 100%;
            left: calc(50% - 20px);
            cursor: ew-resize;
            display: flex;
            align-items: center;
            justify-content: center;
        }}
        .slider-handle::after {{
            content: "\\2194";
            background: #f97316;
            color: white;
            padding: 8px;
            border-radius: 50%;
            font-size: 1.2rem;
        }}
    </style>
    <div class="card">
        <h2>Visual Comparison: {_escape_html(name)}</h2>
        <div class="meta">
            <span class="badge">{artifact_type}</span>
            {f'<span style="margin-left: 10px;">{_escape_html(purpose)}</span>' if purpose else ''}
        </div>
    </div>

    <div class="card">
        <div class="compare-controls">
            <button class="active" onclick="showMode('sidebyside')">Side by Side</button>
            <button onclick="showMode('slider')">Slider</button>
            <button onclick="showMode('overlay')">Overlay</button>
        </div>

        <div id="sidebyside-view" class="compare-container">
            <div class="compare-row">
    '''

    # Add related images (baseline, comparison)
    for i, rel in enumerate(related[:2]):
        panel_type = 'baseline' if i == 0 else 'current'
        rel_name = rel.get('name', 'Related')
        rel_content = rel.get('file_content', '')
        rel_id = rel.get('id')

        if rel_content:
            content += f'''
                <div class="compare-panel {panel_type}">
                    <div class="compare-header">
                        <h3>{panel_type.title()}: {_escape_html(rel_name)}</h3>
                        <div class="meta"><a href="/artifact/{rel_id}">View Details</a></div>
                    </div>
                    <div class="compare-image">
                        <img src="data:image/png;base64,{rel_content}" alt="{_escape_html(rel_name)}">
                    </div>
                </div>
            '''

    # Add the diff image
    if file_content_base64:
        content += f'''
                <div class="compare-panel diff">
                    <div class="compare-header">
                        <h3>Diff: {_escape_html(name)}</h3>
                        <div class="meta">Highlighted differences</div>
                    </div>
                    <div class="compare-image">
                        <img src="data:image/png;base64,{file_content_base64}" alt="Diff">
                    </div>
                </div>
            </div>
        </div>
        '''
    else:
        content += '</div></div>'

    # Add slider view (hidden by default)
    if len(related) >= 2:
        baseline_content = related[0].get('file_content', '')
        current_content = related[1].get('file_content', '')
        if baseline_content and current_content:
            content += f'''
        <div id="slider-view" class="slider-container">
            <img src="data:image/png;base64,{current_content}" style="width:100%;" alt="Current">
            <div class="slider-overlay" id="slider-overlay">
                <img src="data:image/png;base64,{baseline_content}" alt="Baseline">
            </div>
            <div class="slider-handle" id="slider-handle"></div>
        </div>
            '''

    content += '''
    </div>

    <script>
        function showMode(mode) {
            document.querySelectorAll('.compare-controls button').forEach(b => b.classList.remove('active'));
            event.target.classList.add('active');

            document.getElementById('sidebyside-view').style.display = mode === 'sidebyside' ? 'flex' : 'none';
            const slider = document.getElementById('slider-view');
            if (slider) slider.classList.toggle('active', mode === 'slider');
        }

        // Slider interaction
        const handle = document.getElementById('slider-handle');
        const overlay = document.getElementById('slider-overlay');
        if (handle && overlay) {
            let dragging = false;
            handle.addEventListener('mousedown', () => dragging = true);
            document.addEventListener('mouseup', () => dragging = false);
            document.addEventListener('mousemove', (e) => {
                if (!dragging) return;
                const container = handle.parentElement;
                const rect = container.getBoundingClientRect();
                const x = Math.max(0, Math.min(e.clientX - rect.left, rect.width));
                const percent = (x / rect.width) * 100;
                overlay.style.width = percent + '%';
                handle.style.left = 'calc(' + percent + '% - 20px)';
            });
        }
    </script>
    '''

    return _base_html(f"Compare: {name}", content)


def _render_screenshots_gallery(screenshots: list) -> str:
    """Render screenshots gallery page."""
    content = '''
    <div class="breadcrumb"><a href="/">Home</a> / Screenshots</div>
    <div class="card">
        <h2>Screenshots Gallery</h2>
        <p class="meta">Visual artifacts captured by browser automation</p>
    </div>
    '''

    if screenshots:
        content += '''
        <style>
            .gallery { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; }
            .gallery-item {
                background: var(--bg-secondary);
                border: 1px solid var(--border);
                border-radius: 8px;
                overflow: hidden;
                transition: transform 0.2s;
            }
            .gallery-item:hover { transform: scale(1.02); }
            .gallery-item a { text-decoration: none; color: inherit; }
            .gallery-thumb {
                width: 100%;
                height: 200px;
                object-fit: cover;
                background: var(--bg-tertiary);
            }
            .gallery-info { padding: 15px; }
            .gallery-info h4 { margin: 0 0 8px 0; color: var(--text-primary); }
            .gallery-info .meta { font-size: 0.8rem; }
            .type-screenshot { border-left: 3px solid #4ade80; }
            .type-screenshot_diff { border-left: 3px solid #f97316; }
            .type-image { border-left: 3px solid #3b82f6; }
        </style>
        <div class="gallery">
        '''

        for s in screenshots:
            artifact_id = s['id']
            name = s.get('name', 'Unknown')
            artifact_type = s.get('artifact_type', 'screenshot')
            created_at = s.get('created_at', 'Unknown')
            purpose = s.get('purpose', '')

            type_class = f"type-{artifact_type}"
            type_label = artifact_type.replace('_', ' ').title()

            compare_link = f'<a href="/compare/{artifact_id}" style="font-size: 0.8rem; color: var(--accent);">Compare View</a>' if artifact_type == 'screenshot_diff' else ''

            content += f'''
            <div class="gallery-item {type_class}">
                <a href="/artifact/{artifact_id}">
                    <div class="gallery-thumb" style="display: flex; align-items: center; justify-content: center;">
                        <span style="font-size: 3rem; opacity: 0.5;">{'📸' if artifact_type == 'screenshot' else '🔄' if artifact_type == 'screenshot_diff' else '🖼️'}</span>
                    </div>
                    <div class="gallery-info">
                        <h4>{_escape_html(name)}</h4>
                        <span class="badge">{type_label}</span>
                        {compare_link}
                        <div class="meta">{created_at}</div>
                        {f'<div class="meta" style="margin-top: 5px;">{_escape_html(purpose[:80])}...</div>' if purpose and len(purpose) > 80 else f'<div class="meta" style="margin-top: 5px;">{_escape_html(purpose)}</div>' if purpose else ''}
                    </div>
                </a>
            </div>
            '''

        content += '</div>'
    else:
        content += '<div class="card"><p class="empty">No screenshots captured yet. Use browser tools to capture screenshots.</p></div>'

    return _base_html("Screenshots Gallery", content)


def _render_task_queues_list(queues: list) -> str:
    """Render task queues list page."""
    content = '''
    <div class="breadcrumb">
        <a href="/">Home</a> / Task Queues
    </div>
    <div class="card">
        <h2>Task Queues</h2>
        <p class="meta">Manage work items and track progress</p>
    </div>
    '''

    if queues:
        content += '<div class="list">'
        for q in queues:
            queue_id = q['id']
            name = q.get('name', 'Unnamed Queue')
            description = q.get('description', '')
            task_count = q.get('task_count', 0)
            pending_count = q.get('pending_count', 0)
            in_progress_count = q.get('in_progress_count', 0)
            status = q.get('status', 'active')
            updated_at = q.get('updated_at', '')

            status_badge = f'<span class="badge {"active" if status == "active" else ""}">{status}</span>'

            content += f'''
            <li>
                <a href="/tasks/{queue_id}">
                    <strong>{_escape_html(name)}</strong>
                    {status_badge}
                </a>
                <div class="meta">
                    {_escape_html(description) if description else "No description"}
                </div>
                <div class="meta">
                    {task_count} tasks ({pending_count} pending, {in_progress_count} in progress)
                    {f" - Updated: {updated_at[:16].replace('T', ' ')}" if updated_at else ""}
                </div>
            </li>
            '''
        content += '</div>'
    else:
        content += '<div class="card"><p class="empty">No task queues yet. Create one using the MCP tools.</p></div>'

    return _base_html("Task Queues", content)


def _render_task_queue_detail(queue: dict, tasks: list) -> str:
    """Render task queue detail page with tasks."""
    queue_id = queue['id']
    name = queue.get('name', 'Unnamed Queue')
    description = queue.get('description', '')
    status = queue.get('status', 'active')
    task_counts = queue.get('task_counts', {})

    content = f'''
    <div class="breadcrumb">
        <a href="/">Home</a> / <a href="/tasks">Task Queues</a> / {_escape_html(name)}
    </div>
    <div class="card">
        <h2>{_escape_html(name)}</h2>
        <span class="badge {"active" if status == "active" else ""}">{status}</span>
        <p class="meta" style="margin-top: 10px;">{_escape_html(description) if description else "No description"}</p>
        <div class="meta" style="margin-top: 15px;">
            <strong>Tasks by status:</strong>
            {" | ".join(f"{s}: {c}" for s, c in task_counts.items()) if task_counts else "No tasks yet"}
        </div>
    </div>

    <style>
        .task-list {{ list-style: none; margin: 0; padding: 0; }}
        .task-item {{
            background: var(--bg-secondary);
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
        }}
        .task-item.status-pending {{ border-left: 4px solid #6b7280; }}
        .task-item.status-in_progress {{ border-left: 4px solid #3b82f6; }}
        .task-item.status-blocked {{ border-left: 4px solid #ef4444; }}
        .task-item.status-review {{ border-left: 4px solid #f59e0b; }}
        .task-item.status-done {{ border-left: 4px solid #22c55e; }}
        .task-header {{ display: flex; justify-content: space-between; align-items: flex-start; gap: 15px; }}
        .task-title {{ font-weight: bold; color: var(--text-primary); text-decoration: none; }}
        .task-title:hover {{ color: var(--accent); }}
        .task-meta {{ display: flex; gap: 10px; flex-wrap: wrap; margin-top: 10px; }}
        .priority-0 {{ color: #6b7280; }}
        .priority-1 {{ color: var(--text-secondary); }}
        .priority-2 {{ color: #f59e0b; }}
        .priority-3 {{ color: #ef4444; font-weight: bold; }}
        .complexity {{ font-size: 0.8rem; color: var(--text-secondary); }}
    </style>
    <div class="card">
        <h3>Tasks</h3>
    '''

    if tasks:
        content += '<ul class="task-list">'
        for t in tasks:
            task_id = t['id']
            title = t.get('title', 'Untitled')
            task_status = t.get('status', 'pending')
            priority = t.get('priority', 1)
            deadline = t.get('deadline', '')
            complexity = t.get('complexity')
            assigned_to = t.get('assigned_to', '')

            priority_labels = {0: 'Low', 1: 'Normal', 2: 'High', 3: 'Urgent'}
            status_labels = {'pending': 'Pending', 'in_progress': 'In Progress', 'blocked': 'Blocked', 'review': 'Review', 'done': 'Done'}

            content += f'''
            <li class="task-item status-{task_status}">
                <div class="task-header">
                    <a href="/tasks/{queue_id}/task/{task_id}" class="task-title">{_escape_html(title)}</a>
                    <span class="badge">{status_labels.get(task_status, task_status)}</span>
                </div>
                <div class="task-meta">
                    <span class="priority-{priority}">Priority: {priority_labels.get(priority, priority)}</span>
                    {f'<span class="complexity">Complexity: {complexity}/5</span>' if complexity else ''}
                    {f'<span>Deadline: {deadline[:10]}</span>' if deadline else ''}
                    {f'<span>Assigned: {_escape_html(assigned_to)}</span>' if assigned_to else ''}
                </div>
            </li>
            '''
        content += '</ul>'
    else:
        content += '<p class="empty">No tasks in this queue. Create one using the MCP tools.</p>'

    content += '</div>'

    # Real-time updates script
    content += f'''
    <script>
        // Connect to SSE for real-time updates
        const eventSource = new EventSource('/api/tasks/queues/{queue_id}/stream');
        eventSource.onmessage = function(e) {{
            console.log('Task update:', e.data);
            // Reload page on update (simple approach)
            location.reload();
        }};
        eventSource.onerror = function(e) {{
            console.log('SSE connection error, will retry...');
        }};
    </script>
    '''

    return _base_html(name, content)


def _render_task_detail(task: dict, feed: dict, queue_id: int) -> str:
    """Render task detail page with activity feed."""
    task_id = task['id']
    title = task.get('title', 'Untitled')
    description = task.get('description', '')
    acceptance_criteria = task.get('acceptance_criteria', '')
    status = task.get('status', 'pending')
    priority = task.get('priority', 1)
    deadline = task.get('deadline', '')
    complexity = task.get('complexity')
    complexity_notes = task.get('complexity_notes', '')
    assigned_to = task.get('assigned_to', '')
    created_by = task.get('created_by', '')
    created_at = task.get('created_at', '')
    artifacts = task.get('artifacts', [])
    events = feed.get('events', [])

    priority_labels = {0: 'Low', 1: 'Normal', 2: 'High', 3: 'Urgent'}
    status_labels = {
        'pending': ('Pending', '#6b7280'),
        'in_progress': ('In Progress', '#3b82f6'),
        'blocked': ('Blocked', '#ef4444'),
        'review': ('Review', '#f59e0b'),
        'done': ('Done', '#22c55e')
    }
    status_label, status_color = status_labels.get(status, ('Unknown', '#6b7280'))

    content = f'''
    <div class="breadcrumb">
        <a href="/">Home</a> / <a href="/tasks">Task Queues</a> / <a href="/tasks/{queue_id}">Queue {queue_id}</a> / Task
    </div>
    <style>
        .task-detail {{ display: grid; grid-template-columns: 2fr 1fr; gap: 20px; }}
        @media (max-width: 768px) {{ .task-detail {{ grid-template-columns: 1fr; }} }}
        .status-form {{ display: flex; gap: 10px; flex-wrap: wrap; align-items: center; margin-top: 15px; }}
        .status-form select, .status-form button {{
            padding: 8px 12px;
            border: 1px solid var(--border);
            border-radius: 4px;
            background: var(--bg-tertiary);
            color: var(--text-primary);
        }}
        .status-form button {{ cursor: pointer; background: var(--accent); border-color: var(--accent); }}
        .status-form button:hover {{ opacity: 0.9; }}
        .event-item {{ padding: 12px; border-left: 3px solid var(--border); margin-bottom: 10px; background: var(--bg-tertiary); border-radius: 0 6px 6px 0; }}
        .event-item.status_changed {{ border-left-color: #3b82f6; }}
        .event-item.task_created {{ border-left-color: #22c55e; }}
        .event-item.message {{ border-left-color: #8b5cf6; }}
        .event-item.artifact_added {{ border-left-color: #f59e0b; }}
        .event-item.complexity_assigned {{ border-left-color: #ec4899; }}
        .event-header {{ font-size: 0.85rem; color: var(--text-secondary); margin-bottom: 5px; }}
        .event-persona {{ color: var(--accent); font-weight: bold; }}
        .artifact-item {{ padding: 10px; background: var(--bg-tertiary); border-radius: 6px; margin-bottom: 8px; }}
        .message-form {{ margin-top: 20px; }}
        .message-form textarea {{ min-height: 80px; resize: vertical; }}
    </style>

    <div class="card">
        <h2>{_escape_html(title)}</h2>
        <div style="margin-top: 10px;">
            <span class="badge" style="background: {status_color}; color: white;">{status_label}</span>
            <span class="badge priority-{priority}" style="margin-left: 8px;">{priority_labels.get(priority, priority)} Priority</span>
            {f'<span class="badge" style="margin-left: 8px;">Complexity: {complexity}/5</span>' if complexity else ''}
        </div>

        <form method="post" action="/tasks/{queue_id}/task/{task_id}/status" class="status-form">
            <label>Update status:</label>
            <select name="status">
                <option value="pending" {"selected" if status == "pending" else ""}>Pending</option>
                <option value="in_progress" {"selected" if status == "in_progress" else ""}>In Progress</option>
                <option value="blocked" {"selected" if status == "blocked" else ""}>Blocked</option>
                <option value="review" {"selected" if status == "review" else ""}>Review</option>
                <option value="done" {"selected" if status == "done" else ""}>Done (Human Only)</option>
            </select>
            <input type="hidden" name="persona" value="human-operator">
            <button type="submit">Update</button>
        </form>
    </div>

    <div class="task-detail">
        <div class="main-content">
            <div class="card">
                <h3>Description</h3>
                <p style="white-space: pre-wrap;">{_escape_html(description) if description else '<span class="empty">No description provided</span>'}</p>
            </div>

            <div class="card">
                <h3>Acceptance Criteria</h3>
                <p style="white-space: pre-wrap;">{_escape_html(acceptance_criteria) if acceptance_criteria else '<span class="empty">No acceptance criteria defined</span>'}</p>
            </div>

            <div class="card">
                <h3>Activity Feed</h3>
    '''

    if events:
        for e in events:
            event_type = e.get('event_type', 'unknown')
            persona = e.get('persona', '')
            event_data = e.get('data', {})
            created_at_event = e.get('created_at', '')[:16].replace('T', ' ')

            if event_type == 'message':
                message_text = event_data.get('message', '')
                content += f'''
                <div class="event-item {event_type}">
                    <div class="event-header">
                        <span class="event-persona">{_escape_html(persona)}</span> posted a message - {created_at_event}
                    </div>
                    <p style="white-space: pre-wrap;">{_escape_html(message_text)}</p>
                </div>
                '''
            elif event_type == 'status_changed':
                old_status = event_data.get('old_status', '')
                new_status = event_data.get('new_status', '')
                notes = event_data.get('notes', '')
                content += f'''
                <div class="event-item {event_type}">
                    <div class="event-header">
                        <span class="event-persona">{_escape_html(persona) if persona else "System"}</span> changed status
                        from <strong>{old_status}</strong> to <strong>{new_status}</strong> - {created_at_event}
                    </div>
                    {f'<p>{_escape_html(notes)}</p>' if notes else ''}
                </div>
                '''
            elif event_type == 'task_created':
                content += f'''
                <div class="event-item {event_type}">
                    <div class="event-header">
                        <span class="event-persona">{_escape_html(persona) if persona else "System"}</span> created this task - {created_at_event}
                    </div>
                </div>
                '''
            elif event_type == 'artifact_added':
                artifact_type = event_data.get('artifact_type', '')
                git_branch = event_data.get('git_branch', '')
                desc = event_data.get('description', '')
                content += f'''
                <div class="event-item {event_type}">
                    <div class="event-header">
                        <span class="event-persona">{_escape_html(persona) if persona else "System"}</span> added an artifact - {created_at_event}
                    </div>
                    <p>Type: {_escape_html(artifact_type)} {f"(Branch: {_escape_html(git_branch)})" if git_branch else ""}</p>
                    {f'<p>{_escape_html(desc)}</p>' if desc else ''}
                </div>
                '''
            elif event_type == 'complexity_assigned':
                cx = event_data.get('complexity', '')
                notes = event_data.get('notes', '')
                content += f'''
                <div class="event-item {event_type}">
                    <div class="event-header">
                        <span class="event-persona">{_escape_html(persona) if persona else "System"}</span> assigned complexity: {cx}/5 - {created_at_event}
                    </div>
                    {f'<p>{_escape_html(notes)}</p>' if notes else ''}
                </div>
                '''
            else:
                content += f'''
                <div class="event-item">
                    <div class="event-header">
                        <span class="event-persona">{_escape_html(persona) if persona else "System"}</span> - {event_type} - {created_at_event}
                    </div>
                </div>
                '''
    else:
        content += '<p class="empty">No activity yet</p>'

    content += f'''
            </div>

            <div class="card message-form">
                <h3>Add Message</h3>
                <form method="post" action="/tasks/{queue_id}/task/{task_id}/message">
                    <input type="hidden" name="persona" value="human-operator">
                    <textarea name="message" placeholder="Ask a question or add an update..." required></textarea>
                    <button type="submit" style="margin-top: 10px; padding: 10px 20px; background: var(--accent); color: white; border: none; border-radius: 4px; cursor: pointer;">Post Message</button>
                </form>
            </div>
        </div>

        <div class="sidebar">
            <div class="card">
                <h3>Details</h3>
                <ul class="list" style="margin: 0;">
                    <li><strong>Created by:</strong> {_escape_html(created_by) if created_by else "Unknown"}</li>
                    <li><strong>Assigned to:</strong> {_escape_html(assigned_to) if assigned_to else "Unassigned"}</li>
                    <li><strong>Deadline:</strong> {deadline[:10] if deadline else "None"}</li>
                    <li><strong>Created:</strong> {created_at[:16].replace("T", " ") if created_at else "Unknown"}</li>
                    {f'<li><strong>Complexity Notes:</strong> {_escape_html(complexity_notes)}</li>' if complexity_notes else ''}
                </ul>
            </div>

            <div class="card">
                <h3>Linked Artifacts</h3>
    '''

    if artifacts:
        for a in artifacts:
            artifact_type = a.get('artifact_type', '')
            artifact_id = a.get('artifact_id')
            git_branch = a.get('git_branch', '')
            desc = a.get('description', '')
            content += f'''
            <div class="artifact-item">
                <strong>{_escape_html(artifact_type)}</strong>
                {f'<a href="/artifact/{artifact_id}"> (ID: {artifact_id})</a>' if artifact_id else ''}
                {f'<span style="color: var(--accent);">{_escape_html(git_branch)}</span>' if git_branch else ''}
                {f'<div class="meta">{_escape_html(desc)}</div>' if desc else ''}
            </div>
            '''
    else:
        content += '<p class="empty">No artifacts linked</p>'

    content += '''
            </div>
        </div>
    </div>

    <script>
        // Auto-refresh every 30 seconds
        setTimeout(function() { location.reload(); }, 30000);
    </script>
    '''

    return _base_html(title, content)


def main():
    """Entry point for unified server."""
    # Check singleton mode
    singleton = os.environ.get("NPL_MCP_SINGLETON", "false").lower() == "true"
    if singleton and not check_singleton():
        print(f"Use existing server at http://{HOST}:{PORT}", file=sys.stderr)
        sys.exit(0)

    # Build frontend if needed (can be disabled with NPL_MCP_SKIP_BUILD=true)
    skip_build = os.environ.get("NPL_MCP_SKIP_BUILD", "false").lower() == "true"
    if not skip_build:
        build_frontend(skip_if_exists=True)

    app = create_unified_app()

    uvicorn.run(
        app,
        host=HOST,
        port=PORT,
        log_level="info",
    )


if __name__ == "__main__":
    main()
