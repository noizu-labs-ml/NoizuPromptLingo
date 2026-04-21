"""Chat rooms and messages — PRD-007 MVP."""
from __future__ import annotations

from typing import Any


async def room_list(pool, limit: int = 50) -> list[dict[str, Any]]:
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


async def room_create(pool, name: str, description: str = "") -> dict[str, Any]:
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


async def room_get(pool, room_id: int) -> dict[str, Any] | None:
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
    pool, room_id: int, limit: int = 50, before_id: int | None = None
) -> list[dict[str, Any]]:
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
    pool, room_id: int, content: str, author: str = "user"
) -> dict[str, Any]:
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
