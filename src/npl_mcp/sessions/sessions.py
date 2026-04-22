"""Generic sessions — thin CRUD over ``npl_generic_sessions``.

UUIDs are stored as standard Postgres UUIDs and exposed as short-uuid
strings to callers (same convention as ``tool_sessions``).
"""

from __future__ import annotations

import uuid as _uuid_mod
from typing import Any, Optional

import shortuuid

from npl_mcp.storage import get_pool


VALID_STATUSES = {"active", "paused", "completed", "archived"}
_DEFAULT_STATUS = "active"


def _encode(uid: _uuid_mod.UUID) -> str:
    return shortuuid.encode(uid)


def _decode(value: str) -> Optional[_uuid_mod.UUID]:
    try:
        return shortuuid.decode(value)
    except (ValueError, AttributeError):
        pass
    try:
        return _uuid_mod.UUID(value)
    except (ValueError, AttributeError):
        return None


def _row_to_dict(row) -> dict[str, Any]:
    return {
        "uuid": _encode(row["id"]),
        "title": row["title"],
        "status": row["status"],
        "description": row["description"],
        "created_by": row["created_by"],
        "created_at": row["created_at"].isoformat() if row["created_at"] else None,
        "updated_at": row["updated_at"].isoformat() if row["updated_at"] else None,
    }


async def session_create(
    title: Optional[str] = None,
    description: Optional[str] = None,
    status: str = _DEFAULT_STATUS,
    created_by: Optional[str] = None,
) -> dict[str, Any]:
    """Create a new generic session row."""
    if status not in VALID_STATUSES:
        return {
            "status": "error",
            "message": f"Invalid status '{status}'. Must be one of: {', '.join(sorted(VALID_STATUSES))}",
        }

    pool = await get_pool()
    row = await pool.fetchrow(
        """
        INSERT INTO npl_generic_sessions (title, status, description, created_by)
        VALUES ($1, $2, $3, $4)
        RETURNING id, title, status, description, created_by, created_at, updated_at
        """,
        title,
        status,
        description,
        created_by,
    )
    result = _row_to_dict(row)
    # Envelope: re-key as (status=ok, session_status=row.status)
    session_status = result["status"]
    result["status"] = "ok"
    result["session_status"] = session_status
    return result


async def session_get(session_id: str) -> dict[str, Any]:
    """Fetch a single generic session by uuid (short- or full-form)."""
    uid = _decode(session_id)
    if uid is None:
        return {"status": "not_found", "uuid": session_id}

    pool = await get_pool()
    row = await pool.fetchrow(
        """SELECT id, title, status, description, created_by, created_at, updated_at
           FROM npl_generic_sessions
           WHERE id = $1""",
        uid,
    )
    if row is None:
        return {"status": "not_found", "uuid": session_id}

    result = _row_to_dict(row)
    session_status = result["status"]
    result["status"] = "ok"
    result["session_status"] = session_status
    return result


async def session_list(
    status: Optional[str] = None,
    limit: int = 50,
) -> dict[str, Any]:
    """List generic sessions, optionally filtered by status."""
    if status is not None and status not in VALID_STATUSES:
        return {
            "status": "error",
            "message": f"Invalid status '{status}'. Must be one of: {', '.join(sorted(VALID_STATUSES))}",
        }
    try:
        lim = max(1, min(200, int(limit)))
    except (TypeError, ValueError):
        lim = 50

    clauses: list[str] = []
    params: list[Any] = []
    idx = 1
    if status is not None:
        clauses.append(f"status = ${idx}")
        params.append(status)
        idx += 1
    where = f"WHERE {' AND '.join(clauses)}" if clauses else ""
    params.append(lim)

    pool = await get_pool()
    rows = await pool.fetch(
        f"""SELECT id, title, status, description, created_by, created_at, updated_at
            FROM npl_generic_sessions
            {where}
            ORDER BY created_at DESC
            LIMIT ${idx}""",
        *params,
    )

    sessions_out = []
    for r in rows:
        d = _row_to_dict(r)
        d["session_status"] = d.pop("status")
        sessions_out.append(d)

    return {
        "status": "ok",
        "sessions": sessions_out,
        "count": len(sessions_out),
    }


async def session_update(
    session_id: str,
    title: Optional[str] = None,
    status: Optional[str] = None,
    description: Optional[str] = None,
) -> dict[str, Any]:
    """Update mutable fields on a generic session. At least one of
    title/status/description must be provided.
    """
    if title is None and status is None and description is None:
        return {"status": "error", "message": "At least one of title/status/description required."}
    if status is not None and status not in VALID_STATUSES:
        return {
            "status": "error",
            "message": f"Invalid status '{status}'. Must be one of: {', '.join(sorted(VALID_STATUSES))}",
        }

    uid = _decode(session_id)
    if uid is None:
        return {"status": "not_found", "uuid": session_id}

    sets: list[str] = []
    params: list[Any] = []
    idx = 1
    if title is not None:
        sets.append(f"title = ${idx}")
        params.append(title)
        idx += 1
    if status is not None:
        sets.append(f"status = ${idx}")
        params.append(status)
        idx += 1
    if description is not None:
        sets.append(f"description = ${idx}")
        params.append(description)
        idx += 1
    sets.append("updated_at = NOW()")
    params.append(uid)

    pool = await get_pool()
    row = await pool.fetchrow(
        f"""UPDATE npl_generic_sessions
            SET {', '.join(sets)}
            WHERE id = ${idx}
            RETURNING id, title, status, description, created_by, created_at, updated_at""",
        *params,
    )
    if row is None:
        return {"status": "not_found", "uuid": session_id}

    result = _row_to_dict(row)
    session_status = result["status"]
    result["status"] = "ok"
    result["session_status"] = session_status
    return result


# ---------------------------------------------------------------------------
# Enhanced session operations (ported from main's SessionManager)
# ---------------------------------------------------------------------------


async def session_get_contents(session_id: str) -> dict[str, Any]:
    """Aggregate a session with its associated chat rooms and artifacts."""
    uid = _decode(session_id)
    if uid is None:
        return {"status": "not_found", "uuid": session_id}

    pool = await get_pool()
    row = await pool.fetchrow(
        """SELECT id, title, status, description, created_by, created_at, updated_at
           FROM npl_generic_sessions WHERE id = $1""",
        uid,
    )
    if row is None:
        return {"status": "not_found", "uuid": session_id}

    session = _row_to_dict(row)

    rooms = await pool.fetch(
        """SELECT r.id, r.name, r.description, COUNT(m.id) AS message_count,
                  MAX(m.created_at) AS last_activity, r.created_at
           FROM npl_chat_rooms r
           LEFT JOIN npl_chat_messages m ON m.room_id = r.id
           GROUP BY r.id
           ORDER BY r.created_at DESC""",
    )

    artifacts = await pool.fetch(
        """SELECT id, title, kind, description, created_by, latest_revision,
                  created_at, updated_at
           FROM npl_artifacts
           ORDER BY created_at DESC""",
    )

    return {
        "status": "ok",
        "session": session,
        "chat_rooms": [
            {
                "id": r["id"],
                "name": r["name"],
                "message_count": r["message_count"],
                "last_activity": r["last_activity"].isoformat() if r["last_activity"] else None,
            }
            for r in rooms
        ],
        "artifacts": [
            {
                "id": a["id"],
                "title": a["title"],
                "kind": a["kind"],
                "latest_revision": a["latest_revision"],
            }
            for a in artifacts
        ],
    }


async def session_archive(session_id: str) -> dict[str, Any]:
    """Convenience wrapper to archive a session."""
    return await session_update(session_id, status="archived")
