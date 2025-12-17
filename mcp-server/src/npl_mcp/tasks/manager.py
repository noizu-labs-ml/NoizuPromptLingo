"""Task queue management for agent work assignments."""

import json
from datetime import datetime
from typing import Optional, Dict, List, Any
from ..storage.db import Database


# Task status flow: pending -> in_progress -> blocked -> review -> done
# Only human operator can mark as done
TASK_STATUSES = ["pending", "in_progress", "blocked", "review", "done"]

# Priority levels (higher = more urgent)
PRIORITY_LOW = 0
PRIORITY_NORMAL = 1
PRIORITY_HIGH = 2
PRIORITY_URGENT = 3


class TaskQueueManager:
    """Manages task queues, tasks, and activity feed."""

    def __init__(self, db: Database):
        """Initialize task queue manager.

        Args:
            db: Database instance
        """
        self.db = db

    # ============================================================
    # Task Queue Operations
    # ============================================================

    async def create_task_queue(
        self,
        name: str,
        description: Optional[str] = None,
        session_id: Optional[str] = None,
        chat_room_id: Optional[int] = None,
    ) -> Dict[str, Any]:
        """Create a new task queue.

        Args:
            name: Unique name for the queue
            description: Optional description
            session_id: Optional session to associate with
            chat_room_id: Optional chat room for Q&A

        Returns:
            Dict with queue_id and metadata

        Raises:
            ValueError: If queue name already exists
        """
        # Check if queue exists
        existing = await self.db.fetchone(
            "SELECT id FROM task_queues WHERE name = ?",
            (name,)
        )
        if existing:
            raise ValueError(f"Task queue '{name}' already exists")

        # Create queue
        cursor = await self.db.execute(
            """
            INSERT INTO task_queues (name, description, session_id, chat_room_id)
            VALUES (?, ?, ?, ?)
            """,
            (name, description, session_id, chat_room_id)
        )
        queue_id = cursor.lastrowid

        return {
            "queue_id": queue_id,
            "name": name,
            "description": description,
            "session_id": session_id,
            "chat_room_id": chat_room_id,
            "status": "active",
        }

    async def get_task_queue(self, queue_id: int) -> Dict[str, Any]:
        """Get task queue details with task counts.

        Args:
            queue_id: ID of the queue

        Returns:
            Dict with queue details and task statistics

        Raises:
            ValueError: If queue not found
        """
        queue = await self.db.fetchone(
            "SELECT * FROM task_queues WHERE id = ?",
            (queue_id,)
        )
        if not queue:
            raise ValueError(f"Task queue {queue_id} not found")

        # Get task counts by status
        counts = await self.db.fetchall(
            """
            SELECT status, COUNT(*) as count
            FROM tasks WHERE queue_id = ?
            GROUP BY status
            """,
            (queue_id,)
        )
        status_counts = {row["status"]: row["count"] for row in counts}

        result = dict(queue)
        result["task_counts"] = status_counts
        result["total_tasks"] = sum(status_counts.values())
        return result

    async def list_task_queues(
        self,
        status: Optional[str] = None,
        limit: int = 50
    ) -> List[Dict[str, Any]]:
        """List task queues with summary stats.

        Args:
            status: Optional status filter
            limit: Maximum number of queues to return

        Returns:
            List of queue dicts with task counts
        """
        if status:
            queues = await self.db.fetchall(
                """
                SELECT tq.*,
                       (SELECT COUNT(*) FROM tasks WHERE queue_id = tq.id) as task_count,
                       (SELECT COUNT(*) FROM tasks WHERE queue_id = tq.id AND status = 'pending') as pending_count,
                       (SELECT COUNT(*) FROM tasks WHERE queue_id = tq.id AND status = 'in_progress') as in_progress_count
                FROM task_queues tq
                WHERE tq.status = ?
                ORDER BY tq.updated_at DESC
                LIMIT ?
                """,
                (status, limit)
            )
        else:
            queues = await self.db.fetchall(
                """
                SELECT tq.*,
                       (SELECT COUNT(*) FROM tasks WHERE queue_id = tq.id) as task_count,
                       (SELECT COUNT(*) FROM tasks WHERE queue_id = tq.id AND status = 'pending') as pending_count,
                       (SELECT COUNT(*) FROM tasks WHERE queue_id = tq.id AND status = 'in_progress') as in_progress_count
                FROM task_queues tq
                ORDER BY tq.updated_at DESC
                LIMIT ?
                """,
                (limit,)
            )

        return [dict(q) for q in queues]

    async def update_task_queue(
        self,
        queue_id: int,
        name: Optional[str] = None,
        description: Optional[str] = None,
        status: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Update task queue metadata.

        Args:
            queue_id: ID of the queue
            name: New name (optional)
            description: New description (optional)
            status: New status (optional)

        Returns:
            Updated queue dict

        Raises:
            ValueError: If queue not found
        """
        queue = await self.db.fetchone(
            "SELECT * FROM task_queues WHERE id = ?",
            (queue_id,)
        )
        if not queue:
            raise ValueError(f"Task queue {queue_id} not found")

        updates = []
        params = []
        if name is not None:
            updates.append("name = ?")
            params.append(name)
        if description is not None:
            updates.append("description = ?")
            params.append(description)
        if status is not None:
            updates.append("status = ?")
            params.append(status)

        if updates:
            updates.append("updated_at = datetime('now')")
            params.append(queue_id)
            await self.db.execute(
                f"UPDATE task_queues SET {', '.join(updates)} WHERE id = ?",
                tuple(params)
            )

        return await self.get_task_queue(queue_id)

    # ============================================================
    # Task Operations
    # ============================================================

    async def create_task(
        self,
        queue_id: int,
        title: str,
        description: Optional[str] = None,
        acceptance_criteria: Optional[str] = None,
        priority: int = PRIORITY_NORMAL,
        deadline: Optional[str] = None,
        created_by: Optional[str] = None,
        assigned_to: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Create a new task in a queue.

        Args:
            queue_id: ID of the task queue
            title: Task title
            description: Task description
            acceptance_criteria: Criteria for task completion
            priority: Priority level (0-3)
            deadline: ISO timestamp deadline
            created_by: Persona who created the task
            assigned_to: Persona assigned to the task

        Returns:
            Dict with task_id and metadata

        Raises:
            ValueError: If queue not found
        """
        # Verify queue exists
        queue = await self.db.fetchone(
            "SELECT id FROM task_queues WHERE id = ?",
            (queue_id,)
        )
        if not queue:
            raise ValueError(f"Task queue {queue_id} not found")

        # Create task
        cursor = await self.db.execute(
            """
            INSERT INTO tasks
            (queue_id, title, description, acceptance_criteria, priority, deadline, created_by, assigned_to)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (queue_id, title, description, acceptance_criteria, priority, deadline, created_by, assigned_to)
        )
        task_id = cursor.lastrowid

        # Touch queue updated_at
        await self._touch_queue(queue_id)

        # Create task event
        await self._create_task_event(
            task_id=task_id,
            queue_id=queue_id,
            event_type="task_created",
            persona=created_by,
            data={
                "title": title,
                "priority": priority,
                "deadline": deadline,
                "assigned_to": assigned_to,
            }
        )

        return {
            "task_id": task_id,
            "queue_id": queue_id,
            "title": title,
            "description": description,
            "acceptance_criteria": acceptance_criteria,
            "priority": priority,
            "deadline": deadline,
            "status": "pending",
            "created_by": created_by,
            "assigned_to": assigned_to,
        }

    async def get_task(self, task_id: int) -> Dict[str, Any]:
        """Get task details.

        Args:
            task_id: ID of the task

        Returns:
            Dict with task details

        Raises:
            ValueError: If task not found
        """
        task = await self.db.fetchone(
            "SELECT * FROM tasks WHERE id = ?",
            (task_id,)
        )
        if not task:
            raise ValueError(f"Task {task_id} not found")

        result = dict(task)

        # Get linked artifacts
        artifacts = await self.db.fetchall(
            """
            SELECT ta.*, a.name as artifact_name, a.type as artifact_file_type
            FROM task_artifacts ta
            LEFT JOIN artifacts a ON ta.artifact_id = a.id
            WHERE ta.task_id = ?
            ORDER BY ta.created_at DESC
            """,
            (task_id,)
        )
        result["artifacts"] = [dict(a) for a in artifacts]

        return result

    async def list_tasks(
        self,
        queue_id: int,
        status: Optional[str] = None,
        assigned_to: Optional[str] = None,
        limit: int = 100,
    ) -> List[Dict[str, Any]]:
        """List tasks in a queue.

        Args:
            queue_id: ID of the queue
            status: Optional status filter
            assigned_to: Optional assignee filter
            limit: Maximum tasks to return

        Returns:
            List of task dicts ordered by priority and deadline
        """
        conditions = ["queue_id = ?"]
        params = [queue_id]

        if status:
            conditions.append("status = ?")
            params.append(status)
        if assigned_to:
            conditions.append("assigned_to = ?")
            params.append(assigned_to)

        params.append(limit)

        tasks = await self.db.fetchall(
            f"""
            SELECT * FROM tasks
            WHERE {' AND '.join(conditions)}
            ORDER BY
                CASE WHEN deadline IS NOT NULL THEN 0 ELSE 1 END,
                deadline ASC,
                priority DESC,
                created_at ASC
            LIMIT ?
            """,
            tuple(params)
        )

        return [dict(t) for t in tasks]

    async def update_task_status(
        self,
        task_id: int,
        status: str,
        persona: Optional[str] = None,
        notes: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Update task status.

        Args:
            task_id: ID of the task
            status: New status (pending, in_progress, blocked, review, done)
            persona: Persona making the change
            notes: Optional notes about the status change

        Returns:
            Updated task dict

        Raises:
            ValueError: If task not found or invalid status
        """
        if status not in TASK_STATUSES:
            raise ValueError(f"Invalid status '{status}'. Must be one of: {TASK_STATUSES}")

        task = await self.db.fetchone(
            "SELECT * FROM tasks WHERE id = ?",
            (task_id,)
        )
        if not task:
            raise ValueError(f"Task {task_id} not found")

        old_status = task["status"]

        await self.db.execute(
            "UPDATE tasks SET status = ?, updated_at = datetime('now') WHERE id = ?",
            (status, task_id)
        )

        await self._touch_queue(task["queue_id"])

        # Create status change event
        await self._create_task_event(
            task_id=task_id,
            queue_id=task["queue_id"],
            event_type="status_changed",
            persona=persona,
            data={
                "old_status": old_status,
                "new_status": status,
                "notes": notes,
            }
        )

        return await self.get_task(task_id)

    async def assign_complexity(
        self,
        task_id: int,
        complexity: int,
        notes: Optional[str] = None,
        persona: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Assign complexity score to a task (agent-assigned).

        Args:
            task_id: ID of the task
            complexity: Complexity score (1-5 or custom scale)
            notes: Optional notes about complexity assessment
            persona: Persona (agent) making the assessment

        Returns:
            Updated task dict

        Raises:
            ValueError: If task not found
        """
        task = await self.db.fetchone(
            "SELECT * FROM tasks WHERE id = ?",
            (task_id,)
        )
        if not task:
            raise ValueError(f"Task {task_id} not found")

        await self.db.execute(
            """
            UPDATE tasks
            SET complexity = ?, complexity_notes = ?, updated_at = datetime('now')
            WHERE id = ?
            """,
            (complexity, notes, task_id)
        )

        await self._touch_queue(task["queue_id"])

        # Create complexity assessment event
        await self._create_task_event(
            task_id=task_id,
            queue_id=task["queue_id"],
            event_type="complexity_assigned",
            persona=persona,
            data={
                "complexity": complexity,
                "notes": notes,
            }
        )

        return await self.get_task(task_id)

    async def update_task(
        self,
        task_id: int,
        title: Optional[str] = None,
        description: Optional[str] = None,
        acceptance_criteria: Optional[str] = None,
        priority: Optional[int] = None,
        deadline: Optional[str] = None,
        assigned_to: Optional[str] = None,
        persona: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Update task details.

        Args:
            task_id: ID of the task
            title: New title (optional)
            description: New description (optional)
            acceptance_criteria: New criteria (optional)
            priority: New priority (optional)
            deadline: New deadline (optional)
            assigned_to: New assignee (optional)
            persona: Persona making the change

        Returns:
            Updated task dict

        Raises:
            ValueError: If task not found
        """
        task = await self.db.fetchone(
            "SELECT * FROM tasks WHERE id = ?",
            (task_id,)
        )
        if not task:
            raise ValueError(f"Task {task_id} not found")

        updates = []
        params = []
        changes = {}

        if title is not None:
            updates.append("title = ?")
            params.append(title)
            changes["title"] = {"old": task["title"], "new": title}
        if description is not None:
            updates.append("description = ?")
            params.append(description)
            changes["description"] = "updated"
        if acceptance_criteria is not None:
            updates.append("acceptance_criteria = ?")
            params.append(acceptance_criteria)
            changes["acceptance_criteria"] = "updated"
        if priority is not None:
            updates.append("priority = ?")
            params.append(priority)
            changes["priority"] = {"old": task["priority"], "new": priority}
        if deadline is not None:
            updates.append("deadline = ?")
            params.append(deadline)
            changes["deadline"] = {"old": task["deadline"], "new": deadline}
        if assigned_to is not None:
            updates.append("assigned_to = ?")
            params.append(assigned_to)
            changes["assigned_to"] = {"old": task["assigned_to"], "new": assigned_to}

        if updates:
            updates.append("updated_at = datetime('now')")
            params.append(task_id)
            await self.db.execute(
                f"UPDATE tasks SET {', '.join(updates)} WHERE id = ?",
                tuple(params)
            )

            await self._touch_queue(task["queue_id"])

            # Create update event
            await self._create_task_event(
                task_id=task_id,
                queue_id=task["queue_id"],
                event_type="task_updated",
                persona=persona,
                data={"changes": changes}
            )

        return await self.get_task(task_id)

    # ============================================================
    # Task Artifacts
    # ============================================================

    async def add_task_artifact(
        self,
        task_id: int,
        artifact_type: str,
        artifact_id: Optional[int] = None,
        git_branch: Optional[str] = None,
        description: Optional[str] = None,
        created_by: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Link an artifact or git branch to a task.

        Args:
            task_id: ID of the task
            artifact_type: Type of artifact ('artifact', 'git_branch', 'file', etc.)
            artifact_id: ID of artifact if type is 'artifact'
            git_branch: Git branch name if type is 'git_branch'
            description: Description of the artifact
            created_by: Persona uploading the artifact

        Returns:
            Dict with task_artifact_id

        Raises:
            ValueError: If task not found
        """
        task = await self.db.fetchone(
            "SELECT * FROM tasks WHERE id = ?",
            (task_id,)
        )
        if not task:
            raise ValueError(f"Task {task_id} not found")

        cursor = await self.db.execute(
            """
            INSERT INTO task_artifacts
            (task_id, artifact_type, artifact_id, git_branch, description, created_by)
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            (task_id, artifact_type, artifact_id, git_branch, description, created_by)
        )
        task_artifact_id = cursor.lastrowid

        await self._touch_queue(task["queue_id"])

        # Create artifact event
        await self._create_task_event(
            task_id=task_id,
            queue_id=task["queue_id"],
            event_type="artifact_added",
            persona=created_by,
            data={
                "task_artifact_id": task_artifact_id,
                "artifact_type": artifact_type,
                "artifact_id": artifact_id,
                "git_branch": git_branch,
                "description": description,
            }
        )

        return {
            "task_artifact_id": task_artifact_id,
            "task_id": task_id,
            "artifact_type": artifact_type,
            "artifact_id": artifact_id,
            "git_branch": git_branch,
            "description": description,
        }

    async def list_task_artifacts(self, task_id: int) -> List[Dict[str, Any]]:
        """List artifacts linked to a task.

        Args:
            task_id: ID of the task

        Returns:
            List of artifact dicts
        """
        artifacts = await self.db.fetchall(
            """
            SELECT ta.*, a.name as artifact_name, a.type as artifact_file_type
            FROM task_artifacts ta
            LEFT JOIN artifacts a ON ta.artifact_id = a.id
            WHERE ta.task_id = ?
            ORDER BY ta.created_at DESC
            """,
            (task_id,)
        )
        return [dict(a) for a in artifacts]

    # ============================================================
    # Task Events / Feed
    # ============================================================

    async def get_queue_feed(
        self,
        queue_id: int,
        since: Optional[str] = None,
        limit: int = 100,
    ) -> Dict[str, Any]:
        """Get activity feed for a queue.

        Args:
            queue_id: ID of the queue
            since: ISO timestamp to get events after (for polling)
            limit: Maximum events to return

        Returns:
            Dict with events list and next_since timestamp
        """
        if since:
            events = await self.db.fetchall(
                """
                SELECT te.*, t.title as task_title
                FROM task_events te
                JOIN tasks t ON te.task_id = t.id
                WHERE te.queue_id = ? AND te.created_at > ?
                ORDER BY te.created_at ASC
                LIMIT ?
                """,
                (queue_id, since, limit)
            )
        else:
            events = await self.db.fetchall(
                """
                SELECT te.*, t.title as task_title
                FROM task_events te
                JOIN tasks t ON te.task_id = t.id
                WHERE te.queue_id = ?
                ORDER BY te.created_at DESC
                LIMIT ?
                """,
                (queue_id, limit)
            )
            # Reverse to chronological
            events = list(reversed(events))

        result = []
        for event in events:
            event_dict = dict(event)
            event_dict["data"] = json.loads(event_dict["data"])
            result.append(event_dict)

        # Get next_since timestamp for polling
        next_since = datetime.utcnow().isoformat()
        if result:
            next_since = result[-1]["created_at"]

        return {
            "events": result,
            "next_since": next_since,
            "queue_id": queue_id,
        }

    async def get_task_feed(
        self,
        task_id: int,
        since: Optional[str] = None,
        limit: int = 50,
    ) -> Dict[str, Any]:
        """Get activity feed for a specific task.

        Args:
            task_id: ID of the task
            since: ISO timestamp to get events after
            limit: Maximum events to return

        Returns:
            Dict with events list and next_since timestamp
        """
        if since:
            events = await self.db.fetchall(
                """
                SELECT * FROM task_events
                WHERE task_id = ? AND created_at > ?
                ORDER BY created_at ASC
                LIMIT ?
                """,
                (task_id, since, limit)
            )
        else:
            events = await self.db.fetchall(
                """
                SELECT * FROM task_events
                WHERE task_id = ?
                ORDER BY created_at DESC
                LIMIT ?
                """,
                (task_id, limit)
            )
            events = list(reversed(events))

        result = []
        for event in events:
            event_dict = dict(event)
            event_dict["data"] = json.loads(event_dict["data"])
            result.append(event_dict)

        next_since = datetime.utcnow().isoformat()
        if result:
            next_since = result[-1]["created_at"]

        return {
            "events": result,
            "next_since": next_since,
            "task_id": task_id,
        }

    async def add_task_message(
        self,
        task_id: int,
        persona: str,
        message: str,
    ) -> Dict[str, Any]:
        """Add a message/question to a task's feed.

        Args:
            task_id: ID of the task
            persona: Persona sending the message
            message: Message content

        Returns:
            Dict with event_id

        Raises:
            ValueError: If task not found
        """
        task = await self.db.fetchone(
            "SELECT * FROM tasks WHERE id = ?",
            (task_id,)
        )
        if not task:
            raise ValueError(f"Task {task_id} not found")

        event_id = await self._create_task_event(
            task_id=task_id,
            queue_id=task["queue_id"],
            event_type="message",
            persona=persona,
            data={"message": message}
        )

        await self._touch_queue(task["queue_id"])

        return {
            "event_id": event_id,
            "task_id": task_id,
            "persona": persona,
            "message": message,
        }

    # ============================================================
    # Helper Methods
    # ============================================================

    async def _touch_queue(self, queue_id: int):
        """Update queue's updated_at timestamp."""
        await self.db.execute(
            "UPDATE task_queues SET updated_at = datetime('now') WHERE id = ?",
            (queue_id,)
        )

    async def _create_task_event(
        self,
        task_id: int,
        queue_id: int,
        event_type: str,
        persona: Optional[str],
        data: Dict[str, Any],
    ) -> int:
        """Create a task event.

        Args:
            task_id: ID of the task
            queue_id: ID of the queue
            event_type: Type of event
            persona: Persona involved
            data: Event data dict

        Returns:
            ID of created event
        """
        data_json = json.dumps(data)

        cursor = await self.db.execute(
            """
            INSERT INTO task_events (task_id, queue_id, event_type, persona, data)
            VALUES (?, ?, ?, ?, ?)
            """,
            (task_id, queue_id, event_type, persona, data_json)
        )

        return cursor.lastrowid
