"""Artifacts module — thin CRUD over ``npl_artifacts`` + ``npl_artifact_revisions``.

MVP scope (PRD-002): versioned text artifacts. Each artifact has a title,
a free-form ``kind`` (markdown / json / yaml / code / …), and a history
of revisions whose bodies are stored as ``TEXT`` (no binary yet). The
``latest_revision`` column on ``npl_artifacts`` is kept in sync whenever
a new revision is added.

Return envelope convention
--------------------------
Every function returns ``{"status": "ok" | "error" | "not_found", ...}``.
Success payloads inline the entity fields next to ``status: "ok"``.
"""

from __future__ import annotations

from typing import Any, Optional

from npl_mcp.storage import get_pool


VALID_KINDS = {
    "markdown", "json", "yaml", "code", "text", "other",
    "image", "video", "audio", "pdf", "binary",
}
BINARY_KINDS = {"image", "video", "audio", "pdf", "binary"}
_DEFAULT_KIND = "markdown"
MAX_BINARY_BYTES = 15 * 1024 * 1024  # 15 MB


def _artifact_row_to_dict(row) -> dict[str, Any]:
    return {
        "id": row["id"],
        "title": row["title"],
        "kind": row["kind"],
        "description": row["description"] or "",
        "created_by": row["created_by"],
        "latest_revision": row["latest_revision"],
        "created_at": row["created_at"].isoformat() if row["created_at"] else None,
        "updated_at": row["updated_at"].isoformat() if row["updated_at"] else None,
    }


def _revision_row_to_dict(row) -> dict[str, Any]:
    # Binary content is not serialized in the text body — frontend fetches it
    # separately via GET /api/artifacts/{id}/revisions/{n}/raw
    has_binary = False
    try:
        has_binary = row["binary_content"] is not None
    except (KeyError, IndexError):
        has_binary = False
    mime_type = None
    try:
        mime_type = row["mime_type"]
    except (KeyError, IndexError):
        mime_type = None
    return {
        "id": row["id"],
        "artifact_id": row["artifact_id"],
        "revision": row["revision"],
        "content": row["content"] if not has_binary else "",
        "mime_type": mime_type,
        "has_binary": has_binary,
        "notes": row["notes"],
        "created_by": row["created_by"],
        "created_at": row["created_at"].isoformat() if row["created_at"] else None,
    }


def _revision_summary(row) -> dict[str, Any]:
    """Lightweight revision dict without the body content."""
    return {
        "id": row["id"],
        "artifact_id": row["artifact_id"],
        "revision": row["revision"],
        "notes": row["notes"],
        "created_by": row["created_by"],
        "created_at": row["created_at"].isoformat() if row["created_at"] else None,
    }


async def artifact_create(
    title: str,
    content: str = "",
    kind: str = _DEFAULT_KIND,
    description: Optional[str] = None,
    created_by: Optional[str] = None,
    notes: Optional[str] = None,
    binary_content: Optional[bytes] = None,
    mime_type: Optional[str] = None,
) -> dict[str, Any]:
    """Create a new artifact with its initial revision (revision = 1).

    For text kinds (markdown/json/yaml/code/text/other) pass ``content``.
    For binary kinds (image/video/audio/pdf/binary) pass ``binary_content``
    (bytes) and ``mime_type``.
    """
    if not title or not title.strip():
        return {"status": "error", "message": "title must be a non-empty string."}
    if kind not in VALID_KINDS:
        return {
            "status": "error",
            "message": f"Invalid kind '{kind}'. Must be one of: {', '.join(sorted(VALID_KINDS))}",
        }
    if kind in BINARY_KINDS:
        if binary_content is None:
            return {"status": "error", "message": f"binary_content required for kind '{kind}'."}
        if len(binary_content) > MAX_BINARY_BYTES:
            return {
                "status": "error",
                "message": f"binary_content exceeds {MAX_BINARY_BYTES // (1024 * 1024)} MB cap.",
            }
        content = content or ""
    else:
        if content is None:
            return {"status": "error", "message": "content must be provided."}
        binary_content = None

    pool = await get_pool()

    artifact_row = await pool.fetchrow(
        """
        INSERT INTO npl_artifacts (title, kind, description, created_by, latest_revision)
        VALUES ($1, $2, $3, $4, 1)
        RETURNING id, title, kind, description, created_by, latest_revision,
                  created_at, updated_at
        """,
        title.strip(),
        kind,
        description,
        created_by,
    )

    revision_row = await pool.fetchrow(
        """
        INSERT INTO npl_artifact_revisions
            (artifact_id, revision, content, mime_type, binary_content, notes, created_by)
        VALUES ($1, 1, $2, $3, $4, $5, $6)
        RETURNING id, artifact_id, revision, content, mime_type, binary_content,
                  notes, created_by, created_at
        """,
        artifact_row["id"],
        content,
        mime_type,
        binary_content,
        notes,
        created_by,
    )

    result = _artifact_row_to_dict(artifact_row)
    result["status"] = "ok"
    result["revision"] = _revision_row_to_dict(revision_row)
    return result


async def artifact_add_revision(
    artifact_id: int,
    content: str = "",
    notes: Optional[str] = None,
    created_by: Optional[str] = None,
    binary_content: Optional[bytes] = None,
    mime_type: Optional[str] = None,
) -> dict[str, Any]:
    """Append a new revision to an existing artifact.

    Increments ``npl_artifacts.latest_revision`` and refreshes
    ``updated_at``. Returns the new revision + updated artifact.
    Binary/text shape follows the parent artifact's ``kind``.
    """
    try:
        aid = int(artifact_id)
    except (TypeError, ValueError):
        return {"status": "error", "message": "artifact_id must be an integer."}

    pool = await get_pool()
    existing = await pool.fetchrow(
        "SELECT id, kind, latest_revision FROM npl_artifacts WHERE id = $1",
        aid,
    )
    if existing is None:
        return {"status": "not_found", "id": aid}

    parent_kind = existing["kind"]
    if parent_kind in BINARY_KINDS:
        if binary_content is None:
            return {
                "status": "error",
                "message": f"binary_content required for kind '{parent_kind}'.",
            }
        if len(binary_content) > MAX_BINARY_BYTES:
            return {
                "status": "error",
                "message": f"binary_content exceeds {MAX_BINARY_BYTES // (1024 * 1024)} MB cap.",
            }
        content = content or ""
    else:
        if content is None:
            return {"status": "error", "message": "content must be provided."}
        binary_content = None

    new_rev_num = int(existing["latest_revision"]) + 1

    revision_row = await pool.fetchrow(
        """
        INSERT INTO npl_artifact_revisions
            (artifact_id, revision, content, mime_type, binary_content, notes, created_by)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING id, artifact_id, revision, content, mime_type, binary_content,
                  notes, created_by, created_at
        """,
        aid,
        new_rev_num,
        content,
        mime_type,
        binary_content,
        notes,
        created_by,
    )

    artifact_row = await pool.fetchrow(
        """
        UPDATE npl_artifacts
        SET latest_revision = $1, updated_at = NOW()
        WHERE id = $2
        RETURNING id, title, kind, description, created_by, latest_revision,
                  created_at, updated_at
        """,
        new_rev_num,
        aid,
    )

    result = _artifact_row_to_dict(artifact_row)
    result["status"] = "ok"
    result["revision"] = _revision_row_to_dict(revision_row)
    return result


async def artifact_get(
    artifact_id: int,
    revision: Optional[int] = None,
) -> dict[str, Any]:
    """Fetch an artifact + one of its revisions' body.

    If ``revision`` is omitted, the latest revision is loaded.
    """
    try:
        aid = int(artifact_id)
    except (TypeError, ValueError):
        return {"status": "error", "message": "artifact_id must be an integer."}

    pool = await get_pool()
    artifact_row = await pool.fetchrow(
        """SELECT id, title, kind, description, created_by, latest_revision,
                  created_at, updated_at
           FROM npl_artifacts
           WHERE id = $1""",
        aid,
    )
    if artifact_row is None:
        return {"status": "not_found", "id": aid}

    target_rev = revision if revision is not None else artifact_row["latest_revision"]
    try:
        rev_num = int(target_rev)
    except (TypeError, ValueError):
        return {"status": "error", "message": "revision must be an integer."}

    revision_row = await pool.fetchrow(
        """SELECT id, artifact_id, revision, content, mime_type, binary_content,
                  notes, created_by, created_at
           FROM npl_artifact_revisions
           WHERE artifact_id = $1 AND revision = $2""",
        aid,
        rev_num,
    )
    if revision_row is None:
        return {
            "status": "error",
            "message": f"Revision {rev_num} not found for artifact {aid}.",
        }

    result = _artifact_row_to_dict(artifact_row)
    result["status"] = "ok"
    result["revision"] = _revision_row_to_dict(revision_row)
    return result


async def artifact_list(
    kind: Optional[str] = None,
    limit: int = 100,
) -> dict[str, Any]:
    """List artifacts (head rows only — no revision bodies)."""
    if kind is not None and kind not in VALID_KINDS:
        return {
            "status": "error",
            "message": f"Invalid kind '{kind}'. Must be one of: {', '.join(sorted(VALID_KINDS))}",
        }
    try:
        lim = max(1, min(500, int(limit)))
    except (TypeError, ValueError):
        lim = 100

    clauses: list[str] = []
    params: list[Any] = []
    idx = 1
    if kind is not None:
        clauses.append(f"kind = ${idx}")
        params.append(kind)
        idx += 1
    where = f"WHERE {' AND '.join(clauses)}" if clauses else ""
    params.append(lim)

    pool = await get_pool()
    rows = await pool.fetch(
        f"""SELECT id, title, kind, description, created_by, latest_revision,
                   created_at, updated_at
            FROM npl_artifacts
            {where}
            ORDER BY updated_at DESC
            LIMIT ${idx}""",
        *params,
    )
    return {
        "status": "ok",
        "artifacts": [_artifact_row_to_dict(r) for r in rows],
        "count": len(rows),
    }


async def artifact_list_revisions(artifact_id: int) -> dict[str, Any]:
    """List all revisions for an artifact (summaries, no body content)."""
    try:
        aid = int(artifact_id)
    except (TypeError, ValueError):
        return {"status": "error", "message": "artifact_id must be an integer."}

    pool = await get_pool()
    exists = await pool.fetchval("SELECT id FROM npl_artifacts WHERE id = $1", aid)
    if exists is None:
        return {"status": "not_found", "id": aid}

    rows = await pool.fetch(
        """SELECT id, artifact_id, revision, notes, created_by, created_at
           FROM npl_artifact_revisions
           WHERE artifact_id = $1
           ORDER BY revision ASC""",
        aid,
    )
    return {
        "status": "ok",
        "artifact_id": aid,
        "revisions": [_revision_summary(r) for r in rows],
        "count": len(rows),
    }


async def artifact_get_binary(
    artifact_id: int,
    revision: Optional[int] = None,
) -> dict[str, Any]:
    """Fetch raw binary content + mime_type for a revision.

    Returns {"status": "ok", "binary_content": bytes, "mime_type": str, ...}
    or {"status": "not_found"} / {"status": "error"}.
    """
    try:
        aid = int(artifact_id)
    except (TypeError, ValueError):
        return {"status": "error", "message": "artifact_id must be an integer."}

    pool = await get_pool()
    artifact_row = await pool.fetchrow(
        "SELECT latest_revision, title FROM npl_artifacts WHERE id = $1",
        aid,
    )
    if artifact_row is None:
        return {"status": "not_found", "id": aid}

    target_rev = revision if revision is not None else artifact_row["latest_revision"]
    try:
        rev_num = int(target_rev)
    except (TypeError, ValueError):
        return {"status": "error", "message": "revision must be an integer."}

    row = await pool.fetchrow(
        """SELECT binary_content, mime_type
           FROM npl_artifact_revisions
           WHERE artifact_id = $1 AND revision = $2""",
        aid,
        rev_num,
    )
    if row is None:
        return {"status": "not_found", "id": aid, "revision": rev_num}
    if row["binary_content"] is None:
        return {"status": "error", "message": "This revision has no binary content."}
    return {
        "status": "ok",
        "binary_content": bytes(row["binary_content"]),
        "mime_type": row["mime_type"] or "application/octet-stream",
        "title": artifact_row["title"],
        "revision": rev_num,
    }
