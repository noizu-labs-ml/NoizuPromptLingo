"""Tasker lifecycle management for ephemeral executor agents.

Ported from main's TaskerManager class to standalone functions using asyncpg pool.
"""

import asyncio
import json
import secrets
import string
from dataclasses import dataclass, field
from datetime import datetime, timezone
from enum import Enum
from typing import Optional, Dict, List, Any

from npl_mcp.storage import get_pool


class TaskerStatus(str, Enum):
    ACTIVE = "active"
    IDLE = "idle"
    NAGGING = "nagging"
    TERMINATED = "terminated"


def _generate_tasker_id(length: int = 8) -> str:
    alphabet = string.ascii_lowercase + string.digits
    return "tsk-" + "".join(secrets.choice(alphabet) for _ in range(length))


@dataclass
class _TaskerContext:
    """In-memory context for an active tasker."""

    tasker_id: str
    task: str
    patterns: List[str]
    parent_agent_id: str
    chat_room_id: int
    session_id: Optional[str] = None
    timeout_minutes: int = 15
    nag_minutes: int = 5
    status: TaskerStatus = TaskerStatus.IDLE
    created_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
    last_activity: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
    nag_sent_at: Optional[datetime] = None
    command_history: List[Dict[str, Any]] = field(default_factory=list)
    last_raw_output: Optional[str] = None
    last_analysis: Optional[str] = None


# Module-level state
_contexts: Dict[str, _TaskerContext] = {}
_monitor_task: Optional[asyncio.Task] = None
_monitor_running = False


def _tasker_dto(row) -> dict[str, Any]:
    return {
        "tasker_id": row["id"],
        "parent_agent_id": row["parent_agent_id"],
        "session_id": row["session_id"],
        "chat_room_id": row["chat_room_id"],
        "task": row["task"],
        "patterns": row["patterns"] if isinstance(row["patterns"], list) else json.loads(row["patterns"] or "[]"),
        "status": row["status"],
        "timeout_minutes": row["timeout_minutes"],
        "nag_minutes": row["nag_minutes"],
        "created_at": row["created_at"].isoformat() if row["created_at"] else None,
        "last_activity": row["last_activity"].isoformat() if row["last_activity"] else None,
        "terminated_at": row["terminated_at"].isoformat() if row["terminated_at"] else None,
        "termination_reason": row["termination_reason"],
    }


async def spawn_tasker(
    task: str,
    chat_room_id: int,
    parent_agent_id: str = "primary",
    patterns: Optional[List[str]] = None,
    session_id: Optional[str] = None,
    timeout_minutes: int = 15,
    nag_minutes: int = 5,
) -> Dict[str, Any]:
    """Spawn a new ephemeral tasker."""
    pool = await get_pool()
    tasker_id = _generate_tasker_id()
    patterns = patterns or []

    await pool.execute(
        """INSERT INTO npl_taskers (
            id, parent_agent_id, session_id, chat_room_id, task, patterns,
            status, timeout_minutes, nag_minutes
        ) VALUES ($1, $2, $3, $4, $5, $6::jsonb, $7, $8, $9)""",
        tasker_id,
        parent_agent_id,
        session_id,
        chat_room_id,
        task,
        json.dumps(patterns),
        TaskerStatus.IDLE.value,
        timeout_minutes,
        nag_minutes,
    )

    ctx = _TaskerContext(
        tasker_id=tasker_id,
        task=task,
        patterns=patterns,
        parent_agent_id=parent_agent_id,
        chat_room_id=chat_room_id,
        session_id=session_id,
        timeout_minutes=timeout_minutes,
        nag_minutes=nag_minutes,
    )
    _contexts[tasker_id] = ctx

    return {
        "tasker_id": tasker_id,
        "task": task,
        "patterns": patterns,
        "chat_room_id": chat_room_id,
        "session_id": session_id,
        "timeout_minutes": timeout_minutes,
        "nag_minutes": nag_minutes,
        "status": TaskerStatus.IDLE.value,
    }


async def get_tasker(tasker_id: str) -> Optional[Dict[str, Any]]:
    """Get tasker by ID."""
    pool = await get_pool()
    row = await pool.fetchrow("SELECT * FROM npl_taskers WHERE id = $1", tasker_id)
    if not row:
        return None
    return _tasker_dto(row)


async def list_taskers(
    status: Optional[str] = None,
    session_id: Optional[str] = None,
) -> List[Dict[str, Any]]:
    """List taskers with optional filtering."""
    pool = await get_pool()
    conditions = []
    params: list[Any] = []
    idx = 1

    if status:
        conditions.append(f"status = ${idx}")
        params.append(status)
        idx += 1

    if session_id:
        conditions.append(f"session_id = ${idx}")
        params.append(session_id)
        idx += 1

    where = " AND ".join(conditions) if conditions else "TRUE"
    rows = await pool.fetch(
        f"SELECT * FROM npl_taskers WHERE {where} ORDER BY created_at DESC",
        *params,
    )
    return [_tasker_dto(r) for r in rows]


async def touch_tasker(tasker_id: str) -> None:
    """Update tasker's last_activity and reset nag state."""
    pool = await get_pool()
    now = datetime.now(timezone.utc)

    ctx = _contexts.get(tasker_id)
    if ctx:
        ctx.last_activity = now
        ctx.status = TaskerStatus.ACTIVE
        ctx.nag_sent_at = None

    await pool.execute(
        "UPDATE npl_taskers SET last_activity = NOW(), status = $1 WHERE id = $2",
        TaskerStatus.ACTIVE.value,
        tasker_id,
    )


async def store_context(
    tasker_id: str,
    command: Optional[str] = None,
    raw_output: Optional[str] = None,
    analysis: Optional[str] = None,
    result: Optional[str] = None,
) -> None:
    """Store execution context for follow-up queries."""
    ctx = _contexts.get(tasker_id)
    if not ctx:
        return

    ctx.command_history.append({
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "command": command,
        "result": result,
    })

    if len(ctx.command_history) > 10:
        ctx.command_history = ctx.command_history[-10:]

    if raw_output:
        ctx.last_raw_output = raw_output
    if analysis:
        ctx.last_analysis = analysis


async def get_context(tasker_id: str) -> Optional[Dict[str, Any]]:
    """Get tasker's execution context for follow-up queries."""
    ctx = _contexts.get(tasker_id)
    if not ctx:
        return None

    return {
        "task": ctx.task,
        "patterns": ctx.patterns,
        "command_history": ctx.command_history,
        "last_raw_output": ctx.last_raw_output,
        "last_analysis": ctx.last_analysis,
    }


async def dismiss_tasker(
    tasker_id: str,
    reason: Optional[str] = None,
) -> Dict[str, Any]:
    """Explicitly dismiss/terminate a tasker."""
    ctx = _contexts.get(tasker_id)
    if not ctx:
        existing = await get_tasker(tasker_id)
        if not existing:
            return {"status": "error", "error": f"Tasker '{tasker_id}' not found"}

        return {
            "tasker_id": tasker_id,
            "status": "already_terminated",
            "terminated_at": existing.get("terminated_at"),
            "termination_reason": existing.get("termination_reason"),
        }

    duration = (datetime.now(timezone.utc) - ctx.created_at).total_seconds()
    tasks_completed = len(ctx.command_history)

    await _terminate_tasker(tasker_id, reason or "dismissed")

    return {
        "tasker_id": tasker_id,
        "status": "dismissed",
        "duration_seconds": duration,
        "tasks_completed": tasks_completed,
        "termination_reason": reason or "dismissed",
    }


async def keep_alive(tasker_id: str) -> Dict[str, Any]:
    """Respond to nag by keeping tasker alive."""
    ctx = _contexts.get(tasker_id)
    if not ctx:
        return {"status": "error", "error": f"Tasker '{tasker_id}' not found or already terminated"}

    pool = await get_pool()
    ctx.status = TaskerStatus.IDLE
    ctx.nag_sent_at = None
    ctx.last_activity = datetime.now(timezone.utc)

    await pool.execute(
        "UPDATE npl_taskers SET status = $1, last_activity = NOW() WHERE id = $2",
        TaskerStatus.IDLE.value,
        tasker_id,
    )

    return {
        "tasker_id": tasker_id,
        "status": TaskerStatus.IDLE.value,
        "message": "Tasker kept alive",
    }


# --- Lifecycle monitor (module-level) ---


async def start_lifecycle_monitor() -> None:
    """Start background lifecycle monitoring."""
    global _monitor_task, _monitor_running
    if _monitor_running:
        return
    _monitor_running = True
    _monitor_task = asyncio.create_task(_lifecycle_loop())


async def stop_lifecycle_monitor() -> None:
    """Stop background lifecycle monitoring."""
    global _monitor_task, _monitor_running
    _monitor_running = False
    if _monitor_task:
        _monitor_task.cancel()
        try:
            await _monitor_task
        except asyncio.CancelledError:
            pass


async def _lifecycle_loop() -> None:
    while _monitor_running:
        try:
            await asyncio.sleep(30)
            await _check_taskers()
        except asyncio.CancelledError:
            break
        except Exception as e:
            print(f"Lifecycle monitor error: {e}")


async def _check_taskers() -> None:
    now = datetime.now(timezone.utc)

    for tasker_id, ctx in list(_contexts.items()):
        if ctx.status == TaskerStatus.TERMINATED:
            continue

        idle_minutes = (now - ctx.last_activity).total_seconds() / 60
        total_minutes = (now - ctx.created_at).total_seconds() / 60

        if total_minutes >= ctx.timeout_minutes:
            await _terminate_tasker(tasker_id, "timeout")
            continue

        if idle_minutes >= ctx.nag_minutes and ctx.status != TaskerStatus.NAGGING:
            await _send_nag(tasker_id)
            continue

        if ctx.status == TaskerStatus.NAGGING and ctx.nag_sent_at:
            nag_elapsed = (now - ctx.nag_sent_at).total_seconds() / 60
            if nag_elapsed >= 2:
                await _terminate_tasker(tasker_id, "nag_timeout")


async def _send_nag(tasker_id: str) -> None:
    ctx = _contexts.get(tasker_id)
    if not ctx:
        return

    pool = await get_pool()
    ctx.status = TaskerStatus.NAGGING
    ctx.nag_sent_at = datetime.now(timezone.utc)

    await pool.execute(
        "UPDATE npl_taskers SET status = $1, last_activity = NOW() WHERE id = $2",
        TaskerStatus.NAGGING.value,
        tasker_id,
    )

    if ctx.chat_room_id:
        try:
            from npl_mcp.chat.chat import message_create

            await message_create(
                room_id=ctx.chat_room_id,
                content=f"@{ctx.parent_agent_id} Still need me for '{ctx.task}'? (tasker: {tasker_id})",
                author=f"tasker-{tasker_id}",
            )
        except Exception as e:
            print(f"Failed to send nag message: {e}")


async def _terminate_tasker(tasker_id: str, reason: str) -> None:
    ctx = _contexts.get(tasker_id)
    if not ctx:
        return

    pool = await get_pool()
    ctx.status = TaskerStatus.TERMINATED

    await pool.execute(
        """UPDATE npl_taskers SET
            status = $1, terminated_at = NOW(), termination_reason = $2
        WHERE id = $3""",
        TaskerStatus.TERMINATED.value,
        reason,
        tasker_id,
    )

    del _contexts[tasker_id]
