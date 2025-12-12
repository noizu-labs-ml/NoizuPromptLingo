"""Session lifecycle management."""

import secrets
import string
from datetime import datetime, timezone
from typing import Optional, Dict, List, Any
from ..storage.db import Database


def generate_session_id(length: int = 8) -> str:
    """Generate a short, URL-safe session ID.

    Args:
        length: Length of the ID (default: 8)

    Returns:
        Random alphanumeric string
    """
    alphabet = string.ascii_lowercase + string.digits
    return ''.join(secrets.choice(alphabet) for _ in range(length))


class SessionManager:
    """Manages session lifecycle and grouping."""

    def __init__(self, db: Database):
        """Initialize session manager.

        Args:
            db: Database instance
        """
        self.db = db

    async def create_session(
        self,
        title: Optional[str] = None,
        session_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """Create a new session.

        Args:
            title: Optional human-readable title
            session_id: Optional custom session ID (auto-generated if not provided)

        Returns:
            Dict with session_id, title, created_at
        """
        if session_id is None:
            session_id = generate_session_id()

        # Ensure unique
        existing = await self.db.fetchone(
            "SELECT id FROM sessions WHERE id = ?",
            (session_id,)
        )
        if existing:
            # Generate a new one if collision
            session_id = generate_session_id(length=12)

        now = datetime.now(timezone.utc).isoformat()
        await self.db.execute(
            "INSERT INTO sessions (id, title, created_at, updated_at) VALUES (?, ?, ?, ?)",
            (session_id, title, now, now)
        )

        return {
            "session_id": session_id,
            "title": title,
            "created_at": now,
            "status": "active"
        }

    async def get_session(self, session_id: str) -> Optional[Dict[str, Any]]:
        """Get session by ID.

        Args:
            session_id: Session ID

        Returns:
            Session dict or None if not found
        """
        row = await self.db.fetchone(
            "SELECT * FROM sessions WHERE id = ?",
            (session_id,)
        )
        if not row:
            return None
        return dict(row)

    async def list_sessions(
        self,
        status: Optional[str] = None,
        limit: int = 50
    ) -> List[Dict[str, Any]]:
        """List sessions ordered by most recent activity.

        Args:
            status: Optional status filter ('active', 'archived')
            limit: Maximum number of sessions to return

        Returns:
            List of session dicts with summary info
        """
        if status:
            rows = await self.db.fetchall(
                """
                SELECT s.*,
                    (SELECT COUNT(*) FROM chat_rooms WHERE session_id = s.id) as room_count,
                    (SELECT COUNT(*) FROM artifacts WHERE session_id = s.id) as artifact_count
                FROM sessions s
                WHERE s.status = ?
                ORDER BY s.updated_at DESC
                LIMIT ?
                """,
                (status, limit)
            )
        else:
            rows = await self.db.fetchall(
                """
                SELECT s.*,
                    (SELECT COUNT(*) FROM chat_rooms WHERE session_id = s.id) as room_count,
                    (SELECT COUNT(*) FROM artifacts WHERE session_id = s.id) as artifact_count
                FROM sessions s
                ORDER BY s.updated_at DESC
                LIMIT ?
                """,
                (limit,)
            )

        return [dict(row) for row in rows]

    async def update_session(
        self,
        session_id: str,
        title: Optional[str] = None,
        status: Optional[str] = None
    ) -> Dict[str, Any]:
        """Update session metadata.

        Args:
            session_id: Session ID
            title: New title (if provided)
            status: New status (if provided)

        Returns:
            Updated session dict

        Raises:
            ValueError: If session not found
        """
        session = await self.get_session(session_id)
        if not session:
            raise ValueError(f"Session '{session_id}' not found")

        updates = []
        params = []

        if title is not None:
            updates.append("title = ?")
            params.append(title)

        if status is not None:
            updates.append("status = ?")
            params.append(status)

        if updates:
            updates.append("updated_at = ?")
            params.append(datetime.now(timezone.utc).isoformat())
            params.append(session_id)

            await self.db.execute(
                f"UPDATE sessions SET {', '.join(updates)} WHERE id = ?",
                tuple(params)
            )

        return await self.get_session(session_id)

    async def touch_session(self, session_id: str):
        """Update session's updated_at timestamp.

        Args:
            session_id: Session ID
        """
        await self.db.execute(
            "UPDATE sessions SET updated_at = ? WHERE id = ?",
            (datetime.now(timezone.utc).isoformat(), session_id)
        )

    async def get_or_create_session(
        self,
        session_id: Optional[str] = None,
        title: Optional[str] = None
    ) -> Dict[str, Any]:
        """Get existing session or create new one.

        Args:
            session_id: Optional session ID to look up
            title: Title to use if creating new session

        Returns:
            Session dict with session_id key (existing or newly created)
        """
        if session_id:
            session = await self.get_session(session_id)
            if session:
                # Normalize key name from 'id' to 'session_id' for consistency
                return {
                    "session_id": session["id"],
                    "title": session["title"],
                    "status": session["status"],
                    "created_at": session["created_at"],
                    "updated_at": session["updated_at"]
                }

        return await self.create_session(title=title, session_id=session_id)

    async def get_session_contents(self, session_id: str) -> Dict[str, Any]:
        """Get all contents of a session.

        Args:
            session_id: Session ID

        Returns:
            Dict with session info, chat_rooms, and artifacts
        """
        session = await self.get_session(session_id)
        if not session:
            raise ValueError(f"Session '{session_id}' not found")

        # Get chat rooms
        rooms = await self.db.fetchall(
            """
            SELECT cr.*,
                (SELECT COUNT(*) FROM chat_events WHERE room_id = cr.id) as event_count,
                (SELECT COUNT(*) FROM room_members WHERE room_id = cr.id) as member_count
            FROM chat_rooms cr
            WHERE cr.session_id = ?
            ORDER BY cr.created_at DESC
            """,
            (session_id,)
        )

        # Get artifacts
        artifacts = await self.db.fetchall(
            """
            SELECT a.*,
                (SELECT COUNT(*) FROM revisions WHERE artifact_id = a.id) as revision_count
            FROM artifacts a
            WHERE a.session_id = ?
            ORDER BY a.created_at DESC
            """,
            (session_id,)
        )

        return {
            "session": session,
            "chat_rooms": [dict(r) for r in rooms],
            "artifacts": [dict(a) for a in artifacts]
        }

    async def archive_session(self, session_id: str) -> Dict[str, Any]:
        """Archive a session.

        Args:
            session_id: Session ID

        Returns:
            Updated session dict
        """
        return await self.update_session(session_id, status="archived")

    async def associate_artifact(self, session_id: str, artifact_id: int):
        """Associate an artifact with a session.

        Args:
            session_id: Session ID to associate with
            artifact_id: ID of the artifact to associate
        """
        await self.db.execute(
            "UPDATE artifacts SET session_id = ? WHERE id = ?",
            (session_id, artifact_id)
        )
        await self.touch_session(session_id)
