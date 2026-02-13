"""ToolSession tools -- agent session tracking via PostgreSQL.

Sessions are keyed by (agent, task) pairs.  ``ToolSession.Generate`` creates
or retrieves a session UUID, optionally appending notes.  ``ToolSession``
retrieves session info by UUID.

UUIDs are stored as full UUIDs in PostgreSQL but exposed to callers as
short UUIDs via the ``shortuuid`` library.
"""

import uuid as _uuid_mod
from typing import Any, Optional

import shortuuid

from npl_mcp.storage import get_pool


def _encode(uid: _uuid_mod.UUID) -> str:
    """Encode a UUID as a short UUID string."""
    return shortuuid.encode(uid)


def _decode(value: str) -> Optional[_uuid_mod.UUID]:
    """Decode a short UUID (or full UUID) string.  Returns ``None`` on bad input."""
    try:
        return shortuuid.decode(value)
    except (ValueError, AttributeError):
        pass
    # Fall back to standard UUID parsing
    try:
        return _uuid_mod.UUID(value)
    except (ValueError, AttributeError):
        return None


async def tool_session_generate(
    agent: str,
    brief: str,
    task: str,
    notes: Optional[str] = None,
) -> dict[str, Any]:
    """Look up or create a session by (agent, task).

    * If a session already exists for the pair, return its UUID.
      If *notes* is provided and is **not** a substring of the existing
      notes, append it (newline-separated) and update ``modified_at``.
    * If no session exists, create one and return the new UUID.
    """
    if not agent:
        return {"status": "error", "message": "agent must be a non-empty string."}
    if not task:
        return {"status": "error", "message": "task must be a non-empty string."}

    pool = await get_pool()

    # Look for existing session
    row = await pool.fetchrow(
        "SELECT id, notes FROM npl_tool_sessions WHERE agent = $1 AND task = $2",
        agent,
        task,
    )

    if row is not None:
        session_id = _encode(row["id"])
        existing_notes = row["notes"] or ""

        # Append notes if provided and not already a substring
        if notes and notes not in existing_notes:
            new_notes = (
                f"{existing_notes}\n{notes}".strip() if existing_notes else notes
            )
            await pool.execute(
                "UPDATE npl_tool_sessions SET notes = $1, modified_at = NOW() WHERE id = $2",
                new_notes,
                row["id"],
            )
            return {"uuid": session_id, "action": "existing_updated", "status": "ok"}

        return {"uuid": session_id, "action": "existing", "status": "ok"}

    # Create new session
    new_id = await pool.fetchval(
        """
        INSERT INTO npl_tool_sessions (agent, brief, task, notes, created_at, modified_at)
        VALUES ($1, $2, $3, $4, NOW(), NOW())
        RETURNING id
        """,
        agent,
        brief,
        task,
        notes,
    )
    return {"uuid": _encode(new_id), "action": "created", "status": "ok"}


async def tool_session(
    uuid: str,
    verbose: bool = False,
) -> dict[str, Any]:
    """Retrieve session info by UUID.

    Default: returns ``{uuid, agent, brief, status}``.
    Verbose: additionally returns ``task, notes, created_at, modified_at``.
    """
    uid = _decode(uuid)
    if uid is None:
        return {"uuid": uuid, "status": "not_found"}

    pool = await get_pool()

    if verbose:
        row = await pool.fetchrow(
            """SELECT id, agent, brief, task, notes, created_at, modified_at
               FROM npl_tool_sessions WHERE id = $1""",
            uid,
        )
    else:
        row = await pool.fetchrow(
            "SELECT id, agent, brief FROM npl_tool_sessions WHERE id = $1",
            uid,
        )

    if row is None:
        return {"uuid": uuid, "status": "not_found"}

    result: dict[str, Any] = {
        "uuid": _encode(row["id"]),
        "agent": row["agent"],
        "brief": row["brief"],
        "status": "ok",
    }

    if verbose:
        result["task"] = row["task"]
        result["notes"] = row["notes"]
        result["created_at"] = (
            row["created_at"].isoformat() if row["created_at"] else None
        )
        result["modified_at"] = (
            row["modified_at"].isoformat() if row["modified_at"] else None
        )

    return result
