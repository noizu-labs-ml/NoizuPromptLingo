"""ToolSession tools -- agent session tracking via PostgreSQL.

Sessions are keyed by (project, agent, task) triples.  ``ToolSession.Generate``
creates or retrieves a session UUID, optionally appending notes.
``ToolSession`` retrieves session info by UUID.

UUIDs are stored as full UUIDs in PostgreSQL but exposed to callers as
short UUIDs via the ``shortuuid`` library.
"""

import uuid as _uuid_mod
from typing import Any, Optional

import shortuuid

from npl_mcp.storage import get_pool
from npl_mcp.tool_sessions.projects import upsert_project


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
    project: str,
    parent: Optional[str] = None,
    notes: Optional[str] = None,
) -> dict[str, Any]:
    """Look up or create a session by (project, agent, task).

    * If a session already exists for the triple, return its UUID.
      If *notes* is provided and is **not** a substring of the existing
      notes, append it (newline-separated) and update ``updated_at``.
    * If no session exists, create one and return the new UUID.

    *project* is resolved to a ``npl_projects`` row via :func:`upsert_project`.
    *parent*, if given, must be a valid session UUID.
    """
    if not agent:
        return {"status": "error", "message": "agent must be a non-empty string."}
    if not task:
        return {"status": "error", "message": "task must be a non-empty string."}
    if not project:
        return {"status": "error", "message": "project must be a non-empty string."}

    # Resolve project
    project_id = await upsert_project(project)

    # Resolve optional parent
    parent_id: Optional[_uuid_mod.UUID] = None
    if parent:
        parent_id = _decode(parent)
        if parent_id is None:
            return {"status": "error", "message": f"Invalid parent UUID: {parent}"}
        pool = await get_pool()
        exists = await pool.fetchval(
            "SELECT id FROM npl_tool_sessions WHERE id = $1", parent_id
        )
        if exists is None:
            return {"status": "error", "message": f"Parent session not found: {parent}"}
    else:
        pool = await get_pool()

    # Look for existing session
    row = await pool.fetchrow(
        "SELECT id, notes FROM npl_tool_sessions WHERE project_id = $1 AND agent = $2 AND task = $3",
        project_id,
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
                "UPDATE npl_tool_sessions SET notes = $1, updated_at = NOW() WHERE id = $2",
                new_notes,
                row["id"],
            )
            return {"uuid": session_id, "action": "existing_updated", "project": project, "status": "ok"}

        return {"uuid": session_id, "action": "existing", "project": project, "status": "ok"}

    # Create new session
    new_id = await pool.fetchval(
        """
        INSERT INTO npl_tool_sessions (agent, brief, task, notes, project_id, parent_id, created_at, updated_at)
        VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW())
        RETURNING id
        """,
        agent,
        brief,
        task,
        notes,
        project_id,
        parent_id,
    )
    return {"uuid": _encode(new_id), "action": "created", "project": project, "status": "ok"}


async def append_session_notes(
    session_id: str,
    note: str,
) -> dict[str, Any]:
    """Append *note* to an existing session's notes field.

    The append is substring-deduped: if *note* is already contained in the
    existing notes, the call is a no-op and returns the session unchanged.

    Returns ``{status: "ok" | "not_found" | "error", ...session fields}``.
    """
    if not note or not note.strip():
        return {"status": "error", "message": "note must be a non-empty string."}

    uid = _decode(session_id)
    if uid is None:
        return {"status": "not_found", "uuid": session_id}

    pool = await get_pool()
    row = await pool.fetchrow(
        """SELECT s.id, s.agent, s.brief, s.task, s.notes,
                  s.parent_id, s.created_at, s.updated_at,
                  p.name AS project
           FROM npl_tool_sessions s
           JOIN npl_projects p ON s.project_id = p.id
           WHERE s.id = $1""",
        uid,
    )
    if row is None:
        return {"status": "not_found", "uuid": session_id}

    existing_notes = row["notes"] or ""
    action = "noop"
    new_notes = existing_notes

    if note not in existing_notes:
        new_notes = f"{existing_notes}\n{note}".strip() if existing_notes else note
        await pool.execute(
            "UPDATE npl_tool_sessions SET notes = $1, updated_at = NOW() WHERE id = $2",
            new_notes,
            row["id"],
        )
        action = "appended"

    updated_at = row["updated_at"]
    if action == "appended":
        updated_row = await pool.fetchrow(
            "SELECT updated_at FROM npl_tool_sessions WHERE id = $1", row["id"]
        )
        if updated_row is not None:
            updated_at = updated_row["updated_at"]

    return {
        "status": "ok",
        "action": action,
        "uuid": _encode(row["id"]),
        "agent": row["agent"],
        "brief": row["brief"],
        "task": row["task"],
        "project": row["project"],
        "parent": _encode(row["parent_id"]) if row["parent_id"] else None,
        "notes": new_notes,
        "created_at": row["created_at"].isoformat() if row["created_at"] else None,
        "updated_at": updated_at.isoformat() if updated_at else None,
    }


async def tool_session(
    uuid: str,
    verbose: bool = False,
) -> dict[str, Any]:
    """Retrieve session info by UUID.

    Default: returns ``{uuid, agent, brief, project, status}``.
    Verbose: additionally returns ``task, notes, parent, created_at, updated_at``.
    """
    uid = _decode(uuid)
    if uid is None:
        return {"uuid": uuid, "status": "not_found"}

    pool = await get_pool()

    if verbose:
        row = await pool.fetchrow(
            """SELECT s.id, s.agent, s.brief, s.task, s.notes,
                      s.parent_id, s.created_at, s.updated_at,
                      p.name AS project
               FROM npl_tool_sessions s
               JOIN npl_projects p ON s.project_id = p.id
               WHERE s.id = $1""",
            uid,
        )
    else:
        row = await pool.fetchrow(
            """SELECT s.id, s.agent, s.brief, p.name AS project
               FROM npl_tool_sessions s
               JOIN npl_projects p ON s.project_id = p.id
               WHERE s.id = $1""",
            uid,
        )

    if row is None:
        return {"uuid": uuid, "status": "not_found"}

    result: dict[str, Any] = {
        "uuid": _encode(row["id"]),
        "agent": row["agent"],
        "brief": row["brief"],
        "project": row["project"],
        "status": "ok",
    }

    if verbose:
        result["task"] = row["task"]
        result["notes"] = row["notes"]
        result["parent"] = _encode(row["parent_id"]) if row["parent_id"] else None
        result["created_at"] = (
            row["created_at"].isoformat() if row["created_at"] else None
        )
        result["updated_at"] = (
            row["updated_at"].isoformat() if row["updated_at"] else None
        )

    return result
