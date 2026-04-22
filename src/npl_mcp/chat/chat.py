"""Chat rooms and messages — PRD-007 MVP."""
from __future__ import annotations

from typing import Any

from npl_mcp.storage import get_pool


async def room_list(limit: int = 50) -> list[dict[str, Any]]:
    pool = await get_pool()
    rows = await pool.fetch(
        """
        SELECT r.id, r.name, r.description,
               COUNT(m.id) AS message_count,
               MAX(m.created_at) AS last_activity,
               r.created_at
        FROM npl_chat_rooms r
        LEFT JOIN npl_chat_messages m ON m.room_id = r.id
        GROUP BY r.id
        ORDER BY r.created_at DESC
        LIMIT $1
        """,
        limit,
    )
    return [_room_dto(r) for r in rows]


async def room_create(name: str, description: str = "") -> dict[str, Any]:
    pool = await get_pool()
    row = await pool.fetchrow(
        """
        INSERT INTO npl_chat_rooms (name, description, created_at)
        VALUES ($1, $2, NOW())
        RETURNING id, name, description, created_at
        """,
        name,
        description,
    )
    return _room_dto_bare(row)


async def room_get(room_id: int) -> dict[str, Any] | None:
    pool = await get_pool()
    row = await pool.fetchrow(
        """
        SELECT r.id, r.name, r.description,
               COUNT(m.id) AS message_count,
               MAX(m.created_at) AS last_activity,
               r.created_at
        FROM npl_chat_rooms r
        LEFT JOIN npl_chat_messages m ON m.room_id = r.id
        WHERE r.id = $1
        GROUP BY r.id
        """,
        room_id,
    )
    if row is None:
        return None
    return _room_dto(row)


async def message_list(
    room_id: int, limit: int = 50, before_id: int | None = None
) -> list[dict[str, Any]]:
    pool = await get_pool()
    if before_id is not None:
        rows = await pool.fetch(
            """
            SELECT id, room_id, content, author, created_at
            FROM npl_chat_messages
            WHERE room_id = $1 AND id < $2
            ORDER BY created_at DESC
            LIMIT $3
            """,
            room_id,
            before_id,
            limit,
        )
    else:
        rows = await pool.fetch(
            """
            SELECT id, room_id, content, author, created_at
            FROM npl_chat_messages
            WHERE room_id = $1
            ORDER BY created_at DESC
            LIMIT $2
            """,
            room_id,
            limit,
        )
    # Return in ascending order
    return [_message_dto(r) for r in reversed(rows)]


async def message_create(
    room_id: int, content: str, author: str = "user"
) -> dict[str, Any]:
    pool = await get_pool()
    row = await pool.fetchrow(
        """
        INSERT INTO npl_chat_messages (room_id, content, author, created_at)
        VALUES ($1, $2, $3, NOW())
        RETURNING id, room_id, content, author, created_at
        """,
        room_id,
        content,
        author,
    )
    return _message_dto(row)


def _room_dto(row) -> dict[str, Any]:
    last = row["last_activity"]
    return {
        "id": row["id"],
        "name": row["name"],
        "description": row["description"] or "",
        "message_count": row["message_count"],
        "last_activity": last.isoformat() if last else None,
        "created_at": row["created_at"].isoformat() if row["created_at"] else None,
    }


def _room_dto_bare(row) -> dict[str, Any]:
    return {
        "id": row["id"],
        "name": row["name"],
        "description": row["description"] or "",
        "message_count": 0,
        "last_activity": None,
        "created_at": row["created_at"].isoformat() if row["created_at"] else None,
    }


def _message_dto(row) -> dict[str, Any]:
    return {
        "id": row["id"],
        "room_id": row["room_id"],
        "content": row["content"],
        "author": row["author"] or "user",
        "created_at": row["created_at"].isoformat() if row["created_at"] else None,
    }


# ---------------------------------------------------------------------------
# Enhanced chat operations (ported from main's ChatManager)
# ---------------------------------------------------------------------------


async def room_add_member(room_id: int, persona_slug: str) -> dict[str, Any]:
    """Add a persona to a chat room."""
    pool = await get_pool()
    try:
        row = await pool.fetchrow(
            """INSERT INTO npl_chat_room_members (room_id, persona_slug)
            VALUES ($1, $2)
            ON CONFLICT (room_id, persona_slug) DO NOTHING
            RETURNING id, room_id, persona_slug, joined_at""",
            room_id,
            persona_slug,
        )
    except Exception:
        return {"status": "error", "message": f"Room {room_id} not found"}

    if row is None:
        return {"status": "ok", "message": "Already a member", "room_id": room_id, "persona_slug": persona_slug}

    return {
        "status": "ok",
        "id": row["id"],
        "room_id": row["room_id"],
        "persona_slug": row["persona_slug"],
        "joined_at": row["joined_at"].isoformat() if row["joined_at"] else None,
    }


async def room_list_members(room_id: int) -> dict[str, Any]:
    """List all members of a chat room."""
    pool = await get_pool()
    rows = await pool.fetch(
        """SELECT id, room_id, persona_slug, joined_at
        FROM npl_chat_room_members
        WHERE room_id = $1
        ORDER BY joined_at""",
        room_id,
    )
    return {
        "status": "ok",
        "room_id": room_id,
        "members": [
            {
                "persona_slug": r["persona_slug"],
                "joined_at": r["joined_at"].isoformat() if r["joined_at"] else None,
            }
            for r in rows
        ],
        "count": len(rows),
    }


async def event_create(
    room_id: int,
    event_type: str,
    persona: str,
    data: dict | None = None,
    reply_to_id: int | None = None,
) -> dict[str, Any]:
    """Create a chat event."""
    import json

    pool = await get_pool()
    row = await pool.fetchrow(
        """INSERT INTO npl_chat_events (room_id, event_type, persona, data, reply_to_id)
        VALUES ($1, $2, $3, $4::jsonb, $5)
        RETURNING id, room_id, event_type, persona, data, reply_to_id, created_at""",
        room_id,
        event_type,
        persona,
        json.dumps(data or {}),
        reply_to_id,
    )
    return {
        "status": "ok",
        "event_id": row["id"],
        "room_id": row["room_id"],
        "event_type": row["event_type"],
        "persona": row["persona"],
        "created_at": row["created_at"].isoformat() if row["created_at"] else None,
    }


async def event_list(
    room_id: int,
    since: str | None = None,
    limit: int = 50,
) -> dict[str, Any]:
    """List chat events for a room."""
    pool = await get_pool()
    if since:
        rows = await pool.fetch(
            """SELECT id, room_id, event_type, persona, data, reply_to_id, created_at
            FROM npl_chat_events
            WHERE room_id = $1 AND created_at > $2::timestamptz
            ORDER BY created_at
            LIMIT $3""",
            room_id,
            since,
            limit,
        )
    else:
        rows = await pool.fetch(
            """SELECT id, room_id, event_type, persona, data, reply_to_id, created_at
            FROM npl_chat_events
            WHERE room_id = $1
            ORDER BY created_at DESC
            LIMIT $2""",
            room_id,
            limit,
        )
    return {
        "status": "ok",
        "events": [
            {
                "id": r["id"],
                "event_type": r["event_type"],
                "persona": r["persona"],
                "data": r["data"],
                "reply_to_id": r["reply_to_id"],
                "created_at": r["created_at"].isoformat() if r["created_at"] else None,
            }
            for r in rows
        ],
        "count": len(rows),
    }


async def react_to_event(event_id: int, persona: str, emoji: str) -> dict[str, Any]:
    """Add an emoji reaction to an event."""
    return await event_create(
        room_id=(await _event_room_id(event_id)),
        event_type="reaction",
        persona=persona,
        data={"emoji": emoji, "target_event_id": event_id},
        reply_to_id=event_id,
    )


async def create_todo(
    room_id: int,
    persona: str,
    description: str,
    assigned_to: str | None = None,
) -> dict[str, Any]:
    """Create a todo item as a chat event."""
    return await event_create(
        room_id=room_id,
        event_type="todo",
        persona=persona,
        data={"description": description, "assigned_to": assigned_to, "completed": False},
    )


async def share_artifact(
    room_id: int,
    persona: str,
    artifact_id: int,
    revision: int | None = None,
) -> dict[str, Any]:
    """Share an artifact in a chat room."""
    return await event_create(
        room_id=room_id,
        event_type="artifact_share",
        persona=persona,
        data={"artifact_id": artifact_id, "revision": revision},
    )


async def notification_list(
    persona: str,
    unread_only: bool = True,
) -> dict[str, Any]:
    """List notifications for a persona."""
    pool = await get_pool()
    if unread_only:
        rows = await pool.fetch(
            """SELECT n.id, n.persona, n.notification_type, n.created_at, n.read_at,
                      e.event_type, e.room_id, e.data
            FROM npl_chat_notifications n
            JOIN npl_chat_events e ON e.id = n.event_id
            WHERE n.persona = $1 AND n.read_at IS NULL
            ORDER BY n.created_at DESC""",
            persona,
        )
    else:
        rows = await pool.fetch(
            """SELECT n.id, n.persona, n.notification_type, n.created_at, n.read_at,
                      e.event_type, e.room_id, e.data
            FROM npl_chat_notifications n
            JOIN npl_chat_events e ON e.id = n.event_id
            WHERE n.persona = $1
            ORDER BY n.created_at DESC
            LIMIT 100""",
            persona,
        )
    return {
        "status": "ok",
        "notifications": [
            {
                "id": r["id"],
                "notification_type": r["notification_type"],
                "event_type": r["event_type"],
                "room_id": r["room_id"],
                "data": r["data"],
                "created_at": r["created_at"].isoformat() if r["created_at"] else None,
                "read_at": r["read_at"].isoformat() if r["read_at"] else None,
            }
            for r in rows
        ],
        "count": len(rows),
    }


async def notification_mark_read(notification_id: int) -> dict[str, Any]:
    """Mark a notification as read."""
    pool = await get_pool()
    row = await pool.fetchrow(
        """UPDATE npl_chat_notifications
        SET read_at = NOW()
        WHERE id = $1
        RETURNING id, persona, read_at""",
        notification_id,
    )
    if not row:
        return {"status": "not_found", "notification_id": notification_id}
    return {
        "status": "ok",
        "notification_id": row["id"],
        "read_at": row["read_at"].isoformat() if row["read_at"] else None,
    }


async def _event_room_id(event_id: int) -> int:
    pool = await get_pool()
    return await pool.fetchval(
        "SELECT room_id FROM npl_chat_events WHERE id = $1", event_id
    ) or 0
