#!/usr/bin/env python3
"""
Claude Code hook to check for task queue updates after MCP tool calls.

Install: Add to .claude/settings.json hooks configuration.
Requires: TASK_QUEUE_ID environment variable or .claude/task-queue.json config.

This hook checks for new task queue events and injects them as context
when triggered by PostToolUse events on MCP tools.
"""
import json
import os
import sys
import urllib.request
import urllib.error
from pathlib import Path
from datetime import datetime

# Configuration
MCP_SERVER_URL = os.environ.get("NPL_MCP_URL", "http://localhost:8765")
CURSOR_FILE = Path(os.environ.get("CLAUDE_PROJECT_DIR", ".")) / ".claude" / "task-queue-cursor.json"


def load_config():
    """Load task queue configuration."""
    config_file = Path(os.environ.get("CLAUDE_PROJECT_DIR", ".")) / ".claude" / "task-queue.json"
    if config_file.exists():
        with open(config_file) as f:
            return json.load(f)

    # Fallback to environment variable
    queue_id = os.environ.get("TASK_QUEUE_ID")
    if queue_id:
        return {"queue_id": int(queue_id)}

    return None


def load_cursor():
    """Load the last-seen timestamp cursor."""
    if CURSOR_FILE.exists():
        with open(CURSOR_FILE) as f:
            data = json.load(f)
            return data.get("since")
    return None


def save_cursor(since: str):
    """Save the cursor for next check."""
    CURSOR_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(CURSOR_FILE, "w") as f:
        json.dump({"since": since, "updated": datetime.now().isoformat()}, f)


def fetch_queue_updates(queue_id: int, since: str = None):
    """Fetch task queue updates from MCP server."""
    url = f"{MCP_SERVER_URL}/api/tasks/queues/{queue_id}/feed"
    if since:
        url += f"?since={since}"

    try:
        req = urllib.request.Request(url, headers={"Accept": "application/json"})
        with urllib.request.urlopen(req, timeout=5) as resp:
            return json.loads(resp.read().decode())
    except (urllib.error.URLError, urllib.error.HTTPError, TimeoutError):
        return None


def format_event(event: dict) -> str:
    """Format a task event for display."""
    event_type = event.get("event_type", "unknown")
    task_id = event.get("task_id")
    persona = event.get("persona", "system")
    summary = event.get("summary", "")

    if event_type == "task_created":
        return f"[NEW TASK #{task_id}] {summary}"
    elif event_type == "status_changed":
        new_status = event.get("new_status", "?")
        return f"[TASK #{task_id}] Status changed to {new_status}"
    elif event_type == "message":
        return f"[TASK #{task_id}] Message from {persona}: {summary}"
    elif event_type == "artifact_added":
        return f"[TASK #{task_id}] Artifact uploaded by {persona}"
    else:
        return f"[TASK #{task_id}] {event_type}: {summary}"


def main():
    # Read hook input from stdin
    try:
        hook_input = json.load(sys.stdin)
    except json.JSONDecodeError:
        hook_input = {}

    # Only run for MCP tool calls (optional filter)
    tool_name = hook_input.get("toolName", "")
    if tool_name.startswith("mcp__") and "task" not in tool_name.lower():
        # Skip if this is an MCP call but not task-related
        # Still check for updates to provide context
        pass

    config = load_config()
    if not config:
        # No task queue configured, exit silently
        sys.exit(0)

    queue_id = config.get("queue_id")
    if not queue_id:
        sys.exit(0)

    since = load_cursor()
    result = fetch_queue_updates(queue_id, since)

    if not result:
        sys.exit(0)

    # Save new cursor
    if result.get("next_since"):
        save_cursor(result["next_since"])

    events = result.get("events", [])
    if not events:
        sys.exit(0)

    # Filter for interesting events
    interesting = [e for e in events if e.get("event_type") in (
        "task_created", "status_changed", "message"
    )]

    if not interesting:
        sys.exit(0)

    # Format updates for injection
    updates = [format_event(e) for e in interesting[-5:]]  # Last 5 events
    context = "TASK QUEUE UPDATES:\n" + "\n".join(updates)

    # If there are pending tasks requiring attention, highlight them
    pending_count = sum(1 for e in events if e.get("event_type") == "task_created")
    if pending_count > 0:
        context += f"\n\n({pending_count} new task(s) may need your attention)"

    # Output hook response with additional context
    output = {
        "hookSpecificOutput": {
            "hookEventName": "PostToolUse",
            "additionalContext": context
        }
    }
    print(json.dumps(output))
    sys.exit(0)


if __name__ == "__main__":
    main()
