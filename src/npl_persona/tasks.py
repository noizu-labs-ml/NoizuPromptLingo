"""
Task management operations for npl_persona.

Handles task add, update, complete, list, and remove operations.
"""

import sys
from datetime import datetime, timedelta
from pathlib import Path
from typing import List, Optional

from .config import (
    DATE_FORMAT,
    SECTIONS,
    TABLE_MARKERS,
    STATUS_ICONS,
    PRIORITY_ICONS,
    DEFAULT_DUE_DAYS,
)
from .models import Task, TaskStatus
from .paths import resolve_persona
from .io import read_file, write_file
from .parsers import parse_tasks, update_table_row, remove_table_row


class TaskManager:
    """Manages task operations for personas."""

    def add_task(
        self,
        persona_id: str,
        task_description: str,
        due: Optional[str] = None,
        priority: str = "med"
    ) -> bool:
        """
        Add a new task to persona.

        Args:
            persona_id: Persona identifier
            task_description: Task description
            due: Due date (YYYY-MM-DD)
            priority: Task priority (high/med/low)

        Returns:
            True on success, False on failure
        """
        location = resolve_persona(persona_id)

        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        tasks_file = base_path / f"{persona_id}.tasks.md"

        if not tasks_file.exists():
            print(f"Error: Tasks file not found: {tasks_file}", file=sys.stderr)
            return False

        # Read existing content
        result = read_file(tasks_file)
        if result.is_err():
            print(f"Error reading tasks: {result.error}", file=sys.stderr)
            return False

        content = result.value

        # Create task entry
        due_date = due or (datetime.now() + timedelta(days=DEFAULT_DUE_DAYS)).strftime(DATE_FORMAT)
        priority_icon = PRIORITY_ICONS.get(priority, PRIORITY_ICONS["med"])
        status_display = f"{STATUS_ICONS['in_progress']} In Progress"

        task_row = f"| {task_description} | {status_display} | @{persona_id} | {due_date} |"

        # Insert after Active Tasks table header
        table_marker = TABLE_MARKERS["task"]
        if SECTIONS["active_tasks"] in content and table_marker in content:
            parts = content.split(table_marker, 1)
            if len(parts) == 2:
                new_content = parts[0] + table_marker + "\n" + task_row + parts[1]
            else:
                new_content = content
        else:
            new_content = content

        # Write back
        result = write_file(tasks_file, new_content)
        if result.is_err():
            print(f"Error writing tasks: {result.error}", file=sys.stderr)
            return False

        print(f"✅ Task added to {persona_id}: {task_description}")
        return True

    def update_task(
        self,
        persona_id: str,
        task_pattern: str,
        status: str
    ) -> bool:
        """
        Update task status.

        Args:
            persona_id: Persona identifier
            task_pattern: Pattern to match task description
            status: New status (pending/in-progress/blocked/completed)

        Returns:
            True on success, False on failure
        """
        location = resolve_persona(persona_id)

        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        tasks_file = base_path / f"{persona_id}.tasks.md"

        if not tasks_file.exists():
            print(f"Error: Tasks file not found: {tasks_file}", file=sys.stderr)
            return False

        # Status mapping
        status_map = {
            "pending": f"{STATUS_ICONS['pending']} Pending",
            "in-progress": f"{STATUS_ICONS['in_progress']} In Progress",
            "blocked": f"{STATUS_ICONS['blocked']} Blocked",
            "completed": f"{STATUS_ICONS['completed']} Complete",
        }

        if status not in status_map:
            print(f"Error: Invalid status '{status}'. Use: pending, in-progress, blocked, completed", file=sys.stderr)
            return False

        # Read and update
        result = read_file(tasks_file)
        if result.is_err():
            print(f"Error reading tasks: {result.error}", file=sys.stderr)
            return False

        content = result.value

        # Find and update task
        lines = content.split("\n")
        updated = False

        for i, line in enumerate(lines):
            if task_pattern in line and line.strip().startswith("|"):
                # Update status column (second column)
                parts = [p.strip() for p in line.split("|")]
                if len(parts) >= 3:
                    parts[2] = f" {status_map[status]} "
                    lines[i] = "|".join(parts)
                    updated = True
                    break

        if not updated:
            print(f"Error: Task matching '{task_pattern}' not found", file=sys.stderr)
            return False

        # Write back
        result = write_file(tasks_file, "\n".join(lines))
        if result.is_err():
            print(f"Error writing tasks: {result.error}", file=sys.stderr)
            return False

        print(f"✅ Task updated: {task_pattern} → {status}")
        return True

    def list_tasks(
        self,
        persona_id: str,
        status_filter: Optional[str] = None
    ) -> bool:
        """
        List tasks for persona.

        Args:
            persona_id: Persona identifier
            status_filter: Filter by status

        Returns:
            True on success, False on failure
        """
        location = resolve_persona(persona_id)

        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        tasks_file = base_path / f"{persona_id}.tasks.md"

        if not tasks_file.exists():
            print(f"Error: Tasks file not found: {tasks_file}", file=sys.stderr)
            return False

        result = read_file(tasks_file)
        if result.is_err():
            print(f"Error reading tasks: {result.error}", file=sys.stderr)
            return False

        content = result.value

        # Extract tasks from table
        tasks = self._extract_tasks_from_content(content)

        if not tasks:
            print(f"No tasks found for {persona_id}")
            return True

        # Filter if requested
        if status_filter:
            tasks = [t for t in tasks if status_filter.lower() in t["status"].lower()]

        # Display
        print(f"# Tasks for {persona_id} ({len(tasks)} tasks)\n")
        print(f"{'Task':<40} {'Status':<20} {'Due':<12}")
        print("-" * 72)

        for task in tasks:
            task_text = task["task"][:37] + "..." if len(task["task"]) > 40 else task["task"]
            print(f"{task_text:<40} {task['status']:<20} {task['due']:<12}")

        return True

    def remove_task(self, persona_id: str, task_pattern: str) -> bool:
        """
        Remove a task.

        Args:
            persona_id: Persona identifier
            task_pattern: Pattern to match task to remove

        Returns:
            True on success, False on failure
        """
        location = resolve_persona(persona_id)

        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        tasks_file = base_path / f"{persona_id}.tasks.md"

        if not tasks_file.exists():
            print(f"Error: Tasks file not found: {tasks_file}", file=sys.stderr)
            return False

        result = read_file(tasks_file)
        if result.is_err():
            print(f"Error reading tasks: {result.error}", file=sys.stderr)
            return False

        content = result.value

        # Find and remove task
        new_content, removed = remove_table_row(content, task_pattern)

        if not removed:
            print(f"Error: Task matching '{task_pattern}' not found", file=sys.stderr)
            return False

        # Write back
        result = write_file(tasks_file, new_content)
        if result.is_err():
            print(f"Error writing tasks: {result.error}", file=sys.stderr)
            return False

        print(f"✅ Task removed: {task_pattern}")
        return True

    def _extract_tasks_from_content(self, content: str) -> List[dict]:
        """Extract tasks from tasks file content."""
        tasks = []
        in_table = False

        for line in content.split("\n"):
            if SECTIONS["active_tasks"] in line:
                in_table = True
                continue
            if in_table and line.strip().startswith("|") and "---" not in line and "Task,Status" not in line:
                parts = [p.strip() for p in line.split("|")]
                if len(parts) >= 5:  # | Task | Status | Owner | Due |
                    tasks.append({
                        "task": parts[1],
                        "status": parts[2],
                        "owner": parts[3],
                        "due": parts[4],
                    })
            elif in_table and line.strip().startswith("##"):
                break

        return tasks
