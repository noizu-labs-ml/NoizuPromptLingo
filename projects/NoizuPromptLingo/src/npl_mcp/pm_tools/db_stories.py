"""DB-backed user story CRUD tools.

Provides create, get, update, delete, and list operations for the
npl_user_stories table. Uses shortuuid for external UUID encoding.
"""

import json
import uuid as _uuid_mod
from typing import Any, Optional

import shortuuid

from npl_mcp.storage import get_pool

VALID_PRIORITIES = {"critical", "high", "medium", "low"}
VALID_STATUSES = {"draft", "ready", "in_progress", "done", "archived"}


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


def _row_to_dict(row, include_ac: bool = False) -> dict[str, Any]:
    """Convert a DB row to a response dict."""
    result = {
        "uuid": _encode(row["id"]),
        "project_id": _encode(row["project_id"]),
        "persona_ids": [_encode(uid) for uid in row["persona_ids"]] if row["persona_ids"] else [],
        "title": row["title"],
        "story_text": row["story_text"],
        "description": row["description"],
        "priority": row["priority"],
        "status": row["status"],
        "story_points": row["story_points"],
        "tags": row["tags"] if row["tags"] else [],
        "created_by": _encode(row["created_by"]) if row["created_by"] else None,
        "created_at": row["created_at"].isoformat() if row["created_at"] else None,
        "updated_at": row["updated_at"].isoformat() if row["updated_at"] else None,
    }
    if include_ac:
        result["acceptance_criteria"] = (
            json.loads(row["acceptance_criteria"]) if row["acceptance_criteria"] else None
        )
    return result


async def story_create(
    project_id: str,
    title: str,
    persona_ids: Optional[list[str]] = None,
    story_text: Optional[str] = None,
    description: Optional[str] = None,
    priority: Optional[str] = "medium",
    status: Optional[str] = "draft",
    story_points: Optional[int] = None,
    acceptance_criteria: Optional[list[dict]] = None,
    tags: Optional[list[str]] = None,
) -> dict[str, Any]:
    """Create a new user story."""
    if not title:
        return {"status": "error", "message": "title must be a non-empty string."}

    proj_uid = _decode(project_id)
    if proj_uid is None:
        return {"status": "error", "message": "Invalid project_id UUID format."}

    if priority and priority not in VALID_PRIORITIES:
        return {"status": "error", "message": f"Invalid priority '{priority}'. Must be one of: {', '.join(sorted(VALID_PRIORITIES))}"}

    if status and status not in VALID_STATUSES:
        return {"status": "error", "message": f"Invalid status '{status}'. Must be one of: {', '.join(sorted(VALID_STATUSES))}"}

    # Decode persona UUIDs
    decoded_persona_ids = None
    if persona_ids:
        decoded_persona_ids = []
        for pid in persona_ids:
            uid = _decode(pid)
            if uid is None:
                return {"status": "error", "message": f"Invalid persona UUID: '{pid}'"}
            decoded_persona_ids.append(uid)

    ac_json = json.dumps(acceptance_criteria) if acceptance_criteria else None

    pool = await get_pool()
    story_id = await pool.fetchval(
        """
        INSERT INTO npl_user_stories
            (project_id, persona_ids, title, story_text, description,
             priority, status, story_points, acceptance_criteria, tags,
             created_at, updated_at)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9::jsonb, $10, NOW(), NOW())
        RETURNING id
        """,
        proj_uid, decoded_persona_ids, title, story_text, description,
        priority, status, story_points, ac_json, tags,
    )
    return {"uuid": _encode(story_id), "status": "ok"}


async def story_get(
    id: str,
    include: Optional[str] = None,
) -> dict[str, Any]:
    """Retrieve a user story by ID.

    Args:
        id: Story UUID.
        include: Pass "acceptance-criteria" to include acceptance_criteria in response.
    """
    uid = _decode(id)
    if uid is None:
        return {"uuid": id, "status": "error", "message": "Invalid UUID format."}

    pool = await get_pool()
    row = await pool.fetchrow(
        """SELECT id, project_id, persona_ids, title, story_text, description,
                  priority, status, story_points, acceptance_criteria, tags,
                  created_by, created_at, updated_at
           FROM npl_user_stories
           WHERE id = $1 AND deleted_at IS NULL""",
        uid,
    )
    if row is None:
        return {"uuid": id, "status": "not_found"}

    include_ac = include == "acceptance-criteria"
    result = _row_to_dict(row, include_ac=include_ac)
    result["status"] = "ok"
    return result


async def story_update(
    id: str,
    title: Optional[str] = None,
    persona_ids: Optional[list[str]] = None,
    story_text: Optional[str] = None,
    description: Optional[str] = None,
    priority: Optional[str] = None,
    status: Optional[str] = None,
    story_points: Optional[int] = None,
    acceptance_criteria: Optional[list[dict]] = None,
    tags: Optional[list[str]] = None,
) -> dict[str, Any]:
    """Update an existing user story."""
    uid = _decode(id)
    if uid is None:
        return {"uuid": id, "status": "error", "message": "Invalid UUID format."}

    if priority is not None and priority not in VALID_PRIORITIES:
        return {"status": "error", "message": f"Invalid priority '{priority}'. Must be one of: {', '.join(sorted(VALID_PRIORITIES))}"}

    if status is not None and status not in VALID_STATUSES:
        return {"status": "error", "message": f"Invalid status '{status}'. Must be one of: {', '.join(sorted(VALID_STATUSES))}"}

    pool = await get_pool()

    existing = await pool.fetchval(
        "SELECT id FROM npl_user_stories WHERE id = $1 AND deleted_at IS NULL",
        uid,
    )
    if existing is None:
        return {"uuid": id, "status": "not_found"}

    fields = []
    params = []
    idx = 1

    for col, val in [
        ("title", title),
        ("story_text", story_text),
        ("description", description),
        ("priority", priority),
        ("status", status),
    ]:
        if val is not None:
            fields.append(f"{col} = ${idx}")
            params.append(val)
            idx += 1

    if story_points is not None:
        fields.append(f"story_points = ${idx}")
        params.append(story_points)
        idx += 1

    if persona_ids is not None:
        decoded = []
        for pid in persona_ids:
            puid = _decode(pid)
            if puid is None:
                return {"status": "error", "message": f"Invalid persona UUID: '{pid}'"}
            decoded.append(puid)
        fields.append(f"persona_ids = ${idx}")
        params.append(decoded)
        idx += 1

    if acceptance_criteria is not None:
        fields.append(f"acceptance_criteria = ${idx}::jsonb")
        params.append(json.dumps(acceptance_criteria))
        idx += 1

    if tags is not None:
        fields.append(f"tags = ${idx}")
        params.append(tags)
        idx += 1

    if not fields:
        return {"uuid": _encode(uid), "status": "ok", "message": "No fields to update."}

    fields.append("updated_at = NOW()")
    params.append(uid)

    sql = f"UPDATE npl_user_stories SET {', '.join(fields)} WHERE id = ${idx} AND deleted_at IS NULL"
    await pool.execute(sql, *params)

    return {"uuid": _encode(uid), "status": "ok"}


async def story_delete(id: str) -> dict[str, Any]:
    """Soft-delete a user story."""
    uid = _decode(id)
    if uid is None:
        return {"uuid": id, "status": "error", "message": "Invalid UUID format."}

    pool = await get_pool()
    result = await pool.execute(
        "UPDATE npl_user_stories SET deleted_at = NOW(), updated_at = NOW() WHERE id = $1 AND deleted_at IS NULL",
        uid,
    )
    if result == "UPDATE 0":
        return {"uuid": id, "status": "not_found"}

    return {"uuid": _encode(uid), "status": "ok"}


async def story_list(
    project_id: str,
    persona_id: Optional[str] = None,
    status: Optional[str] = None,
    priority: Optional[str] = None,
    tags: Optional[list[str]] = None,
    page: int = 1,
    page_size: int = 20,
) -> dict[str, Any]:
    """List stories for a project with optional filtering and pagination."""
    proj_uid = _decode(project_id)
    if proj_uid is None:
        return {"status": "error", "message": "Invalid project_id UUID format."}

    pool = await get_pool()
    offset = (max(1, page) - 1) * page_size

    # Build WHERE clause
    conditions = ["project_id = $1", "deleted_at IS NULL"]
    params: list[Any] = [proj_uid]
    idx = 2

    if persona_id is not None:
        persona_uid = _decode(persona_id)
        if persona_uid is None:
            return {"status": "error", "message": "Invalid persona_id UUID format."}
        conditions.append(f"persona_ids @> ARRAY[${idx}]::uuid[]")
        params.append(persona_uid)
        idx += 1

    if status is not None:
        conditions.append(f"status = ${idx}")
        params.append(status)
        idx += 1

    if priority is not None:
        conditions.append(f"priority = ${idx}")
        params.append(priority)
        idx += 1

    if tags is not None and len(tags) > 0:
        conditions.append(f"tags && ${idx}")
        params.append(tags)
        idx += 1

    where = " AND ".join(conditions)

    total = await pool.fetchval(
        f"SELECT COUNT(*) FROM npl_user_stories WHERE {where}",
        *params,
    )

    rows = await pool.fetch(
        f"""SELECT id, project_id, persona_ids, title, story_text, description,
                   priority, status, story_points, acceptance_criteria, tags,
                   created_by, created_at, updated_at
            FROM npl_user_stories
            WHERE {where}
            ORDER BY created_at DESC
            LIMIT ${idx} OFFSET ${idx + 1}""",
        *params, page_size, offset,
    )

    stories = [_row_to_dict(r, include_ac=False) for r in rows]

    return {
        "stories": stories,
        "total": total,
        "page": page,
        "page_size": page_size,
        "status": "ok",
    }
