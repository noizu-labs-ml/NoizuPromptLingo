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


async def _validate_session(session: str) -> tuple[Optional[_uuid_mod.UUID], Optional[dict]]:
    """Decode and validate a session UUID string.

    Returns ``(session_uuid, None)`` on success, or ``(None, error_dict)`` on failure.
    """
    uid = _decode(session)
    if uid is None:
        return None, {"status": "error", "message": f"Invalid session UUID: {session}"}
    pool = await get_pool()
    exists = await pool.fetchval("SELECT id FROM npl_tool_sessions WHERE id = $1", uid)
    if exists is None:
        return None, {"status": "error", "message": f"Session not found: {session}"}
    return uid, None


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
    session: Optional[str] = None,
) -> dict[str, Any]:
    """Create a new instruction with its first version (v1).

    If *session* is provided it must be a valid tool-session UUID; the
    instruction will be linked to that session.
    """
    if not title:
        return {"status": "error", "message": "title must be a non-empty string."}
    if not body:
        return {"status": "error", "message": "body must be a non-empty string."}

    session_id: Optional[_uuid_mod.UUID] = None
    if session is not None:
        session_id, err = await _validate_session(session)
        if err is not None:
            return err

    pool = await get_pool()

    async with pool.acquire() as conn:
        async with conn.transaction():
            instruction_id = await conn.fetchval(
                """
                INSERT INTO npl_instructions
                    (title, description, tags, active_version, session_id, created_at, updated_at)
                VALUES ($1, $2, $3, 1, $4, NOW(), NOW())
                RETURNING id
                """,
                title,
                description,
                tags,
                session_id,
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

    # Generate embeddings (best-effort, non-blocking on failure)
    from npl_mcp.instructions.embeddings import generate_and_store_embeddings
    await generate_and_store_embeddings(
        instruction_id=instruction_id,
        title=title,
        description=description,
        tags=tags,
        body=body,
    )

    result: dict[str, Any] = {"uuid": _encode(instruction_id), "version": 1, "status": "ok"}
    if session is not None:
        result["session"] = session
    return result


async def instructions_get(
    uuid: str,
    version: Optional[int] = None,
    json: bool = False,
    session: Optional[str] = None,
) -> dict[str, Any] | str:
    """Retrieve instruction body.  Active version if *version* is ``None``.

    If *session* is provided it is validated (must exist) as a gate check.

    When *json* is ``False`` (default) returns a Markdown document::

        # {title}
        ---

        {body}

    When *json* is ``True`` returns the full metadata dict.
    """
    uid = _decode(uuid)
    if uid is None:
        return {"uuid": uuid, "status": "error", "message": "Invalid UUID format."}

    # Validate session if provided
    if session is not None:
        _, err = await _validate_session(session)
        if err is not None:
            return err

    pool = await get_pool()

    instr = await pool.fetchrow(
        "SELECT id, title, description, tags, active_version, session_id FROM npl_instructions WHERE id = $1",
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

    if not json:
        return f"# {instr['title']}\n---\n\n{ver['body']}"

    result = {
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
    if instr["session_id"] is not None:
        result["session"] = _encode(instr["session_id"])
    return result


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
                """SELECT id, title, active_version, description, tags
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
                   SET active_version = $1, description = $2, tags = $3, updated_at = NOW()
                   WHERE id = $4""",
                new_version,
                new_description,
                new_tags,
                uid,
            )

    # Re-generate embeddings with updated content (best-effort)
    from npl_mcp.instructions.embeddings import generate_and_store_embeddings
    await generate_and_store_embeddings(
        instruction_id=uid,
        title=instr["title"],
        description=new_description,
        tags=new_tags,
        body=new_body,
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
        "UPDATE npl_instructions SET active_version = $1, updated_at = NOW() WHERE id = $2",
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


# ---------------------------------------------------------------------------
# Instructions.List -- search and list
# ---------------------------------------------------------------------------


def _row_to_dict(row: dict, include_score: bool = False) -> dict[str, Any]:
    """Convert a DB row to an instruction summary dict."""
    result: dict[str, Any] = {
        "uuid": _encode(row["id"]),
        "title": row["title"],
        "description": row["description"],
        "tags": row["tags"],
        "active_version": row["active_version"],
        "updated_at": row["updated_at"].isoformat() if row["updated_at"] else None,
    }
    if row["session_id"] is not None:
        result["session"] = _encode(row["session_id"])
    if include_score and "score" in row.keys():
        result["similarity"] = round(1.0 - float(row["score"]), 4)
    return result


async def _list_all(pool, tags: list[str] | None, limit: int) -> dict[str, Any]:
    """Return all instructions, optionally filtered by tags."""
    if tags:
        rows = await pool.fetch(
            """SELECT id, title, description, tags, active_version,
                      session_id, created_at, updated_at
               FROM npl_instructions
               WHERE tags @> $1
               ORDER BY updated_at DESC
               LIMIT $2""",
            tags,
            limit,
        )
    else:
        rows = await pool.fetch(
            """SELECT id, title, description, tags, active_version,
                      session_id, created_at, updated_at
               FROM npl_instructions
               ORDER BY updated_at DESC
               LIMIT $1""",
            limit,
        )

    return {
        "mode": "all",
        "total": len(rows),
        "instructions": [_row_to_dict(r) for r in rows],
        "status": "ok",
    }


async def _text_search(
    pool, query: str, tags: list[str] | None, limit: int
) -> dict[str, Any]:
    """ILIKE search across title, description, tags, and embedding labels."""
    pattern = f"%{query}%"

    if tags:
        rows = await pool.fetch(
            """SELECT DISTINCT i.id, i.title, i.description, i.tags,
                      i.active_version, i.session_id, i.created_at, i.updated_at
               FROM npl_instructions i
               LEFT JOIN npl_instruction_embeddings e ON e.instruction_id = i.id
               WHERE (i.title ILIKE $1
                      OR i.description ILIKE $1
                      OR EXISTS (SELECT 1 FROM unnest(i.tags) t WHERE t ILIKE $1)
                      OR e.label ILIKE $1)
                 AND i.tags @> $2
               ORDER BY i.updated_at DESC
               LIMIT $3""",
            pattern,
            tags,
            limit,
        )
    else:
        rows = await pool.fetch(
            """SELECT DISTINCT i.id, i.title, i.description, i.tags,
                      i.active_version, i.session_id, i.created_at, i.updated_at
               FROM npl_instructions i
               LEFT JOIN npl_instruction_embeddings e ON e.instruction_id = i.id
               WHERE i.title ILIKE $1
                     OR i.description ILIKE $1
                     OR EXISTS (SELECT 1 FROM unnest(i.tags) t WHERE t ILIKE $1)
                     OR e.label ILIKE $1
               ORDER BY i.updated_at DESC
               LIMIT $2""",
            pattern,
            limit,
        )

    return {
        "mode": "text",
        "query": query,
        "total": len(rows),
        "instructions": [_row_to_dict(r) for r in rows],
        "status": "ok",
    }


async def _intent_search(
    pool, query: str, tags: list[str] | None, limit: int
) -> dict[str, Any]:
    """Embed query and search by cosine similarity."""
    from npl_mcp.meta_tools.llm_client import embed_texts

    try:
        vectors = await embed_texts([query])
        query_vector = vectors[0]
    except Exception as e:
        # Fall back to text search if embedding fails
        result = await _text_search(pool, query, tags, limit)
        result["mode"] = "intent"
        result["fallback"] = True
        result["fallback_reason"] = f"{type(e).__name__}: {e}"
        return result

    vector_str = str(query_vector)

    if tags:
        rows = await pool.fetch(
            """SELECT i.id, i.title, i.description, i.tags, i.active_version,
                      i.session_id, i.created_at, i.updated_at,
                      MIN(e.embedding <=> $1::vector) AS score
               FROM npl_instructions i
               JOIN npl_instruction_embeddings e ON e.instruction_id = i.id
               WHERE i.tags @> $2
               GROUP BY i.id, i.title, i.description, i.tags, i.active_version,
                        i.session_id, i.created_at, i.updated_at
               ORDER BY score ASC
               LIMIT $3""",
            vector_str,
            tags,
            limit,
        )
    else:
        rows = await pool.fetch(
            """SELECT i.id, i.title, i.description, i.tags, i.active_version,
                      i.session_id, i.created_at, i.updated_at,
                      MIN(e.embedding <=> $1::vector) AS score
               FROM npl_instructions i
               JOIN npl_instruction_embeddings e ON e.instruction_id = i.id
               GROUP BY i.id, i.title, i.description, i.tags, i.active_version,
                        i.session_id, i.created_at, i.updated_at
               ORDER BY score ASC
               LIMIT $2""",
            vector_str,
            limit,
        )

    return {
        "mode": "intent",
        "query": query,
        "total": len(rows),
        "instructions": [_row_to_dict(r, include_score=True) for r in rows],
        "status": "ok",
    }


async def instructions_list(
    session: Optional[str] = None,
    query: Optional[str] = None,
    mode: str = "text",
    tags: Optional[list[str]] = None,
    limit: int = 20,
) -> dict[str, Any]:
    """List and search instructions.

    Modes:
        - ``"text"``: ILIKE search on title, description, tags, and embedding labels.
        - ``"intent"``: Embed query via LLM, cosine similarity search.
        - ``"all"``: Return all instructions (no search filter).

    Args:
        session: Valid tool-session UUID (required for access gating).
        query: Search query string (required for text/intent modes).
        mode: Search mode -- ``"text"``, ``"intent"``, or ``"all"``.
        tags: Optional tag filter (AND logic).
        limit: Maximum results (default 20, max 100).

    Returns:
        Dict with matching instructions and metadata.
    """
    if session is not None:
        _, err = await _validate_session(session)
        if err is not None:
            return err

    limit = min(max(1, limit), 100)

    pool = await get_pool()

    if mode == "intent" and query:
        return await _intent_search(pool, query, tags, limit)
    elif mode == "text" and query:
        return await _text_search(pool, query, tags, limit)
    else:
        return await _list_all(pool, tags, limit)
