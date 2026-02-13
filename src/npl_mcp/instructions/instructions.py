"""Instructions tools -- versioned instruction documents via PostgreSQL.

Provides create, retrieve, update, version-rollback, and version-listing
for instruction prompts used to spawn agents.

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


async def instructions_create(
    title: str,
    description: str,
    tags: list[str],
    body: str,
) -> dict[str, Any]:
    """Create a new instruction with its first version (v1)."""
    if not title:
        return {"status": "error", "message": "title must be a non-empty string."}
    if not body:
        return {"status": "error", "message": "body must be a non-empty string."}

    pool = await get_pool()

    async with pool.acquire() as conn:
        async with conn.transaction():
            instruction_id = await conn.fetchval(
                """
                INSERT INTO npl_instructions
                    (title, description, tags, active_version, created_at, modified_at)
                VALUES ($1, $2, $3, 1, NOW(), NOW())
                RETURNING id
                """,
                title,
                description,
                tags,
            )

            await conn.execute(
                """
                INSERT INTO npl_instruction_versions
                    (instruction_id, version, body, change_note, created_at)
                VALUES ($1, 1, $2, 'Initial version', NOW())
                """,
                instruction_id,
                body,
            )

    return {"uuid": _encode(instruction_id), "version": 1, "status": "ok"}


async def instructions_get(
    uuid: str,
    version: Optional[int] = None,
) -> dict[str, Any]:
    """Retrieve instruction body.  Active version if *version* is ``None``."""
    uid = _decode(uuid)
    if uid is None:
        return {"uuid": uuid, "status": "error", "message": "Invalid UUID format."}

    pool = await get_pool()

    instr = await pool.fetchrow(
        "SELECT id, title, description, tags, active_version FROM npl_instructions WHERE id = $1",
        uid,
    )
    if instr is None:
        return {"uuid": uuid, "status": "not_found"}

    target_version = version if version is not None else instr["active_version"]

    ver = await pool.fetchrow(
        """SELECT version, body, change_note, created_at
           FROM npl_instruction_versions
           WHERE instruction_id = $1 AND version = $2""",
        uid,
        target_version,
    )
    if ver is None:
        return {
            "uuid": uuid,
            "status": "error",
            "message": f"Version {target_version} not found.",
        }

    return {
        "uuid": _encode(instr["id"]),
        "title": instr["title"],
        "description": instr["description"],
        "tags": instr["tags"],
        "active_version": instr["active_version"],
        "version": ver["version"],
        "body": ver["body"],
        "change_note": ver["change_note"],
        "created_at": ver["created_at"].isoformat() if ver["created_at"] else None,
        "status": "ok",
    }


async def instructions_update(
    uuid: str,
    change_note: str,
    description: Optional[str] = None,
    tags: Optional[list[str]] = None,
    body: Optional[str] = None,
) -> dict[str, Any]:
    """Create a new version, optionally updating description/tags/body.

    The new version number is ``active_version + 1`` and becomes active.
    If *body* is omitted the body is carried forward from the current
    active version.
    """
    uid = _decode(uuid)
    if uid is None:
        return {"uuid": uuid, "status": "error", "message": "Invalid UUID format."}

    pool = await get_pool()

    async with pool.acquire() as conn:
        async with conn.transaction():
            instr = await conn.fetchrow(
                """SELECT id, active_version, description, tags
                   FROM npl_instructions WHERE id = $1 FOR UPDATE""",
                uid,
            )
            if instr is None:
                return {"uuid": uuid, "status": "not_found"}

            # Get current body from active version
            current_ver = await conn.fetchrow(
                """SELECT body FROM npl_instruction_versions
                   WHERE instruction_id = $1 AND version = $2""",
                uid,
                instr["active_version"],
            )

            new_version = instr["active_version"] + 1
            new_body = body if body is not None else current_ver["body"]

            await conn.execute(
                """INSERT INTO npl_instruction_versions
                       (instruction_id, version, body, change_note, created_at)
                   VALUES ($1, $2, $3, $4, NOW())""",
                uid,
                new_version,
                new_body,
                change_note,
            )

            new_description = (
                description if description is not None else instr["description"]
            )
            new_tags = tags if tags is not None else instr["tags"]

            await conn.execute(
                """UPDATE npl_instructions
                   SET active_version = $1, description = $2, tags = $3, modified_at = NOW()
                   WHERE id = $4""",
                new_version,
                new_description,
                new_tags,
                uid,
            )

    return {"uuid": uuid, "version": new_version, "status": "ok"}


async def instructions_active_version(
    uuid: str,
    version: int,
) -> dict[str, Any]:
    """Change the active version (rollback or forward)."""
    uid = _decode(uuid)
    if uid is None:
        return {"uuid": uuid, "status": "error", "message": "Invalid UUID format."}

    pool = await get_pool()

    ver = await pool.fetchrow(
        """SELECT version FROM npl_instruction_versions
           WHERE instruction_id = $1 AND version = $2""",
        uid,
        version,
    )
    if ver is None:
        return {
            "uuid": uuid,
            "status": "error",
            "message": f"Version {version} not found.",
        }

    await pool.execute(
        "UPDATE npl_instructions SET active_version = $1, modified_at = NOW() WHERE id = $2",
        version,
        uid,
    )

    return {"uuid": _encode(uid), "active_version": version, "status": "ok"}


async def instructions_versions(
    uuid: str,
) -> dict[str, Any]:
    """List all versions with change notes."""
    uid = _decode(uuid)
    if uid is None:
        return {"uuid": uuid, "status": "error", "message": "Invalid UUID format."}

    pool = await get_pool()

    instr = await pool.fetchrow(
        "SELECT id, active_version FROM npl_instructions WHERE id = $1",
        uid,
    )
    if instr is None:
        return {"uuid": uuid, "status": "not_found"}

    rows = await pool.fetch(
        """SELECT version, change_note, created_at
           FROM npl_instruction_versions
           WHERE instruction_id = $1
           ORDER BY version ASC""",
        uid,
    )

    versions = [
        {
            "version": r["version"],
            "change_note": r["change_note"],
            "created_at": r["created_at"].isoformat() if r["created_at"] else None,
            "is_active": r["version"] == instr["active_version"],
        }
        for r in rows
    ]

    return {
        "uuid": _encode(uid),
        "active_version": instr["active_version"],
        "versions": versions,
        "status": "ok",
    }
