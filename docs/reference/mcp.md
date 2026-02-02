# MCP Commands Reference

Complete reference for all MCP (Model Context Protocol) commands available in the **NoizuPromptLingo** project. Each command includes a brief description and stubbed example request/response payloads.

**Note:** This documentation describes the full MCP server implementation located in `worktrees/main/mcp-server/`. The minimal server in `src/` provides only basic `hello-world` and `echo` tools for prototyping.

---

## Quick Summary

| Category | Commands |
|----------|----------|
| Script Tools | 5 |
| Artifact Tools | 5 |
| Review Tools | 6 |
| Session Tools | 4 |
| Chat / Room Tools | 8 |
| Screenshot Tools | 2 |
| Browser / Interaction Tools | 31 |
| Task Queue Tools | 13 |
| **Total** | **73** |

---

## How to Invoke MCP Commands

MCP commands can be called via:

- **Python client** (using the FastMCP client library):
  ```python
  result = await client.call("<command_name>", {"param": "value"})
  ```
- **HTTP SSE endpoint** (`/sse`) – MCP clients connect via Server-Sent Events to send tool calls with `"tool": "<command_name>"` and `"args": { ... }`.
- **Start the server**:
  ```bash
  # Run from worktrees/main/mcp-server/
  uv run -m npl_mcp.launcher
  # or
  uv run npl-mcp
  ```

---

## Response Formats

### Success Response
```json
{ "status": "ok", "result": { ... } }
```

### Error Response
```json
{ "status": "error", "code": "<error_code>", "message": "<human readable>" }
```

### Common Error Codes

| Code | Description |
|------|-------------|
| `INVALID_PARAMS` | Required parameters missing or invalid type |
| `NOT_FOUND` | Resource (artifact, session, task, etc.) not found |
| `UNAUTHORIZED` | (Placeholder) Authentication token missing or invalid |
| `INTERNAL_ERROR` | Unexpected server-side error |
| `CONFLICT` | Duplicate resource or state conflict |

---

## Authentication

> **Note**: The current server does not enforce authentication. When auth is added, include an `Authorization` header with a bearer token in HTTP requests:
> ```
> Authorization: Bearer <your_token>
> ```

---

---

## Script Tools

| Command | Description |
|---|---|
| `dump_files` | Dump contents of files in a directory respecting `.gitignore`. |
| `git_tree` | Display directory tree respecting `.gitignore`. |
| `git_tree_depth` | List directories with nesting depth information. |
| `npl_load` | Load NPL components, metadata, or style guides. |
| `web_to_md` | Fetch a web page and return its content as markdown using Jina Reader. |

<details><summary>`dump_files` Example</summary>

**Request**
```json
{ "path": "/home/user/project", "glob_filter": "*.py" }
```
**Response**
```json
{ "status": "ok", "result": "<concatenated file contents>" }
```
</details>

<details><summary>`git_tree` Example</summary>

**Request**
```json
{ "path": "." }
```
**Response**
```json
{ "status": "ok", "result": "project/\n├─ src/\n│  ├─ npl_mcp/\n│  └─ ..." }
```
</details>

<details><summary>`git_tree_depth` Example</summary>

**Request**
```json
{ "path": "src" }
```
**Response**
```json
{ "status": "ok", "result": [{"path": "src/npl_mcp", "depth": 1}, {"path": "src/npl_mcp/web", "depth": 2}] }
```
</details>

<details><summary>`npl_load` Example</summary>

**Request**
```json
{ "resource_type": "core", "items": "syntax,agent", "skip": null }
```
**Response**
```json
{ "status": "ok", "result": "Loaded core resources: syntax, agent" }
```
</details>

<details><summary>`web_to_md` Example</summary>

**Request**
```json
{ "url": "https://example.com", "timeout": 30 }
```
**Response**
```json
{ "status": "ok", "result": "# Example Title\n... markdown content ..." }
```
</details>

---

## Artifact Tools

| Command | Description |
|---|---|
| `create_artifact` | Create a new artifact with initial revision. |
| `add_revision` | Add a new revision to an artifact. |
| `get_artifact` | Get artifact and its revision content. |
| `list_artifacts` | List all artifacts. |
| `get_artifact_history` | Get revision history for an artifact. |

<details><summary>`create_artifact` Example</summary>

**Request**
```json
{ "name": "design-doc", "artifact_type": "markdown", "file_content_base64": "<base64>", "filename": "design.md", "created_by": "alice", "purpose": "Initial design" }
```
**Response**
```json
{ "status": "ok", "result": {"artifact_id": 42, "name": "design-doc", "type": "markdown", "filename": "design.md", "created_by": "alice", "web_url": "http://127.0.0.1:8765/artifact/42"} }
```
</details>

<details><summary>`add_revision` Example</summary>

**Request**
```json
{ "artifact_id": 42, "file_content_base64": "<new base64>", "filename": "design_v2.md", "created_by": "bob", "purpose": "Update", "notes": "Added section on API" }
```
**Response**
```json
{ "status": "ok", "result": {"revision_id": 5, "artifact_id": 42, "filename": "design_v2.md", "created_by": "bob"} }
```
</details>

<details><summary>`get_artifact` Example</summary>

**Request**
```json
{ "artifact_id": 42, "revision": null }
```
**Response**
```json
{ "status": "ok", "result": {"artifact_id": 42, "name": "design-doc", "content_base64": "<base64>", "filename": "design.md", "revision_id": 4} }
```
</details>

<details><summary>`list_artifacts` Example</summary>

**Request**
```json
{}
```
**Response**
```json
{ "status": "ok", "result": [{"artifact_id": 1, "name": "spec", "type": "markdown"}, {"artifact_id": 2, "name": "screenshot", "type": "image"}] }
```
</details>

<details><summary>`get_artifact_history` Example</summary>

**Request**
```json
{ "artifact_id": 42 }
```
**Response**
```json
{ "status": "ok", "result": [{"revision_id": 1, "created_at": "2024-01-01T12:00:00Z"}, {"revision_id": 2, "created_at": "2024-02-15T09:30:00Z"}] }
```
</details>

---

## Review Tools

| Command | Description |
|---|---|
| `create_review` | Start a new review for an artifact revision. |
| `add_inline_comment` | Add an inline comment to a review. |
| `add_overlay_annotation` | Add an image overlay annotation. |
| `get_review` | Get a review with all its comments. |
| `generate_annotated_artifact` | Generate an annotated version of an artifact with all review comments. |
| `complete_review` | Mark a review as completed. |

<details><summary>`create_review` Example</summary>

**Request**
```json
{ "artifact_id": 42, "revision_id": 4, "reviewer_persona": "bob" }
```
**Response**
```json
{ "status": "ok", "result": {"review_id": 7, "artifact_id": 42, "revision_id": 4, "reviewer": "bob", "status": "open"} }
```
</details>

<details><summary>`add_inline_comment` Example</summary>

**Request**
```json
{ "review_id": 7, "location": "line:12", "comment": "Consider renaming this variable.", "persona": "bob" }
```
**Response**
```json
{ "status": "ok", "result": {"comment_id": 15, "review_id": 7} }
```
</details>

<details><summary>`add_overlay_annotation` Example</summary>

**Request**
```json
{ "review_id": 7, "x": 120, "y": 250, "comment": "Highlight area of concern", "persona": "bob" }
```
**Response**
```json
{ "status": "ok", "result": {"annotation_id": 3} }
```
</details>

<details><summary>`get_review` Example</summary>

**Request**
```json
{ "review_id": 7 }
```
**Response**
```json
{ "status": "ok", "result": {"review_id": 7, "comments": [{"id":15,"text":"Consider renaming..."}], "annotations": [{"id":3,"x":120,"y":250}]} }
```
</details>

<details><summary>`generate_annotated_artifact` Example</summary>

**Request**
```json
{ "artifact_id": 42, "revision_id": 4 }
```
**Response**
```json
{ "status": "ok", "result": {"artifact_id": 42, "revision_id": 4, "annotated_file_path": "/tmp/annotated_42_4.png"} }
```
</details>

<details><summary>`complete_review` Example</summary>

**Request**
```json
{ "review_id": 7, "overall_comment": "All good." }
```
**Response**
```json
{ "status": "ok", "result": {"review_id":7,"status":"completed"} }
```
</details>

---

## Session Tools

| Command | Description |
|---|---|
| `create_session` | Create a new session to group chat rooms and artifacts. |
| `get_session` | Get session details and contents. |
| `list_sessions` | List recent sessions. |
| `update_session` | Update session metadata. |

<details><summary>`create_session` Example</summary>

**Request**
```json
{ "title": "Sprint Planning", "session_id": null }
```
**Response**
```json
{ "status": "ok", "result": {"session_id": "sess-123", "title": "Sprint Planning", "web_url": "http://127.0.0.1:8765/session/sess-123"} }
```
</details>

<details><summary>`get_session` Example</summary>

**Request**
```json
{ "session_id": "sess-123" }
```
**Response**
```json
{ "status": "ok", "result": {"session_id": "sess-123", "title": "Sprint Planning", "rooms": [], "artifacts": []} }
```
</details>

<details><summary>`list_sessions` Example</summary>

**Request**
```json
{ "status": null, "limit": 20 }
```
**Response**
```json
{ "status": "ok", "result": [{"session_id":"sess-123","title":"Sprint Planning"}, {"session_id":"sess-124","title":"Retrospective"}] }
```
</details>

<details><summary>`update_session` Example</summary>

**Request**
```json
{ "session_id": "sess-123", "title": "Sprint Planning Q1", "status": "active" }
```
**Response**
```json
{ "status": "ok", "result": {"session_id":"sess-123","title":"Sprint Planning Q1","status":"active"} }
```
</details>

---

## Chat / Room Tools

| Command | Description |
|---|---|
| `create_chat_room` | Create a new chat room. |
| `send_message` | Send a message to a chat room. |
| `react_to_message` | Add an emoji reaction to a message. |
| `share_artifact` | Share an artifact in a chat room. |
| `create_todo` | Create a shared todo item in a chat room. |
| `get_chat_feed` | Get chat event feed for a room. |
| `get_notifications` | Get notifications for a persona. |
| `mark_notification_read` | Mark a notification as read. |

<details><summary>`create_chat_room` Example</summary>

**Request**
```json
{ "name": "Design Discussion", "members": ["alice","bob"], "description": "Discuss UI mockups", "session_id": "sess-123", "session_title": null }
```
**Response**
```json
{ "status": "ok", "result": {"room_id": 9, "name": "Design Discussion", "web_url": "http://127.0.0.1:8765/session/sess-123/room/9"} }
```
</details>

<details><summary>`send_message` Example</summary>

**Request**
```json
{ "room_id": 9, "persona": "alice", "message": "What do you think of the new logo?" }
```
**Response**
```json
{ "status": "ok", "result": {"event_id": 101} }
```
</details>

<details><summary>`react_to_message` Example</summary>

**Request**
```json
{ "event_id": 101, "persona": "bob", "emoji": "👍" }
```
**Response**
```json
{ "status": "ok", "result": {"event_id":102} }
```
</details>

<details><summary>`share_artifact` Example</summary>

**Request**
```json
{ "room_id": 9, "persona": "alice", "artifact_id": 42, "revision": null }
```
**Response**
```json
{ "status": "ok", "result": {"shared_artifact_id": 55} }
```
</details>

<details><summary>`create_todo` Example</summary>

**Request**
```json
{ "room_id": 9, "persona": "bob", "description": "Review the design spec", "assigned_to": "alice" }
```
**Response**
```json
{ "status": "ok", "result": {"todo_id": 33} }
```
</details>

<details><summary>`get_chat_feed` Example</summary>

**Request**
```json
{ "room_id": 9, "since": null, "limit": 50 }
```
**Response**
```json
{ "status": "ok", "result": [{"event_id":101,"type":"message","persona":"alice","content":"What do you think of the new logo?"}, {"event_id":102,"type":"reaction","persona":"bob","emoji":"👍"}] }
```
</details>

<details><summary>`get_notifications` Example</summary>

**Request**
```json
{ "persona": "alice", "unread_only": true }
```
**Response**
```json
{ "status": "ok", "result": [{"notification_id": 7, "message": "You were mentioned in room 9"}] }
```
</details>

<details><summary>`mark_notification_read` Example</summary>

**Request**
```json
{ "notification_id": 7 }
```
**Response**
```json
{ "status": "ok", "result": {"notification_id":7,"read":true} }
```
</details>

---

## Screenshot Tools

| Command | Description |
|---|---|
| `screenshot_capture` | Capture screenshot of a web page and store as artifact. |
| `screenshot_diff` | Generate visual diff between two screenshot artifacts. |

<details><summary>`screenshot_capture` Example</summary>

**Request**
```json
{ "url": "https://example.com", "name": "homepage", "viewport": "desktop", "theme": "light", "full_page": true, "wait_for": null, "wait_timeout": 5000, "network_idle": true, "session_id": null, "created_by": "alice" }
```
**Response**
```json
{ "status": "ok", "result": {"artifact_id": 88, "file_path": "/artifacts/homepage.png", "metadata": {"url": "https://example.com", "viewport": {"width":1280,"height":720,"preset":"desktop"}, "theme": "light", "full_page": true, "captured_at": "2026-02-02T10:15:00Z"}} }
```
</details>

<details><summary>`screenshot_diff` Example</summary>

**Request**
```json
{ "baseline_artifact_id": 88, "comparison_artifact_id": 89, "threshold": 0.1, "session_id": null, "created_by": "bob" }
```
**Response**
```json
{ "status": "ok", "result": {"diff_artifact_id": 90, "diff_percentage": 2.3, "status": "passed", "file_path": "/artifacts/diff_homepage.png"} }
```
</details>

---

## Browser / Interaction Tools

| Command | Description |
|---|---|
| `browser_navigate` | Navigate browser to a URL. |
| `browser_click` | Click an element in the browser. |
| `browser_fill` | Fill a form field in the browser. |
| `browser_type` | Type text character by character (simulates real typing). |
| `browser_select` | Select option from dropdown. |
| `browser_scroll` | Scroll the page or an element. |
| `browser_wait_for` | Wait for an element to reach a state. |
| `browser_get_text` | Get text content of an element. |
| `browser_query_elements` | Query multiple elements matching a selector. |
| `browser_evaluate` | Evaluate JavaScript expression in page context. |
| `browser_screenshot` | Capture screenshot of current browser page or element. |
| `browser_get_state` | Get current browser page state. |
| `browser_close_session` | Close a browser session. |
| `browser_list_sessions` | List active browser sessions. |
| `browser_press_key` | Press a keyboard key. |
| `browser_hover` | Hover over an element. |
| `browser_focus` | Focus on an element. |
| `browser_get_html` | Get HTML content of page or element. |
| `browser_set_viewport` | Change browser viewport size. |
| `browser_go_back` | Navigate back in browser history. |
| `browser_go_forward` | Navigate forward in browser history. |
| `browser_reload` | Reload the current page. |
| `browser_inject_script` | Inject and execute JavaScript via script tag. |
| `browser_inject_style` | Inject CSS styles into the page. |
| `browser_wait_network_idle` | Wait for network activity to become idle. |
| `browser_get_cookies` | Get all cookies for the current page. |
| `browser_set_cookie` | Set a cookie. |
| `browser_clear_cookies` | Clear all cookies for the browser session. |
| `browser_get_local_storage` | Get localStorage value(s). |
| `browser_set_local_storage` | Set localStorage value. |

<details><summary>`browser_navigate` Example</summary>

**Request**
```json
{ "url": "https://example.com", "session_id": "default", "wait_for": null, "timeout": 30000 }
```
**Response**
```json
{ "status": "ok", "result": {"success": true, "action": "navigate", "message": "Navigated successfully", "page": {"url": "https://example.com", "title": "Example Domain", "viewport": [1280,720]}} }
```
</details>

<details><summary>`browser_click` Example</summary>

**Request**
```json
{ "selector": "#submit", "session_id": "default", "timeout": 5000, "screenshot_after": false, "artifact_name": null }
```
**Response**
```json
{ "status": "ok", "result": {"success": true, "action": "click", "target": "#submit", "message": "Element clicked"} }
```
</details>

<details><summary>`browser_fill` Example</summary>

**Request**
```json
{ "selector": "#email", "value": "user@example.com", "session_id": "default", "timeout": 5000 }
```
**Response**
```json
{ "status": "ok", "result": {"success": true, "action": "fill", "target": "#email", "message": "Field filled"} }
```
</details>

<details><summary>`browser_type` Example</summary>

**Request**
```json
{ "selector": "#search", "text": "search term", "session_id": "default", "delay": 50, "timeout": 5000 }
```
**Response**
```json
{ "status": "ok", "result": {"success": true, "action": "type", "target": "#search", "message": "Text typed"} }
```
</details>

<details><summary>`browser_select` Example</summary>

**Request**
```json
{ "selector": "#country", "value": "US", "session_id": "default", "timeout": 5000 }
```
**Response**
```json
{ "status": "ok", "result": {"success": true, "action": "select", "target": "#country", "message": "Option selected"} }
```
</details>

<details><summary>`browser_scroll` Example</summary>

**Request**
```json
{ "direction": "down", "amount": 500, "selector": null, "session_id": "default" }
```
**Response**
```json
{ "status": "ok", "result": {"success": true, "action": "scroll", "message": "Scrolled down 500px"} }
```
</details>

<details><summary>`browser_wait_for` Example</summary>

**Request**
```json
{ "selector": ".results", "state": "visible", "session_id": "default", "timeout": 10000 }
```
**Response**
```json
{ "status": "ok", "result": {"success": true, "action": "wait_for", "target": ".results", "message": "Element became visible"} }
```
</details>

<details><summary>`browser_get_text` Example</summary>

**Request**
```json
{ "selector": "h1", "session_id": "default", "timeout": 5000 }
```
**Response**
```json
{ "status": "ok", "result": {"selector": "h1", "text": "Welcome to Example"} }
```
</details>

<details><summary>`browser_query_elements` Example</summary>

**Request**
```json
{ "selector": "a.link", "session_id": "default", "limit": 10 }
```
**Response**
```json
{ "status": "ok", "result": {"selector": "a.link", "count": 3, "elements": [{"tag": "a","text":"Home","visible":true,"attributes":{"href":"/"}}, {"tag": "a","text":"About","visible":true,"attributes":{"href":"/about"}}]} }
```
</details>

<details><summary>`browser_evaluate` Example</summary>

**Request**
```json
{ "expression": "document.title", "session_id": "default" }
```
**Response**
```json
{ "status": "ok", "result": {"expression": "document.title", "result": "Example Domain"} }
```
</details>

<details><summary>`browser_screenshot` Example</summary>

**Request**
```json
{ "name": "page-capture", "session_id": "default", "full_page": false, "selector": null, "created_by": "alice" }
```
**Response**
```json
{ "status": "ok", "result": {"artifact_id": 99, "filename": "page-capture.png", "web_url": "http://127.0.0.1:8765/artifact/99", "metadata": {"url": "https://example.com", "title": "Example Domain"}} }
```
</details>

<details><summary>`browser_get_state` Example</summary>

**Request**
```json
{ "session_id": "default" }
```
**Response**
```json
{ "status": "ok", "result": {"url": "https://example.com", "title": "Example Domain", "viewport": [1280,720], "scroll_position": [0,0]} }
```
</details>

<details><summary>`browser_close_session` Example</summary>

**Request**
```json
{ "session_id": "default" }
```
**Response**
```json
{ "status": "ok", "result": {"success": true, "message": "Closed browser session: default"} }
```
</details>

<details><summary>`browser_list_sessions` Example</summary>

**Request**
```json
{}
```
**Response**
```json
{ "status": "ok", "result": {"sessions": ["default", "mobile-preview"], "count": 2} }
```
</details>

<details><summary>`browser_press_key` Example</summary>

**Request**
```json
{ "key": "Enter", "session_id": "default", "modifiers": null }
```
**Response**
```json
{ "status": "ok", "result": {"success": true, "action": "press_key", "message": "Pressed key: Enter"} }
```
</details>

<details><summary>`browser_hover` Example</summary>

**Request**
```json
{ "selector": "#menu-item", "session_id": "default", "timeout": 5000 }
```
**Response**
```json
{ "status": "ok", "result": {"success": true, "action": "hover", "target": "#menu-item", "message": "Hovered over element"} }
```
</details>

<details><summary>`browser_focus` Example</summary>

**Request**
```json
{ "selector": "#username", "session_id": "default", "timeout": 5000 }
```
**Response**
```json
{ "status": "ok", "result": {"success": true, "action": "focus", "target": "#username", "message": "Focused on element"} }
```
</details>

<details><summary>`browser_get_html` Example</summary>

**Request**
```json
{ "session_id": "default", "selector": "#content", "outer": true }
```
**Response**
```json
{ "status": "ok", "result": {"selector": "#content", "html": "<div id=\"content\">...</div>", "length": 256} }
```
</details>

<details><summary>`browser_set_viewport` Example</summary>

**Request**
```json
{ "width": 1920, "height": 1080, "session_id": "default" }
```
**Response**
```json
{ "status": "ok", "result": {"success": true, "action": "set_viewport", "message": "Viewport set to 1920x1080"} }
```
</details>

<details><summary>`browser_go_back` Example</summary>

**Request**
```json
{ "session_id": "default" }
```
**Response**
```json
{ "status": "ok", "result": {"success": true, "action": "go_back", "message": "Navigated back"} }
```
</details>

<details><summary>`browser_go_forward` Example</summary>

**Request**
```json
{ "session_id": "default" }
```
**Response**
```json
{ "status": "ok", "result": {"success": true, "action": "go_forward", "message": "Navigated forward"} }
```
</details>

<details><summary>`browser_reload` Example</summary>

**Request**
```json
{ "session_id": "default" }
```
**Response**
```json
{ "status": "ok", "result": {"success": true, "action": "reload", "message": "Page reloaded"} }
```
</details>

<details><summary>`browser_inject_script` Example</summary>

**Request**
```json
{ "script": "console.log('hello');", "session_id": "default" }
```
**Response**
```json
{ "status": "ok", "result": {"success": true, "action": "add_script", "message": "Script injected"} }
```
</details>

<details><summary>`browser_inject_style` Example</summary>

**Request**
```json
{ "css": "body { background: red; }", "session_id": "default" }
```
**Response**
```json
{ "status": "ok", "result": {"success": true, "action": "add_style", "message": "Styles injected"} }
```
</details>

<details><summary>`browser_wait_network_idle` Example</summary>

**Request**
```json
{ "session_id": "default", "timeout": 30000 }
```
**Response**
```json
{ "status": "ok", "result": {"success": true, "action": "wait_network_idle", "message": "Network became idle"} }
```
</details>

<details><summary>`browser_get_cookies` Example</summary>

**Request**
```json
{ "session_id": "default" }
```
**Response**
```json
{ "status": "ok", "result": {"cookies": [{"name": "session", "value": "abc123", "domain": ".example.com"}], "count": 1} }
```
</details>

<details><summary>`browser_set_cookie` Example</summary>

**Request**
```json
{ "name": "pref", "value": "dark", "session_id": "default", "domain": null, "path": "/" }
```
**Response**
```json
{ "status": "ok", "result": {"success": true, "action": "set_cookie", "target": "pref", "message": "Cookie set"} }
```
</details>

<details><summary>`browser_clear_cookies` Example</summary>

**Request**
```json
{ "session_id": "default" }
```
**Response**
```json
{ "status": "ok", "result": {"success": true, "action": "clear_cookies", "message": "All cookies cleared"} }
```
</details>

<details><summary>`browser_get_local_storage` Example</summary>

**Request**
```json
{ "session_id": "default", "key": "theme" }
```
**Response**
```json
{ "status": "ok", "result": {"key": "theme", "data": "dark"} }
```
</details>

<details><summary>`browser_set_local_storage` Example</summary>

**Request**
```json
{ "key": "theme", "value": "dark", "session_id": "default" }
```
**Response**
```json
{ "status": "ok", "result": {"success": true, "action": "set_local_storage", "target": "theme", "message": "localStorage updated"} }
```
</details>

---

## Task Queue Tools

| Command | Description |
|---|---|
| `create_task_queue` | Create a new task queue for organizing work items. |
| `get_task_queue` | Get task queue details with task counts. |
| `list_task_queues` | List task queues with summary stats. |
| `create_task` | Create a new task in a queue. |
| `get_task` | Get task details with linked artifacts. |
| `list_tasks` | List tasks in a queue. |
| `update_task_status` | Update task status (pending → in_progress → blocked → review → done). |
| `assign_task_complexity` | Assign complexity score to a task. |
| `update_task` | Update task details. |
| `add_task_artifact` | Link an artifact or git branch to a task. |
| `add_task_message` | Add a message/question to a task's activity feed. |
| `get_task_queue_feed` | Get activity feed for a task queue. |
| `get_task_feed` | Get activity feed for a specific task. |

<details><summary>`create_task_queue` Example</summary>

**Request**
```json
{ "name": "Feature Backlog", "description": "All upcoming features", "session_id": "sess-123", "chat_room_id": null }
```
**Response**
```json
{ "status": "ok", "result": {"queue_id": 5, "name": "Feature Backlog", "web_url": "http://127.0.0.1:8765/tasks/5"} }
```
</details>

<details><summary>`get_task_queue` Example</summary>

**Request**
```json
{ "queue_id": 5 }
```
**Response**
```json
{ "status": "ok", "result": {"queue_id": 5, "name": "Feature Backlog", "task_count": {"pending":3,"in_progress":2,"blocked":0,"review":1,"done":10}, "web_url": "http://127.0.0.1:8765/tasks/5"} }
```
</details>

<details><summary>`list_task_queues` Example</summary>

**Request**
```json
{ "status": null, "limit": 50 }
```
**Response**
```json
{ "status": "ok", "result": [{"id": 5, "name": "Feature Backlog", "status": "active", "task_count": 16, "web_url": "http://127.0.0.1:8765/tasks/5"}, {"id": 6, "name": "Bug Fixes", "status": "active", "task_count": 4, "web_url": "http://127.0.0.1:8765/tasks/6"}] }
```
</details>

<details><summary>`create_task` Example</summary>

**Request**
```json
{ "queue_id": 5, "title": "Add dark mode", "description": "Implement UI theme switching", "acceptance_criteria": "User can toggle dark mode", "priority": 2, "deadline": "2026-03-01T00:00:00Z", "created_by": "alice", "assigned_to": "bob" }
```
**Response**
```json
{ "status": "ok", "result": {"task_id": 21, "queue_id":5, "web_url": "http://127.0.0.1:8765/tasks/5/task/21"} }
```
</details>

<details><summary>`get_task` Example</summary>

**Request**
```json
{ "task_id": 21 }
```
**Response**
```json
{ "status": "ok", "result": {"task_id": 21, "queue_id": 5, "title": "Add dark mode", "status": "pending", "artifacts": [], "web_url": "http://127.0.0.1:8765/tasks/5/task/21"} }
```
</details>

<details><summary>`list_tasks` Example</summary>

**Request**
```json
{ "queue_id": 5, "status": null, "assigned_to": null, "limit": 100 }
```
**Response**
```json
{ "status": "ok", "result": [{"task_id": 21, "title": "Add dark mode", "status": "pending"}, {"task_id": 22, "title": "Fix navigation bug", "status": "in_progress"}] }
```
</details>

<details><summary>`update_task_status` Example</summary>

**Request**
```json
{ "task_id": 21, "status": "in_progress", "persona": "bob", "notes": "Started work" }
```
**Response**
```json
{ "status": "ok", "result": {"task_id":21,"status":"in_progress"} }
```
</details>

<details><summary>`assign_task_complexity` Example</summary>

**Request**
```json
{ "task_id": 21, "complexity": 3, "notes": "Requires backend change", "persona": "bob" }
```
**Response**
```json
{ "status": "ok", "result": {"task_id": 21, "complexity": 3, "complexity_label": "moderate"} }
```
</details>

<details><summary>`update_task` Example</summary>

**Request**
```json
{ "task_id": 21, "title": "Add dark mode UI", "description": "Implement theme toggle button", "acceptance_criteria": null, "priority": null, "deadline": null, "assigned_to": "alice", "persona": "bob" }
```
**Response**
```json
{ "status": "ok", "result": {"task_id": 21, "title": "Add dark mode UI", "assigned_to": "alice"} }
```
</details>

<details><summary>`add_task_artifact` Example</summary>

**Request**
```json
{ "task_id": 21, "artifact_type": "git_branch", "artifact_id": null, "git_branch": "feature/dark-mode", "description": "Implementation branch", "created_by": "bob" }
```
**Response**
```json
{ "status": "ok", "result": {"task_artifact_id": 7, "task_id": 21, "artifact_type": "git_branch", "git_branch": "feature/dark-mode"} }
```
</details>

<details><summary>`add_task_message` Example</summary>

**Request**
```json
{ "task_id": 21, "persona": "alice", "message": "How should we handle the persistence of theme preference?" }
```
**Response**
```json
{ "status": "ok", "result": {"event_id": 405, "task_id": 21, "persona": "alice", "type": "message"} }
```
</details>

<details><summary>`get_task_queue_feed` Example</summary>

**Request**
```json
{ "queue_id": 5, "since": null, "limit": 100 }
```
**Response**
```json
{ "status": "ok", "result": {"since": "2026-02-02T10:00:00Z", "next_since": "2026-02-02T11:00:00Z", "events": [{"event_id":405,"type":"task_created","task_id":21}]} }
```
</details>

<details><summary>`get_task_feed` Example</summary>

**Request**
```json
{ "task_id": 21, "since": null, "limit": 50 }
```
**Response**
```json
{ "status": "ok", "result": {"since": "2026-02-02T10:00:00Z", "next_since": "2026-02-02T11:00:00Z", "events": [{"event_id":405,"type":"message","persona":"alice","content":"How should we handle persistence?"}]} }
```
</details>

---

## Alphabetical Command Index

| Command | Category |
|---------|----------|
| `add_inline_comment` | Review Tools |
| `add_overlay_annotation` | Review Tools |
| `add_revision` | Artifact Tools |
| `add_task_artifact` | Task Queue Tools |
| `add_task_message` | Task Queue Tools |
| `assign_task_complexity` | Task Queue Tools |
| `browser_click` | Browser Tools |
| `browser_close_session` | Browser Tools |
| `browser_evaluate` | Browser Tools |
| `browser_fill` | Browser Tools |
| `browser_focus` | Browser Tools |
| `browser_get_cookies` | Browser Tools |
| `browser_get_html` | Browser Tools |
| `browser_get_local_storage` | Browser Tools |
| `browser_get_state` | Browser Tools |
| `browser_get_text` | Browser Tools |
| `browser_go_back` | Browser Tools |
| `browser_go_forward` | Browser Tools |
| `browser_hover` | Browser Tools |
| `browser_inject_script` | Browser Tools |
| `browser_inject_style` | Browser Tools |
| `browser_list_sessions` | Browser Tools |
| `browser_navigate` | Browser Tools |
| `browser_press_key` | Browser Tools |
| `browser_query_elements` | Browser Tools |
| `browser_reload` | Browser Tools |
| `browser_screenshot` | Browser Tools |
| `browser_scroll` | Browser Tools |
| `browser_select` | Browser Tools |
| `browser_set_cookie` | Browser Tools |
| `browser_set_local_storage` | Browser Tools |
| `browser_set_viewport` | Browser Tools |
| `browser_type` | Browser Tools |
| `browser_wait_for` | Browser Tools |
| `browser_wait_network_idle` | Browser Tools |
| `browser_clear_cookies` | Browser Tools |
| `complete_review` | Review Tools |
| `create_artifact` | Artifact Tools |
| `create_chat_room` | Chat Tools |
| `create_review` | Review Tools |
| `create_session` | Session Tools |
| `create_task` | Task Queue Tools |
| `create_task_queue` | Task Queue Tools |
| `create_todo` | Chat Tools |
| `dump_files` | Script Tools |
| `generate_annotated_artifact` | Review Tools |
| `get_artifact` | Artifact Tools |
| `get_artifact_history` | Artifact Tools |
| `get_chat_feed` | Chat Tools |
| `get_notifications` | Chat Tools |
| `get_review` | Review Tools |
| `get_session` | Session Tools |
| `get_task` | Task Queue Tools |
| `get_task_feed` | Task Queue Tools |
| `get_task_queue` | Task Queue Tools |
| `get_task_queue_feed` | Task Queue Tools |
| `git_tree` | Script Tools |
| `git_tree_depth` | Script Tools |
| `list_artifacts` | Artifact Tools |
| `list_sessions` | Session Tools |
| `list_task_queues` | Task Queue Tools |
| `list_tasks` | Task Queue Tools |
| `mark_notification_read` | Chat Tools |
| `npl_load` | Script Tools |
| `react_to_message` | Chat Tools |
| `screenshot_capture` | Screenshot Tools |
| `screenshot_diff` | Screenshot Tools |
| `send_message` | Chat Tools |
| `share_artifact` | Chat Tools |
| `update_session` | Session Tools |
| `update_task` | Task Queue Tools |
| `update_task_status` | Task Queue Tools |
| `web_to_md` | Script Tools |

---

## Extending the Command Set

To add a new command:

1. Implement a new `@mcp.tool()` function in `worktrees/main/mcp-server/src/npl_mcp/unified.py`
2. Provide a docstring describing the command's purpose and parameters
3. Return values should follow the JSON response patterns shown above
4. Update this reference file with the new command details

Example:
```python
@mcp.tool()
async def my_new_command(param1: str, param2: Optional[int] = None) -> dict:
    """Brief description of what the command does.

    Args:
        param1: Description of first parameter
        param2: Description of optional second parameter

    Returns:
        Dict with operation status and results
    """
    # Implementation here
    return {"status": "ok", "result": {"key": "value"}}
```

---

*Generated by Claude Code (CLI) – Documentation prepared based on the current codebase (as of 2026-02-02).*