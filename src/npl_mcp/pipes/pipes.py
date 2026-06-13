"""Agent input/output pipe — inter-agent structured messaging.

Output pipe: agent pushes YAML body with sections targeting other agents
or groups.  Each (sender_agent_id, message_name, target*) row is upserted.

Input pipe: agent pulls entries addressed to it (by UUID, agent handle,
or group membership), optionally filtered by time and section name.
"""

from __future__ import annotations

import uuid as _uuid_mod
from datetime import datetime, timezone
from typing import Any, Optional

import shortuuid
import yaml

from npl_mcp.storage import get_pool


def _decode(value: str) -> Optional[_uuid_mod.UUID]:
    try:
        return shortuuid.decode(value)
    except (ValueError, AttributeError):
        pass
    try:
        return _uuid_mod.UUID(value)
    except (ValueError, AttributeError):
        return None


def _encode(uid: _uuid_mod.UUID) -> str:
    return shortuuid.encode(uid)


async def _resolve_session(pool, agent_id: str) -> Optional[dict]:
    uid = _decode(agent_id)
    if uid is None:
        return None
    row = await pool.fetchrow(
        "SELECT id, agent, project_id FROM npl_tool_sessions WHERE id = $1",
        uid,
    )
    if row is None:
        return None
    return {"id": row["id"], "agent": row["agent"], "project_id": row["project_id"]}


async def _agent_groups(pool, session_id: _uuid_mod.UUID, agent_handle: str) -> list[dict]:
    rows = await pool.fetch(
        """SELECT g.group_name, g.group_handle
           FROM npl_agent_groups g
           JOIN npl_agent_group_members m ON m.group_id = g.id
           WHERE m.session_id = $1 OR m.agent_handle = $2""",
        session_id,
        agent_handle,
    )
    return [{"group_name": r["group_name"], "group_handle": r["group_handle"]} for r in rows]


# ── output pipe ──────────────────────────────────────────────────────────


async def agent_output_pipe(
    agent: str,
    body: str,
) -> dict[str, Any]:
    """Push structured YAML data to target agents/groups.

    ``body`` is YAML with top-level keys as message names.  Each entry:

    .. code-block:: yaml

       message-name:
         target:
           agent: <uuid>           # optional — direct session target
           agent-handle: <name>    # optional — target by agent name
           group: <name>           # optional — target group by name
           group-handle: <uuid>    # optional — target group by handle
         data:
           <arbitrary yaml payload>

    Each (sender, message_name, target) tuple is upserted — calling again
    replaces the previous entry's body and bumps ``updated_at``.
    """
    pool = await get_pool()
    session = await _resolve_session(pool, agent)
    if session is None:
        return {"status": "error", "message": f"Session not found: {agent}"}

    try:
        parsed = yaml.safe_load(body)
    except yaml.YAMLError as exc:
        return {"status": "error", "message": f"Invalid YAML: {exc}"}

    if not isinstance(parsed, dict):
        return {"status": "error", "message": "Body must be a YAML mapping of message sections."}

    sender_id: _uuid_mod.UUID = session["id"]
    sender_handle: str = session["agent"]
    upserted = 0

    for message_name, section in parsed.items():
        if not isinstance(section, dict):
            continue
        target = section.get("target", {}) or {}
        data = section.get("data", section)
        if data is target:
            data = {k: v for k, v in section.items() if k != "target"}

        target_agent_raw = target.get("agent")
        target_agent = _decode(target_agent_raw) if target_agent_raw else None
        target_agent_handle = target.get("agent-handle")
        target_group = target.get("group")
        target_group_handle_raw = target.get("group-handle")
        target_group_handle = _decode(target_group_handle_raw) if target_group_handle_raw else None

        body_text = yaml.dump(data, default_flow_style=False, allow_unicode=True)
        now = datetime.now(timezone.utc)

        # Upsert by (sender, message_name, target combination)
        await pool.execute(
            """INSERT INTO npl_agent_pipe_entries
                   (sender_agent_id, sender_agent_handle, message_name,
                    target_agent, target_agent_handle, target_group, target_group_handle,
                    body, created_at, updated_at)
               VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$9)
               ON CONFLICT (sender_agent_id, message_name,
                            COALESCE(target_agent::text,''),
                            COALESCE(target_agent_handle,''),
                            COALESCE(target_group,''),
                            COALESCE(target_group_handle::text,''))
               DO UPDATE SET body = EXCLUDED.body,
                             updated_at = EXCLUDED.updated_at""",
            sender_id,
            sender_handle,
            str(message_name),
            target_agent,
            target_agent_handle,
            target_group,
            target_group_handle,
            body_text,
            now,
        )
        upserted += 1

    return {"status": "ok", "upserted": upserted, "sender": _encode(sender_id)}


# ── input pipe ───────────────────────────────────────────────────────────


async def agent_input_pipe(
    agent: str,
    since: Optional[str] = None,
    full: bool = False,
    with_sections: Optional[list[str]] = None,
) -> dict[str, Any]:
    """Pull messages addressed to this agent.

    Matches entries where any target field matches the agent's session UUID,
    agent handle, or group memberships.

    Args:
        agent: Session UUID (short or full) of the requesting agent.
        since: ISO-8601 UTC timestamp — only entries updated after this time.
        full: If True, return all matching entries (no time filter even if since set).
        with_sections: Optional list of message_name values to include.

    Returns a YAML dashboard keyed by message_name with sender info + data.
    """
    pool = await get_pool()
    session = await _resolve_session(pool, agent)
    if session is None:
        return {"status": "error", "message": f"Session not found: {agent}"}

    session_id: _uuid_mod.UUID = session["id"]
    agent_handle: str = session["agent"]

    groups = await _agent_groups(pool, session_id, agent_handle)
    group_names = [g["group_name"] for g in groups]
    group_handles = [g["group_handle"] for g in groups]

    # Build query — match any target field
    conditions = [
        "e.target_agent = $1",
        "e.target_agent_handle = $2",
    ]
    params: list[Any] = [session_id, agent_handle]
    idx = 3

    if group_names:
        conditions.append(f"e.target_group = ANY(${idx}::text[])")
        params.append(group_names)
        idx += 1

    if group_handles:
        conditions.append(f"e.target_group_handle = ANY(${idx}::uuid[])")
        params.append(group_handles)
        idx += 1

    where = f"({' OR '.join(conditions)})"

    # Optional time filter
    if since and not full:
        try:
            since_dt = datetime.fromisoformat(since.replace("Z", "+00:00"))
        except ValueError:
            return {"status": "error", "message": f"Invalid since timestamp: {since}"}
        where += f" AND e.updated_at > ${idx}"
        params.append(since_dt)
        idx += 1

    # Optional section filter
    if with_sections:
        where += f" AND e.message_name = ANY(${idx}::text[])"
        params.append(with_sections)
        idx += 1

    rows = await pool.fetch(
        f"""SELECT e.message_name, e.sender_agent_id, e.sender_agent_handle,
                   e.body, e.updated_at
            FROM npl_agent_pipe_entries e
            WHERE {where}
            ORDER BY e.updated_at DESC""",
        *params,
    )

    # Build dashboard
    dashboard: dict[str, Any] = {}
    for row in rows:
        key = row["message_name"]
        try:
            data = yaml.safe_load(row["body"])
        except yaml.YAMLError:
            data = row["body"]
        entry = {
            "sender": {
                "agent_id": _encode(row["sender_agent_id"]),
                "agent_handle": row["sender_agent_handle"],
            },
            "updated_at": row["updated_at"].isoformat() if row["updated_at"] else None,
            "data": data,
        }
        if key in dashboard:
            if not isinstance(dashboard[key], list):
                dashboard[key] = [dashboard[key]]
            dashboard[key].append(entry)
        else:
            dashboard[key] = entry

    return {
        "status": "ok",
        "agent": _encode(session_id),
        "agent_handle": agent_handle,
        "groups": [g["group_name"] for g in groups],
        "entries": len(rows),
        "dashboard": dashboard,
    }
