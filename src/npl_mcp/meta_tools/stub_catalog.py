"""Static stub catalog for tools without implementations.

These tools are discoverable via ToolSummary/ToolSearch/ToolDefinition
but return a 'stub' status when called via ToolCall.
"""

from __future__ import annotations
from typing import TypedDict


class ToolParam(TypedDict):
    name: str
    type: str
    required: bool
    description: str


class ToolEntry(TypedDict):
    name: str
    category: str
    description: str
    parameters: list[ToolParam]


STUB_CATEGORIES: dict[str, str] = {
    "Scripts": "Shell script wrappers for file dumping, directory trees, NPL resource loading",
    "Artifacts": "Create, retrieve, manage versioned artifacts with revision tracking",
    "Reviews": "Review workflows: inline comments, overlay annotations, annotated output",
    "Sessions": "Session lifecycle for grouping chat rooms and artifacts",
    "Chat": "Event-sourced chat rooms: messaging, reactions, todo items, notifications",
    "Browser.Screenshots": "Capture and compare screenshots of web pages",
    "Browser.Navigation": "Navigate, scroll, and control browser history",
    "Browser.Input": "Click, type, fill forms, and interact with page elements",
    "Browser.Query": "Read text, HTML, element state, and evaluate JavaScript",
    "Browser.Session": "Manage browser sessions and viewport settings",
    "Browser.Wait": "Wait for elements or network idle states",
    "Browser.Inject": "Inject JavaScript and CSS into pages",
    "Browser.Storage": "Manage cookies and localStorage",
    "Task Queues": "Task queue management: create queues, add tasks, track status, activity feeds",
    "Executors": "Ephemeral agent management: spawn, lifecycle, fabric pattern analysis",
    "Project Management": "Access user stories, PRDs, functional requirements, acceptance tests, personas, and DB-backed project/persona/story CRUD",
}

STUB_CATALOG: list[ToolEntry] = [
    # Artifacts: replaced by Artifact.Create/AddRevision/Get/List/ListRevisions/GetBinary MCP tools

    # ======================================================================
    # Reviews (6)
    # ======================================================================
    {
        "name": "create_review",
        "category": "Reviews",
        "description": "Start a new review for an artifact revision.",
        "parameters": [
            {"name": "artifact_id", "type": "int", "required": True, "description": "ID of the artifact to review"},
            {"name": "revision_id", "type": "int", "required": True, "description": "ID of the revision to review"},
            {"name": "reviewer_persona", "type": "str", "required": True, "description": "Persona slug of the reviewer"},
        ],
    },
    {
        "name": "add_inline_comment",
        "category": "Reviews",
        "description": "Add an inline comment to a review.",
        "parameters": [
            {"name": "review_id", "type": "int", "required": True, "description": "ID of the review"},
            {"name": "location", "type": "str", "required": True, "description": "Location in artifact (e.g., line number, section)"},
            {"name": "comment", "type": "str", "required": True, "description": "Comment text"},
            {"name": "persona", "type": "str", "required": True, "description": "Persona slug of commenter"},
        ],
    },
    {
        "name": "add_overlay_annotation",
        "category": "Reviews",
        "description": "Add an image overlay annotation.",
        "parameters": [
            {"name": "review_id", "type": "int", "required": True, "description": "ID of the review"},
            {"name": "x", "type": "int", "required": True, "description": "X coordinate of annotation"},
            {"name": "y", "type": "int", "required": True, "description": "Y coordinate of annotation"},
            {"name": "comment", "type": "str", "required": True, "description": "Annotation comment text"},
            {"name": "persona", "type": "str", "required": True, "description": "Persona slug of annotator"},
        ],
    },
    {
        "name": "get_review",
        "category": "Reviews",
        "description": "Get a review with all its comments.",
        "parameters": [
            {"name": "review_id", "type": "int", "required": True, "description": "ID of the review"},
        ],
    },
    {
        "name": "generate_annotated_artifact",
        "category": "Reviews",
        "description": "Generate an annotated version of an artifact with all review comments.",
        "parameters": [
            {"name": "artifact_id", "type": "int", "required": True, "description": "ID of the artifact"},
            {"name": "revision_id", "type": "int", "required": True, "description": "ID of the revision"},
        ],
    },
    {
        "name": "complete_review",
        "category": "Reviews",
        "description": "Mark a review as completed.",
        "parameters": [
            {"name": "review_id", "type": "int", "required": True, "description": "ID of the review"},
            {"name": "overall_comment", "type": "str", "required": False, "description": "Optional overall review comment"},
        ],
    },

    # ======================================================================
    # Sessions (4)
    # ======================================================================
    {
        "name": "create_session",
        "category": "Sessions",
        "description": "Create a new session to group chat rooms and artifacts.",
        "parameters": [
            {"name": "title", "type": "str", "required": False, "description": "Optional session title"},
            {"name": "session_id", "type": "str", "required": False, "description": "Optional custom session ID"},
        ],
    },
    {
        "name": "get_session",
        "category": "Sessions",
        "description": "Get session details and contents.",
        "parameters": [
            {"name": "session_id", "type": "str", "required": True, "description": "Session ID to retrieve"},
        ],
    },
    {
        "name": "list_sessions",
        "category": "Sessions",
        "description": "List recent sessions.",
        "parameters": [
            {"name": "status", "type": "str", "required": False, "description": "Optional status filter"},
            {"name": "limit", "type": "int", "required": False, "description": "Maximum sessions to return (default 20)"},
        ],
    },
    {
        "name": "update_session",
        "category": "Sessions",
        "description": "Update session metadata.",
        "parameters": [
            {"name": "session_id", "type": "str", "required": True, "description": "Session ID to update"},
            {"name": "title", "type": "str", "required": False, "description": "New title"},
            {"name": "status", "type": "str", "required": False, "description": "New status"},
        ],
    },

    # ======================================================================
    # Chat (5 stubs remaining — 3 replaced by Chat.* MCP tools)
    # ======================================================================
    # Replaced: create_chat_room → Chat.CreateRoom
    # Replaced: send_message → Chat.SendMessage
    # Replaced: get_chat_feed → Chat.ListMessages
    {
        "name": "react_to_message",
        "category": "Chat",
        "description": "Add an emoji reaction to a message.",
        "parameters": [
            {"name": "event_id", "type": "int", "required": True, "description": "ID of the event to react to"},
            {"name": "persona", "type": "str", "required": True, "description": "Persona slug of reactor"},
            {"name": "emoji", "type": "str", "required": True, "description": "Emoji to react with"},
        ],
    },
    {
        "name": "share_artifact",
        "category": "Chat",
        "description": "Share an artifact in a chat room.",
        "parameters": [
            {"name": "room_id", "type": "int", "required": True, "description": "ID of the chat room"},
            {"name": "persona", "type": "str", "required": True, "description": "Persona slug of sharer"},
            {"name": "artifact_id", "type": "int", "required": True, "description": "ID of the artifact to share"},
            {"name": "revision", "type": "int", "required": False, "description": "Optional specific revision number"},
        ],
    },
    {
        "name": "create_todo",
        "category": "Chat",
        "description": "Create a shared todo item in a chat room.",
        "parameters": [
            {"name": "room_id", "type": "int", "required": True, "description": "ID of the chat room"},
            {"name": "persona", "type": "str", "required": True, "description": "Persona slug of creator"},
            {"name": "description", "type": "str", "required": True, "description": "Todo item description"},
            {"name": "assigned_to", "type": "str", "required": False, "description": "Optional persona to assign to"},
        ],
    },
    {
        "name": "get_notifications",
        "category": "Chat",
        "description": "Get notifications for a persona.",
        "parameters": [
            {"name": "persona", "type": "str", "required": True, "description": "Persona slug to get notifications for"},
            {"name": "unread_only", "type": "bool", "required": False, "description": "Only return unread notifications (default True)"},
        ],
    },
    {
        "name": "mark_notification_read",
        "category": "Chat",
        "description": "Mark a notification as read.",
        "parameters": [
            {"name": "notification_id", "type": "int", "required": True, "description": "ID of the notification to mark read"},
        ],
    },

    # ======================================================================
    # Browser.Screenshots (3)
    # ======================================================================
    {
        "name": "screenshot_capture",
        "category": "Browser.Screenshots",
        "description": "Capture screenshot of a web page and store as artifact.",
        "parameters": [
            {"name": "url", "type": "str", "required": True, "description": "URL of the webpage to screenshot"},
            {"name": "name", "type": "str", "required": True, "description": "Name for the screenshot artifact"},
            {"name": "viewport", "type": "str", "required": False, "description": "Viewport preset: 'desktop' (1280x720), 'mobile' (375x667), or 'WIDTHxHEIGHT'"},
            {"name": "theme", "type": "str", "required": False, "description": "Color scheme: 'light' or 'dark'"},
            {"name": "full_page", "type": "bool", "required": False, "description": "Capture entire scrollable page (default True)"},
            {"name": "wait_for", "type": "str", "required": False, "description": "CSS selector to wait for before capture"},
            {"name": "wait_timeout", "type": "int", "required": False, "description": "Milliseconds to wait for selector (default 5000)"},
            {"name": "network_idle", "type": "bool", "required": False, "description": "Wait for network idle (default True)"},
            {"name": "session_id", "type": "str", "required": False, "description": "Optional session to associate artifact with"},
            {"name": "created_by", "type": "str", "required": False, "description": "Persona slug of creator"},
        ],
    },
    {
        "name": "screenshot_diff",
        "category": "Browser.Screenshots",
        "description": "Generate visual diff between two screenshot artifacts.",
        "parameters": [
            {"name": "baseline_artifact_id", "type": "int", "required": True, "description": "Artifact ID of baseline screenshot"},
            {"name": "comparison_artifact_id", "type": "int", "required": True, "description": "Artifact ID of comparison screenshot"},
            {"name": "threshold", "type": "float", "required": False, "description": "Diff sensitivity 0.0-1.0 (default 0.1)"},
            {"name": "session_id", "type": "str", "required": False, "description": "Optional session to associate diff artifact with"},
            {"name": "created_by", "type": "str", "required": False, "description": "Persona slug of creator"},
        ],
    },
    {
        "name": "browser_screenshot",
        "category": "Browser.Screenshots",
        "description": "Capture screenshot of current browser page or element.",
        "parameters": [
            {"name": "name", "type": "str", "required": True, "description": "Name for the screenshot artifact"},
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
            {"name": "full_page", "type": "bool", "required": False, "description": "Capture entire scrollable page (default False)"},
            {"name": "selector", "type": "str", "required": False, "description": "Optional element to screenshot"},
            {"name": "created_by", "type": "str", "required": False, "description": "Persona slug of creator"},
        ],
    },

    # ======================================================================
    # Browser.Navigation (5)
    # ======================================================================
    {
        "name": "browser_navigate",
        "category": "Browser.Navigation",
        "description": "Navigate browser to a URL.",
        "parameters": [
            {"name": "url", "type": "str", "required": True, "description": "URL to navigate to"},
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
            {"name": "wait_for", "type": "str", "required": False, "description": "Optional CSS selector to wait for"},
            {"name": "timeout", "type": "int", "required": False, "description": "Navigation timeout in milliseconds (default 30000)"},
        ],
    },
    {
        "name": "browser_scroll",
        "category": "Browser.Navigation",
        "description": "Scroll the page or an element.",
        "parameters": [
            {"name": "direction", "type": "str", "required": False, "description": "Direction: 'up', 'down', 'left', 'right' (default 'down')"},
            {"name": "amount", "type": "int", "required": False, "description": "Pixels to scroll (default 500)"},
            {"name": "selector", "type": "str", "required": False, "description": "Optional element to scroll (scrolls page if None)"},
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
        ],
    },
    {
        "name": "browser_go_back",
        "category": "Browser.Navigation",
        "description": "Navigate back in browser history.",
        "parameters": [
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
        ],
    },
    {
        "name": "browser_go_forward",
        "category": "Browser.Navigation",
        "description": "Navigate forward in browser history.",
        "parameters": [
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
        ],
    },
    {
        "name": "browser_reload",
        "category": "Browser.Navigation",
        "description": "Reload the current page.",
        "parameters": [
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
        ],
    },

    # ======================================================================
    # Browser.Input (7)
    # ======================================================================
    {
        "name": "browser_click",
        "category": "Browser.Input",
        "description": "Click an element in the browser.",
        "parameters": [
            {"name": "selector", "type": "str", "required": True, "description": "CSS selector for element to click"},
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
            {"name": "timeout", "type": "int", "required": False, "description": "Wait timeout in milliseconds (default 5000)"},
            {"name": "screenshot_after", "type": "bool", "required": False, "description": "Capture screenshot after click (default False)"},
            {"name": "artifact_name", "type": "str", "required": False, "description": "Name for screenshot artifact (required if screenshot_after=True)"},
        ],
    },
    {
        "name": "browser_fill",
        "category": "Browser.Input",
        "description": "Fill a form field in the browser.",
        "parameters": [
            {"name": "selector", "type": "str", "required": True, "description": "CSS selector for input element"},
            {"name": "value", "type": "str", "required": True, "description": "Value to fill"},
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
            {"name": "timeout", "type": "int", "required": False, "description": "Wait timeout in milliseconds (default 5000)"},
        ],
    },
    {
        "name": "browser_type",
        "category": "Browser.Input",
        "description": "Type text character by character (simulates real typing).",
        "parameters": [
            {"name": "selector", "type": "str", "required": True, "description": "CSS selector for input element"},
            {"name": "text", "type": "str", "required": True, "description": "Text to type"},
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
            {"name": "delay", "type": "int", "required": False, "description": "Delay between keystrokes in milliseconds (default 50)"},
            {"name": "timeout", "type": "int", "required": False, "description": "Wait timeout in milliseconds (default 5000)"},
        ],
    },
    {
        "name": "browser_select",
        "category": "Browser.Input",
        "description": "Select option from dropdown.",
        "parameters": [
            {"name": "selector", "type": "str", "required": True, "description": "CSS selector for select element"},
            {"name": "value", "type": "str", "required": True, "description": "Option value to select"},
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
            {"name": "timeout", "type": "int", "required": False, "description": "Wait timeout in milliseconds (default 5000)"},
        ],
    },
    {
        "name": "browser_press_key",
        "category": "Browser.Input",
        "description": "Press a keyboard key.",
        "parameters": [
            {"name": "key", "type": "str", "required": True, "description": "Key to press (e.g., 'Enter', 'Tab', 'Escape', 'ArrowDown')"},
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
            {"name": "modifiers", "type": "list[str]", "required": False, "description": "Optional list of modifiers: 'Control', 'Shift', 'Alt', 'Meta'"},
        ],
    },
    {
        "name": "browser_hover",
        "category": "Browser.Input",
        "description": "Hover over an element.",
        "parameters": [
            {"name": "selector", "type": "str", "required": True, "description": "CSS selector for element"},
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
            {"name": "timeout", "type": "int", "required": False, "description": "Wait timeout in milliseconds (default 5000)"},
        ],
    },
    {
        "name": "browser_focus",
        "category": "Browser.Input",
        "description": "Focus on an element.",
        "parameters": [
            {"name": "selector", "type": "str", "required": True, "description": "CSS selector for element"},
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
            {"name": "timeout", "type": "int", "required": False, "description": "Wait timeout in milliseconds (default 5000)"},
        ],
    },

    # ======================================================================
    # Browser.Query (5)
    # ======================================================================
    {
        "name": "browser_get_text",
        "category": "Browser.Query",
        "description": "Get text content of an element.",
        "parameters": [
            {"name": "selector", "type": "str", "required": True, "description": "CSS selector for element"},
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
            {"name": "timeout", "type": "int", "required": False, "description": "Wait timeout in milliseconds (default 5000)"},
        ],
    },
    {
        "name": "browser_query_elements",
        "category": "Browser.Query",
        "description": "Query multiple elements matching a selector.",
        "parameters": [
            {"name": "selector", "type": "str", "required": True, "description": "CSS selector"},
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
            {"name": "limit", "type": "int", "required": False, "description": "Maximum elements to return (default 10)"},
        ],
    },
    {
        "name": "browser_evaluate",
        "category": "Browser.Query",
        "description": "Evaluate JavaScript expression in page context.",
        "parameters": [
            {"name": "expression", "type": "str", "required": True, "description": "JavaScript expression to evaluate"},
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
        ],
    },
    {
        "name": "browser_get_state",
        "category": "Browser.Query",
        "description": "Get current browser page state.",
        "parameters": [
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
        ],
    },
    {
        "name": "browser_get_html",
        "category": "Browser.Query",
        "description": "Get HTML content of page or element.",
        "parameters": [
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
            {"name": "selector", "type": "str", "required": False, "description": "Optional CSS selector (entire page if None)"},
            {"name": "outer", "type": "bool", "required": False, "description": "Include element's own tag: outerHTML vs innerHTML (default True)"},
        ],
    },

    # ======================================================================
    # Browser.Session (3)
    # ======================================================================
    {
        "name": "browser_close_session",
        "category": "Browser.Session",
        "description": "Close a browser session.",
        "parameters": [
            {"name": "session_id", "type": "str", "required": True, "description": "Browser session ID to close"},
        ],
    },
    {
        "name": "browser_list_sessions",
        "category": "Browser.Session",
        "description": "List active browser sessions.",
        "parameters": [],
    },
    {
        "name": "browser_set_viewport",
        "category": "Browser.Session",
        "description": "Change browser viewport size.",
        "parameters": [
            {"name": "width", "type": "int", "required": True, "description": "Viewport width in pixels"},
            {"name": "height", "type": "int", "required": True, "description": "Viewport height in pixels"},
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
        ],
    },

    # ======================================================================
    # Browser.Wait (2)
    # ======================================================================
    {
        "name": "browser_wait_for",
        "category": "Browser.Wait",
        "description": "Wait for an element to reach a state.",
        "parameters": [
            {"name": "selector", "type": "str", "required": True, "description": "CSS selector for element"},
            {"name": "state", "type": "str", "required": False, "description": "Target state: 'visible', 'hidden', 'attached', 'detached' (default 'visible')"},
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
            {"name": "timeout", "type": "int", "required": False, "description": "Wait timeout in milliseconds (default 10000)"},
        ],
    },
    {
        "name": "browser_wait_network_idle",
        "category": "Browser.Wait",
        "description": "Wait for network activity to become idle.",
        "parameters": [
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
            {"name": "timeout", "type": "int", "required": False, "description": "Maximum wait time in milliseconds (default 30000)"},
        ],
    },

    # ======================================================================
    # Browser.Inject (2)
    # ======================================================================
    {
        "name": "browser_inject_script",
        "category": "Browser.Inject",
        "description": "Inject and execute JavaScript in the page via script tag.",
        "parameters": [
            {"name": "script", "type": "str", "required": True, "description": "JavaScript code to inject"},
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
        ],
    },
    {
        "name": "browser_inject_style",
        "category": "Browser.Inject",
        "description": "Inject CSS styles into the page.",
        "parameters": [
            {"name": "css", "type": "str", "required": True, "description": "CSS code to inject"},
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
        ],
    },

    # ======================================================================
    # Browser.Storage (5)
    # ======================================================================
    {
        "name": "browser_get_cookies",
        "category": "Browser.Storage",
        "description": "Get all cookies for the current page.",
        "parameters": [
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
        ],
    },
    {
        "name": "browser_set_cookie",
        "category": "Browser.Storage",
        "description": "Set a cookie.",
        "parameters": [
            {"name": "name", "type": "str", "required": True, "description": "Cookie name"},
            {"name": "value", "type": "str", "required": True, "description": "Cookie value"},
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
            {"name": "domain", "type": "str", "required": False, "description": "Cookie domain (uses current page domain if None)"},
            {"name": "path", "type": "str", "required": False, "description": "Cookie path (default '/')"},
        ],
    },
    {
        "name": "browser_clear_cookies",
        "category": "Browser.Storage",
        "description": "Clear all cookies for the browser session.",
        "parameters": [
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
        ],
    },
    {
        "name": "browser_get_local_storage",
        "category": "Browser.Storage",
        "description": "Get localStorage value(s).",
        "parameters": [
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
            {"name": "key", "type": "str", "required": False, "description": "Specific key to get (all items if None)"},
        ],
    },
    {
        "name": "browser_set_local_storage",
        "category": "Browser.Storage",
        "description": "Set localStorage value.",
        "parameters": [
            {"name": "key", "type": "str", "required": True, "description": "Storage key"},
            {"name": "value", "type": "str", "required": True, "description": "Storage value"},
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
        ],
    },

    # ======================================================================
    # Task Queues (13)
    # ======================================================================
    {
        "name": "create_task_queue",
        "category": "Task Queues",
        "description": "Create a new task queue for organizing work items.",
        "parameters": [
            {"name": "name", "type": "str", "required": True, "description": "Unique name for the queue"},
            {"name": "description", "type": "str", "required": False, "description": "Optional description of the queue's purpose"},
            {"name": "session_id", "type": "str", "required": False, "description": "Optional session to associate with"},
            {"name": "chat_room_id", "type": "int", "required": False, "description": "Optional chat room for Q&A about tasks"},
        ],
    },
    {
        "name": "get_task_queue",
        "category": "Task Queues",
        "description": "Get task queue details with task counts.",
        "parameters": [
            {"name": "queue_id", "type": "int", "required": True, "description": "ID of the queue"},
        ],
    },
    {
        "name": "list_task_queues",
        "category": "Task Queues",
        "description": "List task queues with summary stats.",
        "parameters": [
            {"name": "status", "type": "str", "required": False, "description": "Optional status filter ('active', 'archived')"},
            {"name": "limit", "type": "int", "required": False, "description": "Maximum queues to return (default 50)"},
        ],
    },
    {
        "name": "create_task",
        "category": "Task Queues",
        "description": "Create a new task in a queue.",
        "parameters": [
            {"name": "queue_id", "type": "int", "required": True, "description": "ID of the task queue"},
            {"name": "title", "type": "str", "required": True, "description": "Task title"},
            {"name": "description", "type": "str", "required": False, "description": "Task description"},
            {"name": "acceptance_criteria", "type": "str", "required": False, "description": "Criteria for task completion"},
            {"name": "priority", "type": "int", "required": False, "description": "Priority level: 0=low, 1=normal, 2=high, 3=urgent (default 1)"},
            {"name": "deadline", "type": "str", "required": False, "description": "ISO timestamp deadline"},
            {"name": "created_by", "type": "str", "required": False, "description": "Persona who created the task"},
            {"name": "assigned_to", "type": "str", "required": False, "description": "Persona assigned to the task"},
        ],
    },
    {
        "name": "get_task",
        "category": "Task Queues",
        "description": "Get task details with linked artifacts.",
        "parameters": [
            {"name": "task_id", "type": "int", "required": True, "description": "ID of the task"},
        ],
    },
    {
        "name": "list_tasks",
        "category": "Task Queues",
        "description": "List tasks in a queue.",
        "parameters": [
            {"name": "queue_id", "type": "int", "required": True, "description": "ID of the queue"},
            {"name": "status", "type": "str", "required": False, "description": "Optional status filter (pending, in_progress, blocked, review, done)"},
            {"name": "assigned_to", "type": "str", "required": False, "description": "Optional assignee filter"},
            {"name": "limit", "type": "int", "required": False, "description": "Maximum tasks to return (default 100)"},
        ],
    },
    {
        "name": "update_task_status",
        "category": "Task Queues",
        "description": "Update task status.",
        "parameters": [
            {"name": "task_id", "type": "int", "required": True, "description": "ID of the task"},
            {"name": "status", "type": "str", "required": True, "description": "New status (pending, in_progress, blocked, review, done)"},
            {"name": "persona", "type": "str", "required": False, "description": "Persona making the change"},
            {"name": "notes", "type": "str", "required": False, "description": "Optional notes about the status change"},
        ],
    },
    {
        "name": "assign_task_complexity",
        "category": "Task Queues",
        "description": "Assign complexity score to a task (agent should call this after reviewing).",
        "parameters": [
            {"name": "task_id", "type": "int", "required": True, "description": "ID of the task"},
            {"name": "complexity", "type": "int", "required": True, "description": "Complexity score: 1=trivial, 2=simple, 3=moderate, 4=complex, 5=very complex"},
            {"name": "notes", "type": "str", "required": False, "description": "Notes about complexity assessment"},
            {"name": "persona", "type": "str", "required": False, "description": "Agent persona making the assessment"},
        ],
    },
    {
        "name": "update_task",
        "category": "Task Queues",
        "description": "Update task details.",
        "parameters": [
            {"name": "task_id", "type": "int", "required": True, "description": "ID of the task"},
            {"name": "title", "type": "str", "required": False, "description": "New title"},
            {"name": "description", "type": "str", "required": False, "description": "New description"},
            {"name": "acceptance_criteria", "type": "str", "required": False, "description": "New acceptance criteria"},
            {"name": "priority", "type": "int", "required": False, "description": "New priority"},
            {"name": "deadline", "type": "str", "required": False, "description": "New deadline"},
            {"name": "assigned_to", "type": "str", "required": False, "description": "New assignee"},
            {"name": "persona", "type": "str", "required": False, "description": "Persona making the change"},
        ],
    },
    {
        "name": "add_task_artifact",
        "category": "Task Queues",
        "description": "Link an artifact or git branch to a task.",
        "parameters": [
            {"name": "task_id", "type": "int", "required": True, "description": "ID of the task"},
            {"name": "artifact_type", "type": "str", "required": True, "description": "Type of artifact ('artifact', 'git_branch', 'file')"},
            {"name": "artifact_id", "type": "int", "required": False, "description": "ID of artifact if type is 'artifact'"},
            {"name": "git_branch", "type": "str", "required": False, "description": "Git branch name if type is 'git_branch'"},
            {"name": "description", "type": "str", "required": False, "description": "Description of the artifact"},
            {"name": "created_by", "type": "str", "required": False, "description": "Persona uploading the artifact"},
        ],
    },
    {
        "name": "add_task_message",
        "category": "Task Queues",
        "description": "Add a message/question to a task's activity feed.",
        "parameters": [
            {"name": "task_id", "type": "int", "required": True, "description": "ID of the task"},
            {"name": "persona", "type": "str", "required": True, "description": "Persona sending the message"},
            {"name": "message", "type": "str", "required": True, "description": "Message content"},
        ],
    },
    {
        "name": "get_task_queue_feed",
        "category": "Task Queues",
        "description": "Get activity feed for a task queue (for polling).",
        "parameters": [
            {"name": "queue_id", "type": "int", "required": True, "description": "ID of the queue"},
            {"name": "since", "type": "str", "required": False, "description": "ISO timestamp to get events after (for polling)"},
            {"name": "limit", "type": "int", "required": False, "description": "Maximum events to return (default 100)"},
        ],
    },
    {
        "name": "get_task_feed",
        "category": "Task Queues",
        "description": "Get activity feed for a specific task.",
        "parameters": [
            {"name": "task_id", "type": "int", "required": True, "description": "ID of the task"},
            {"name": "since", "type": "str", "required": False, "description": "ISO timestamp to get events after"},
            {"name": "limit", "type": "int", "required": False, "description": "Maximum events to return (default 50)"},
        ],
    },

    # ======================================================================
    # Executors (11)
    # ======================================================================
    {
        "name": "spawn_tasker",
        "category": "Executors",
        "description": "Spawn a new ephemeral tasker agent with optional fabric patterns.",
        "parameters": [
            {"name": "task", "type": "str", "required": True, "description": "Description of the task/topic for the tasker"},
            {"name": "chat_room_id", "type": "int", "required": True, "description": "ID of chat room to join for nag messages"},
            {"name": "parent_agent_id", "type": "str", "required": False, "description": "Agent ID of spawning parent (default 'primary')"},
            {"name": "patterns", "type": "list[str]", "required": False, "description": "Fabric patterns to apply for analysis"},
            {"name": "session_id", "type": "str", "required": False, "description": "Optional session to associate with"},
            {"name": "timeout_minutes", "type": "int", "required": False, "description": "Auto-dismiss timeout (default 15)"},
            {"name": "nag_minutes", "type": "int", "required": False, "description": "Idle time before nagging parent (default 5)"},
        ],
    },
    {
        "name": "get_tasker",
        "category": "Executors",
        "description": "Get tasker details including status and context.",
        "parameters": [
            {"name": "tasker_id", "type": "str", "required": True, "description": "Tasker ID (e.g., 'tsk-abc12345')"},
        ],
    },
    {
        "name": "list_taskers",
        "category": "Executors",
        "description": "List taskers with optional filtering.",
        "parameters": [
            {"name": "status_filter", "type": "str", "required": False, "description": "Filter by status ('idle', 'active', 'nagging', 'terminated')"},
            {"name": "session_id", "type": "str", "required": False, "description": "Filter by session ID"},
        ],
    },
    {
        "name": "touch_tasker",
        "category": "Executors",
        "description": "Reset tasker's idle timer and mark as active.",
        "parameters": [
            {"name": "tasker_id", "type": "str", "required": True, "description": "Tasker ID"},
        ],
    },
    {
        "name": "dismiss_tasker",
        "category": "Executors",
        "description": "Explicitly dismiss/terminate a tasker.",
        "parameters": [
            {"name": "tasker_id", "type": "str", "required": True, "description": "Tasker ID"},
            {"name": "reason", "type": "str", "required": False, "description": "Optional dismissal reason"},
        ],
    },
    {
        "name": "keep_alive_tasker",
        "category": "Executors",
        "description": "Respond to nag by keeping tasker alive.",
        "parameters": [
            {"name": "tasker_id", "type": "str", "required": True, "description": "Tasker ID"},
            {"name": "message", "type": "str", "required": False, "description": "Optional message to acknowledge"},
        ],
    },
    {
        "name": "apply_fabric_pattern",
        "category": "Executors",
        "description": "Apply a single fabric pattern to content for analysis.",
        "parameters": [
            {"name": "pattern", "type": "str", "required": True, "description": "Fabric pattern name (e.g., 'summarize', 'analyze_logs')"},
            {"name": "content", "type": "str", "required": True, "description": "Input content to analyze"},
            {"name": "model", "type": "str", "required": False, "description": "Optional model override"},
            {"name": "timeout", "type": "int", "required": False, "description": "Timeout in seconds (default 300)"},
        ],
    },
    {
        "name": "analyze_with_fabric",
        "category": "Executors",
        "description": "Apply multiple fabric patterns to content.",
        "parameters": [
            {"name": "patterns", "type": "list[str]", "required": True, "description": "List of pattern names (e.g., ['summarize', 'extract_wisdom'])"},
            {"name": "content", "type": "str", "required": True, "description": "Input content to analyze"},
            {"name": "combine_results", "type": "bool", "required": False, "description": "Whether to combine results or return separately (default True)"},
        ],
    },
    {
        "name": "list_fabric_patterns",
        "category": "Executors",
        "description": "List available fabric patterns.",
        "parameters": [],
    },
    {
        "name": "store_tasker_context",
        "category": "Executors",
        "description": "Store execution context for follow-up queries.",
        "parameters": [
            {"name": "tasker_id", "type": "str", "required": True, "description": "Tasker ID"},
            {"name": "command", "type": "str", "required": False, "description": "Command that was executed"},
            {"name": "raw_output", "type": "str", "required": False, "description": "Raw command output"},
            {"name": "analysis", "type": "str", "required": False, "description": "Fabric analysis result"},
            {"name": "result", "type": "str", "required": False, "description": "Distilled result"},
        ],
    },
    {
        "name": "get_tasker_context",
        "category": "Executors",
        "description": "Retrieve stored context for follow-up queries.",
        "parameters": [
            {"name": "tasker_id", "type": "str", "required": True, "description": "Tasker ID"},
        ],
    },

    # ======================================================================
    # Project Management - file-based (8)
    # ======================================================================
    {
        "name": "get_story",
        "category": "Project Management",
        "description": "Load a user story by ID from project-management/user-stories/.",
        "parameters": [
            {"name": "story_id", "type": "str", "required": True, "description": "User story ID (e.g., 'US-001', '001', or '1')"},
        ],
    },
    {
        "name": "list_stories",
        "category": "Project Management",
        "description": "List and filter user stories.",
        "parameters": [
            {"name": "status", "type": "str", "required": False, "description": "Filter by status (draft, in-progress, documented, implemented, tested)"},
            {"name": "priority", "type": "str", "required": False, "description": "Filter by priority (critical, high, medium, low)"},
            {"name": "persona", "type": "str", "required": False, "description": "Filter by persona ID (e.g., 'P-001')"},
            {"name": "prd_group", "type": "str", "required": False, "description": "Filter by PRD group (e.g., 'mcp_tools', 'npl_load')"},
            {"name": "prd", "type": "str", "required": False, "description": "Filter by linked PRD (e.g., 'PRD-005')"},
            {"name": "limit", "type": "int", "required": False, "description": "Maximum stories to return (default 50)"},
            {"name": "offset", "type": "int", "required": False, "description": "Number of stories to skip (default 0)"},
        ],
    },
    {
        "name": "update_story_metadata",
        "category": "Project Management",
        "description": "Update user story metadata in index.yaml.",
        "parameters": [
            {"name": "story_id", "type": "str", "required": True, "description": "User story ID (e.g., 'US-001')"},
            {"name": "key", "type": "str", "required": True, "description": "Metadata field (status, priority, prds, related_stories, related_personas)"},
            {"name": "value", "type": "str", "required": True, "description": "New value (string for scalar fields, comma-separated for arrays)"},
        ],
    },
    {
        "name": "get_prd",
        "category": "Project Management",
        "description": "Load a PRD by ID from project-management/PRDs/.",
        "parameters": [
            {"name": "prd_id", "type": "str", "required": True, "description": "PRD ID (e.g., 'PRD-017', '017', or '17')"},
        ],
    },
    {
        "name": "get_prd_functional_requirement",
        "category": "Project Management",
        "description": "Access PRD functional requirements.",
        "parameters": [
            {"name": "prd_id", "type": "str", "required": True, "description": "PRD ID (e.g., 'PRD-017')"},
            {"name": "fr_id", "type": "str", "required": False, "description": "FR ID (e.g., 'FR-001') or '*' to list all (default '*')"},
        ],
    },
    {
        "name": "get_prd_acceptance_test",
        "category": "Project Management",
        "description": "Access PRD acceptance tests.",
        "parameters": [
            {"name": "prd_id", "type": "str", "required": True, "description": "PRD ID (e.g., 'PRD-017')"},
            {"name": "at_id", "type": "str", "required": False, "description": "AT ID (e.g., 'AT-001') or '*' to list all (default '*')"},
            {"name": "fr_id", "type": "str", "required": False, "description": "Optional FR ID to filter ATs by functional requirement"},
        ],
    },
    {
        "name": "get_persona",
        "category": "Project Management",
        "description": "Load a persona by ID from project-management/personas/.",
        "parameters": [
            {"name": "persona_id", "type": "str", "required": True, "description": "Persona ID (e.g., 'P-001' for core persona, 'A-001' for agent)"},
        ],
    },
    {
        "name": "list_personas",
        "category": "Project Management",
        "description": "List and filter personas.",
        "parameters": [
            {"name": "tags", "type": "str", "required": False, "description": "Comma-separated tags to filter by (OR logic)"},
            {"name": "category", "type": "str", "required": False, "description": "Category filter (e.g., 'Core', 'Infrastructure')"},
        ],
    },
]
