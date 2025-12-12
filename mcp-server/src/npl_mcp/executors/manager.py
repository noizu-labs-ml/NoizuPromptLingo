"""Tasker lifecycle management for ephemeral executor agents."""

import asyncio
import json
import secrets
import string
from dataclasses import dataclass, field
from datetime import datetime, timezone, timedelta
from enum import Enum
from typing import Optional, Dict, List, Any

from ..storage.db import Database


class TaskerStatus(str, Enum):
    """Tasker lifecycle states."""
    ACTIVE = "active"
    IDLE = "idle"
    NAGGING = "nagging"
    TERMINATED = "terminated"


def generate_tasker_id(length: int = 8) -> str:
    """Generate a short, URL-safe tasker ID.

    Args:
        length: Length of the ID (default: 8)

    Returns:
        Random alphanumeric string prefixed with 'tsk-'
    """
    alphabet = string.ascii_lowercase + string.digits
    return 'tsk-' + ''.join(secrets.choice(alphabet) for _ in range(length))


@dataclass
class TaskerContext:
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

    # Context buffer for follow-up queries
    command_history: List[Dict[str, Any]] = field(default_factory=list)
    last_raw_output: Optional[str] = None
    last_analysis: Optional[str] = None


class TaskerManager:
    """Manages ephemeral tasker lifecycle and operations."""

    def __init__(self, db: Database, chat_manager=None):
        """Initialize tasker manager.

        Args:
            db: Database instance
            chat_manager: Optional ChatManager for nag messages
        """
        self.db = db
        self.chat_manager = chat_manager

        # In-memory context for active taskers (faster than DB for hot data)
        self._contexts: Dict[str, TaskerContext] = {}

        # Lifecycle monitor task
        self._monitor_task: Optional[asyncio.Task] = None
        self._monitor_running = False

    async def start_lifecycle_monitor(self):
        """Start background lifecycle monitoring."""
        if self._monitor_running:
            return
        self._monitor_running = True
        self._monitor_task = asyncio.create_task(self._lifecycle_loop())

    async def stop_lifecycle_monitor(self):
        """Stop background lifecycle monitoring."""
        self._monitor_running = False
        if self._monitor_task:
            self._monitor_task.cancel()
            try:
                await self._monitor_task
            except asyncio.CancelledError:
                pass

    async def _lifecycle_loop(self):
        """Monitor taskers for idle/timeout conditions."""
        while self._monitor_running:
            try:
                await asyncio.sleep(30)  # Check every 30 seconds
                await self._check_taskers()
            except asyncio.CancelledError:
                break
            except Exception as e:
                # Log but don't crash the monitor
                print(f"Lifecycle monitor error: {e}")

    async def _check_taskers(self):
        """Check all taskers for timeout/nag conditions."""
        now = datetime.now(timezone.utc)

        for tasker_id, ctx in list(self._contexts.items()):
            if ctx.status == TaskerStatus.TERMINATED:
                continue

            idle_minutes = (now - ctx.last_activity).total_seconds() / 60
            total_minutes = (now - ctx.created_at).total_seconds() / 60

            # Check for total timeout (15 min default)
            if total_minutes >= ctx.timeout_minutes:
                await self._terminate_tasker(tasker_id, "timeout")
                continue

            # Check for nag condition (5 min idle default)
            if idle_minutes >= ctx.nag_minutes and ctx.status != TaskerStatus.NAGGING:
                await self._send_nag(tasker_id)
                continue

            # Check for nag timeout (2 min after nag sent)
            if ctx.status == TaskerStatus.NAGGING and ctx.nag_sent_at:
                nag_elapsed = (now - ctx.nag_sent_at).total_seconds() / 60
                if nag_elapsed >= 2:
                    await self._terminate_tasker(tasker_id, "nag_timeout")

    async def _send_nag(self, tasker_id: str):
        """Send nag message to parent agent via chat room."""
        ctx = self._contexts.get(tasker_id)
        if not ctx:
            return

        ctx.status = TaskerStatus.NAGGING
        ctx.nag_sent_at = datetime.now(timezone.utc)

        # Update DB status
        await self.db.execute(
            "UPDATE taskers SET status = ?, last_activity = ? WHERE id = ?",
            (TaskerStatus.NAGGING.value, ctx.nag_sent_at.isoformat(), tasker_id)
        )

        # Send chat message if chat manager available
        if self.chat_manager and ctx.chat_room_id:
            try:
                await self.chat_manager.send_message(
                    room_id=ctx.chat_room_id,
                    persona=f"tasker-{tasker_id}",
                    message=f"@{ctx.parent_agent_id} Still need me for '{ctx.task}'? (tasker: {tasker_id})"
                )
            except Exception as e:
                print(f"Failed to send nag message: {e}")

    async def _terminate_tasker(self, tasker_id: str, reason: str):
        """Terminate a tasker and clean up."""
        ctx = self._contexts.get(tasker_id)
        if not ctx:
            return

        ctx.status = TaskerStatus.TERMINATED
        now = datetime.now(timezone.utc)

        # Update DB
        await self.db.execute(
            """UPDATE taskers SET
                status = ?,
                terminated_at = ?,
                termination_reason = ?
            WHERE id = ?""",
            (TaskerStatus.TERMINATED.value, now.isoformat(), reason, tasker_id)
        )

        # Remove from in-memory contexts
        del self._contexts[tasker_id]

    async def spawn_tasker(
        self,
        task: str,
        chat_room_id: int,
        parent_agent_id: str = "primary",
        patterns: Optional[List[str]] = None,
        session_id: Optional[str] = None,
        timeout_minutes: int = 15,
        nag_minutes: int = 5
    ) -> Dict[str, Any]:
        """Spawn a new ephemeral tasker.

        Args:
            task: Description of the task/topic for the tasker
            chat_room_id: ID of chat room to join for nag messages
            parent_agent_id: Agent ID of spawning parent
            patterns: Fabric patterns to apply for analysis
            session_id: Optional session to associate with
            timeout_minutes: Auto-dismiss timeout (default: 15)
            nag_minutes: Idle time before nagging parent (default: 5)

        Returns:
            Dict with tasker_id, status, and configuration
        """
        tasker_id = generate_tasker_id()
        now = datetime.now(timezone.utc).isoformat()
        patterns = patterns or []

        # Insert into DB
        await self.db.execute(
            """INSERT INTO taskers (
                id, parent_agent_id, session_id, chat_room_id, task, patterns,
                status, timeout_minutes, nag_minutes, created_at, last_activity
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
            (
                tasker_id, parent_agent_id, session_id, chat_room_id, task,
                json.dumps(patterns), TaskerStatus.IDLE.value,
                timeout_minutes, nag_minutes, now, now
            )
        )

        # Create in-memory context
        ctx = TaskerContext(
            tasker_id=tasker_id,
            task=task,
            patterns=patterns,
            parent_agent_id=parent_agent_id,
            chat_room_id=chat_room_id,
            session_id=session_id,
            timeout_minutes=timeout_minutes,
            nag_minutes=nag_minutes
        )
        self._contexts[tasker_id] = ctx

        return {
            "tasker_id": tasker_id,
            "task": task,
            "patterns": patterns,
            "chat_room_id": chat_room_id,
            "session_id": session_id,
            "timeout_minutes": timeout_minutes,
            "nag_minutes": nag_minutes,
            "status": TaskerStatus.IDLE.value
        }

    async def get_tasker(self, tasker_id: str) -> Optional[Dict[str, Any]]:
        """Get tasker by ID.

        Args:
            tasker_id: Tasker ID

        Returns:
            Tasker dict or None if not found
        """
        row = await self.db.fetchone(
            "SELECT * FROM taskers WHERE id = ?",
            (tasker_id,)
        )
        if not row:
            return None

        result = dict(row)
        result['patterns'] = json.loads(result['patterns']) if result['patterns'] else []
        return result

    async def list_taskers(
        self,
        status: Optional[str] = None,
        session_id: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """List taskers with optional filtering.

        Args:
            status: Optional status filter
            session_id: Optional session filter

        Returns:
            List of tasker dicts
        """
        query = "SELECT * FROM taskers WHERE 1=1"
        params = []

        if status:
            query += " AND status = ?"
            params.append(status)

        if session_id:
            query += " AND session_id = ?"
            params.append(session_id)

        query += " ORDER BY created_at DESC"

        rows = await self.db.fetchall(query, tuple(params))
        results = []
        for row in rows:
            result = dict(row)
            result['patterns'] = json.loads(result['patterns']) if result['patterns'] else []
            results.append(result)
        return results

    async def touch_tasker(self, tasker_id: str):
        """Update tasker's last_activity timestamp and reset nag state.

        Args:
            tasker_id: Tasker ID
        """
        now = datetime.now(timezone.utc)

        # Update in-memory context
        ctx = self._contexts.get(tasker_id)
        if ctx:
            ctx.last_activity = now
            ctx.status = TaskerStatus.ACTIVE
            ctx.nag_sent_at = None

        # Update DB
        await self.db.execute(
            "UPDATE taskers SET last_activity = ?, status = ? WHERE id = ?",
            (now.isoformat(), TaskerStatus.ACTIVE.value, tasker_id)
        )

    async def store_context(
        self,
        tasker_id: str,
        command: Optional[str] = None,
        raw_output: Optional[str] = None,
        analysis: Optional[str] = None,
        result: Optional[str] = None
    ):
        """Store execution context for follow-up queries.

        Args:
            tasker_id: Tasker ID
            command: Command that was executed
            raw_output: Raw command output
            analysis: Fabric analysis result
            result: Distilled result
        """
        ctx = self._contexts.get(tasker_id)
        if not ctx:
            return

        # Store in context buffer
        ctx.command_history.append({
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "command": command,
            "result": result
        })

        # Keep only last 10 commands
        if len(ctx.command_history) > 10:
            ctx.command_history = ctx.command_history[-10:]

        # Store latest outputs for follow-up
        if raw_output:
            ctx.last_raw_output = raw_output
        if analysis:
            ctx.last_analysis = analysis

    async def get_context(self, tasker_id: str) -> Optional[Dict[str, Any]]:
        """Get tasker's execution context for follow-up queries.

        Args:
            tasker_id: Tasker ID

        Returns:
            Context dict with command_history, last_raw_output, last_analysis
        """
        ctx = self._contexts.get(tasker_id)
        if not ctx:
            return None

        return {
            "task": ctx.task,
            "patterns": ctx.patterns,
            "command_history": ctx.command_history,
            "last_raw_output": ctx.last_raw_output,
            "last_analysis": ctx.last_analysis
        }

    async def dismiss_tasker(
        self,
        tasker_id: str,
        reason: Optional[str] = None
    ) -> Dict[str, Any]:
        """Explicitly dismiss/terminate a tasker.

        Args:
            tasker_id: Tasker ID
            reason: Optional dismissal reason

        Returns:
            Dict with status and stats
        """
        ctx = self._contexts.get(tasker_id)
        if not ctx:
            # Check if exists in DB
            existing = await self.get_tasker(tasker_id)
            if not existing:
                raise ValueError(f"Tasker '{tasker_id}' not found")

            # Already terminated
            return {
                "tasker_id": tasker_id,
                "status": "already_terminated",
                "terminated_at": existing.get('terminated_at'),
                "termination_reason": existing.get('termination_reason')
            }

        # Calculate stats
        duration = (datetime.now(timezone.utc) - ctx.created_at).total_seconds()
        tasks_completed = len(ctx.command_history)

        # Terminate
        await self._terminate_tasker(tasker_id, reason or "dismissed")

        return {
            "tasker_id": tasker_id,
            "status": "dismissed",
            "duration_seconds": duration,
            "tasks_completed": tasks_completed,
            "termination_reason": reason or "dismissed"
        }

    async def keep_alive(self, tasker_id: str) -> Dict[str, Any]:
        """Respond to nag by keeping tasker alive.

        Args:
            tasker_id: Tasker ID

        Returns:
            Dict with updated status
        """
        ctx = self._contexts.get(tasker_id)
        if not ctx:
            raise ValueError(f"Tasker '{tasker_id}' not found or already terminated")

        # Reset nag state
        ctx.status = TaskerStatus.IDLE
        ctx.nag_sent_at = None
        ctx.last_activity = datetime.now(timezone.utc)

        # Update DB
        await self.db.execute(
            "UPDATE taskers SET status = ?, last_activity = ? WHERE id = ?",
            (TaskerStatus.IDLE.value, ctx.last_activity.isoformat(), tasker_id)
        )

        return {
            "tasker_id": tasker_id,
            "status": TaskerStatus.IDLE.value,
            "message": "Tasker kept alive"
        }
