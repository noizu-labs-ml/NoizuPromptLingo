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


# ---------------------------------------------------------------------------
# Enhanced task operations (ported from main's TaskQueueManager)
# ---------------------------------------------------------------------------


def _queue_dto(row) -> dict[str, Any]:
    return {
        "id": row["id"],
        "name": row["name"],
        "description": row["description"] or "",
        "session_id": row["session_id"],
        "chat_room_id": row["chat_room_id"],
        "queue_status": row["status"],
        "created_at": row["created_at"].isoformat() if row["created_at"] else None,
        "updated_at": row["updated_at"].isoformat() if row["updated_at"] else None,
    }


async def task_queue_create(
    name: str,
    description: Optional[str] = None,
    session_id: Optional[str] = None,
    chat_room_id: Optional[int] = None,
) -> dict[str, Any]:
    """Create a task queue."""
    if not name or not name.strip():
        return {"status": "error", "message": "name must be a non-empty string."}

    pool = await get_pool()
    row = await pool.fetchrow(
        """INSERT INTO npl_task_queues (name, description, session_id, chat_room_id)
        VALUES ($1, $2, $3, $4)
        RETURNING id, name, description, session_id, chat_room_id, status,
                  created_at, updated_at""",
        name.strip(),
        description,
        session_id,
        chat_room_id,
    )
    result = _queue_dto(row)
    result["status"] = "ok"
    return result


async def task_queue_get(queue_id: int) -> dict[str, Any]:
    """Get a task queue with task counts by status."""
    pool = await get_pool()
    row = await pool.fetchrow(
        """SELECT id, name, description, session_id, chat_room_id, status,
                  created_at, updated_at
           FROM npl_task_queues WHERE id = $1""",
        queue_id,
    )
    if not row:
        return {"status": "not_found", "queue_id": queue_id}

    counts = await pool.fetch(
        """SELECT status, COUNT(*) AS cnt
           FROM npl_tasks WHERE queue_id = $1
           GROUP BY status""",
        queue_id,
    )

    result = _queue_dto(row)
    result["status"] = "ok"
    result["task_counts"] = {r["status"]: r["cnt"] for r in counts}
    return result


async def task_queue_list(
    status: Optional[str] = None,
    limit: int = 50,
) -> dict[str, Any]:
    """List task queues."""
    pool = await get_pool()
    if status:
        rows = await pool.fetch(
            """SELECT id, name, description, session_id, chat_room_id, status,
                      created_at, updated_at
               FROM npl_task_queues WHERE status = $1
               ORDER BY created_at DESC LIMIT $2""",
            status,
            limit,
        )
    else:
        rows = await pool.fetch(
            """SELECT id, name, description, session_id, chat_room_id, status,
                      created_at, updated_at
               FROM npl_task_queues
               ORDER BY created_at DESC LIMIT $1""",
            limit,
        )

    return {
        "status": "ok",
        "queues": [_queue_dto(r) for r in rows],
        "count": len(rows),
    }


async def task_create_in_queue(
    queue_id: int,
    title: str,
    description: Optional[str] = None,
    status: str = _DEFAULT_STATUS,
    priority: int = _DEFAULT_PRIORITY,
    assigned_to: Optional[str] = None,
    acceptance_criteria: Optional[str] = None,
    deadline: Optional[str] = None,
    complexity: Optional[int] = None,
    complexity_notes: Optional[str] = None,
) -> dict[str, Any]:
    """Create a task within a queue with enhanced fields."""
    if not title or not title.strip():
        return {"status": "error", "message": "title must be a non-empty string."}
    if status not in VALID_STATUSES:
        return {
            "status": "error",
            "message": f"Invalid status '{status}'. Must be one of: {', '.join(sorted(VALID_STATUSES))}",
        }

    pool = await get_pool()
    row = await pool.fetchrow(
        """INSERT INTO npl_tasks (
            title, description, status, priority, assigned_to,
            queue_id, acceptance_criteria, deadline, complexity, complexity_notes
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8::timestamptz, $9, $10)
        RETURNING id, title, description, status, priority, assigned_to, notes,
                  queue_id, acceptance_criteria, deadline, complexity, complexity_notes,
                  created_at, updated_at""",
        title.strip(),
        description,
        status,
        priority,
        assigned_to,
        queue_id,
        acceptance_criteria,
        deadline,
        complexity,
        complexity_notes,
    )
    result = _row_to_dict(row)
    result["status"] = "ok"
    result["queue_id"] = row["queue_id"]
    result["acceptance_criteria"] = row["acceptance_criteria"]
    result["deadline"] = row["deadline"].isoformat() if row["deadline"] else None
    result["complexity"] = row["complexity"]
    result["complexity_notes"] = row["complexity_notes"]
    return result


async def task_assign_complexity(
    task_id: int,
    complexity: int,
    notes: Optional[str] = None,
) -> dict[str, Any]:
    """Assign complexity score to a task."""
    pool = await get_pool()
    row = await pool.fetchrow(
        """UPDATE npl_tasks
           SET complexity = $1, complexity_notes = $2, updated_at = NOW()
           WHERE id = $3
           RETURNING id, title, complexity, complexity_notes""",
        complexity,
        notes,
        task_id,
    )
    if not row:
        return {"status": "not_found", "id": task_id}

    return {
        "status": "ok",
        "id": row["id"],
        "title": row["title"],
        "complexity": row["complexity"],
        "complexity_notes": row["complexity_notes"],
    }


async def task_add_artifact(
    task_id: int,
    artifact_type: str,
    artifact_id: Optional[int] = None,
    git_branch: Optional[str] = None,
    description: Optional[str] = None,
    created_by: Optional[str] = None,
) -> dict[str, Any]:
    """Link an artifact or git branch to a task."""
    pool = await get_pool()
    row = await pool.fetchrow(
        """INSERT INTO npl_task_artifacts (
            task_id, artifact_type, artifact_id, git_branch, description, created_by
        ) VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING id, task_id, artifact_type, artifact_id, git_branch, description,
                  created_by, created_at""",
        task_id,
        artifact_type,
        artifact_id,
        git_branch,
        description,
        created_by,
    )
    return {
        "status": "ok",
        "id": row["id"],
        "task_id": row["task_id"],
        "artifact_type": row["artifact_type"],
        "artifact_id": row["artifact_id"],
        "git_branch": row["git_branch"],
        "created_at": row["created_at"].isoformat() if row["created_at"] else None,
    }


async def task_list_artifacts(task_id: int) -> dict[str, Any]:
    """List artifacts linked to a task."""
    pool = await get_pool()
    rows = await pool.fetch(
        """SELECT id, task_id, artifact_type, artifact_id, git_branch, description,
                  created_by, created_at
           FROM npl_task_artifacts
           WHERE task_id = $1
           ORDER BY created_at""",
        task_id,
    )
    return {
        "status": "ok",
        "task_id": task_id,
        "artifacts": [
            {
                "id": r["id"],
                "artifact_type": r["artifact_type"],
                "artifact_id": r["artifact_id"],
                "git_branch": r["git_branch"],
                "description": r["description"],
                "created_by": r["created_by"],
                "created_at": r["created_at"].isoformat() if r["created_at"] else None,
            }
            for r in rows
        ],
        "count": len(rows),
    }


async def task_feed(
    task_id: int,
    since: Optional[str] = None,
    limit: int = 50,
) -> dict[str, Any]:
    """Get activity feed for a task."""
    pool = await get_pool()
    if since:
        rows = await pool.fetch(
            """SELECT id, task_id, queue_id, event_type, persona, data, created_at
               FROM npl_task_events
               WHERE task_id = $1 AND created_at > $2::timestamptz
               ORDER BY created_at
               LIMIT $3""",
            task_id,
            since,
            limit,
        )
    else:
        rows = await pool.fetch(
            """SELECT id, task_id, queue_id, event_type, persona, data, created_at
               FROM npl_task_events
               WHERE task_id = $1
               ORDER BY created_at DESC
               LIMIT $2""",
            task_id,
            limit,
        )
    return {
        "status": "ok",
        "task_id": task_id,
        "events": [
            {
                "id": r["id"],
                "event_type": r["event_type"],
                "persona": r["persona"],
                "data": r["data"],
                "created_at": r["created_at"].isoformat() if r["created_at"] else None,
            }
            for r in rows
        ],
        "count": len(rows),
    }


async def queue_feed(
    queue_id: int,
    since: Optional[str] = None,
    limit: int = 100,
) -> dict[str, Any]:
    """Get activity feed for a task queue."""
    pool = await get_pool()
    if since:
        rows = await pool.fetch(
            """SELECT id, task_id, queue_id, event_type, persona, data, created_at
               FROM npl_task_events
               WHERE queue_id = $1 AND created_at > $2::timestamptz
               ORDER BY created_at
               LIMIT $3""",
            queue_id,
            since,
            limit,
        )
    else:
        rows = await pool.fetch(
            """SELECT id, task_id, queue_id, event_type, persona, data, created_at
               FROM npl_task_events
               WHERE queue_id = $1
               ORDER BY created_at DESC
               LIMIT $2""",
            queue_id,
            limit,
        )
    return {
        "status": "ok",
        "queue_id": queue_id,
        "events": [
            {
                "id": r["id"],
                "task_id": r["task_id"],
                "event_type": r["event_type"],
                "persona": r["persona"],
                "data": r["data"],
                "created_at": r["created_at"].isoformat() if r["created_at"] else None,
            }
            for r in rows
        ],
        "count": len(rows),
    }
