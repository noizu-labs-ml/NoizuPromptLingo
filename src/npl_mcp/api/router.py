"""Read-only JSON REST API router for the NPL MCP server.

Mounts under ``/api`` in the main FastAPI app.  All endpoints are
GET-only and return JSON.  DB unavailability returns 503.
"""

from __future__ import annotations

import asyncio
import datetime
import glob
import os
import re
import shortuuid
import time
import yaml
from pathlib import Path
from typing import Any, Optional

from fastapi import APIRouter, File, Form, HTTPException, Query, UploadFile
from fastapi.responses import Response
from pydantic import BaseModel

router = APIRouter(prefix="/api", tags=["api"])


# ---------------------------------------------------------------------------
# Health endpoints
# ---------------------------------------------------------------------------

@router.get("/health/ping")
async def health_ping() -> dict:
    """Liveness probe — no dependency checks."""
    return {
        "status": "ok",
        "ts": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    }


@router.get("/health")
async def health_check() -> dict:
    """Comprehensive health report for all subsystems."""
    report: dict[str, Any] = {}

    # ── server ───────────────────────────────────────────────────────────
    try:
        from npl_mcp.launcher import _STARTED_AT
        uptime = (datetime.datetime.now(datetime.timezone.utc) - _STARTED_AT).total_seconds()
    except Exception:
        uptime = -1.0

    try:
        import fastmcp
        fmcp_version = getattr(fastmcp, "__version__", "unknown")
    except Exception:
        fmcp_version = "unknown"

    report["server"] = {
        "status": "ok",
        "uptime_seconds": max(0.0, uptime),
        "fastmcp_version": fmcp_version,
    }

    # ── database ─────────────────────────────────────────────────────────
    try:
        from npl_mcp.storage.pool import get_pool
        pool = await asyncio.wait_for(get_pool(), timeout=2.0)
        t0 = time.monotonic()
        await asyncio.wait_for(pool.fetchval("SELECT 1"), timeout=2.0)
        latency_ms = round((time.monotonic() - t0) * 1000, 2)
        report["database"] = {"status": "ok", "latency_ms": latency_ms}
    except Exception as exc:
        report["database"] = {"status": "unavailable", "message": str(exc)}

    # ── litellm ──────────────────────────────────────────────────────────
    litellm_url = os.environ.get("NPL_LITELLM_URL", "").strip()
    if not litellm_url:
        report["litellm"] = {"status": "not_configured"}
    else:
        try:
            import httpx
            t0 = time.monotonic()
            async with httpx.AsyncClient(timeout=2.0) as client:
                resp = await client.get(f"{litellm_url}/models")
            latency_ms = round((time.monotonic() - t0) * 1000, 2)
            if resp.status_code < 500:
                report["litellm"] = {
                    "status": "ok",
                    "url": litellm_url,
                    "latency_ms": latency_ms,
                }
            else:
                report["litellm"] = {
                    "status": "unavailable",
                    "url": litellm_url,
                    "message": f"HTTP {resp.status_code}",
                }
        except Exception as exc:
            report["litellm"] = {
                "status": "unavailable",
                "url": litellm_url,
                "message": str(exc),
            }

    # ── catalog ──────────────────────────────────────────────────────────
    try:
        from npl_mcp.meta_tools.catalog import (
            build_catalog,
            _DISCOVERABLE_TOOLS,
            _MCP_TOOL_CATEGORIES,
        )
        try:
            from npl_mcp.meta_tools.stub_catalog import STUB_CATALOG
            stub_count = len(STUB_CATALOG)
        except Exception:
            stub_count = 0

        catalog = await build_catalog()
        total = len(catalog)
        mcp_count = len(_MCP_TOOL_CATEGORIES)
        hidden_count = len(_DISCOVERABLE_TOOLS)
        report["catalog"] = {
            "status": "ok",
            "tool_count": total,
            "mcp_tools": mcp_count,
            "hidden_tools": hidden_count,
            "stub_tools": stub_count,
        }
    except Exception as exc:
        report["catalog"] = {"status": "unavailable", "message": str(exc)}

    # ── frontend_build ───────────────────────────────────────────────────
    try:
        dist_path = Path(__file__).resolve().parents[1] / "web" / "static"
        index_html = dist_path / "index.html"
        if index_html.exists():
            report["frontend_build"] = {
                "status": "ok",
                "dist_path": str(dist_path),
            }
        else:
            report["frontend_build"] = {
                "status": "missing",
                "dist_path": str(dist_path),
            }
    except Exception as exc:
        report["frontend_build"] = {"status": "missing", "message": str(exc)}

    return report


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _tool_entry_to_json(entry: dict) -> dict:
    """Normalise a ToolEntry for JSON output (set → sorted list for tags)."""
    out = dict(entry)
    tags = out.get("tags")
    if isinstance(tags, set):
        out["tags"] = sorted(tags)
    elif tags is None:
        out["tags"] = []
    return out


def _dt(val: Any) -> Optional[str]:
    """Convert a datetime to ISO string with Z suffix, or None."""
    if val is None:
        return None
    ts = val.isoformat()
    if not ts.endswith("Z") and "+" not in ts:
        ts += "Z"
    return ts


def _uuid_str(val: Any) -> Optional[str]:
    """Convert a DB UUID (uuid.UUID or short-uuid str) to string, or None."""
    if val is None:
        return None
    try:
        return shortuuid.encode(val)
    except Exception:
        return str(val)


# ---------------------------------------------------------------------------
# Catalog endpoints (no DB)
# ---------------------------------------------------------------------------

@router.get("/catalog")
async def catalog_list() -> list[dict]:
    """List all tools in the catalog."""
    try:
        from npl_mcp.meta_tools.catalog import build_catalog
        entries = await build_catalog()
        return [_tool_entry_to_json(e) for e in entries]
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.get("/catalog/categories")
async def catalog_categories() -> list[dict]:
    """List all tool categories with counts."""
    try:
        from npl_mcp.meta_tools.catalog import get_categories
        return list(await get_categories())
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.get("/catalog/search")
async def catalog_search(
    q: str = Query(..., description="Search query"),
    mode: str = Query("text", description="Search mode: text or intent"),
) -> list[dict]:
    """Search catalog tools by name, description, or tags (substring)."""
    try:
        from npl_mcp.meta_tools.catalog import build_catalog
        catalog = await build_catalog()
        q_lower = q.lower()
        results = []
        for entry in catalog:
            name = entry.get("name", "").lower()
            desc = entry.get("description", "").lower()
            tags = entry.get("tags") or set()
            tag_str = " ".join(sorted(tags)).lower() if tags else ""
            if q_lower in name or q_lower in desc or q_lower in tag_str:
                results.append(_tool_entry_to_json(entry))
        return results
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.get("/catalog/tool/{name}")
async def catalog_tool(name: str) -> dict:
    """Get a single tool by name."""
    try:
        from npl_mcp.meta_tools.catalog import get_tool_by_name
        entry = await get_tool_by_name(name)
        if entry is None:
            raise HTTPException(status_code=404, detail=f"Tool '{name}' not found")
        return _tool_entry_to_json(entry)
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


# ---------------------------------------------------------------------------
# Sessions endpoints (DB-backed)
# ---------------------------------------------------------------------------

async def _get_db_pool():
    """Get the asyncpg pool, raising 503 if unavailable."""
    try:
        from npl_mcp.storage.pool import get_pool
        pool = await get_pool()
        return pool
    except Exception as exc:
        raise HTTPException(
            status_code=503,
            detail=f"Database unavailable: {exc}",
        ) from exc


@router.get("/sessions")
async def sessions_list(
    project: Optional[str] = Query(None),
    agent: Optional[str] = Query(None),
    search: Optional[str] = Query(None),
    limit: int = Query(50, ge=1, le=200),
) -> list[dict]:
    """List tool sessions with optional filtering."""
    pool = await _get_db_pool()
    try:
        conditions = ["1=1"]
        params: list[Any] = []
        idx = 1

        if project:
            conditions.append(f"p.name = ${idx}")
            params.append(project)
            idx += 1

        if agent:
            conditions.append(f"s.agent = ${idx}")
            params.append(agent)
            idx += 1

        if search:
            conditions.append(
                f"(s.brief ILIKE ${idx} OR s.notes ILIKE ${idx} OR s.task ILIKE ${idx})"
            )
            params.append(f"%{search}%")
            idx += 1

        where = " AND ".join(conditions)
        params.append(limit)

        rows = await pool.fetch(
            f"""SELECT s.id, s.agent, s.brief, s.task, s.project_id,
                        s.parent_id, s.notes, s.created_at, s.updated_at,
                        p.name AS project_name
                 FROM npl_tool_sessions s
                 JOIN npl_projects p ON s.project_id = p.id
                 WHERE {where}
                 ORDER BY s.updated_at DESC
                 LIMIT ${idx}""",
            *params,
        )

        return [
            {
                "uuid": _uuid_str(r["id"]),
                "agent": r["agent"],
                "brief": r["brief"],
                "task": r["task"],
                "project": r["project_name"],
                "parent": _uuid_str(r["parent_id"]),
                "notes": r["notes"],
                "created_at": _dt(r["created_at"]),
                "updated_at": _dt(r["updated_at"]),
            }
            for r in rows
        ]
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.get("/sessions/{uuid}/tree")
async def sessions_tree(uuid: str) -> dict:
    """Return a recursive tree rooted at the given session UUID."""
    pool = await _get_db_pool()
    try:
        import uuid as _uuid_mod

        # Decode the root UUID
        root_uid: Optional[_uuid_mod.UUID] = None
        try:
            root_uid = shortuuid.decode(uuid)
        except Exception:
            try:
                root_uid = _uuid_mod.UUID(uuid)
            except Exception:
                raise HTTPException(status_code=404, detail="Invalid UUID format")

        # Fetch the root session to get its project
        root_row = await pool.fetchrow(
            """SELECT s.id, s.agent, s.brief, s.task, s.project_id,
                       s.parent_id, s.notes, s.created_at, s.updated_at,
                       p.name AS project_name
                FROM npl_tool_sessions s
                JOIN npl_projects p ON s.project_id = p.id
                WHERE s.id = $1""",
            root_uid,
        )
        if root_row is None:
            raise HTTPException(status_code=404, detail="Session not found")

        project_id = root_row["project_id"]

        # Fetch all sessions in the same project
        all_rows = await pool.fetch(
            """SELECT s.id, s.agent, s.brief, s.task, s.project_id,
                       s.parent_id, s.notes, s.created_at, s.updated_at,
                       p.name AS project_name
                FROM npl_tool_sessions s
                JOIN npl_projects p ON s.project_id = p.id
                WHERE s.project_id = $1
                ORDER BY s.created_at ASC""",
            project_id,
        )

        def row_to_node(r) -> dict:
            return {
                "uuid": _uuid_str(r["id"]),
                "agent": r["agent"],
                "brief": r["brief"],
                "task": r["task"],
                "project": r["project_name"],
                "parent": _uuid_str(r["parent_id"]),
                "notes": r["notes"],
                "created_at": _dt(r["created_at"]),
                "updated_at": _dt(r["updated_at"]),
                "children": [],
            }

        # Build id → node map
        node_map: dict[str, dict] = {}
        for r in all_rows:
            uid_str = _uuid_str(r["id"])
            node_map[uid_str] = row_to_node(r)

        # Wire up children
        root_node_key = _uuid_str(root_uid)
        for uid_str, node in node_map.items():
            parent_key = node["parent_id"]
            if parent_key and parent_key in node_map and uid_str != root_node_key:
                node_map[parent_key]["children"].append(node)

        root_node = node_map.get(root_node_key)
        if root_node is None:
            raise HTTPException(status_code=404, detail="Session not found")
        return root_node

    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


class SessionNoteAppend(BaseModel):
    note: str


@router.post("/sessions/{uuid}/notes")
async def sessions_append_notes(uuid: str, body: SessionNoteAppend) -> dict:
    """Append a note to a session's notes (substring-deduped)."""
    if not body.note or not body.note.strip():
        raise HTTPException(status_code=400, detail="note must be a non-empty string")
    try:
        from npl_mcp.tool_sessions.tool_sessions import append_session_notes

        result = await append_session_notes(uuid, body.note)
        status = result.get("status")
        if status == "not_found":
            raise HTTPException(status_code=404, detail="Session not found")
        if status == "error":
            raise HTTPException(status_code=400, detail=result.get("message", "Invalid request"))
        return {
            "uuid": result["uuid"],
            "agent": result["agent"],
            "brief": result["brief"],
            "task": result["task"],
            "project": result["project"],
            "parent": result.get("parent"),
            "notes": result.get("notes"),
            "created_at": result.get("created_at"),
            "updated_at": result.get("updated_at"),
            "action": result.get("action", "appended"),
        }
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.get("/sessions/{uuid}")
async def sessions_get(uuid: str) -> dict:
    """Get a single session by UUID."""
    pool = await _get_db_pool()
    try:
        import uuid as _uuid_mod

        uid: Optional[_uuid_mod.UUID] = None
        try:
            uid = shortuuid.decode(uuid)
        except Exception:
            try:
                uid = _uuid_mod.UUID(uuid)
            except Exception:
                raise HTTPException(status_code=404, detail="Invalid UUID format")

        row = await pool.fetchrow(
            """SELECT s.id, s.agent, s.brief, s.task, s.project_id,
                       s.parent_id, s.notes, s.created_at, s.updated_at,
                       p.name AS project_name
                FROM npl_tool_sessions s
                JOIN npl_projects p ON s.project_id = p.id
                WHERE s.id = $1""",
            uid,
        )
        if row is None:
            raise HTTPException(status_code=404, detail="Session not found")

        return {
            "uuid": _uuid_str(row["id"]),
            "agent": row["agent"],
            "brief": row["brief"],
            "task": row["task"],
            "project": row["project_name"],
            "parent": _uuid_str(row["parent_id"]),
            "notes": row["notes"],
            "created_at": _dt(row["created_at"]),
            "updated_at": _dt(row["updated_at"]),
        }
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


# ---------------------------------------------------------------------------
# Instructions endpoints
# ---------------------------------------------------------------------------

@router.get("/instructions")
async def instructions_list(
    query: Optional[str] = Query(None),
    mode: str = Query("text"),
    tags: Optional[str] = Query(None, description="Comma-separated tag list"),
    limit: int = Query(20, ge=1, le=100),
) -> list[dict]:
    """List/search instruction documents (no session auth for read)."""
    pool = await _get_db_pool()
    try:
        tag_list: Optional[list[str]] = None
        if tags:
            tag_list = [t.strip() for t in tags.split(",") if t.strip()]

        # Reuse the internal helpers from instructions module
        from npl_mcp.instructions.instructions import (
            _list_all, _text_search, _intent_search
        )

        if mode == "intent" and query:
            result = await _intent_search(pool, query, tag_list, limit)
        elif query:
            result = await _text_search(pool, query, tag_list, limit)
        else:
            result = await _list_all(pool, tag_list, limit)

        raw = result.get("instructions", [])
        # Normalize to frontend Instruction type: session_id (not session), created_at present
        normalized = []
        for item in raw:
            normalized.append({
                "uuid": item.get("uuid"),
                "title": item.get("title"),
                "description": item.get("description"),
                "tags": item.get("tags") or [],
                "active_version": item.get("active_version"),
                "session_id": item.get("session") or item.get("session_id"),
                "created_at": item.get("created_at"),
                "updated_at": item.get("updated_at"),
            })
        return normalized
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.get("/instructions/{uuid}")
async def instructions_get(uuid: str) -> dict:
    """Get a single instruction with all versions."""
    pool = await _get_db_pool()
    try:
        import uuid as _uuid_mod
        import shortuuid as _su

        uid: Optional[_uuid_mod.UUID] = None
        try:
            uid = _su.decode(uuid)
        except Exception:
            try:
                uid = _uuid_mod.UUID(uuid)
            except Exception:
                raise HTTPException(status_code=404, detail="Invalid UUID format")

        instr = await pool.fetchrow(
            """SELECT id, title, description, tags, active_version,
                      session_id, created_at, updated_at
               FROM npl_instructions WHERE id = $1""",
            uid,
        )
        if instr is None:
            raise HTTPException(status_code=404, detail="Instruction not found")

        versions = await pool.fetch(
            """SELECT version, body, change_note, created_at
               FROM npl_instruction_versions
               WHERE instruction_id = $1
               ORDER BY version ASC""",
            uid,
        )

        return {
            "uuid": _uuid_str(instr["id"]),
            "title": instr["title"],
            "description": instr["description"],
            "tags": instr["tags"] or [],
            "active_version": instr["active_version"],
            "session_id": _uuid_str(instr["session_id"]),
            "created_at": _dt(instr["created_at"]),
            "updated_at": _dt(instr["updated_at"]),
            "versions": [
                {
                    "version": v["version"],
                    "body": v["body"],
                    "change_note": v["change_note"],
                    "created_at": _dt(v["created_at"]),
                }
                for v in versions
            ],
        }
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


class InstructionCreateBody(BaseModel):
    title: str
    description: str = ""
    tags: list[str] = []
    body: str = ""
    session: Optional[str] = None


@router.post("/instructions")
async def instructions_create_endpoint(body: InstructionCreateBody) -> dict:
    """Create a new instruction document with its first version."""
    try:
        from npl_mcp.instructions.instructions import instructions_create
        result = await instructions_create(
            title=body.title,
            description=body.description,
            tags=body.tags,
            body=body.body,
            session=body.session,
        )
        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message", "Invalid request"))
        if result.get("status") == "not_found":
            raise HTTPException(status_code=404, detail="Not found")
        # instructions_create returns {"uuid": ..., "version": 1, "status": "ok"}
        # Fetch the full record to return consistent shape with GET /instructions/{uuid}
        uuid_val = result.get("uuid")
        if uuid_val:
            import uuid as _uuid_mod
            import shortuuid as _su
            try:
                uid = _su.decode(uuid_val)
            except Exception:
                uid = _uuid_mod.UUID(uuid_val)
            pool = await _get_db_pool()
            instr = await pool.fetchrow(
                """SELECT id, title, description, tags, active_version,
                          session_id, created_at, updated_at
                   FROM npl_instructions WHERE id = $1""",
                uid,
            )
            if instr:
                return {
                    "uuid": uuid_val,
                    "title": instr["title"],
                    "description": instr["description"] or "",
                    "tags": instr["tags"] or [],
                    "active_version": instr["active_version"],
                    "session_id": _uuid_str(instr["session_id"]),
                    "created_at": _dt(instr["created_at"]),
                    "updated_at": _dt(instr["updated_at"]),
                }
        return result
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


# ---------------------------------------------------------------------------
# Projects endpoints
# ---------------------------------------------------------------------------

@router.get("/projects")
async def projects_list() -> list[dict]:
    """List all projects with persona and story counts."""
    pool = await _get_db_pool()
    try:
        rows = await pool.fetch(
            """SELECT p.id, p.name, p.title, p.description, p.created_at,
                      (SELECT COUNT(*) FROM npl_user_personas up
                       WHERE up.project_id = p.id AND up.deleted_at IS NULL) AS persona_count,
                      (SELECT COUNT(*) FROM npl_user_stories us
                       WHERE us.project_id = p.id AND us.deleted_at IS NULL) AS story_count
               FROM npl_projects p
               WHERE p.deleted_at IS NULL
               ORDER BY p.created_at DESC"""
        )
        return [
            {
                "id": _uuid_str(r["id"]),
                "name": r["name"],
                "title": r.get("title") or r["name"],
                "description": r["description"] or "",
                "created_at": _dt(r["created_at"]),
                "persona_count": r["persona_count"],
                "story_count": r["story_count"],
            }
            for r in rows
        ]
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.get("/projects/{id}")
async def projects_get(id: str) -> dict:
    """Get a single project by ID."""
    pool = await _get_db_pool()
    try:
        import uuid as _uuid_mod
        import shortuuid as _su

        uid: Optional[_uuid_mod.UUID] = None
        try:
            uid = _su.decode(id)
        except Exception:
            try:
                uid = _uuid_mod.UUID(id)
            except Exception:
                raise HTTPException(status_code=404, detail="Invalid UUID format")

        row = await pool.fetchrow(
            """SELECT p.id, p.name, p.title, p.description, p.created_at,
                      (SELECT COUNT(*) FROM npl_user_personas up
                       WHERE up.project_id = p.id AND up.deleted_at IS NULL) AS persona_count,
                      (SELECT COUNT(*) FROM npl_user_stories us
                       WHERE us.project_id = p.id AND us.deleted_at IS NULL) AS story_count
               FROM npl_projects p
               WHERE p.id = $1 AND p.deleted_at IS NULL""",
            uid,
        )
        if row is None:
            raise HTTPException(status_code=404, detail="Project not found")

        return {
            "id": _uuid_str(row["id"]),
            "name": row["name"],
            "title": row.get("title") or row["name"],
            "description": row["description"] or "",
            "created_at": _dt(row["created_at"]),
            "persona_count": row["persona_count"],
            "story_count": row["story_count"],
        }
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


class ProjectCreateBody(BaseModel):
    name: str
    title: str = ""
    description: str = ""


@router.post("/projects")
async def projects_create_endpoint(body: ProjectCreateBody) -> dict:
    """Create a new project."""
    try:
        import uuid as _uuid_mod
        import shortuuid as _su
        pool = await _get_db_pool()
        row = await pool.fetchrow(
            """
            INSERT INTO npl_projects (name, title, description, created_at, updated_at)
            VALUES ($1, $2, $3, NOW(), NOW())
            RETURNING id, name, title, description, created_at
            """,
            body.name,
            body.title or body.name,
            body.description,
        )
        return {
            "id": _uuid_str(row["id"]),
            "name": row["name"],
            "title": row.get("title") or row["name"],
            "description": row["description"] or "",
            "persona_count": 0,
            "story_count": 0,
            "created_at": _dt(row["created_at"]),
        }
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.get("/projects/{id}/personas")
async def projects_personas(id: str) -> list[dict]:
    """List personas for a project."""
    pool = await _get_db_pool()
    try:
        import uuid as _uuid_mod
        import json
        import shortuuid as _su

        uid: Optional[_uuid_mod.UUID] = None
        try:
            uid = _su.decode(id)
        except Exception:
            try:
                uid = _uuid_mod.UUID(id)
            except Exception:
                raise HTTPException(status_code=404, detail="Invalid UUID format")

        # Verify project exists
        exists = await pool.fetchval(
            "SELECT id FROM npl_projects WHERE id = $1 AND deleted_at IS NULL", uid
        )
        if exists is None:
            raise HTTPException(status_code=404, detail="Project not found")

        rows = await pool.fetch(
            """SELECT id, project_id, name, role, description, goals, pain_points,
                      behaviors, physical_description, persona_image, demographics,
                      created_by, created_at, updated_at
               FROM npl_user_personas
               WHERE project_id = $1 AND deleted_at IS NULL
               ORDER BY created_at DESC""",
            uid,
        )
        return [
            {
                "id": _uuid_str(r["id"]),
                "project_id": _uuid_str(r["project_id"]),
                "name": r["name"],
                "role": r["role"] or "",
                "description": r["description"] or "",
                "goals": r["goals"] or [],
                "pain_points": r["pain_points"] or [],
                "behaviors": r["behaviors"] or [],
                "image": r["persona_image"],
                "demographics": json.loads(r["demographics"]) if r["demographics"] else {},
                "created_at": _dt(r["created_at"]),
                "updated_at": _dt(r["updated_at"]),
            }
            for r in rows
        ]
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.get("/projects/{id}/stories")
async def projects_stories(
    id: str,
    status: Optional[str] = Query(None),
    priority: Optional[str] = Query(None),
    persona_id: Optional[str] = Query(None),
) -> list[dict]:
    """List stories for a project with optional filtering."""
    pool = await _get_db_pool()
    try:
        import uuid as _uuid_mod
        import shortuuid as _su

        uid: Optional[_uuid_mod.UUID] = None
        try:
            uid = _su.decode(id)
        except Exception:
            try:
                uid = _uuid_mod.UUID(id)
            except Exception:
                raise HTTPException(status_code=404, detail="Invalid UUID format")

        # Verify project exists
        exists = await pool.fetchval(
            "SELECT id FROM npl_projects WHERE id = $1 AND deleted_at IS NULL", uid
        )
        if exists is None:
            raise HTTPException(status_code=404, detail="Project not found")

        conditions = ["project_id = $1", "deleted_at IS NULL"]
        params: list[Any] = [uid]
        param_idx = 2

        if persona_id:
            persona_uid: Optional[_uuid_mod.UUID] = None
            try:
                persona_uid = _su.decode(persona_id)
            except Exception:
                try:
                    persona_uid = _uuid_mod.UUID(persona_id)
                except Exception:
                    raise HTTPException(status_code=400, detail="Invalid persona_id format")
            conditions.append(f"persona_ids @> ARRAY[${param_idx}]::uuid[]")
            params.append(persona_uid)
            param_idx += 1

        if status:
            conditions.append(f"status = ${param_idx}")
            params.append(status)
            param_idx += 1

        if priority:
            conditions.append(f"priority = ${param_idx}")
            params.append(priority)
            param_idx += 1

        where = " AND ".join(conditions)

        rows = await pool.fetch(
            f"""SELECT id, project_id, persona_ids, title, story_text, description,
                       priority, status, story_points, tags,
                       created_by, created_at, updated_at
                FROM npl_user_stories
                WHERE {where}
                ORDER BY created_at DESC""",
            *params,
        )

        return [
            {
                "id": _uuid_str(r["id"]),
                "project_id": _uuid_str(r["project_id"]),
                "persona_ids": [_uuid_str(p) for p in r["persona_ids"]] if r["persona_ids"] else [],
                "title": r["title"],
                "story_text": r["story_text"] or "",
                "description": r["description"] or "",
                "priority": r["priority"] or "medium",
                "status": r["status"] or "draft",
                "story_points": r["story_points"] or 0,
                "acceptance_criteria": [],
                "tags": r["tags"] or [],
                "created_at": _dt(r["created_at"]),
                "updated_at": _dt(r["updated_at"]),
            }
            for r in rows
        ]
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


# ---------------------------------------------------------------------------
# Stories PATCH endpoint (US-231)
# ---------------------------------------------------------------------------

class StoryPatch(BaseModel):
    status: Optional[str] = None
    priority: Optional[str] = None
    story_points: Optional[int] = None
    tags: Optional[list[str]] = None
    title: Optional[str] = None


@router.get("/stories/{story_id}")
async def stories_get(story_id: str) -> dict:
    """Get a single user story by ID (direct DB fetch to preserve story.status)."""
    pool = await _get_db_pool()
    try:
        import json
        import uuid as _uuid_mod
        import shortuuid as _su

        uid: Optional[_uuid_mod.UUID] = None
        try:
            uid = _su.decode(story_id)
        except Exception:
            try:
                uid = _uuid_mod.UUID(story_id)
            except Exception:
                raise HTTPException(status_code=404, detail="Invalid UUID format")

        row = await pool.fetchrow(
            """SELECT id, project_id, persona_ids, title, story_text, description,
                      priority, status, story_points, acceptance_criteria, tags,
                      created_by, created_at, updated_at
               FROM npl_user_stories
               WHERE id = $1 AND deleted_at IS NULL""",
            uid,
        )
        if row is None:
            raise HTTPException(status_code=404, detail="Story not found")

        ac_raw = row["acceptance_criteria"]
        if ac_raw:
            try:
                acceptance = json.loads(ac_raw) if isinstance(ac_raw, str) else ac_raw
            except (TypeError, ValueError):
                acceptance = []
        else:
            acceptance = []

        return {
            "id": _uuid_str(row["id"]),
            "project_id": _uuid_str(row["project_id"]),
            "persona_ids": [_uuid_str(p) for p in row["persona_ids"]] if row["persona_ids"] else [],
            "title": row["title"],
            "story_text": row["story_text"] or "",
            "description": row["description"] or "",
            "priority": row["priority"] or "medium",
            "status": row["status"] or "draft",
            "story_points": row["story_points"] or 0,
            "acceptance_criteria": acceptance or [],
            "tags": row["tags"] or [],
            "created_at": _dt(row["created_at"]),
            "updated_at": _dt(row["updated_at"]),
        }
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.patch("/stories/{story_id}")
async def stories_patch(story_id: str, patch: StoryPatch) -> dict:
    """Partial-update a user story's metadata (status, priority, story_points, tags, title)."""
    try:
        from npl_mcp.pm_tools.db_stories import story_update, story_get

        result = await story_update(
            id=story_id,
            status=patch.status,
            priority=patch.priority,
            story_points=patch.story_points,
            tags=patch.tags,
            title=patch.title,
        )

        if result.get("status") == "not_found":
            raise HTTPException(status_code=404, detail="Story not found")
        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message", "Update failed"))

        # Fetch and return the updated story
        story = await story_get(story_id)
        if story.get("status") == "not_found":
            raise HTTPException(status_code=404, detail="Story not found")

        return {
            "id": story.get("uuid"),
            "project_id": story.get("project_id"),
            "persona_ids": story.get("persona_ids", []),
            "title": story.get("title"),
            "story_text": story.get("story_text", ""),
            "description": story.get("description", ""),
            "priority": story.get("priority", "medium"),
            "status": story.get("status", "draft"),
            "story_points": story.get("story_points", 0),
            "acceptance_criteria": [],
            "tags": story.get("tags", []),
            "created_at": story.get("created_at"),
            "updated_at": story.get("updated_at"),
        }
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


# ---------------------------------------------------------------------------
# PRD filesystem helpers
# ---------------------------------------------------------------------------

_PRD_DIR = Path(__file__).resolve().parents[3] / "project-management" / "PRDs"
_PRD_DIR_PATTERN = re.compile(r"^PRD-(\d+)-(.+)$")
_PRD_FILE_PATTERN = re.compile(r"^PRD-(\d+)-(.+)\.md$")


def _parse_md_meta(text: str) -> tuple[str, Optional[str]]:
    """Return (title, status) extracted from markdown text."""
    title = ""
    status: Optional[str] = None
    for line in text.splitlines():
        stripped = line.strip()
        if not title and stripped.startswith("#"):
            title = stripped.lstrip("#").strip()
        if not status:
            m = re.match(r"\*\*Status\*\*:\s*(.+)", stripped)
            if m:
                status = m.group(1).strip()
        if title and status:
            break
    return title, status


def _doc_id_and_title(path: Path) -> tuple[str, str]:
    """Parse id and title from a FR-xxx or AT-xxx file."""
    text = path.read_text(encoding="utf-8", errors="replace")
    stem = path.stem  # e.g. "FR-001-core-schema-definition"
    doc_id = stem.split("-", 2)[:2]
    doc_id_str = "-".join(doc_id) if len(doc_id) >= 2 else stem
    # Extract title from first # heading
    title = doc_id_str
    for line in text.splitlines():
        s = line.strip()
        if s.startswith("#"):
            title = s.lstrip("#").strip()
            break
    return doc_id_str, title


def _scan_prds(base: Path) -> list[dict]:
    """Scan PRD directory and return list summaries sorted by number."""
    results = []

    # Directories: PRD-NNN-slug/
    for entry in base.iterdir():
        if entry.is_dir():
            m = _PRD_DIR_PATTERN.match(entry.name)
            if m:
                number = int(m.group(1))
                readme = entry / "README.md"
                if not readme.exists():
                    continue
                text = readme.read_text(encoding="utf-8", errors="replace")
                title, status = _parse_md_meta(text)
                has_frs = (entry / "functional-requirements").is_dir()
                has_ats = (entry / "acceptance-tests").is_dir()
                results.append({
                    "id": entry.name,
                    "number": number,
                    "title": title or entry.name,
                    "status": status,
                    "has_frs": has_frs,
                    "has_ats": has_ats,
                    "path": str(entry.relative_to(base.parent.parent)),
                })

    # Standalone .md files: PRD-NNN-slug.md  (no matching directory)
    dir_ids = {r["id"] for r in results}
    for entry in base.iterdir():
        if entry.is_file() and entry.suffix == ".md":
            m = _PRD_FILE_PATTERN.match(entry.name)
            if m:
                number = int(m.group(1))
                slug = m.group(2)
                dir_equiv = f"PRD-{m.group(1)}-{slug}"
                if dir_equiv in dir_ids:
                    continue  # directory version takes precedence
                text = entry.read_text(encoding="utf-8", errors="replace")
                title, status = _parse_md_meta(text)
                results.append({
                    "id": entry.stem,
                    "number": number,
                    "title": title or entry.stem,
                    "status": status,
                    "has_frs": False,
                    "has_ats": False,
                    "path": str(entry.relative_to(base.parent.parent)),
                })

    results.sort(key=lambda r: r["number"])
    return results


def _find_prd(prd_id: str, base: Path) -> Optional[Path]:
    """Return the Path (dir or .md file) for a PRD id, or None."""
    candidate_dir = base / prd_id
    if candidate_dir.is_dir() and (candidate_dir / "README.md").exists():
        return candidate_dir
    candidate_file = base / f"{prd_id}.md"
    if candidate_file.is_file():
        return candidate_file
    return None


def _read_docs_in_dir(subdir: Path) -> list[dict]:
    """Read all .md files in subdir (excluding index.yaml) and return list of {id, title, body}."""
    docs = []
    if not subdir.is_dir():
        return docs
    for f in sorted(subdir.iterdir()):
        if f.suffix != ".md":
            continue
        text = f.read_text(encoding="utf-8", errors="replace")
        doc_id, title = _doc_id_and_title(f)
        docs.append({"id": doc_id, "title": title, "body": text})
    return docs


# ---------------------------------------------------------------------------
# PRD endpoints
# ---------------------------------------------------------------------------

@router.get("/prds")
async def prds_list() -> list[dict]:
    """List all PRDs from the project-management/PRDs directory."""
    try:
        return _scan_prds(_PRD_DIR)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.get("/prds/{prd_id}/functional-requirements")
async def prds_functional_requirements(prd_id: str) -> list[dict]:
    """Return full FR bodies for a given PRD."""
    prd_path = _find_prd(prd_id, _PRD_DIR)
    if prd_path is None:
        raise HTTPException(status_code=404, detail=f"PRD '{prd_id}' not found")
    if not prd_path.is_dir():
        return []
    try:
        return _read_docs_in_dir(prd_path / "functional-requirements")
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.get("/prds/{prd_id}/acceptance-tests")
async def prds_acceptance_tests(prd_id: str) -> list[dict]:
    """Return full AT bodies for a given PRD."""
    prd_path = _find_prd(prd_id, _PRD_DIR)
    if prd_path is None:
        raise HTTPException(status_code=404, detail=f"PRD '{prd_id}' not found")
    if not prd_path.is_dir():
        return []
    try:
        return _read_docs_in_dir(prd_path / "acceptance-tests")
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.get("/prds/{prd_id}")
async def prds_get(prd_id: str) -> dict:
    """Get a single PRD detail with FR and AT summaries."""
    prd_path = _find_prd(prd_id, _PRD_DIR)
    if prd_path is None:
        raise HTTPException(status_code=404, detail=f"PRD '{prd_id}' not found")
    try:
        if prd_path.is_dir():
            text = (prd_path / "README.md").read_text(encoding="utf-8", errors="replace")
            m = _PRD_DIR_PATTERN.match(prd_path.name)
            number = int(m.group(1)) if m else 0
            fr_dir = prd_path / "functional-requirements"
            at_dir = prd_path / "acceptance-tests"
            fr_summaries = []
            if fr_dir.is_dir():
                for f in sorted(fr_dir.iterdir()):
                    if f.suffix == ".md":
                        doc_id, title = _doc_id_and_title(f)
                        fr_summaries.append({"id": doc_id, "title": title})
            at_summaries = []
            if at_dir.is_dir():
                for f in sorted(at_dir.iterdir()):
                    if f.suffix == ".md":
                        doc_id, title = _doc_id_and_title(f)
                        at_summaries.append({"id": doc_id, "title": title})
        else:
            text = prd_path.read_text(encoding="utf-8", errors="replace")
            m = _PRD_FILE_PATTERN.match(prd_path.name)
            number = int(m.group(1)) if m else 0
            fr_summaries = []
            at_summaries = []

        title, status = _parse_md_meta(text)
        return {
            "id": prd_id,
            "number": number,
            "title": title or prd_id,
            "status": status,
            "has_frs": len(fr_summaries) > 0,
            "has_ats": len(at_summaries) > 0,
            "path": str(prd_path.relative_to(_PRD_DIR.parent.parent)) if prd_path.is_dir() else str(prd_path.relative_to(_PRD_DIR.parent.parent)),
            "body": text,
            "functional_requirements": fr_summaries,
            "acceptance_tests": at_summaries,
        }
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


# ---------------------------------------------------------------------------
# NPL elements endpoint (US-223)
# ---------------------------------------------------------------------------

_CONVENTIONS_DIR = Path(__file__).resolve().parents[3] / "conventions"
_NPL_YAML = _CONVENTIONS_DIR / "npl.yaml"


def _npl_section_order() -> list[str]:
    """Return section names in the order specified by npl.yaml, or []."""
    try:
        npl_path = _NPL_YAML
        if not npl_path.exists():
            return []
        with open(npl_path, encoding="utf-8") as fh:
            data = yaml.safe_load(fh)
        if not isinstance(data, dict):
            return []
        npl_block = data.get("/npl") or data.get("npl") or data
        section_order = npl_block.get("section_order") if isinstance(npl_block, dict) else None
        if isinstance(section_order, dict):
            return list(section_order.get("components") or [])
        if isinstance(section_order, list):
            return list(section_order)
        return []
    except Exception:
        return []


def _is_complete_component(comp: dict) -> bool:
    """Return True if the component has brief, description, syntax[], and examples[]."""
    if not isinstance(comp, dict):
        return False
    brief = (comp.get("brief") or "").strip()
    description = (comp.get("description") or "").strip()
    syntax = comp.get("syntax") or []
    examples = comp.get("examples") or []
    return bool(brief) and bool(description) and len(syntax) >= 1 and len(examples) >= 1


@router.get("/npl/coverage")
async def npl_coverage() -> dict:
    """Coverage report: how many NPL components are 'complete' per section.

    A component is complete if it has non-empty brief, non-empty description,
    at least one syntax entry, and at least one example.
    Sections are ordered by npl.yaml section_order, then alphabetically.
    """
    try:
        section_order = _npl_section_order()
        order_index: dict[str, int] = {s: i for i, s in enumerate(section_order)}

        # section_name -> {total, complete, missing}
        sections: dict[str, dict] = {}

        pattern = str(_CONVENTIONS_DIR / "*.yaml")
        for path_str in glob.glob(pattern):
            fname = Path(path_str).name
            if fname == "npl.yaml":
                continue
            with open(path_str, encoding="utf-8") as fh:
                data = yaml.safe_load(fh)
            if not isinstance(data, dict):
                continue
            section = data.get("name") or fname.replace(".yaml", "")
            components = data.get("components") or []
            if section not in sections:
                sections[section] = {"total": 0, "complete": 0, "missing": []}
            for comp in components:
                if not isinstance(comp, dict):
                    continue
                sections[section]["total"] += 1
                if _is_complete_component(comp):
                    sections[section]["complete"] += 1
                else:
                    label = comp.get("name") or comp.get("slug") or ""
                    if label:
                        sections[section]["missing"].append(label)

        def _sort_key(name: str) -> tuple:
            idx = order_index.get(name, len(section_order))
            return (idx, name)

        by_section = []
        total_components = 0
        complete_components = 0
        for sname in sorted(sections.keys(), key=_sort_key):
            info = sections[sname]
            t = info["total"]
            c = info["complete"]
            total_components += t
            complete_components += c
            pct = round(c / t * 100) if t > 0 else 0
            by_section.append({
                "section": sname,
                "total": t,
                "complete": c,
                "coverage_percent": pct,
                "missing": info["missing"],
            })

        total_sections = len(by_section)
        overall_pct = round(complete_components / total_components * 100) if total_components > 0 else 0

        return {
            "total_sections": total_sections,
            "total_components": total_components,
            "complete_components": complete_components,
            "coverage_percent": overall_pct,
            "by_section": by_section,
        }
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.get("/npl/elements")
async def npl_elements() -> list[dict]:
    """Flat list of every NPL component across all convention YAML files.

    Iterates over conventions/*.yaml (skipping npl.yaml).  For each file's
    ``components[]`` list, one row is emitted per component.  Sorted by
    section -> priority -> name.
    """
    try:
        results: list[dict] = []
        pattern = str(_CONVENTIONS_DIR / "*.yaml")
        for path_str in glob.glob(pattern):
            fname = Path(path_str).name
            if fname == "npl.yaml":
                continue
            with open(path_str, encoding="utf-8") as fh:
                data = yaml.safe_load(fh)
            if not isinstance(data, dict):
                continue
            section = data.get("name") or fname.replace(".yaml", "")
            components = data.get("components") or []
            for comp in components:
                if not isinstance(comp, dict):
                    continue
                name = comp.get("name") or ""
                slug = comp.get("slug") or name
                friendly_name = comp.get("friendly-name") or comp.get("title") or name
                brief = comp.get("brief") or ""
                priority = int(comp.get("priority") or 0)
                labels = comp.get("labels") or []
                tags: list[str] = list(labels) if isinstance(labels, list) else []
                results.append({
                    "section": section,
                    "name": name,
                    "slug": slug,
                    "friendly_name": friendly_name,
                    "brief": brief,
                    "priority": priority,
                    "tags": tags,
                })
        results.sort(key=lambda r: (r["section"], r["priority"], r["name"]))
        return results
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


# ---------------------------------------------------------------------------
# NPL load/spec endpoints (book view)
# ---------------------------------------------------------------------------


class NPLLoadRequest(BaseModel):
    expression: str
    layout: str = "yaml_order"
    skip: Optional[list[str]] = None


class NPLSpecComponent(BaseModel):
    spec: str
    component_priority: int = 0
    example_priority: int = 0


class NPLSpecRequest(BaseModel):
    components: Optional[list[NPLSpecComponent]] = None
    rendered: Optional[list[NPLSpecComponent]] = None
    component_priority: int = 0
    example_priority: int = 0
    extension: bool = False
    concise: bool = True
    xml: bool = False


@router.post("/npl/load")
async def npl_load_endpoint(req: NPLLoadRequest) -> dict:
    try:
        from npl_mcp.npl.loader import load_npl
        from npl_mcp.npl.layout import LayoutStrategy

        layout_map = {
            "yaml_order": LayoutStrategy.YAML_ORDER,
            "classic": LayoutStrategy.CLASSIC,
            "grouped": LayoutStrategy.GROUPED,
        }
        strategy = layout_map.get(req.layout.lower(), LayoutStrategy.YAML_ORDER)
        markdown = load_npl(
            expression=req.expression,
            npl_dir=_CONVENTIONS_DIR,
            layout=strategy,
            skip=req.skip,
        )
        return {"markdown": markdown, "char_count": len(markdown)}
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.post("/npl/spec")
async def npl_spec_endpoint(req: NPLSpecRequest) -> dict:
    try:
        from npl_mcp.convention_formatter import NPLDefinition, ComponentSpec

        def _to_specs(items):
            if not items:
                return None
            return [
                ComponentSpec(
                    spec=i.spec,
                    component_priority=i.component_priority,
                    example_priority=i.example_priority,
                )
                for i in items
            ]

        npl = NPLDefinition(conventions_dir=_CONVENTIONS_DIR)
        markdown = npl.format(
            components=_to_specs(req.components),
            rendered=_to_specs(req.rendered),
            component_priority=req.component_priority,
            example_priority=req.example_priority,
            extension=req.extension,
            flags={"concise": req.concise, "xml": req.xml},
        )
        return {"markdown": markdown, "char_count": len(markdown)}
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


# ---------------------------------------------------------------------------
# Docs endpoints (US-047)
# ---------------------------------------------------------------------------

_DOCS_REPO_ROOT = Path(__file__).resolve().parents[3]
_ALLOWED_DOCS = {
    "schema": _DOCS_REPO_ROOT / "docs" / "PROJ-SCHEMA.md",
    "arch":   _DOCS_REPO_ROOT / "docs" / "PROJ-ARCH.md",
    "layout": _DOCS_REPO_ROOT / "docs" / "PROJ-LAYOUT.md",
    "status": _DOCS_REPO_ROOT / "docs" / "STATUS.md",
}


def _read_doc(name: str) -> dict:
    """Read a whitelisted doc file and return {path, content, size}."""
    doc_path = _ALLOWED_DOCS.get(name)
    if doc_path is None:
        raise HTTPException(status_code=404, detail=f"Unknown doc '{name}'")
    if not doc_path.exists():
        raise HTTPException(status_code=404, detail=f"Doc '{name}' not found on disk")
    content = doc_path.read_text(encoding="utf-8", errors="replace")
    try:
        rel_path = str(doc_path.relative_to(_DOCS_REPO_ROOT))
    except ValueError:
        rel_path = str(doc_path)
    return {
        "path": rel_path,
        "content": content,
        "size": len(content),
    }


@router.get("/docs/schema")
async def docs_schema() -> dict:
    """Return the PROJ-SCHEMA.md content."""
    try:
        return _read_doc("schema")
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.get("/docs/arch")
async def docs_arch() -> dict:
    """Return the PROJ-ARCH.md content."""
    try:
        return _read_doc("arch")
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.get("/docs/layout")
async def docs_layout() -> dict:
    """Return the PROJ-LAYOUT.md content."""
    try:
        return _read_doc("layout")
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


# ---------------------------------------------------------------------------
# Project file tree explorer  (US-025)
# ---------------------------------------------------------------------------

import os as _os

# Repo root: directory containing pyproject.toml  (…/NoizuPromptLingo)
_REPO_ROOT: Path = Path(__file__).resolve().parent.parent.parent.parent

_TREE_BLOCKLIST = {
    ".git", "node_modules", "__pycache__", ".venv", ".next",
    ".pytest_cache", ".ruff_cache", "htmlcov", ".tmp", "dist",
    "build", ".DS_Store",
}
_MAX_FILE_BYTES = 256 * 1024  # 256 KB


def _is_blocked(name: str) -> bool:
    return name in _TREE_BLOCKLIST or name.endswith(".pyc")


def _gitignore_spec(root: Path):
    """Return a pathspec.PathSpec for .gitignore, or None if unavailable."""
    try:
        import pathspec  # type: ignore
        gi = root / ".gitignore"
        if gi.exists():
            return pathspec.PathSpec.from_lines("gitwildmatch", gi.read_text().splitlines())
    except ImportError:
        pass
    return None


def _safe_resolve(root: Path, rel: str) -> Path:
    """Resolve *rel* inside *root*; raise 400 on path-traversal attempts."""
    if not rel or rel in (".", ""):
        return root
    # Reject absolute paths and .. segments
    if _os.path.isabs(rel):
        raise HTTPException(status_code=400, detail="Absolute paths are not allowed")
    parts = rel.replace("\\", "/").split("/")
    if ".." in parts:
        raise HTTPException(status_code=400, detail="Path must not contain '..'")
    target = (root / rel).resolve()
    try:
        target.relative_to(root)
    except ValueError:
        raise HTTPException(status_code=400, detail="Path escapes repository root")
    return target


def _build_tree_node(path: Path, root: Path, depth: int, spec) -> dict:
    rel = str(path.relative_to(root)).replace(_os.sep, "/")
    if rel == ".":
        rel = ""

    if path.is_file():
        return {"name": path.name, "path": rel, "kind": "file", "size": path.stat().st_size}

    children: list[dict] = []
    if depth > 0:
        try:
            entries = sorted(path.iterdir(), key=lambda p: (p.is_file(), p.name.lower()))
        except PermissionError:
            entries = []
        for entry in entries:
            if _is_blocked(entry.name):
                continue
            if spec is not None:
                entry_rel = str(entry.relative_to(root)).replace(_os.sep, "/")
                if entry.is_dir():
                    entry_rel += "/"
                if spec.match_file(entry_rel):
                    continue
            children.append(_build_tree_node(entry, root, depth - 1, spec))

    return {"name": path.name, "path": rel, "kind": "directory", "children": children}


@router.get("/project/tree")
async def project_tree(
    path: str = Query(".", description="Path relative to repo root"),
    depth: int = Query(3, ge=1, le=6, description="Traversal depth 1-6"),
) -> dict:
    """Return a recursive directory listing of the repository."""
    target = _safe_resolve(_REPO_ROOT, path if path not in (".", "") else "")
    if not target.exists():
        raise HTTPException(status_code=404, detail="Path not found")
    spec = _gitignore_spec(_REPO_ROOT)
    try:
        return _build_tree_node(target, _REPO_ROOT, depth, spec)
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.get("/project/file")
async def project_file(
    path: str = Query(..., description="File path relative to repo root"),
) -> dict:
    """Return the text content of a repository file (max 256 KB)."""
    target = _safe_resolve(_REPO_ROOT, path)

    if not target.exists():
        raise HTTPException(status_code=404, detail="File not found")

    # Resolve symlinks and confirm containment
    try:
        resolved = target.resolve()
        resolved.relative_to(_REPO_ROOT)
    except ValueError:
        raise HTTPException(status_code=400, detail="Symlink target escapes repository root")

    if not resolved.is_file():
        raise HTTPException(status_code=400, detail="Path is not a file")

    size = resolved.stat().st_size
    rel = str(resolved.relative_to(_REPO_ROOT)).replace(_os.sep, "/")

    try:
        with open(resolved, "rb") as fh:
            probe = fh.read(1024)
    except OSError as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc

    if b"\x00" in probe:
        return {"path": rel, "kind": "binary", "size": size, "content": None}

    truncated = size > _MAX_FILE_BYTES
    try:
        with open(resolved, "r", encoding="utf-8", errors="replace") as fh:
            content = fh.read(_MAX_FILE_BYTES)
    except OSError as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc

    return {"path": rel, "content": content, "size": size, "truncated": truncated}


# ---------------------------------------------------------------------------
# Tool error log  (US-049)
# ---------------------------------------------------------------------------

@router.get("/errors")
async def errors_list(
    limit: int = Query(50, ge=1, le=200, description="Maximum number of errors to return"),
) -> list[dict]:
    """Return recent tool-call errors (newest first)."""
    try:
        from npl_mcp.storage.error_log import list_tool_errors
        return await list_tool_errors(limit=limit)
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


# ---------------------------------------------------------------------------
# Metrics endpoints (stubs — tables not yet provisioned)
# ---------------------------------------------------------------------------

@router.get("/metrics/tool-calls")
async def metrics_tool_calls(limit: int = Query(default=20, ge=1, le=100)) -> dict:
    raise HTTPException(
        status_code=501,
        detail="Tool call metrics table not yet provisioned",
    )


@router.get("/metrics/llm-calls")
async def metrics_llm_calls(limit: int = Query(default=20, ge=1, le=100)) -> dict:
    raise HTTPException(
        status_code=501,
        detail="LLM call metrics table not yet provisioned",
    )


# ---------------------------------------------------------------------------
# Skills validation  (US-119)
# ---------------------------------------------------------------------------


# ---------------------------------------------------------------------------
# Tasks endpoints (PRD-005 MVP)
# ---------------------------------------------------------------------------

class TaskCreateBody(BaseModel):
    title: str
    description: Optional[str] = None
    status: Optional[str] = None
    priority: Optional[int] = None
    assigned_to: Optional[str] = None
    notes: Optional[str] = None


class TaskStatusBody(BaseModel):
    status: str
    notes: Optional[str] = None


def _task_dto(task: dict) -> dict:
    """Normalize a tasks module result into a JSON-safe REST dict."""
    return {
        "id": task.get("id"),
        "title": task.get("title"),
        "description": task.get("description", "") or "",
        "status": task.get("task_status", "pending"),
        "priority": task.get("priority", 1),
        "assigned_to": task.get("assigned_to"),
        "notes": task.get("notes"),
        "created_at": task.get("created_at"),
        "updated_at": task.get("updated_at"),
    }


@router.get("/tasks")
async def tasks_list_endpoint(
    status: Optional[str] = Query(None),
    assigned_to: Optional[str] = Query(None),
    limit: int = Query(100, ge=1, le=500),
) -> dict:
    """List tasks with optional status/assignee filters."""
    try:
        from npl_mcp.tasks import task_list
        result = await task_list(status=status, assigned_to=assigned_to, limit=limit)
        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message", "Invalid request"))
        return {
            "tasks": [_task_dto(t) for t in result.get("tasks", [])],
            "count": result.get("count", 0),
        }
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.post("/tasks")
async def tasks_create_endpoint(body: TaskCreateBody) -> dict:
    """Create a new task."""
    try:
        from npl_mcp.tasks import task_create
        kwargs: dict[str, Any] = {"title": body.title}
        if body.description is not None:
            kwargs["description"] = body.description
        if body.status is not None:
            kwargs["status"] = body.status
        if body.priority is not None:
            kwargs["priority"] = body.priority
        if body.assigned_to is not None:
            kwargs["assigned_to"] = body.assigned_to
        if body.notes is not None:
            kwargs["notes"] = body.notes

        result = await task_create(**kwargs)
        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message", "Invalid request"))
        return _task_dto(result)
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.get("/tasks/{task_id}")
async def tasks_get_endpoint(task_id: int) -> dict:
    """Fetch a single task by id."""
    try:
        from npl_mcp.tasks import task_get
        result = await task_get(task_id)
        if result.get("status") == "not_found":
            raise HTTPException(status_code=404, detail=f"Task {task_id} not found")
        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message", "Invalid request"))
        return _task_dto(result)
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.patch("/tasks/{task_id}/status")
async def tasks_update_status_endpoint(task_id: int, body: TaskStatusBody) -> dict:
    """Update a task's status (and optionally append a note)."""
    try:
        from npl_mcp.tasks import task_update_status
        result = await task_update_status(task_id=task_id, status=body.status, notes=body.notes)
        if result.get("status") == "not_found":
            raise HTTPException(status_code=404, detail=f"Task {task_id} not found")
        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message", "Invalid request"))
        return _task_dto(result)
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


# ---------------------------------------------------------------------------
# Generic Sessions endpoints (PRD-004 MVP)
# Served under /api/work-sessions to avoid collision with /api/sessions
# (the existing tool_sessions endpoints).
# ---------------------------------------------------------------------------

class WorkSessionCreateBody(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    status: Optional[str] = None
    created_by: Optional[str] = None


class WorkSessionUpdateBody(BaseModel):
    title: Optional[str] = None
    status: Optional[str] = None
    description: Optional[str] = None


def _work_session_dto(session: dict) -> dict:
    return {
        "uuid": session.get("uuid"),
        "title": session.get("title"),
        "status": session.get("session_status", "active"),
        "description": session.get("description"),
        "created_by": session.get("created_by"),
        "created_at": session.get("created_at"),
        "updated_at": session.get("updated_at"),
    }


@router.get("/work-sessions")
async def work_sessions_list_endpoint(
    status: Optional[str] = Query(None),
    limit: int = Query(50, ge=1, le=200),
) -> dict:
    try:
        from npl_mcp.sessions import session_list
        result = await session_list(status=status, limit=limit)
        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message", "Invalid request"))
        return {
            "sessions": [_work_session_dto(s) for s in result.get("sessions", [])],
            "count": result.get("count", 0),
        }
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.post("/work-sessions")
async def work_sessions_create_endpoint(body: WorkSessionCreateBody) -> dict:
    try:
        from npl_mcp.sessions import session_create
        kwargs: dict[str, Any] = {}
        if body.title is not None:
            kwargs["title"] = body.title
        if body.description is not None:
            kwargs["description"] = body.description
        if body.status is not None:
            kwargs["status"] = body.status
        if body.created_by is not None:
            kwargs["created_by"] = body.created_by
        result = await session_create(**kwargs)
        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message", "Invalid request"))
        return _work_session_dto(result)
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.get("/work-sessions/{session_id}")
async def work_sessions_get_endpoint(session_id: str) -> dict:
    try:
        from npl_mcp.sessions import session_get
        result = await session_get(session_id)
        if result.get("status") == "not_found":
            raise HTTPException(status_code=404, detail=f"Session {session_id} not found")
        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message", "Invalid request"))
        return _work_session_dto(result)
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.patch("/work-sessions/{session_id}")
async def work_sessions_update_endpoint(session_id: str, body: WorkSessionUpdateBody) -> dict:
    try:
        from npl_mcp.sessions import session_update
        result = await session_update(
            session_id=session_id,
            title=body.title,
            status=body.status,
            description=body.description,
        )
        if result.get("status") == "not_found":
            raise HTTPException(status_code=404, detail=f"Session {session_id} not found")
        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message", "Invalid request"))
        return _work_session_dto(result)
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


# ---------------------------------------------------------------------------
# Artifacts endpoints (PRD-002 MVP)
# ---------------------------------------------------------------------------

class ArtifactCreateBody(BaseModel):
    title: str
    content: str
    kind: Optional[str] = None
    description: Optional[str] = None
    created_by: Optional[str] = None
    notes: Optional[str] = None


class ArtifactRevisionBody(BaseModel):
    content: str
    notes: Optional[str] = None
    created_by: Optional[str] = None


def _artifact_head_dto(artifact: dict) -> dict:
    """Normalize an artifact module result head to JSON."""
    return {
        "id": artifact.get("id"),
        "title": artifact.get("title"),
        "kind": artifact.get("kind"),
        "description": artifact.get("description", "") or "",
        "created_by": artifact.get("created_by"),
        "latest_revision": artifact.get("latest_revision"),
        "created_at": artifact.get("created_at"),
        "updated_at": artifact.get("updated_at"),
    }


def _artifact_full_dto(result: dict) -> dict:
    """Head + revision body (from create/add_revision/get)."""
    out = _artifact_head_dto(result)
    rev = result.get("revision")
    if rev is not None:
        out["revision"] = {
            "id": rev.get("id"),
            "artifact_id": rev.get("artifact_id"),
            "revision": rev.get("revision"),
            "content": rev.get("content"),
            "mime_type": rev.get("mime_type"),
            "has_binary": rev.get("has_binary", False),
            "notes": rev.get("notes"),
            "created_by": rev.get("created_by"),
            "created_at": rev.get("created_at"),
        }
    return out


@router.get("/artifacts")
async def artifacts_list_endpoint(
    kind: Optional[str] = Query(None),
    limit: int = Query(100, ge=1, le=500),
) -> dict:
    try:
        from npl_mcp.artifacts import artifact_list
        result = await artifact_list(kind=kind, limit=limit)
        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message", "Invalid request"))
        return {
            "artifacts": [_artifact_head_dto(a) for a in result.get("artifacts", [])],
            "count": result.get("count", 0),
        }
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.post("/artifacts")
async def artifacts_create_endpoint(body: ArtifactCreateBody) -> dict:
    try:
        from npl_mcp.artifacts import artifact_create
        kwargs: dict[str, Any] = {"title": body.title, "content": body.content}
        if body.kind is not None:
            kwargs["kind"] = body.kind
        if body.description is not None:
            kwargs["description"] = body.description
        if body.created_by is not None:
            kwargs["created_by"] = body.created_by
        if body.notes is not None:
            kwargs["notes"] = body.notes
        result = await artifact_create(**kwargs)
        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message", "Invalid request"))
        return _artifact_full_dto(result)
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.get("/artifacts/{artifact_id}")
async def artifacts_get_endpoint(
    artifact_id: int,
    revision: Optional[int] = Query(None),
) -> dict:
    try:
        from npl_mcp.artifacts import artifact_get
        result = await artifact_get(artifact_id=artifact_id, revision=revision)
        if result.get("status") == "not_found":
            raise HTTPException(status_code=404, detail=f"Artifact {artifact_id} not found")
        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message", "Invalid request"))
        return _artifact_full_dto(result)
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.get("/artifacts/{artifact_id}/revisions")
async def artifacts_list_revisions_endpoint(artifact_id: int) -> dict:
    try:
        from npl_mcp.artifacts import artifact_list_revisions
        result = await artifact_list_revisions(artifact_id=artifact_id)
        if result.get("status") == "not_found":
            raise HTTPException(status_code=404, detail=f"Artifact {artifact_id} not found")
        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message", "Invalid request"))
        return {
            "artifact_id": result.get("artifact_id"),
            "revisions": result.get("revisions", []),
            "count": result.get("count", 0),
        }
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.post("/artifacts/{artifact_id}/revisions")
async def artifacts_add_revision_endpoint(
    artifact_id: int,
    body: ArtifactRevisionBody,
) -> dict:
    try:
        from npl_mcp.artifacts import artifact_add_revision
        result = await artifact_add_revision(
            artifact_id=artifact_id,
            content=body.content,
            notes=body.notes,
            created_by=body.created_by,
        )
        if result.get("status") == "not_found":
            raise HTTPException(status_code=404, detail=f"Artifact {artifact_id} not found")
        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message", "Invalid request"))
        return _artifact_full_dto(result)
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


# ---------------------------------------------------------------------------
# Artifact binary upload + raw streaming (Wave Q — media kinds)
# ---------------------------------------------------------------------------

_MAX_UPLOAD_BYTES = 15 * 1024 * 1024


def _kind_for_mime(mime: str | None) -> str:
    if not mime:
        return "binary"
    m = mime.lower()
    if m.startswith("image/"):
        return "image"
    if m.startswith("video/"):
        return "video"
    if m.startswith("audio/"):
        return "audio"
    if m == "application/pdf":
        return "pdf"
    return "binary"


@router.post("/artifacts/upload")
async def artifacts_upload_endpoint(
    file: UploadFile = File(...),
    title: str = Form(...),
    kind: Optional[str] = Form(None),
    description: Optional[str] = Form(None),
    created_by: Optional[str] = Form(None),
    notes: Optional[str] = Form(None),
) -> dict:
    """Create a binary artifact from a multipart file upload."""
    try:
        raw = await file.read()
        if len(raw) > _MAX_UPLOAD_BYTES:
            raise HTTPException(
                status_code=413,
                detail=f"File exceeds {_MAX_UPLOAD_BYTES // (1024 * 1024)} MB cap.",
            )
        resolved_kind = kind or _kind_for_mime(file.content_type)
        from npl_mcp.artifacts import artifact_create
        result = await artifact_create(
            title=title,
            content="",
            kind=resolved_kind,
            description=description,
            created_by=created_by,
            notes=notes,
            binary_content=raw,
            mime_type=file.content_type,
        )
        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message", "Invalid request"))
        return _artifact_full_dto(result)
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.post("/artifacts/{artifact_id}/revisions/upload")
async def artifacts_add_revision_upload_endpoint(
    artifact_id: int,
    file: UploadFile = File(...),
    notes: Optional[str] = Form(None),
    created_by: Optional[str] = Form(None),
) -> dict:
    """Append a binary revision via multipart upload."""
    try:
        raw = await file.read()
        if len(raw) > _MAX_UPLOAD_BYTES:
            raise HTTPException(
                status_code=413,
                detail=f"File exceeds {_MAX_UPLOAD_BYTES // (1024 * 1024)} MB cap.",
            )
        from npl_mcp.artifacts import artifact_add_revision
        result = await artifact_add_revision(
            artifact_id=artifact_id,
            content="",
            notes=notes,
            created_by=created_by,
            binary_content=raw,
            mime_type=file.content_type,
        )
        if result.get("status") == "not_found":
            raise HTTPException(status_code=404, detail=f"Artifact {artifact_id} not found")
        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message", "Invalid request"))
        return _artifact_full_dto(result)
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.get("/artifacts/{artifact_id}/revisions/{revision}/raw")
async def artifacts_raw_endpoint(artifact_id: int, revision: int) -> Response:
    """Stream raw binary content of a revision with its Content-Type."""
    try:
        from npl_mcp.artifacts import artifact_get_binary
        result = await artifact_get_binary(artifact_id=artifact_id, revision=revision)
        if result.get("status") == "not_found":
            raise HTTPException(status_code=404, detail="Revision not found")
        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message", "Invalid request"))
        return Response(
            content=result["binary_content"],
            media_type=result["mime_type"],
            headers={"Cache-Control": "private, max-age=60"},
        )
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


# ---------------------------------------------------------------------------
# Agent pipes (REST)
# ---------------------------------------------------------------------------


class PipeOutputBody(BaseModel):
    agent: str
    body: str


class PipeInputBody(BaseModel):
    agent: str
    since: Optional[str] = None
    full: bool = False
    with_sections: Optional[list[str]] = None


@router.post("/pipes/output")
async def pipes_output_endpoint(req: PipeOutputBody) -> dict:
    try:
        from npl_mcp.pipes import agent_output_pipe
        result = await agent_output_pipe(agent=req.agent, body=req.body)
        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message", "Invalid request"))
        return result
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.post("/pipes/input")
async def pipes_input_endpoint(req: PipeInputBody) -> dict:
    try:
        from npl_mcp.pipes import agent_input_pipe
        result = await agent_input_pipe(
            agent=req.agent,
            since=req.since,
            full=req.full,
            with_sections=req.with_sections,
        )
        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message", "Invalid request"))
        return result
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


# ---------------------------------------------------------------------------
# Agent Pipes (inter-agent messaging)
# ---------------------------------------------------------------------------


class PipeInputBody(BaseModel):
    agent: str
    since: Optional[str] = None
    full: bool = False
    with_sections: Optional[list[str]] = None


class PipeOutputBody(BaseModel):
    agent: str
    body: str


@router.post("/pipes/input")
async def pipes_input_endpoint(body: PipeInputBody) -> dict:
    try:
        from npl_mcp.pipes import agent_input_pipe
        return await agent_input_pipe(
            agent=body.agent,
            since=body.since,
            full=body.full,
            with_sections=body.with_sections,
        )
    except Exception as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.post("/pipes/output")
async def pipes_output_endpoint(body: PipeOutputBody) -> dict:
    try:
        from npl_mcp.pipes import agent_output_pipe
        return await agent_output_pipe(agent=body.agent, body=body.body)
    except Exception as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


# ---------------------------------------------------------------------------
# Orchestration trigger  (Wave O)
# ---------------------------------------------------------------------------

class OrchestrationTriggerBody(BaseModel):
    feature_description: str
    agent: str = "npl-tdd-coder"


@router.post("/orchestration/trigger")
async def orchestration_trigger(body: OrchestrationTriggerBody) -> dict:
    """Queue an orchestration pipeline run as a task."""
    try:
        pool = await _get_db_pool()
        from npl_mcp.tasks.tasks import task_create
        result = await task_create(
            title=f"[Orchestration] {body.feature_description[:200]}",
            description=f"Triggered via orchestration UI. Agent: {body.agent}",
            status="pending",
            priority=2,
        )
        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message", "Failed to queue"))
        task_id = result.get("id")
        return {
            "run_id": str(task_id),
            "status": "queued",
            "task_id": task_id,
            "created_at": result.get("created_at"),
        }
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


# ---------------------------------------------------------------------------
# Sessions activity feed  (Wave O)
# ---------------------------------------------------------------------------

@router.get("/sessions/{uuid}/activity")
async def sessions_activity(
    uuid: str,
    limit: int = Query(default=50, ge=1, le=200),
) -> dict:
    """Return an activity feed for a session (child sessions + errors)."""
    try:
        pool = await _get_db_pool()

        import uuid as _uuid_mod

        uid: Optional[_uuid_mod.UUID] = None
        try:
            uid = shortuuid.decode(uuid)
        except Exception:
            try:
                uid = _uuid_mod.UUID(uuid)
            except Exception:
                raise HTTPException(status_code=404, detail="Invalid UUID format")

        # 1. Child sessions (sub-agents spawned under this session)
        child_rows = await pool.fetch(
            """
            SELECT id, agent, brief, task, created_at
            FROM npl_tool_sessions
            WHERE parent_id = $1
            ORDER BY created_at DESC
            LIMIT $2
            """,
            uid,
            limit,
        )
        child_events = [
            {
                "id": f"session_{_uuid_str(row['id'])}",
                "type": "sub_session",
                "summary": f"Sub-agent: {row['agent']} — {(row['brief'] or row['task'] or '')[:80]}",
                "detail": _uuid_str(row['id']),
                "created_at": _dt(row['created_at']),
            }
            for row in child_rows
        ]

        # 2. Errors associated with this session (UUID stored as text in session_id)
        error_rows = await pool.fetch(
            """
            SELECT id, tool_name, error_type, error_message, created_at
            FROM npl_tool_errors
            WHERE session_id = $1
            ORDER BY created_at DESC
            LIMIT $2
            """,
            str(uid),
            limit,
        )
        error_events = [
            {
                "id": f"error_{row['id']}",
                "type": "error",
                "summary": f"Error in {row['tool_name']}: {(row['error_message'] or '')[:80]}",
                "detail": row['error_type'],
                "created_at": _dt(row['created_at']),
            }
            for row in error_rows
        ]

        all_events = child_events + error_events
        all_events.sort(key=lambda e: e['created_at'] or '', reverse=True)
        all_events = all_events[:limit]

        return {"items": all_events, "count": len(all_events)}
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


# ---------------------------------------------------------------------------
# Agents endpoints (US-221)
# ---------------------------------------------------------------------------

@router.get("/agents")
async def agents_list() -> list[dict]:
    """List all agent definitions from agents/*.md."""
    try:
        from npl_mcp.agents.catalog import list_agents
        agents = await list_agents()
        return list(agents)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.get("/agents/{name}")
async def agents_get(name: str) -> dict:
    """Get a single agent definition including full body, or 404."""
    try:
        from npl_mcp.agents.catalog import get_agent
        agent = await get_agent(name)
        if agent is None:
            raise HTTPException(status_code=404, detail=f"Agent '{name}' not found")
        return agent
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


# ---------------------------------------------------------------------------
# Browser tools endpoints (US-096)
# ---------------------------------------------------------------------------

class ToMarkdownRequest(BaseModel):
    source: str
    heading_filter: Optional[str] = None
    collapse_depth: Optional[int] = None
    with_image_descriptions: bool = False
    bare: bool = False


@router.post("/browser/to-markdown")
async def browser_to_markdown(body: ToMarkdownRequest) -> dict:
    """Convert a URL or local file to Markdown.

    Body:
        source: URL or local file path (required).
        heading_filter: Heading/CSS filter (e.g. "Overview").
        collapse_depth: Collapse headings below this depth (1-6).
        with_image_descriptions: Inject LLM image descriptions.
        bare: Extract only matched section (filtered_only mode).

    Returns:
        {markdown: str, source: str, char_count: int}
    """
    if not body.source or not body.source.strip():
        raise HTTPException(status_code=400, detail="source must not be empty")
    try:
        from npl_mcp.browser.to_markdown import to_markdown
        result = await to_markdown(
            source=body.source,
            filter=body.heading_filter,
            collapsed_depth=body.collapse_depth,
            filtered_only=body.bare,
            with_image_descriptions=body.with_image_descriptions,
        )
        content = result.get("content", "")
        if not isinstance(content, str):
            import json as _json
            content = _json.dumps(content, ensure_ascii=False, indent=2)
        return {
            "markdown": content,
            "source": result.get("source", body.source),
            "char_count": result.get("content_length", len(content)),
        }
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


class SkillValidateRequest(BaseModel):
    content: str
    filename: Optional[str] = None


@router.post("/skills/validate")
async def skills_validate(body: SkillValidateRequest) -> dict:
    """Validate a skill file's structure and content.

    Body:
        content: Full text of the skill markdown file (frontmatter + body).
        filename: Optional filename for name/field cross-check.

    Returns:
        ValidationResult JSON with valid, errors, warnings, summary.
    """
    try:
        from npl_mcp.skills.validator import validate_skill
        return await validate_skill(body.content, body.filename or None)
    except Exception as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


# ---------------------------------------------------------------------------
# Skills evaluation  (US-120)
# ---------------------------------------------------------------------------


class SkillEvaluateRequest(BaseModel):
    content: str
    filename: Optional[str] = None


@router.post("/skills/evaluate")
async def skills_evaluate(body: SkillEvaluateRequest) -> dict:
    """Evaluate a skill file's quality across heuristic dimensions.

    Body:
        content: Full text of the skill markdown file (frontmatter + body).
        filename: Optional filename for name/field cross-check.

    Returns:
        EvaluationResult JSON with overall_score, dimensions, validation,
        and suggestions.
    """
    try:
        from npl_mcp.skills.validator import evaluate_skill
        return await evaluate_skill(body.content, body.filename or None)
    except Exception as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


# ---------------------------------------------------------------------------
# Chat (PRD-007)
# ---------------------------------------------------------------------------

class ChatRoomCreateBody(BaseModel):
    name: str
    description: str = ""


class ChatMessageCreateBody(BaseModel):
    content: str
    author: str = "user"


@router.get("/chat/rooms")
async def chat_rooms_list(limit: int = Query(default=50, ge=1, le=200)) -> dict:
    try:
        pool = await _get_db_pool()
        from npl_mcp.chat.chat import room_list
        items = await room_list(pool, limit=limit)
        return {"items": items, "count": len(items)}
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.post("/chat/rooms")
async def chat_rooms_create(body: ChatRoomCreateBody) -> dict:
    try:
        pool = await _get_db_pool()
        from npl_mcp.chat.chat import room_create
        return await room_create(pool, name=body.name, description=body.description)
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.get("/chat/rooms/{room_id}")
async def chat_room_get(room_id: int) -> dict:
    try:
        pool = await _get_db_pool()
        from npl_mcp.chat.chat import room_get
        room = await room_get(pool, room_id)
        if room is None:
            raise HTTPException(status_code=404, detail="Chat room not found")
        return room
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.get("/chat/rooms/{room_id}/messages")
async def chat_messages_list(
    room_id: int,
    limit: int = Query(default=50, ge=1, le=200),
    before_id: Optional[int] = Query(default=None),
) -> dict:
    try:
        pool = await _get_db_pool()
        from npl_mcp.chat.chat import message_list
        items = await message_list(pool, room_id=room_id, limit=limit, before_id=before_id)
        return {"items": items, "count": len(items)}
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.post("/chat/rooms/{room_id}/messages")
async def chat_message_create(room_id: int, body: ChatMessageCreateBody) -> dict:
    try:
        pool = await _get_db_pool()
        from npl_mcp.chat.chat import message_create
        return await message_create(pool, room_id=room_id, content=body.content, author=body.author)
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


# ---------------------------------------------------------------------------
# Chat enhanced endpoints
# ---------------------------------------------------------------------------


class ChatMemberAddBody(BaseModel):
    persona_slug: str


class ChatEventCreateBody(BaseModel):
    event_type: str
    persona: str
    data: Optional[dict] = None


class ChatReactBody(BaseModel):
    persona: str
    emoji: str


class ChatTodoBody(BaseModel):
    persona: str
    description: str
    assigned_to: Optional[str] = None


class ChatShareArtifactBody(BaseModel):
    persona: str
    artifact_id: int
    revision: Optional[int] = None


@router.get("/chat/rooms/{room_id}/members")
async def chat_room_members_list(room_id: int) -> dict:
    """List members of a chat room."""
    try:
        from npl_mcp.chat.chat import room_list_members
        return await room_list_members(room_id=room_id)
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.post("/chat/rooms/{room_id}/members")
async def chat_room_member_add(room_id: int, body: ChatMemberAddBody) -> dict:
    """Add a persona member to a chat room."""
    try:
        from npl_mcp.chat.chat import room_add_member
        return await room_add_member(room_id=room_id, persona_slug=body.persona_slug)
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.get("/chat/rooms/{room_id}/events")
async def chat_room_events_list(
    room_id: int,
    since: Optional[str] = Query(None),
    limit: int = Query(default=50, ge=1, le=200),
) -> dict:
    """List chat events in a room."""
    try:
        from npl_mcp.chat.chat import event_list
        return await event_list(room_id=room_id, since=since, limit=limit)
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.post("/chat/rooms/{room_id}/events")
async def chat_room_event_create(room_id: int, body: ChatEventCreateBody) -> dict:
    """Create a chat event in a room."""
    try:
        from npl_mcp.chat.chat import event_create
        return await event_create(
            room_id=room_id, event_type=body.event_type,
            persona=body.persona, data=body.data,
        )
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.post("/chat/rooms/{room_id}/events/{event_id}/react")
async def chat_event_react(room_id: int, event_id: int, body: ChatReactBody) -> dict:
    """React to a chat event with an emoji."""
    try:
        from npl_mcp.chat.chat import react_to_event
        return await react_to_event(event_id=event_id, persona=body.persona, emoji=body.emoji)
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.post("/chat/rooms/{room_id}/todos")
async def chat_room_todo_create(room_id: int, body: ChatTodoBody) -> dict:
    """Create a todo item in a chat room."""
    try:
        from npl_mcp.chat.chat import create_todo
        return await create_todo(
            room_id=room_id, persona=body.persona,
            description=body.description, assigned_to=body.assigned_to,
        )
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.post("/chat/rooms/{room_id}/share-artifact")
async def chat_room_share_artifact(room_id: int, body: ChatShareArtifactBody) -> dict:
    """Share an artifact in a chat room."""
    try:
        from npl_mcp.chat.chat import share_artifact
        return await share_artifact(
            room_id=room_id, persona=body.persona,
            artifact_id=body.artifact_id, revision=body.revision,
        )
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.get("/chat/notifications/{persona}")
async def chat_notifications_list(
    persona: str,
    unread_only: bool = Query(default=True),
) -> dict:
    """List notifications for a persona."""
    try:
        from npl_mcp.chat.chat import notification_list
        return await notification_list(persona=persona, unread_only=unread_only)
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.patch("/chat/notifications/{notification_id}/read")
async def chat_notification_mark_read(notification_id: int) -> dict:
    """Mark a notification as read."""
    try:
        from npl_mcp.chat.chat import notification_mark_read
        return await notification_mark_read(notification_id=notification_id)
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


# ---------------------------------------------------------------------------
# Sessions enhanced endpoints
# ---------------------------------------------------------------------------


@router.get("/work-sessions/{session_id}/contents")
async def work_session_contents(session_id: str) -> dict:
    """Get aggregated session contents (chat rooms, artifacts)."""
    try:
        from npl_mcp.sessions.sessions import session_get_contents
        result = await session_get_contents(session_id)
        if result.get("status") == "not_found":
            raise HTTPException(status_code=404, detail=f"Session {session_id} not found")
        return result
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.post("/work-sessions/{session_id}/archive")
async def work_session_archive(session_id: str) -> dict:
    """Archive a session."""
    try:
        from npl_mcp.sessions.sessions import session_archive
        result = await session_archive(session_id)
        if result.get("status") == "not_found":
            raise HTTPException(status_code=404, detail=f"Session {session_id} not found")
        return result
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


# ---------------------------------------------------------------------------
# Task queue and enhanced task endpoints
# ---------------------------------------------------------------------------


class TaskQueueCreateBody(BaseModel):
    name: str
    description: Optional[str] = None
    session_id: Optional[str] = None
    chat_room_id: Optional[int] = None


class TaskInQueueCreateBody(BaseModel):
    title: str
    description: Optional[str] = None
    status: str = "pending"
    priority: int = 1
    assigned_to: Optional[str] = None
    acceptance_criteria: Optional[str] = None
    deadline: Optional[str] = None
    complexity: Optional[int] = None
    complexity_notes: Optional[str] = None


class TaskComplexityBody(BaseModel):
    complexity: int
    notes: Optional[str] = None


class TaskArtifactBody(BaseModel):
    artifact_type: str
    artifact_id: Optional[int] = None
    git_branch: Optional[str] = None
    description: Optional[str] = None
    created_by: Optional[str] = None


@router.get("/task-queues")
async def task_queues_list(
    status: Optional[str] = Query(None),
    limit: int = Query(default=50, ge=1, le=200),
) -> dict:
    """List task queues."""
    try:
        from npl_mcp.tasks.tasks import task_queue_list
        return await task_queue_list(status=status, limit=limit)
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.post("/task-queues")
async def task_queues_create(body: TaskQueueCreateBody) -> dict:
    """Create a task queue."""
    try:
        from npl_mcp.tasks.tasks import task_queue_create
        result = await task_queue_create(
            name=body.name, description=body.description,
            session_id=body.session_id, chat_room_id=body.chat_room_id,
        )
        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message", "Invalid request"))
        return result
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.get("/task-queues/{queue_id}")
async def task_queue_get_endpoint(queue_id: int) -> dict:
    """Get a task queue with task counts."""
    try:
        from npl_mcp.tasks.tasks import task_queue_get
        result = await task_queue_get(queue_id)
        if result.get("status") == "not_found":
            raise HTTPException(status_code=404, detail=f"Queue {queue_id} not found")
        return result
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.get("/task-queues/{queue_id}/feed")
async def task_queue_feed_endpoint(
    queue_id: int,
    since: Optional[str] = Query(None),
    limit: int = Query(default=100, ge=1, le=500),
) -> dict:
    """Get activity feed for a task queue."""
    try:
        from npl_mcp.tasks.tasks import queue_feed
        return await queue_feed(queue_id=queue_id, since=since, limit=limit)
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.post("/task-queues/{queue_id}/tasks")
async def task_queue_create_task(queue_id: int, body: TaskInQueueCreateBody) -> dict:
    """Create a task within a queue."""
    try:
        from npl_mcp.tasks.tasks import task_create_in_queue
        result = await task_create_in_queue(
            queue_id=queue_id, title=body.title,
            description=body.description, status=body.status,
            priority=body.priority, assigned_to=body.assigned_to,
            acceptance_criteria=body.acceptance_criteria,
            deadline=body.deadline, complexity=body.complexity,
            complexity_notes=body.complexity_notes,
        )
        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message", "Invalid request"))
        return result
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.patch("/tasks/{task_id}/complexity")
async def task_assign_complexity_endpoint(task_id: int, body: TaskComplexityBody) -> dict:
    """Assign complexity score to a task."""
    try:
        from npl_mcp.tasks.tasks import task_assign_complexity
        result = await task_assign_complexity(
            task_id=task_id, complexity=body.complexity, notes=body.notes,
        )
        if result.get("status") == "not_found":
            raise HTTPException(status_code=404, detail=f"Task {task_id} not found")
        return result
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.post("/tasks/{task_id}/artifacts")
async def task_add_artifact_endpoint(task_id: int, body: TaskArtifactBody) -> dict:
    """Link an artifact or git branch to a task."""
    try:
        from npl_mcp.tasks.tasks import task_add_artifact
        return await task_add_artifact(
            task_id=task_id, artifact_type=body.artifact_type,
            artifact_id=body.artifact_id, git_branch=body.git_branch,
            description=body.description, created_by=body.created_by,
        )
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.get("/tasks/{task_id}/artifacts")
async def task_list_artifacts_endpoint(task_id: int) -> dict:
    """List artifacts linked to a task."""
    try:
        from npl_mcp.tasks.tasks import task_list_artifacts
        return await task_list_artifacts(task_id=task_id)
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.get("/tasks/{task_id}/feed")
async def task_feed_endpoint(
    task_id: int,
    since: Optional[str] = Query(None),
    limit: int = Query(default=50, ge=1, le=200),
) -> dict:
    """Get activity feed for a task."""
    try:
        from npl_mcp.tasks.tasks import task_feed
        return await task_feed(task_id=task_id, since=since, limit=limit)
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


# ---------------------------------------------------------------------------
# Reviews endpoints
# ---------------------------------------------------------------------------


class ReviewCreateBody(BaseModel):
    artifact_id: int
    revision_id: int
    reviewer_persona: str


class ReviewCommentBody(BaseModel):
    location: str
    comment: str
    persona: str


class ReviewCompleteBody(BaseModel):
    overall_comment: Optional[str] = None


@router.post("/reviews")
async def review_create_endpoint(body: ReviewCreateBody) -> dict:
    """Start a review session for an artifact revision."""
    try:
        from npl_mcp.artifacts.reviews import review_create
        return await review_create(
            artifact_id=body.artifact_id,
            revision_id=body.revision_id,
            reviewer_persona=body.reviewer_persona,
        )
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.get("/reviews/{review_id}")
async def review_get_endpoint(
    review_id: int,
    include_comments: bool = Query(default=True),
) -> dict:
    """Fetch a review with optional inline comments."""
    try:
        from npl_mcp.artifacts.reviews import review_get
        result = await review_get(review_id=review_id, include_comments=include_comments)
        if result.get("status") == "not_found":
            raise HTTPException(status_code=404, detail=f"Review {review_id} not found")
        return result
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.post("/reviews/{review_id}/comments")
async def review_add_comment_endpoint(review_id: int, body: ReviewCommentBody) -> dict:
    """Add an inline comment to a review."""
    try:
        from npl_mcp.artifacts.reviews import review_add_comment
        result = await review_add_comment(
            review_id=review_id, location=body.location,
            comment=body.comment, persona=body.persona,
        )
        if result.get("status") == "not_found":
            raise HTTPException(status_code=404, detail=f"Review {review_id} not found")
        return result
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


@router.post("/reviews/{review_id}/complete")
async def review_complete_endpoint(review_id: int, body: ReviewCompleteBody) -> dict:
    """Mark a review as completed."""
    try:
        from npl_mcp.artifacts.reviews import review_complete
        result = await review_complete(
            review_id=review_id, overall_comment=body.overall_comment,
        )
        if result.get("status") == "not_found":
            raise HTTPException(status_code=404, detail=f"Review {review_id} not found")
        return result
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {exc}") from exc


# ---------------------------------------------------------------------------
# Executor endpoints — Taskers
# ---------------------------------------------------------------------------


class TaskerSpawnBody(BaseModel):
    task: str
    chat_room_id: int
    parent_agent_id: str = "primary"
    patterns: Optional[list[str]] = None
    session_id: Optional[str] = None
    timeout_minutes: int = 15
    nag_minutes: int = 5


class TaskerDismissBody(BaseModel):
    reason: Optional[str] = None


@router.post("/taskers")
async def tasker_spawn_endpoint(body: TaskerSpawnBody) -> dict:
    """Spawn an ephemeral tasker."""
    try:
        from npl_mcp.executors.manager import spawn_tasker
        return await spawn_tasker(
            task=body.task, chat_room_id=body.chat_room_id,
            parent_agent_id=body.parent_agent_id,
            patterns=body.patterns, session_id=body.session_id,
            timeout_minutes=body.timeout_minutes,
            nag_minutes=body.nag_minutes,
        )
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Service unavailable: {exc}") from exc


@router.get("/taskers")
async def taskers_list_endpoint(
    status: Optional[str] = Query(None),
    session_id: Optional[str] = Query(None),
) -> dict:
    """List taskers with optional filtering."""
    try:
        from npl_mcp.executors.manager import list_taskers
        items = await list_taskers(status=status, session_id=session_id)
        return {"taskers": items, "count": len(items)}
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Service unavailable: {exc}") from exc


@router.get("/taskers/{tasker_id}")
async def tasker_get_endpoint(tasker_id: str) -> dict:
    """Get a tasker by ID."""
    try:
        from npl_mcp.executors.manager import get_tasker
        result = await get_tasker(tasker_id)
        if result is None:
            raise HTTPException(status_code=404, detail=f"Tasker '{tasker_id}' not found")
        return result
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Service unavailable: {exc}") from exc


@router.post("/taskers/{tasker_id}/dismiss")
async def tasker_dismiss_endpoint(tasker_id: str, body: TaskerDismissBody) -> dict:
    """Dismiss a tasker."""
    try:
        from npl_mcp.executors.manager import dismiss_tasker
        return await dismiss_tasker(tasker_id=tasker_id, reason=body.reason)
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Service unavailable: {exc}") from exc


@router.post("/taskers/{tasker_id}/keep-alive")
async def tasker_keep_alive_endpoint(tasker_id: str) -> dict:
    """Keep a tasker alive in response to a nag."""
    try:
        from npl_mcp.executors.manager import keep_alive
        return await keep_alive(tasker_id)
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Service unavailable: {exc}") from exc


@router.post("/taskers/{tasker_id}/touch")
async def tasker_touch_endpoint(tasker_id: str) -> dict:
    """Touch a tasker to reset its idle timer."""
    try:
        from npl_mcp.executors.manager import touch_tasker
        await touch_tasker(tasker_id)
        return {"status": "ok", "tasker_id": tasker_id}
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Service unavailable: {exc}") from exc


# ---------------------------------------------------------------------------
# Executor endpoints — Fabric
# ---------------------------------------------------------------------------


class FabricApplyBody(BaseModel):
    content: str
    pattern: str
    model: Optional[str] = None
    timeout: int = 300


class FabricAnalyzeBody(BaseModel):
    content: str
    patterns: list[str]
    combine_results: bool = True


@router.post("/fabric/apply")
async def fabric_apply_endpoint(body: FabricApplyBody) -> dict:
    """Apply a fabric pattern to content."""
    try:
        from npl_mcp.executors.fabric import apply_fabric_pattern
        return await apply_fabric_pattern(
            content=body.content, pattern=body.pattern,
            model=body.model, timeout=body.timeout,
        )
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Service unavailable: {exc}") from exc


@router.post("/fabric/analyze")
async def fabric_analyze_endpoint(body: FabricAnalyzeBody) -> dict:
    """Apply multiple fabric patterns to content."""
    try:
        from npl_mcp.executors.fabric import analyze_with_patterns
        return await analyze_with_patterns(
            content=body.content, patterns=body.patterns,
            combine_results=body.combine_results,
        )
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Service unavailable: {exc}") from exc


@router.get("/fabric/patterns")
async def fabric_list_patterns_endpoint() -> dict:
    """List available fabric patterns."""
    try:
        from npl_mcp.executors.fabric import list_patterns
        return await list_patterns()
    except Exception as exc:
        raise HTTPException(status_code=503, detail=f"Service unavailable: {exc}") from exc
