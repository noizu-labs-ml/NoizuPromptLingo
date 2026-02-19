"""DB-backed user persona CRUD tools.

Provides create, get, update, delete, and list operations for the
npl_user_personas table. Uses shortuuid for external UUID encoding.
"""

import json
import uuid as _uuid_mod
from typing import Any, Optional

import shortuuid

from npl_mcp.storage import get_pool


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
    """Convert a DB row to a response dict."""
    return {
        "uuid": _encode(row["id"]),
        "project_id": _encode(row["project_id"]),
        "name": row["name"],
        "role": row["role"],
        "description": row["description"],
        "goals": row["goals"],
        "pain_points": row["pain_points"],
        "behaviors": row["behaviors"],
        "physical_description": row["physical_description"],
        "persona_image": row["persona_image"],
        "demographics": json.loads(row["demographics"]) if row["demographics"] else None,
        "created_by": _encode(row["created_by"]) if row["created_by"] else None,
        "created_at": row["created_at"].isoformat() if row["created_at"] else None,
        "updated_at": row["updated_at"].isoformat() if row["updated_at"] else None,
    }


async def persona_create(
    project_id: str,
    name: str,
    role: Optional[str] = None,
    description: Optional[str] = None,
    goals: Optional[str] = None,
    pain_points: Optional[str] = None,
    behaviors: Optional[str] = None,
    physical_description: Optional[str] = None,
    persona_image: Optional[str] = None,
    demographics: Optional[dict] = None,
) -> dict[str, Any]:
    """Create a new user persona."""
    if not name:
        return {"status": "error", "message": "name must be a non-empty string."}

    proj_uid = _decode(project_id)
    if proj_uid is None:
        return {"status": "error", "message": "Invalid project_id UUID format."}

    pool = await get_pool()
    demo_json = json.dumps(demographics) if demographics else None

    persona_id = await pool.fetchval(
        """
        INSERT INTO npl_user_personas
            (project_id, name, role, description, goals, pain_points,
             behaviors, physical_description, persona_image, demographics,
             created_at, updated_at)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10::jsonb, NOW(), NOW())
        RETURNING id
        """,
        proj_uid, name, role, description, goals, pain_points,
        behaviors, physical_description, persona_image, demo_json,
    )
    return {"uuid": _encode(persona_id), "status": "ok"}


async def persona_get(id: str) -> dict[str, Any]:
    """Retrieve a user persona by ID."""
    uid = _decode(id)
    if uid is None:
        return {"uuid": id, "status": "error", "message": "Invalid UUID format."}

    pool = await get_pool()
    row = await pool.fetchrow(
        """SELECT id, project_id, name, role, description, goals, pain_points,
                  behaviors, physical_description, persona_image, demographics,
                  created_by, created_at, updated_at
           FROM npl_user_personas
           WHERE id = $1 AND deleted_at IS NULL""",
        uid,
    )
    if row is None:
        return {"uuid": id, "status": "not_found"}

    result = _row_to_dict(row)
    result["status"] = "ok"
    return result


async def persona_update(
    id: str,
    name: Optional[str] = None,
    role: Optional[str] = None,
    description: Optional[str] = None,
    goals: Optional[str] = None,
    pain_points: Optional[str] = None,
    behaviors: Optional[str] = None,
    physical_description: Optional[str] = None,
    persona_image: Optional[str] = None,
    demographics: Optional[dict] = None,
) -> dict[str, Any]:
    """Update an existing user persona."""
    uid = _decode(id)
    if uid is None:
        return {"uuid": id, "status": "error", "message": "Invalid UUID format."}

    pool = await get_pool()

    # Check existence
    existing = await pool.fetchval(
        "SELECT id FROM npl_user_personas WHERE id = $1 AND deleted_at IS NULL",
        uid,
    )
    if existing is None:
        return {"uuid": id, "status": "not_found"}

    # Build dynamic SET clause
    fields = []
    params = []
    idx = 1

    for col, val in [
        ("name", name),
        ("role", role),
        ("description", description),
        ("goals", goals),
        ("pain_points", pain_points),
        ("behaviors", behaviors),
        ("physical_description", physical_description),
        ("persona_image", persona_image),
    ]:
        if val is not None:
            fields.append(f"{col} = ${idx}")
            params.append(val)
            idx += 1

    if demographics is not None:
        fields.append(f"demographics = ${idx}::jsonb")
        params.append(json.dumps(demographics))
        idx += 1

    if not fields:
        return {"uuid": _encode(uid), "status": "ok", "message": "No fields to update."}

    fields.append("updated_at = NOW()")
    params.append(uid)

    sql = f"UPDATE npl_user_personas SET {', '.join(fields)} WHERE id = ${idx} AND deleted_at IS NULL"
    await pool.execute(sql, *params)

    return {"uuid": _encode(uid), "status": "ok"}


async def persona_delete(id: str) -> dict[str, Any]:
    """Soft-delete a user persona."""
    uid = _decode(id)
    if uid is None:
        return {"uuid": id, "status": "error", "message": "Invalid UUID format."}

    pool = await get_pool()
    result = await pool.execute(
        "UPDATE npl_user_personas SET deleted_at = NOW(), updated_at = NOW() WHERE id = $1 AND deleted_at IS NULL",
        uid,
    )
    if result == "UPDATE 0":
        return {"uuid": id, "status": "not_found"}

    return {"uuid": _encode(uid), "status": "ok"}


async def persona_list(
    project_id: str,
    page: int = 1,
    page_size: int = 20,
) -> dict[str, Any]:
    """List personas for a project with pagination."""
    proj_uid = _decode(project_id)
    if proj_uid is None:
        return {"status": "error", "message": "Invalid project_id UUID format."}

    pool = await get_pool()
    offset = (max(1, page) - 1) * page_size

    total = await pool.fetchval(
        "SELECT COUNT(*) FROM npl_user_personas WHERE project_id = $1 AND deleted_at IS NULL",
        proj_uid,
    )

    rows = await pool.fetch(
        """SELECT id, project_id, name, role, description, goals, pain_points,
                  behaviors, physical_description, persona_image, demographics,
                  created_by, created_at, updated_at
           FROM npl_user_personas
           WHERE project_id = $1 AND deleted_at IS NULL
           ORDER BY created_at DESC
           LIMIT $2 OFFSET $3""",
        proj_uid, page_size, offset,
    )

    personas = [_row_to_dict(r) for r in rows]

    return {
        "personas": personas,
        "total": total,
        "page": page,
        "page_size": page_size,
        "status": "ok",
    }
