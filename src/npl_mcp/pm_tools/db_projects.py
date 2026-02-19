"""DB-backed project CRUD tools.

Minimal project management for the npl_projects table, which serves
as the FK target for user_personas and user_stories.
"""

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


async def project_create(
    name: str,
    description: Optional[str] = None,
) -> dict[str, Any]:
    """Create a new project."""
    if not name:
        return {"status": "error", "message": "name must be a non-empty string."}

    pool = await get_pool()
    project_id = await pool.fetchval(
        """
        INSERT INTO npl_projects (name, description, created_at, updated_at)
        VALUES ($1, $2, NOW(), NOW())
        RETURNING id
        """,
        name,
        description,
    )
    return {"uuid": _encode(project_id), "status": "ok"}


async def project_get(id: str) -> dict[str, Any]:
    """Retrieve a project by ID."""
    uid = _decode(id)
    if uid is None:
        return {"uuid": id, "status": "error", "message": "Invalid UUID format."}

    pool = await get_pool()
    row = await pool.fetchrow(
        """SELECT id, name, description, created_at, updated_at
           FROM npl_projects
           WHERE id = $1 AND deleted_at IS NULL""",
        uid,
    )
    if row is None:
        return {"uuid": id, "status": "not_found"}

    return {
        "uuid": _encode(row["id"]),
        "name": row["name"],
        "description": row["description"],
        "created_at": row["created_at"].isoformat() if row["created_at"] else None,
        "updated_at": row["updated_at"].isoformat() if row["updated_at"] else None,
        "status": "ok",
    }


async def project_list(
    page: int = 1,
    page_size: int = 20,
) -> dict[str, Any]:
    """List projects with pagination."""
    pool = await get_pool()
    offset = (max(1, page) - 1) * page_size

    total = await pool.fetchval(
        "SELECT COUNT(*) FROM npl_projects WHERE deleted_at IS NULL"
    )

    rows = await pool.fetch(
        """SELECT id, name, description, created_at, updated_at
           FROM npl_projects
           WHERE deleted_at IS NULL
           ORDER BY created_at DESC
           LIMIT $1 OFFSET $2""",
        page_size,
        offset,
    )

    projects = [
        {
            "uuid": _encode(r["id"]),
            "name": r["name"],
            "description": r["description"],
            "created_at": r["created_at"].isoformat() if r["created_at"] else None,
        }
        for r in rows
    ]

    return {
        "projects": projects,
        "total": total,
        "page": page,
        "page_size": page_size,
        "status": "ok",
    }
