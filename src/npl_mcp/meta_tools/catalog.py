"""Static tool catalog for the NPL MCP server.

This module provides a complete, static description of every MCP tool
registered by the server. It is the single source of truth for tool
discovery, documentation generation, and LLM-assisted tool selection.

Total: 110 tools across 13 categories (5 discovery, 10 exposed, 95 hidden).
"""

from typing import Optional, TypedDict


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


class CategoryInfo(TypedDict):
    name: str
    description: str
    tool_count: int


# ---------------------------------------------------------------------------
# Categories
# ---------------------------------------------------------------------------

CATEGORIES: list[CategoryInfo] = [
    {
        "name": "Discovery",
        "description": "Tool discovery and management: search, browse, inspect, and call catalog tools",
        "tool_count": 5,
    },
    {
        "name": "Scripts",
        "description": "Shell script wrappers for file dumping, directory trees, NPL resource loading",
        "tool_count": 5,
    },
    {
        "name": "Artifacts",
        "description": "Create, retrieve, manage versioned artifacts with revision tracking",
        "tool_count": 5,
    },
    {
        "name": "Reviews",
        "description": "Review workflows: inline comments, overlay annotations, annotated output",
        "tool_count": 6,
    },
    {
        "name": "Sessions",
        "description": "Session lifecycle for grouping chat rooms and artifacts",
        "tool_count": 4,
    },
    {
        "name": "Chat",
        "description": "Event-sourced chat rooms: messaging, reactions, todo items, notifications",
        "tool_count": 8,
    },
    {
        "name": "Utility",
        "description": "Persist named credentials for API authentication",
        "tool_count": 1,
    },
    {
        "name": "Browser",
        "description": "Headless browser automation, markdown conversion, screenshots, downloads, connectivity, REST client",
        "tool_count": 37,
    },
    {"name": "Browser.Screenshots", "description": "Capture and compare screenshots of web pages", "tool_count": 3},
    {"name": "Browser.Navigation", "description": "Navigate, scroll, and control browser history", "tool_count": 5},
    {"name": "Browser.Input", "description": "Click, type, fill forms, and interact with page elements", "tool_count": 7},
    {"name": "Browser.Query", "description": "Read text, HTML, element state, and evaluate JavaScript", "tool_count": 5},
    {"name": "Browser.Session", "description": "Manage browser sessions and viewport settings", "tool_count": 3},
    {"name": "Browser.Wait", "description": "Wait for elements or network idle states", "tool_count": 2},
    {"name": "Browser.Inject", "description": "Inject JavaScript and CSS into pages", "tool_count": 2},
    {"name": "Browser.Storage", "description": "Manage cookies and localStorage", "tool_count": 5},
    {
        "name": "Task Queues",
        "description": "Task queue management: create queues, add tasks, track status, activity feeds",
        "tool_count": 13,
    },
    {
        "name": "Executors",
        "description": "Ephemeral agent management: spawn, lifecycle, fabric pattern analysis",
        "tool_count": 11,
    },
    {
        "name": "Project Management",
        "description": "Access user stories, PRDs, functional requirements, acceptance tests, personas, and DB-backed project/persona/story CRUD",
        "tool_count": 21,
    },
    {
        "name": "ToolSessions",
        "description": "Agent session tracking: generate, retrieve, and manage tool sessions keyed by agent/task pairs",
        "tool_count": 2,
    },
    {
        "name": "Instructions",
        "description": "Versioned instruction documents: create, retrieve, update, rollback, list versions, and search",
        "tool_count": 6,
    },
]


# ---------------------------------------------------------------------------
# Tool Catalog
# ---------------------------------------------------------------------------

TOOL_CATALOG: list[ToolEntry] = [
    # ======================================================================
    # Discovery (5)
    # ======================================================================
    {
        "name": "ToolSummary",
        "category": "Discovery",
        "description": "List available tools, or drill into a catalog category. Without filter: returns the exposed tools. With filter: expands that catalog category to show tool definitions and subcategories. Use dot notation to drill deeper (e.g. 'Browser.Screenshots'). With Category#ToolName: returns a single tool's full definition.",
        "parameters": [
            {"name": "filter", "type": "str", "required": False, "description": "Category path to expand, or Category#Tool for a single tool. Omit to see exposed tools."},
        ],
    },
    {
        "name": "ToolSearch",
        "category": "Discovery",
        "description": "Search for tools by name/description or by intent. Two search modes: 'text' for fast substring matching, 'intent' for LLM-powered semantic search with multi-tool workflow suggestions.",
        "parameters": [
            {"name": "query", "type": "str", "required": True, "description": "Search text (tool name for text mode, natural language for intent mode)"},
            {"name": "mode", "type": "str", "required": False, "description": "'text' or 'intent' (default: 'text')"},
            {"name": "limit", "type": "int", "required": False, "description": "Maximum results (default: 10)"},
            {"name": "verbose", "type": "bool", "required": False, "description": "If True, include full parameter definitions in each match"},
        ],
    },
    {
        "name": "ToolDefinition",
        "category": "Discovery",
        "description": "Get full definitions for one or more catalog tools by name. Returns complete tool info including all parameters.",
        "parameters": [
            {"name": "tools", "type": "list", "required": True, "description": "List of tool names to look up (e.g. ['ToMarkdown', 'Ping'])"},
        ],
    },
    {
        "name": "ToolHelp",
        "category": "Discovery",
        "description": "Get LLM-driven instructions on how to use a tool for a specific task. Returns actionable guidance tailored to your task.",
        "parameters": [
            {"name": "tool", "type": "str", "required": True, "description": "Name of the catalog tool (e.g. 'ToMarkdown')"},
            {"name": "task", "type": "str", "required": True, "description": "What you are trying to accomplish"},
            {"name": "verbose", "type": "int", "required": False, "description": "Detail level: 1=brief, 2=standard, 3=detailed with examples"},
        ],
    },
    {
        "name": "ToolCall",
        "category": "Discovery",
        "description": "Call any catalog tool by name, whether pinned or not. Dispatches to the tool's implementation with the provided arguments. Returns the tool's result directly, or an error if the tool is not found or has no implementation.",
        "parameters": [
            {"name": "tool", "type": "str", "required": True, "description": "Name of the catalog tool to call (e.g. 'Ping')"},
            {"name": "arguments", "type": "dict", "required": False, "description": "Arguments to pass to the tool as a JSON object (default: {})"},
        ],
    },

    # ======================================================================
    # Scripts (5)
    # ======================================================================
    {
        "name": "dump_files",
        "category": "Scripts",
        "description": "Dump contents of files in a directory respecting .gitignore.",
        "parameters": [
            {"name": "path", "type": "str", "required": True, "description": "Absolute path to directory to dump"},
            {"name": "glob_filter", "type": "str", "required": False, "description": "Optional glob pattern to filter files"},
        ],
    },
    {
        "name": "git_tree",
        "category": "Scripts",
        "description": "Display directory tree respecting .gitignore.",
        "parameters": [
            {"name": "path", "type": "str", "required": False, "description": "Absolute path to directory (default '.')"},
        ],
    },
    {
        "name": "git_tree_depth",
        "category": "Scripts",
        "description": "List directories with nesting depth information.",
        "parameters": [
            {"name": "path", "type": "str", "required": True, "description": "Absolute path to directory"},
        ],
    },
    {
        "name": "npl_load",
        "category": "Scripts",
        "description": "Load NPL components, metadata, or style guides.",
        "parameters": [
            {"name": "resource_type", "type": "str", "required": True, "description": "Resource type to load (c, m, s, agent, etc.)"},
            {"name": "items", "type": "str", "required": True, "description": "Comma-separated items to load"},
            {"name": "skip", "type": "str", "required": False, "description": "Comma-separated items to skip (already loaded)"},
        ],
    },
    {
        "name": "web_to_md",
        "category": "Scripts",
        "description": "Fetch a web page and return its content as markdown using Jina Reader.",
        "parameters": [
            {"name": "url", "type": "str", "required": True, "description": "The URL of the web page to fetch"},
            {"name": "timeout", "type": "int", "required": False, "description": "Request timeout in seconds (default 30)"},
        ],
    },

    # ======================================================================
    # Artifacts (5)
    # ======================================================================
    {
        "name": "create_artifact",
        "category": "Artifacts",
        "description": "Create a new artifact with initial revision.",
        "parameters": [
            {"name": "name", "type": "str", "required": True, "description": "Name of the artifact"},
            {"name": "artifact_type", "type": "str", "required": True, "description": "Type of artifact (e.g., 'screenshot', 'document')"},
            {"name": "file_content_base64", "type": "str", "required": True, "description": "Base64-encoded file content"},
            {"name": "filename", "type": "str", "required": True, "description": "Original filename"},
            {"name": "created_by", "type": "str", "required": False, "description": "Persona slug of creator"},
            {"name": "purpose", "type": "str", "required": False, "description": "Purpose description for the artifact"},
        ],
    },
    {
        "name": "add_revision",
        "category": "Artifacts",
        "description": "Add a new revision to an artifact.",
        "parameters": [
            {"name": "artifact_id", "type": "int", "required": True, "description": "ID of the artifact"},
            {"name": "file_content_base64", "type": "str", "required": True, "description": "Base64-encoded file content"},
            {"name": "filename", "type": "str", "required": True, "description": "Filename for the revision"},
            {"name": "created_by", "type": "str", "required": False, "description": "Persona slug of creator"},
            {"name": "purpose", "type": "str", "required": False, "description": "Purpose of this revision"},
            {"name": "notes", "type": "str", "required": False, "description": "Revision notes"},
        ],
    },
    {
        "name": "get_artifact",
        "category": "Artifacts",
        "description": "Get artifact and its revision content.",
        "parameters": [
            {"name": "artifact_id", "type": "int", "required": True, "description": "ID of the artifact"},
            {"name": "revision", "type": "int", "required": False, "description": "Specific revision number (latest if omitted)"},
        ],
    },
    {
        "name": "list_artifacts",
        "category": "Artifacts",
        "description": "List all artifacts.",
        "parameters": [],
    },
    {
        "name": "get_artifact_history",
        "category": "Artifacts",
        "description": "Get revision history for an artifact.",
        "parameters": [
            {"name": "artifact_id", "type": "int", "required": True, "description": "ID of the artifact"},
        ],
    },

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
    # Chat (8)
    # ======================================================================
    {
        "name": "create_chat_room",
        "category": "Chat",
        "description": "Create a new chat room.",
        "parameters": [
            {"name": "name", "type": "str", "required": True, "description": "Name of the chat room"},
            {"name": "members", "type": "list[str]", "required": True, "description": "List of persona slugs to add as members"},
            {"name": "description", "type": "str", "required": False, "description": "Optional room description"},
            {"name": "session_id", "type": "str", "required": False, "description": "Optional session ID to associate with"},
            {"name": "session_title", "type": "str", "required": False, "description": "Optional session title (creates session if needed)"},
        ],
    },
    {
        "name": "send_message",
        "category": "Chat",
        "description": "Send a message to a chat room.",
        "parameters": [
            {"name": "room_id", "type": "int", "required": True, "description": "ID of the chat room"},
            {"name": "persona", "type": "str", "required": True, "description": "Persona slug of sender"},
            {"name": "message", "type": "str", "required": True, "description": "Message content"},
            {"name": "reply_to_id", "type": "int", "required": False, "description": "Optional event ID to reply to"},
        ],
    },
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
        "name": "get_chat_feed",
        "category": "Chat",
        "description": "Get chat event feed for a room.",
        "parameters": [
            {"name": "room_id", "type": "int", "required": True, "description": "ID of the chat room"},
            {"name": "since", "type": "str", "required": False, "description": "ISO timestamp to get events after"},
            {"name": "limit", "type": "int", "required": False, "description": "Maximum events to return (default 50)"},
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
    # Utility (1)
    # ======================================================================
    {
        "name": "Secret",
        "category": "Utility",
        "description": "Store a named secret for use in API authentication. Secrets are persisted in PostgreSQL and referenced via ${secret.NAME} in Rest tool headers/body. Creates or updates the secret.",
        "parameters": [
            {"name": "name", "type": "str", "required": True, "description": "Secret identifier matching [a-zA-Z_][a-zA-Z0-9_]* (max 128 chars)"},
            {"name": "value", "type": "str", "required": True, "description": "Secret value (max 64 KB)"},
        ],
    },

    # ======================================================================
    # Browser (32 stubs + 4 exposed + 1 Rest)
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
    {
        "name": "browser_get_state",
        "category": "Browser.Query",
        "description": "Get current browser page state.",
        "parameters": [
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
        ],
    },
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
    {
        "name": "browser_wait_network_idle",
        "category": "Browser.Wait",
        "description": "Wait for network activity to become idle.",
        "parameters": [
            {"name": "session_id", "type": "str", "required": False, "description": "Browser session ID (default 'default')"},
            {"name": "timeout", "type": "int", "required": False, "description": "Maximum wait time in milliseconds (default 30000)"},
        ],
    },
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
    # Browser - Exposed tools (4) - directly under Browser category
    # ======================================================================
    {
        "name": "ToMarkdown",
        "category": "Browser",
        "description": "Convert file/URL to markdown with optional filter, collapse, and image descriptions.",
        "parameters": [
            {"name": "source", "type": "str", "required": True, "description": "URL, file path, or markdown content string"},
            {"name": "filter", "type": "str", "required": False, "description": "Filter selector to extract specific sections. Heading name: 'API Reference' matches ## API Reference. Path: 'Overview > API' matches API under Overview. CSS: 'css:#main' uses CSS selector. Use filtered_only=True for extraction, False (default) for context view with collapsed siblings."},
            {"name": "collapsed_depth", "type": "int", "required": False, "description": "Collapse headings below this depth (1-6)"},
            {"name": "filtered_only", "type": "bool", "required": False, "description": "Show only filtered sections (default False)"},
            {"name": "output", "type": "str", "required": False, "description": "File path to write output. If omitted, returns in payload."},
            {"name": "with_image_descriptions", "type": "bool", "required": False, "description": "Inject LLM-generated image descriptions (default False)"},
            {"name": "image_model", "type": "str", "required": False, "description": "Multi-modal LLM for image descriptions (default 'openai/gpt-5-mini')"},
            {"name": "fallback_parser", "type": "bool", "required": False, "description": "Fall back to html2text if Jina fails (default False, Jina only)"},
        ],
    },
    {
        "name": "Ping",
        "category": "Browser",
        "description": "Check connectivity to a URL. Returns status code and response time. Optional sentinel validates response via xpath:, regex:, or llm: prefix.",
        "parameters": [
            {"name": "url", "type": "str", "required": True, "description": "URL to ping/check connectivity"},
            {"name": "sentinel", "type": "str", "required": False, "description": "Validation expression: 'xpath:<expr>' checks HTML elements, 'regex:<pattern>' searches response body, 'llm:<condition>' asks LLM to evaluate condition (returns TRUE/FALSE + detail)"},
            {"name": "timeout", "type": "float", "required": False, "description": "Request timeout in seconds (default 10.0)"},
        ],
    },
    {
        "name": "Download",
        "category": "Browser",
        "description": "Download a URL or copy a file to a local path.",
        "parameters": [
            {"name": "file", "type": "str", "required": True, "description": "URL or file path to download from"},
            {"name": "out", "type": "str", "required": False, "description": "Local file path to save to. If omitted, uses source filename in current directory."},
        ],
    },
    {
        "name": "Screenshot",
        "category": "Browser",
        "description": "Capture a screenshot of a URL. Returns file path or base64 data.",
        "parameters": [
            {"name": "url", "type": "str", "required": True, "description": "URL to screenshot"},
            {"name": "output", "type": "str", "required": False, "description": "File path to save. If omitted, returns base64 data."},
            {"name": "max_width", "type": "int", "required": False, "description": "Maximum width in pixels. Image is scaled down preserving aspect ratio."},
            {"name": "max_height", "type": "int", "required": False, "description": "Maximum height in pixels. Image is scaled down preserving aspect ratio."},
            {"name": "full_page", "type": "bool", "required": False, "description": "Capture full scrollable page (default False, viewport only)"},
        ],
    },

    # ======================================================================
    # Browser – Rest (1)
    # ======================================================================
    {
        "name": "Rest",
        "category": "Browser",
        "description": "Full HTTP client with ${secret.NAME} injection in headers and body. Supports GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS. Secrets are resolved from the database before the request is sent.",
        "parameters": [
            {"name": "url", "type": "str", "required": True, "description": "Request URL"},
            {"name": "method", "type": "str", "required": False, "description": "HTTP method: GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS (default GET)"},
            {"name": "headers", "type": "dict", "required": False, "description": "Request headers as {name: value} dict. May contain ${secret.NAME} placeholders."},
            {"name": "accept", "type": "str", "required": False, "description": "Default Accept header (won't override explicit header)"},
            {"name": "encoding", "type": "str", "required": False, "description": "Default Accept-Encoding header (won't override explicit)"},
            {"name": "body", "type": "str", "required": False, "description": "Request body string. May contain ${secret.NAME} placeholders. Max 1 MB."},
            {"name": "timeout", "type": "float", "required": False, "description": "Request timeout in seconds (default 30)"},
        ],
    },

    # ======================================================================
    # Project Management (8)
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

    # ======================================================================
    # Project Management — DB-backed CRUD (13)
    # ======================================================================
    {
        "name": "Proj.Projects.Create",
        "category": "Project Management",
        "description": "Create a new project.",
        "parameters": [
            {"name": "name", "type": "str", "required": True, "description": "Project name"},
            {"name": "description", "type": "str", "required": False, "description": "Project description"},
        ],
    },
    {
        "name": "Proj.Projects.Get",
        "category": "Project Management",
        "description": "Retrieve a project by ID.",
        "parameters": [
            {"name": "id", "type": "str", "required": True, "description": "Project UUID"},
        ],
    },
    {
        "name": "Proj.Projects.List",
        "category": "Project Management",
        "description": "List projects with pagination.",
        "parameters": [
            {"name": "page", "type": "int", "required": False, "description": "Page number (default 1)"},
            {"name": "page_size", "type": "int", "required": False, "description": "Items per page (default 20)"},
        ],
    },
    {
        "name": "Proj.UserPersonas.Create",
        "category": "Project Management",
        "description": "Create a new user persona within a project.",
        "parameters": [
            {"name": "project_id", "type": "str", "required": True, "description": "Project UUID"},
            {"name": "name", "type": "str", "required": True, "description": "Persona name (e.g. 'Power Admin', 'Casual Browser')"},
            {"name": "role", "type": "str", "required": False, "description": "Role or job title"},
            {"name": "description", "type": "str", "required": False, "description": "Narrative description of who this persona is"},
            {"name": "goals", "type": "str", "required": False, "description": "What this persona is trying to achieve"},
            {"name": "pain_points", "type": "str", "required": False, "description": "Frustrations or obstacles"},
            {"name": "behaviors", "type": "str", "required": False, "description": "Typical behaviors, habits, or patterns"},
            {"name": "physical_description", "type": "str", "required": False, "description": "Physical appearance description"},
            {"name": "persona_image", "type": "str", "required": False, "description": "URL or path to persona avatar image"},
            {"name": "demographics", "type": "dict", "required": False, "description": "Flexible demographic attributes as JSON object"},
        ],
    },
    {
        "name": "Proj.UserPersonas.Get",
        "category": "Project Management",
        "description": "Retrieve a user persona by ID.",
        "parameters": [
            {"name": "id", "type": "str", "required": True, "description": "Persona UUID"},
        ],
    },
    {
        "name": "Proj.UserPersonas.Update",
        "category": "Project Management",
        "description": "Update an existing user persona.",
        "parameters": [
            {"name": "id", "type": "str", "required": True, "description": "Persona UUID"},
            {"name": "name", "type": "str", "required": False, "description": "New persona name"},
            {"name": "role", "type": "str", "required": False, "description": "New role"},
            {"name": "description", "type": "str", "required": False, "description": "New description"},
            {"name": "goals", "type": "str", "required": False, "description": "New goals"},
            {"name": "pain_points", "type": "str", "required": False, "description": "New pain points"},
            {"name": "behaviors", "type": "str", "required": False, "description": "New behaviors"},
            {"name": "physical_description", "type": "str", "required": False, "description": "New physical description"},
            {"name": "persona_image", "type": "str", "required": False, "description": "New persona image URL"},
            {"name": "demographics", "type": "dict", "required": False, "description": "New demographics JSON object"},
        ],
    },
    {
        "name": "Proj.UserPersonas.Delete",
        "category": "Project Management",
        "description": "Soft-delete a user persona.",
        "parameters": [
            {"name": "id", "type": "str", "required": True, "description": "Persona UUID"},
        ],
    },
    {
        "name": "Proj.UserPersonas.List",
        "category": "Project Management",
        "description": "List personas for a project with pagination.",
        "parameters": [
            {"name": "project_id", "type": "str", "required": True, "description": "Project UUID"},
            {"name": "page", "type": "int", "required": False, "description": "Page number (default 1)"},
            {"name": "page_size", "type": "int", "required": False, "description": "Items per page (default 20)"},
        ],
    },
    {
        "name": "Proj.UserStories.Create",
        "category": "Project Management",
        "description": "Create a new user story within a project.",
        "parameters": [
            {"name": "project_id", "type": "str", "required": True, "description": "Project UUID"},
            {"name": "title", "type": "str", "required": True, "description": "Short summary / title of the story"},
            {"name": "persona_ids", "type": "list", "required": False, "description": "Array of persona UUIDs — the 'As a...' personas"},
            {"name": "story_text", "type": "str", "required": False, "description": "Full 'As a [persona], I want [X], so that [Y]' narrative"},
            {"name": "description", "type": "str", "required": False, "description": "Additional context or notes"},
            {"name": "priority", "type": "str", "required": False, "description": "Priority: critical, high, medium (default), low"},
            {"name": "status", "type": "str", "required": False, "description": "Status: draft (default), ready, in_progress, done, archived"},
            {"name": "story_points", "type": "int", "required": False, "description": "Story point estimate"},
            {"name": "acceptance_criteria", "type": "list", "required": False, "description": "Array of acceptance criterion objects [{id, criterion, sort_order, is_met}]"},
            {"name": "tags", "type": "list", "required": False, "description": "Freeform tags for categorization"},
        ],
    },
    {
        "name": "Proj.UserStories.Get",
        "category": "Project Management",
        "description": "Retrieve a user story by ID. Pass include='acceptance-criteria' to include acceptance criteria.",
        "parameters": [
            {"name": "id", "type": "str", "required": True, "description": "Story UUID"},
            {"name": "include", "type": "str", "required": False, "description": "Pass 'acceptance-criteria' to include acceptance_criteria in response"},
        ],
    },
    {
        "name": "Proj.UserStories.Update",
        "category": "Project Management",
        "description": "Update an existing user story.",
        "parameters": [
            {"name": "id", "type": "str", "required": True, "description": "Story UUID"},
            {"name": "title", "type": "str", "required": False, "description": "New title"},
            {"name": "persona_ids", "type": "list", "required": False, "description": "New persona UUID array"},
            {"name": "story_text", "type": "str", "required": False, "description": "New story text"},
            {"name": "description", "type": "str", "required": False, "description": "New description"},
            {"name": "priority", "type": "str", "required": False, "description": "New priority"},
            {"name": "status", "type": "str", "required": False, "description": "New status"},
            {"name": "story_points", "type": "int", "required": False, "description": "New story points"},
            {"name": "acceptance_criteria", "type": "list", "required": False, "description": "New acceptance criteria array"},
            {"name": "tags", "type": "list", "required": False, "description": "New tags array"},
        ],
    },
    {
        "name": "Proj.UserStories.Delete",
        "category": "Project Management",
        "description": "Soft-delete a user story.",
        "parameters": [
            {"name": "id", "type": "str", "required": True, "description": "Story UUID"},
        ],
    },
    {
        "name": "Proj.UserStories.List",
        "category": "Project Management",
        "description": "List stories for a project with optional filtering and pagination.",
        "parameters": [
            {"name": "project_id", "type": "str", "required": True, "description": "Project UUID"},
            {"name": "persona_id", "type": "str", "required": False, "description": "Filter by persona UUID (array containment query)"},
            {"name": "status", "type": "str", "required": False, "description": "Filter by status"},
            {"name": "priority", "type": "str", "required": False, "description": "Filter by priority"},
            {"name": "tags", "type": "list", "required": False, "description": "Filter by tags (array overlap)"},
            {"name": "page", "type": "int", "required": False, "description": "Page number (default 1)"},
            {"name": "page_size", "type": "int", "required": False, "description": "Items per page (default 20)"},
        ],
    },

    # ======================================================================
    # ToolSessions (2)
    # ======================================================================
    {
        "name": "ToolSession.Generate",
        "category": "ToolSessions",
        "description": "Generate or look up a session UUID by (project, agent, task) triple. Sessions are scoped to a project. If existing, returns the UUID; if notes provided and not already present, appends them. If not existing, creates a new session.",
        "parameters": [
            {"name": "agent", "type": "str", "required": True, "description": "Agent identifier"},
            {"name": "brief", "type": "str", "required": True, "description": "Brief description of the session purpose"},
            {"name": "task", "type": "str", "required": True, "description": "Task identifier (unique per agent within project)"},
            {"name": "project", "type": "str", "required": True, "description": "Project name for scoping (e.g. from $NPL_PROJECT)"},
            {"name": "parent", "type": "str", "required": False, "description": "Optional parent session UUID for hierarchy"},
            {"name": "notes", "type": "str", "required": False, "description": "Optional notes to append to the session"},
        ],
    },
    {
        "name": "ToolSession",
        "category": "ToolSessions",
        "description": "Retrieve session info by UUID. Default returns agent, brief, and project name. Verbose mode returns all fields including task, notes, parent, and timestamps.",
        "parameters": [
            {"name": "uuid", "type": "str", "required": True, "description": "Session UUID"},
            {"name": "verbose", "type": "bool", "required": False, "description": "If True, return all fields (default False)"},
        ],
    },

    # ======================================================================
    # Instructions (5)
    # ======================================================================
    {
        "name": "Instructions",
        "category": "Instructions",
        "description": "Retrieve instruction body by UUID. Gets active version by default, or a specific version if specified. Requires a valid session UUID for access gating.",
        "parameters": [
            {"name": "uuid", "type": "str", "required": True, "description": "Instruction UUID"},
            {"name": "session", "type": "str", "required": True, "description": "A valid tool-session UUID (required for access gating)"},
            {"name": "version", "type": "int", "required": False, "description": "Specific version number (active version if omitted)"},
            {"name": "json", "type": "bool", "required": False, "description": "If True, return full metadata as JSON. Default returns markdown."},
        ],
    },
    {
        "name": "Instructions.Create",
        "category": "Instructions",
        "description": "Create a new instruction document with its first version (v1). Returns the UUID. Requires a valid session UUID.",
        "parameters": [
            {"name": "title", "type": "str", "required": True, "description": "Instruction title"},
            {"name": "description", "type": "str", "required": True, "description": "Instruction description"},
            {"name": "tags", "type": "list", "required": True, "description": "List of string tags for categorization"},
            {"name": "body", "type": "str", "required": True, "description": "Instruction body content"},
            {"name": "session", "type": "str", "required": True, "description": "A valid tool-session UUID to link this instruction to"},
        ],
    },
    {
        "name": "Instructions.Update",
        "category": "Instructions",
        "description": "Create a new version of an instruction. Increments version number and sets it as active. Optionally updates description, tags, and/or body.",
        "parameters": [
            {"name": "uuid", "type": "str", "required": True, "description": "Instruction UUID"},
            {"name": "change_note", "type": "str", "required": True, "description": "Description of what changed in this version"},
            {"name": "description", "type": "str", "required": False, "description": "New description (keeps current if omitted)"},
            {"name": "tags", "type": "list", "required": False, "description": "New tags list (keeps current if omitted)"},
            {"name": "body", "type": "str", "required": False, "description": "New body content (keeps current if omitted)"},
        ],
    },
    {
        "name": "Instructions.ActiveVersion",
        "category": "Instructions",
        "description": "Change the active version of an instruction (rollback or forward).",
        "parameters": [
            {"name": "uuid", "type": "str", "required": True, "description": "Instruction UUID"},
            {"name": "version", "type": "int", "required": True, "description": "Version number to set as active"},
        ],
    },
    {
        "name": "Instructions.Versions",
        "category": "Instructions",
        "description": "List all versions of an instruction with change notes and active indicator.",
        "parameters": [
            {"name": "uuid", "type": "str", "required": True, "description": "Instruction UUID"},
        ],
    },
    {
        "name": "Instructions.List",
        "category": "Instructions",
        "description": "Search and list instruction documents. Supports text search (ILIKE on title/description/tags/labels), intent search (pgvector cosine similarity on embeddings), and listing all instructions. Requires a valid session UUID.",
        "parameters": [
            {"name": "session", "type": "str", "required": True, "description": "A valid tool-session UUID (required for access gating)"},
            {"name": "query", "type": "str", "required": False, "description": "Search query string (required for text/intent modes)"},
            {"name": "mode", "type": "str", "required": False, "description": "Search mode: 'text', 'intent', or 'all' (default: 'text')"},
            {"name": "tags", "type": "list", "required": False, "description": "Tag filter (AND logic -- instruction must have all listed tags)"},
            {"name": "limit", "type": "int", "required": False, "description": "Maximum results (default 20, max 100)"},
        ],
    },

]


# ---------------------------------------------------------------------------
# Exposed tools - shown in ToolSummary default view (no filter)
# Discovery tools are excluded since the client already knows them.
# ---------------------------------------------------------------------------

EXPOSED_TOOL_NAMES: set[str] = {
    "ToMarkdown", "Ping", "Download", "Screenshot", "Secret", "Rest",
    "ToolSession", "ToolSession.Generate",
    "Instructions", "Instructions.Create", "Instructions.Update",
    "Instructions.ActiveVersion", "Instructions.Versions",
    "Instructions.List",
}


# ---------------------------------------------------------------------------
# Convenience helpers
# ---------------------------------------------------------------------------

def get_tools_by_category(category: str) -> list[ToolEntry]:
    """Return all tools in a given category."""
    return [t for t in TOOL_CATALOG if t["category"] == category]


def get_tool_by_name(name: str) -> Optional[ToolEntry]:
    """Look up a single tool by its registered name."""
    for t in TOOL_CATALOG:
        if t["name"] == name:
            return t
    return None


def get_category_info(name: str) -> Optional[CategoryInfo]:
    """Look up category metadata by name."""
    for c in CATEGORIES:
        if c["name"] == name:
            return c
    return None
