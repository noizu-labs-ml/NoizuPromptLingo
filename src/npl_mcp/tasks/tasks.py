"""Tasks module — thin CRUD over the ``npl_tasks`` table.

This is the MVP flat-task implementation (PRD-005). It intentionally
omits queues, activity feeds, artifact links, and complexity scoring —
those stay in the stub catalog until there's a demand-driven reason
to implement them.

Return envelope convention
--------------------------
Every function returns ``{"status": "ok" | "error" | "not_found", ...}``.
On success the task fields live alongside ``status: "ok"`` in the
returned dict — callers should key on ``status`` then read the rest.
"""

from __future__ import annotations

from typing import Any, Optional

from npl_mcp.storage import get_pool


VALID_STATUSES = {"pending", "in_progress", "blocked", "review", "done"}
_DEFAULT_STATUS = "pending"
_DEFAULT_PRIORITY = 1


def _row_to_dict(row) -> dict[str, Any]:
    """Convert a DB row to a response dict (without the ``status`` envelope key)."""
    return {
        "id": row["id"],
        "title": row["title"],
        "description": row["description"] or "",
        "task_status": row["status"],  # renamed to avoid collision with envelope
        "priority": row["priority"],
        "assigned_to": row["assigned_to"],
        "notes": row["notes"],
        "created_at": row["created_at"].isoformat() if row["created_at"] else None,
        "updated_at": row["updated_at"].isoformat() if row["updated_at"] else None,
    }


async def task_create(
    title: str,
    description: Optional[str] = None,
    status: str = _DEFAULT_STATUS,
    priority: int = _DEFAULT_PRIORITY,
    assigned_to: Optional[str] = None,
    notes: Optional[str] = None,
) -> dict[str, Any]:
    """Create a task row.

    Args:
        title: Task title (required, non-empty).
        description: Optional longer description.
        status: One of ``VALID_STATUSES`` — defaults to ``pending``.
        priority: Integer priority; 0=low, 1=normal, 2=high, 3=urgent.
        assigned_to: Optional assignee identifier.
        notes: Optional free-form notes.
    """
    if not title or not title.strip():
        return {"status": "error", "message": "title must be a non-empty string."}
    if status not in VALID_STATUSES:
        return {
            "status": "error",
            "message": f"Invalid status '{status}'. Must be one of: {', '.join(sorted(VALID_STATUSES))}",
        }

    pool = await get_pool()
    row = await pool.fetchrow(
        """
        INSERT INTO npl_tasks (title, description, status, priority, assigned_to, notes)
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING id, title, description, status, priority, assigned_to, notes,
                  created_at, updated_at
        """,
        title.strip(),
        description,
        status,
        priority,
        assigned_to,
        notes,
    )
    result = _row_to_dict(row)
    result["status"] = "ok"
    return result


async def task_get(task_id: int) -> dict[str, Any]:
    """Fetch a single task by integer id."""
    try:
        tid = int(task_id)
    except (TypeError, ValueError):
        return {"status": "error", "message": "task_id must be an integer."}

    pool = await get_pool()
    row = await pool.fetchrow(
        """SELECT id, title, description, status, priority, assigned_to, notes,
                  created_at, updated_at
           FROM npl_tasks
           WHERE id = $1""",
        tid,
    )
    if row is None:
        return {"status": "not_found", "id": tid}

    result = _row_to_dict(row)
    result["status"] = "ok"
    return result


async def task_list(
    status: Optional[str] = None,
    assigned_to: Optional[str] = None,
    limit: int = 100,
) -> dict[str, Any]:
    """List tasks, optionally filtered by status / assignee.

    Args:
        status: Optional status filter — must be in ``VALID_STATUSES`` if set.
        assigned_to: Optional assignee filter (exact match).
        limit: Max rows to return (1..500, default 100).
    """
    if status is not None and status not in VALID_STATUSES:
        return {
            "status": "error",
            "message": f"Invalid status '{status}'. Must be one of: {', '.join(sorted(VALID_STATUSES))}",
        }
    try:
        lim = max(1, min(500, int(limit)))
    except (TypeError, ValueError):
        lim = 100

    clauses: list[str] = []
    params: list[Any] = []
    idx = 1
    if status is not None:
        clauses.append(f"status = ${idx}")
        params.append(status)
        idx += 1
    if assigned_to is not None:
        clauses.append(f"assigned_to = ${idx}")
        params.append(assigned_to)
        idx += 1

    where = f"WHERE {' AND '.join(clauses)}" if clauses else ""
    params.append(lim)

    pool = await get_pool()
    rows = await pool.fetch(
        f"""SELECT id, title, description, status, priority, assigned_to, notes,
                   created_at, updated_at
            FROM npl_tasks
            {where}
            ORDER BY created_at DESC
            LIMIT ${idx}""",
        *params,
    )

    return {
        "status": "ok",
        "tasks": [_row_to_dict(r) for r in rows],
        "count": len(rows),
    }


async def task_update_status(
    task_id: int,
    status: str,
    notes: Optional[str] = None,
) -> dict[str, Any]:
    """Change a task's ``status`` column and refresh ``updated_at``.

    Args:
        task_id: Integer id.
        status: New status (must be in ``VALID_STATUSES``).
        notes: Optional — when provided, *appended* to existing notes using
            the same substring-dedupe semantics as
            :func:`npl_mcp.tool_sessions.tool_sessions.append_session_notes`.
    """
    if status not in VALID_STATUSES:
        return {
            "status": "error",
            "message": f"Invalid status '{status}'. Must be one of: {', '.join(sorted(VALID_STATUSES))}",
        }
    try:
        tid = int(task_id)
    except (TypeError, ValueError):
        return {"status": "error", "message": "task_id must be an integer."}

    pool = await get_pool()
    existing = await pool.fetchrow(
        "SELECT id, notes FROM npl_tasks WHERE id = $1",
        tid,
    )
    if existing is None:
        return {"status": "not_found", "id": tid}

    new_notes = existing["notes"]
    if notes is not None:
        stripped = notes.strip()
        if stripped:
            current = existing["notes"] or ""
            if stripped not in current:
                new_notes = f"{current}\n{stripped}".strip() if current else stripped

    row = await pool.fetchrow(
        """UPDATE npl_tasks
           SET status = $1, notes = $2, updated_at = NOW()
           WHERE id = $3
           RETURNING id, title, description, status, priority, assigned_to, notes,
                     created_at, updated_at""",
        status,
        new_notes,
        tid,
    )

    result = _row_to_dict(row)
    result["status"] = "ok"
    return result
