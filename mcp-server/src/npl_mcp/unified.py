"""Unified HTTP server: MCP over HTTP + Web UI in one process.

This server:
1. Serves MCP protocol over HTTP/SSE at /mcp
2. Serves web UI at / and other routes
3. Can be configured to only start if not already running (singleton mode)
4. Shares a single database connection
"""

import asyncio
import os
import socket
import sys
from contextlib import asynccontextmanager
from pathlib import Path
from typing import Optional

import uvicorn
from fastapi import FastAPI
from starlette.routing import Mount

from .storage import Database
from .artifacts.manager import ArtifactManager
from .artifacts.reviews import ReviewManager
from .chat import ChatManager
from .sessions import SessionManager
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


def create_mcp_server() -> "FastMCP":
    """Create MCP server with all tools."""
    import base64
    from typing import List

    mcp = FastMCP("npl-mcp")

    # Script tools
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

    return mcp


def create_unified_app() -> FastAPI:
    """Create unified FastAPI app with MCP and Web UI."""
    global _db, _artifact_manager, _review_manager, _chat_manager, _session_manager

    @asynccontextmanager
    async def lifespan(app: FastAPI):
        global _db, _artifact_manager, _review_manager, _chat_manager, _session_manager

        # Initialize database
        _db = Database()
        await _db.connect()

        # Initialize managers
        _artifact_manager = ArtifactManager(_db)
        _review_manager = ReviewManager(_db)
        _chat_manager = ChatManager(_db)
        _session_manager = SessionManager(_db)

        # Store managers on app state for web routes to access
        app.state.db = _db
        app.state.session_manager = _session_manager
        app.state.chat_manager = _chat_manager
        app.state.artifact_manager = _artifact_manager

        write_pid_file()
        print(f"NPL MCP Server running at http://{HOST}:{PORT}", file=sys.stderr)
        print(f"  Web UI: http://{HOST}:{PORT}/", file=sys.stderr)
        print(f"  MCP endpoint: http://{HOST}:{PORT}/mcp", file=sys.stderr)

        yield

        remove_pid_file()
        await _db.disconnect()

    # Create main FastAPI app
    app = FastAPI(
        title="NPL MCP Server",
        description="MCP + Web UI unified server",
        lifespan=lifespan
    )

    # Create and mount MCP HTTP app
    if FastMCP:
        mcp = create_mcp_server()
        mcp_app = mcp.http_app(path="/mcp")
        app.mount("/mcp", mcp_app)

    # Add web UI routes directly to main app
    # These use app.state to access db/managers after lifespan init
    from fastapi import Request
    from fastapi.responses import HTMLResponse, JSONResponse, RedirectResponse

    @app.get("/", response_class=HTMLResponse)
    async def index(request: Request):
        """Landing page with recent sessions."""
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
            elif artifact_type == 'image' or filename.lower().endswith(('.png', '.jpg', '.jpeg', '.gif', '.webp', '.svg')):
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


def main():
    """Entry point for unified server."""
    # Check singleton mode
    singleton = os.environ.get("NPL_MCP_SINGLETON", "false").lower() == "true"
    if singleton and not check_singleton():
        print(f"Use existing server at http://{HOST}:{PORT}", file=sys.stderr)
        sys.exit(0)

    app = create_unified_app()

    uvicorn.run(
        app,
        host=HOST,
        port=PORT,
        log_level="info",
    )


if __name__ == "__main__":
    main()
