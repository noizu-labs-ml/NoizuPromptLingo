"""FastAPI web application for NPL MCP."""

import asyncio
import json
import os
from contextlib import asynccontextmanager
from datetime import datetime
from pathlib import Path
from typing import Optional

from fastapi import FastAPI, Request, Form, HTTPException
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles

from ..storage.db import Database
from ..sessions.manager import SessionManager
from ..chat.rooms import ChatManager
from ..artifacts.manager import ArtifactManager


# Templates directory
TEMPLATES_DIR = Path(__file__).parent / "templates"


def render_template(name: str, **context) -> str:
    """Simple template rendering with string substitution.

    Args:
        name: Template filename
        **context: Variables to substitute

    Returns:
        Rendered HTML string
    """
    template_path = TEMPLATES_DIR / name
    with open(template_path, 'r') as f:
        template = f.read()

    # Simple {{variable}} substitution
    for key, value in context.items():
        template = template.replace(f"{{{{{key}}}}}", str(value) if value is not None else "")

    return template


class WebServer:
    """Web server with shared database connection."""

    def __init__(self, db: Database):
        """Initialize web server.

        Args:
            db: Shared database instance
        """
        self.db = db
        self.session_manager = SessionManager(db)
        self.chat_manager = ChatManager(db)
        self.artifact_manager = ArtifactManager(db)
        self.app = self._create_app()

    def _create_app(self) -> FastAPI:
        """Create FastAPI application."""

        @asynccontextmanager
        async def lifespan(app: FastAPI):
            # DB already connected by parent
            yield

        app = FastAPI(
            title="NPL MCP Web Interface",
            description="Web interface for NPL MCP chat and artifacts",
            lifespan=lifespan
        )

        # Register routes
        self._register_routes(app)

        return app

    def _register_routes(self, app: FastAPI):
        """Register all routes."""

        @app.get("/", response_class=HTMLResponse)
        async def index():
            """Landing page with recent sessions."""
            sessions = await self.session_manager.list_sessions(limit=20)
            return self._render_index(sessions)

        @app.get("/session/{session_id}", response_class=HTMLResponse)
        async def session_detail(session_id: str):
            """Session detail page."""
            try:
                contents = await self.session_manager.get_session_contents(session_id)
                return self._render_session(contents)
            except ValueError as e:
                raise HTTPException(status_code=404, detail=str(e))

        @app.get("/session/{session_id}/room/{room_id}", response_class=HTMLResponse)
        async def chat_room(session_id: str, room_id: int):
            """Chat room view."""
            try:
                session = await self.session_manager.get_session(session_id)
                if not session:
                    raise HTTPException(status_code=404, detail="Session not found")

                # Get room info
                room = await self.db.fetchone(
                    "SELECT * FROM chat_rooms WHERE id = ?",
                    (room_id,)
                )
                if not room:
                    raise HTTPException(status_code=404, detail="Room not found")

                # Get members
                members = await self.db.fetchall(
                    "SELECT persona_slug FROM room_members WHERE room_id = ?",
                    (room_id,)
                )

                # Get chat feed
                events = await self.chat_manager.get_chat_feed(room_id, limit=100)

                return self._render_chat_room(session, dict(room), [m["persona_slug"] for m in members], events)
            except ValueError as e:
                raise HTTPException(status_code=404, detail=str(e))

        @app.post("/session/{session_id}/room/{room_id}/message")
        async def post_message(
            session_id: str,
            room_id: int,
            persona: str = Form(...),
            message: str = Form(...)
        ):
            """Post a message to a chat room."""
            try:
                await self.chat_manager.send_message(room_id, persona, message)
                await self.session_manager.touch_session(session_id)
                return RedirectResponse(
                    url=f"/session/{session_id}/room/{room_id}",
                    status_code=303
                )
            except ValueError as e:
                raise HTTPException(status_code=400, detail=str(e))

        @app.post("/session/{session_id}/room/{room_id}/todo")
        async def post_todo(
            session_id: str,
            room_id: int,
            persona: str = Form(...),
            description: str = Form(...),
            assigned_to: Optional[str] = Form(None)
        ):
            """Create a todo in a chat room."""
            try:
                await self.chat_manager.create_todo(
                    room_id, persona, description,
                    assigned_to if assigned_to else None
                )
                await self.session_manager.touch_session(session_id)
                return RedirectResponse(
                    url=f"/session/{session_id}/room/{room_id}",
                    status_code=303
                )
            except ValueError as e:
                raise HTTPException(status_code=400, detail=str(e))

        @app.get("/room/{room_id}", response_class=HTMLResponse)
        async def chat_room_standalone(room_id: int):
            """Chat room view without session context."""
            try:
                # Get room info
                room = await self.db.fetchone(
                    "SELECT * FROM chat_rooms WHERE id = ?",
                    (room_id,)
                )
                if not room:
                    raise HTTPException(status_code=404, detail="Room not found")

                room_dict = dict(room)

                # If room has session, redirect to session view
                if room_dict.get("session_id"):
                    return RedirectResponse(
                        url=f"/session/{room_dict['session_id']}/room/{room_id}",
                        status_code=302
                    )

                # Get members
                members = await self.db.fetchall(
                    "SELECT persona_slug FROM room_members WHERE room_id = ?",
                    (room_id,)
                )

                # Get chat feed
                events = await self.chat_manager.get_chat_feed(room_id, limit=100)

                return self._render_chat_room(None, room_dict, [m["persona_slug"] for m in members], events)
            except ValueError as e:
                raise HTTPException(status_code=404, detail=str(e))

        @app.post("/room/{room_id}/message")
        async def post_message_standalone(
            room_id: int,
            persona: str = Form(...),
            message: str = Form(...)
        ):
            """Post a message to a chat room (standalone)."""
            try:
                await self.chat_manager.send_message(room_id, persona, message)
                return RedirectResponse(
                    url=f"/room/{room_id}",
                    status_code=303
                )
            except ValueError as e:
                raise HTTPException(status_code=400, detail=str(e))

        # API endpoints for AJAX/programmatic access
        @app.get("/api/sessions")
        async def api_list_sessions(status: Optional[str] = None, limit: int = 50):
            """API: List sessions."""
            return await self.session_manager.list_sessions(status=status, limit=limit)

        @app.get("/api/session/{session_id}")
        async def api_get_session(session_id: str):
            """API: Get session details."""
            try:
                return await self.session_manager.get_session_contents(session_id)
            except ValueError as e:
                raise HTTPException(status_code=404, detail=str(e))

        @app.get("/api/room/{room_id}/feed")
        async def api_chat_feed(room_id: int, since: Optional[str] = None, limit: int = 50):
            """API: Get chat feed."""
            try:
                return await self.chat_manager.get_chat_feed(room_id, since=since, limit=limit)
            except ValueError as e:
                raise HTTPException(status_code=404, detail=str(e))

        @app.post("/api/room/{room_id}/message")
        async def api_post_message(room_id: int, persona: str, message: str):
            """API: Post message."""
            try:
                return await self.chat_manager.send_message(room_id, persona, message)
            except ValueError as e:
                raise HTTPException(status_code=400, detail=str(e))

    def _render_index(self, sessions: list) -> str:
        """Render landing page."""
        sessions_html = ""
        if sessions:
            for s in sessions:
                title = s.get("title") or f"Session {s['id']}"
                rooms = s.get("room_count", 0)
                artifacts = s.get("artifact_count", 0)
                updated = s.get("updated_at", "")[:16].replace("T", " ")
                sessions_html += f"""
                <tr>
                    <td><a href="/session/{s['id']}">{s['id']}</a></td>
                    <td>{title}</td>
                    <td>{rooms}</td>
                    <td>{artifacts}</td>
                    <td>{updated}</td>
                    <td><span class="status-{s.get('status', 'active')}">{s.get('status', 'active')}</span></td>
                </tr>
                """
        else:
            sessions_html = '<tr><td colspan="6" class="empty">No sessions yet</td></tr>'

        return self._base_html(
            title="NPL MCP Sessions",
            content=f"""
            <h1>NPL MCP Sessions</h1>
            <p class="subtitle">Chat rooms, artifacts, and collaborative sessions</p>

            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Title</th>
                        <th>Rooms</th>
                        <th>Artifacts</th>
                        <th>Last Activity</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    {sessions_html}
                </tbody>
            </table>
            """
        )

    def _render_session(self, contents: dict) -> str:
        """Render session detail page."""
        session = contents["session"]
        rooms = contents["chat_rooms"]
        artifacts = contents["artifacts"]

        title = session.get("title") or f"Session {session['id']}"

        rooms_html = ""
        if rooms:
            for r in rooms:
                members = r.get("member_count", 0)
                events = r.get("event_count", 0)
                rooms_html += f"""
                <div class="card">
                    <h3><a href="/session/{session['id']}/room/{r['id']}">{r['name']}</a></h3>
                    <p>{r.get('description') or 'No description'}</p>
                    <div class="meta">{members} members · {events} events</div>
                </div>
                """
        else:
            rooms_html = '<p class="empty">No chat rooms in this session</p>'

        artifacts_html = ""
        if artifacts:
            for a in artifacts:
                revisions = a.get("revision_count", 0)
                artifacts_html += f"""
                <div class="card">
                    <h3>{a['name']}</h3>
                    <p>Type: {a['type']}</p>
                    <div class="meta">{revisions} revisions</div>
                </div>
                """
        else:
            artifacts_html = '<p class="empty">No artifacts in this session</p>'

        return self._base_html(
            title=title,
            content=f"""
            <nav class="breadcrumb">
                <a href="/">Sessions</a> / <span>{session['id']}</span>
            </nav>

            <h1>{title}</h1>
            <p class="meta">Created: {session['created_at'][:16].replace('T', ' ')} · Status: {session.get('status', 'active')}</p>

            <section>
                <h2>Chat Rooms</h2>
                <div class="card-grid">
                    {rooms_html}
                </div>
            </section>

            <section>
                <h2>Artifacts</h2>
                <div class="card-grid">
                    {artifacts_html}
                </div>
            </section>
            """
        )

    def _render_chat_room(self, session: Optional[dict], room: dict, members: list, events: list) -> str:
        """Render chat room page."""
        session_id = session["id"] if session else None
        session_title = (session.get("title") or f"Session {session['id']}") if session else None

        # Build breadcrumb
        if session:
            breadcrumb = f'<a href="/">Sessions</a> / <a href="/session/{session_id}">{session_id}</a> / <span>{room["name"]}</span>'
            form_action = f"/session/{session_id}/room/{room['id']}/message"
            todo_action = f"/session/{session_id}/room/{room['id']}/todo"
        else:
            breadcrumb = f'<a href="/">Home</a> / <span>{room["name"]}</span>'
            form_action = f"/room/{room['id']}/message"
            todo_action = f"/room/{room['id']}/todo"  # Not available without session

        # Build messages
        messages_html = ""
        for event in events:
            data = event.get("data", {})
            event_type = event.get("event_type", "")
            persona = event.get("persona", "")
            timestamp = event.get("timestamp", "")[:16].replace("T", " ")

            if event_type == "message":
                msg = data.get("message", "")
                messages_html += f"""
                <div class="message">
                    <div class="message-header">
                        <span class="persona">{persona}</span>
                        <span class="timestamp">{timestamp}</span>
                    </div>
                    <div class="message-body">{self._escape_html(msg)}</div>
                </div>
                """
            elif event_type == "persona_join":
                messages_html += f"""
                <div class="event system">
                    <span class="persona">{persona}</span> joined · {timestamp}
                </div>
                """
            elif event_type == "todo_create":
                desc = data.get("description", "")
                assigned = data.get("assigned_to", "")
                assign_text = f" (assigned to {assigned})" if assigned else ""
                messages_html += f"""
                <div class="event todo">
                    <span class="persona">{persona}</span> created todo: {self._escape_html(desc)}{assign_text} · {timestamp}
                </div>
                """
            elif event_type == "artifact_share":
                artifact_id = data.get("artifact_id", "")
                messages_html += f"""
                <div class="event artifact">
                    <span class="persona">{persona}</span> shared artifact #{artifact_id} · {timestamp}
                </div>
                """
            elif event_type == "emoji_reaction":
                emoji = data.get("emoji", "")
                messages_html += f"""
                <div class="event reaction">
                    <span class="persona">{persona}</span> reacted with {emoji} · {timestamp}
                </div>
                """

        if not messages_html:
            messages_html = '<p class="empty">No messages yet</p>'

        # Member select options
        member_options = "".join(f'<option value="{m}">{m}</option>' for m in members)

        return self._base_html(
            title=f"{room['name']} - Chat",
            content=f"""
            <nav class="breadcrumb">{breadcrumb}</nav>

            <div class="chat-header">
                <h1>{room['name']}</h1>
                <p class="meta">{room.get('description') or 'No description'}</p>
                <p class="members">Members: {', '.join(members)}</p>
            </div>

            <div class="chat-feed" id="chat-feed">
                {messages_html}
            </div>

            <div class="chat-input">
                <form method="post" action="{form_action}">
                    <div class="form-row">
                        <label for="persona">As:</label>
                        <select name="persona" id="persona" required>
                            {member_options}
                        </select>
                    </div>
                    <div class="form-row">
                        <input type="text" name="message" placeholder="Type a message..." required autofocus>
                        <button type="submit">Send</button>
                    </div>
                </form>
            </div>

            <details class="todo-form">
                <summary>Create Todo</summary>
                <form method="post" action="{todo_action}">
                    <div class="form-row">
                        <label for="todo-persona">As:</label>
                        <select name="persona" id="todo-persona" required>
                            {member_options}
                        </select>
                    </div>
                    <div class="form-row">
                        <input type="text" name="description" placeholder="Todo description..." required>
                    </div>
                    <div class="form-row">
                        <label for="assigned_to">Assign to:</label>
                        <select name="assigned_to" id="assigned_to">
                            <option value="">Unassigned</option>
                            {member_options}
                        </select>
                    </div>
                    <button type="submit">Create Todo</button>
                </form>
            </details>

            <script>
                // Auto-scroll to bottom
                const feed = document.getElementById('chat-feed');
                feed.scrollTop = feed.scrollHeight;
            </script>
            """
        )

    def _escape_html(self, text: str) -> str:
        """Escape HTML special characters."""
        return (text
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace('"', "&quot;")
            .replace("'", "&#39;")
            .replace("\n", "<br>"))

    def _base_html(self, title: str, content: str) -> str:
        """Base HTML template."""
        return f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title}</title>
    <style>
        :root {{
            --bg: #1a1a2e;
            --bg-light: #16213e;
            --fg: #eee;
            --fg-muted: #888;
            --accent: #4f8cff;
            --accent-hover: #3d7ce8;
            --success: #4caf50;
            --border: #333;
        }}

        * {{
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }}

        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: var(--bg);
            color: var(--fg);
            line-height: 1.6;
            min-height: 100vh;
        }}

        .container {{
            max-width: 1000px;
            margin: 0 auto;
            padding: 2rem;
        }}

        h1 {{
            margin-bottom: 0.5rem;
        }}

        h2 {{
            margin: 2rem 0 1rem;
            border-bottom: 1px solid var(--border);
            padding-bottom: 0.5rem;
        }}

        .subtitle, .meta {{
            color: var(--fg-muted);
            margin-bottom: 1.5rem;
        }}

        a {{
            color: var(--accent);
            text-decoration: none;
        }}

        a:hover {{
            text-decoration: underline;
        }}

        .breadcrumb {{
            margin-bottom: 1.5rem;
            color: var(--fg-muted);
        }}

        .breadcrumb a {{
            color: var(--fg-muted);
        }}

        table {{
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
        }}

        th, td {{
            padding: 0.75rem;
            text-align: left;
            border-bottom: 1px solid var(--border);
        }}

        th {{
            background: var(--bg-light);
            font-weight: 600;
        }}

        tr:hover {{
            background: var(--bg-light);
        }}

        .empty {{
            text-align: center;
            color: var(--fg-muted);
            padding: 2rem;
        }}

        .status-active {{
            color: var(--success);
        }}

        .status-archived {{
            color: var(--fg-muted);
        }}

        .card-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 1rem;
        }}

        .card {{
            background: var(--bg-light);
            padding: 1rem;
            border-radius: 8px;
            border: 1px solid var(--border);
        }}

        .card h3 {{
            margin-bottom: 0.5rem;
        }}

        .card p {{
            color: var(--fg-muted);
            font-size: 0.9rem;
        }}

        .card .meta {{
            margin-top: 0.5rem;
            font-size: 0.8rem;
        }}

        /* Chat specific styles */
        .chat-header {{
            border-bottom: 1px solid var(--border);
            padding-bottom: 1rem;
            margin-bottom: 1rem;
        }}

        .chat-header .members {{
            color: var(--fg-muted);
            font-size: 0.9rem;
        }}

        .chat-feed {{
            height: 400px;
            overflow-y: auto;
            background: var(--bg-light);
            border-radius: 8px;
            padding: 1rem;
            margin-bottom: 1rem;
            border: 1px solid var(--border);
        }}

        .message {{
            margin-bottom: 1rem;
            padding: 0.75rem;
            background: var(--bg);
            border-radius: 8px;
        }}

        .message-header {{
            display: flex;
            justify-content: space-between;
            margin-bottom: 0.25rem;
        }}

        .message-header .persona {{
            font-weight: 600;
            color: var(--accent);
        }}

        .message-header .timestamp {{
            font-size: 0.8rem;
            color: var(--fg-muted);
        }}

        .message-body {{
            word-wrap: break-word;
        }}

        .event {{
            padding: 0.5rem;
            margin-bottom: 0.5rem;
            font-size: 0.9rem;
            color: var(--fg-muted);
            border-left: 3px solid var(--border);
            padding-left: 1rem;
        }}

        .event .persona {{
            color: var(--accent);
        }}

        .event.todo {{
            border-left-color: var(--success);
        }}

        .event.artifact {{
            border-left-color: #9c27b0;
        }}

        .chat-input form {{
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }}

        .form-row {{
            display: flex;
            gap: 0.5rem;
            align-items: center;
        }}

        .form-row label {{
            min-width: 60px;
        }}

        .form-row input[type="text"] {{
            flex: 1;
            padding: 0.75rem;
            border: 1px solid var(--border);
            border-radius: 4px;
            background: var(--bg-light);
            color: var(--fg);
            font-size: 1rem;
        }}

        select {{
            padding: 0.5rem;
            border: 1px solid var(--border);
            border-radius: 4px;
            background: var(--bg-light);
            color: var(--fg);
        }}

        button {{
            padding: 0.75rem 1.5rem;
            background: var(--accent);
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1rem;
        }}

        button:hover {{
            background: var(--accent-hover);
        }}

        details {{
            margin-top: 1rem;
            padding: 1rem;
            background: var(--bg-light);
            border-radius: 8px;
            border: 1px solid var(--border);
        }}

        summary {{
            cursor: pointer;
            font-weight: 600;
        }}

        details[open] summary {{
            margin-bottom: 1rem;
        }}

        details form {{
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }}
    </style>
</head>
<body>
    <div class="container">
        {content}
    </div>
</body>
</html>"""


def create_app(db: Database) -> FastAPI:
    """Create FastAPI app with shared database.

    Args:
        db: Database instance

    Returns:
        FastAPI application
    """
    server = WebServer(db)
    return server.app
