# NPL MCP Server

Comprehensive MCP server for Noizu Prompt Lingo (NPL) providing:

- **Script Tools**: Access to existing NPL scripts (dump-files, git-tree, npl-load)
- **Artifact Management**: Version-controlled artifacts with revision history
- **Review System**: Collaborative reviews with inline comments and image overlays
- **Session Management**: Group chat rooms and artifacts into logical sessions
- **Chat System**: Multi-room persona collaboration with @mentions and notifications

## Installation

```bash
cd mcp-server
uv pip install -e .
```

## Starting the Server

The server provides multiple entry points for different use cases:

| Command | Transport | Use Case |
|---------|-----------|----------|
| `npl-mcp` | stdio | Direct Claude Code integration (recommended) |
| `npl-mcp-launcher` | HTTP | Managed server with auto-start and Web UI |
| `npl-mcp-unified` | HTTP/SSE | Single HTTP server for MCP + Web UI |
| `npl-mcp-web` | stdio + HTTP | MCP on stdio with Web UI in background |

### Quick Start (stdio mode)

```bash
npl-mcp
```

### HTTP Mode with Web UI

```bash
# Start the unified server (HTTP-based MCP + Web UI)
npl-mcp-unified

# Or use the launcher for managed startup
npl-mcp-launcher
```

### Launcher Commands

```bash
npl-mcp-launcher           # Start server (or connect if already running)
npl-mcp-launcher --status  # Check server status
npl-mcp-launcher --stop    # Stop running server
npl-mcp-launcher --config  # Print Claude Code configuration snippet
```

## MCP Tools

### Script Tools
- `dump_files(path, glob_filter)` - Dump file contents respecting .gitignore
- `git_tree(path)` - Show directory tree
- `git_tree_depth(path)` - Show directories with nesting depth
- `npl_load(resource_type, items, skip)` - Load NPL components/metadata/styles

### Artifact Management
- `create_artifact(name, artifact_type, file_content_base64, filename, created_by, purpose)` - Create artifact with initial revision
- `add_revision(artifact_id, file_content_base64, filename, created_by, purpose, notes)` - Add new revision
- `get_artifact(artifact_id, revision)` - Retrieve artifact revision
- `list_artifacts()` - List all artifacts
- `get_artifact_history(artifact_id)` - Show revision timeline

### Review System
- `create_review(artifact_id, revision_id, reviewer_persona)` - Start review
- `add_inline_comment(review_id, location, comment, persona)` - Add inline comment
- `add_overlay_annotation(review_id, x, y, comment, persona)` - Add image annotation
- `get_review(review_id)` - Get full review
- `generate_annotated_artifact(artifact_id, revision_id)` - Create annotated version
- `complete_review(review_id, overall_comment)` - Mark review as completed

### Session Management
- `create_session(title, session_id)` - Create session with optional custom ID
- `get_session(session_id)` - Get session details and contents
- `list_sessions(status, limit)` - List recent sessions (filter by 'active'/'archived')
- `update_session(session_id, title, status)` - Update session metadata

### Chat System
- `create_chat_room(name, members, description, session_id, session_title)` - Create chat room
- `send_message(room_id, persona, message, reply_to_id)` - Send message (with @mention support)
- `react_to_message(event_id, persona, emoji)` - Add emoji reaction
- `share_artifact(room_id, persona, artifact_id, revision)` - Share artifact
- `create_todo(room_id, persona, description, assigned_to)` - Create shared todo
- `get_chat_feed(room_id, since, limit)` - Get event stream
- `get_notifications(persona, unread_only)` - Get notifications
- `mark_notification_read(notification_id)` - Mark notification as read

## Data Storage

By default, data is stored in `data/` directory:
- `data/npl-mcp.db` - SQLite database
- `data/artifacts/` - Artifact files organized by artifact/revision
- `data/chats/` - Chat-related data
- `data/.npl-mcp.pid` - Server PID file (for singleton mode)

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `NPL_MCP_DATA_DIR` | `./data` | Directory for database and artifact storage |
| `NPL_MCP_HOST` | `127.0.0.1` | HTTP server bind host |
| `NPL_MCP_PORT` | `8765` | HTTP server port (unified/launcher modes) |
| `NPL_MCP_WEB_PORT` | `8765` | Web UI port (combined mode) |
| `NPL_MCP_SINGLETON` | `false` | Enable singleton server mode |
| `NPL_MCP_FORCE` | `false` | Force restart if server already running |

## Claude Code Configuration

### Option 1: stdio mode (Recommended for single-user)

Add to your `~/.claude/settings.json` (or project `.claude/settings.json`):

```json
{
  "mcpServers": {
    "npl-mcp": {
      "command": "uv",
      "args": ["run", "--directory", "/path/to/npl/mcp-server", "npl-mcp"],
      "env": {
        "NPL_MCP_DATA_DIR": "/path/to/data"
      }
    }
  }
}
```

Or using the installed command directly:

```json
{
  "mcpServers": {
    "npl-mcp": {
      "command": "npl-mcp"
    }
  }
}
```

### Option 2: HTTP mode (Recommended for Web UI access)

First start the server:
```bash
npl-mcp-launcher
```

Then configure Claude Code with URL endpoint:

```json
{
  "mcpServers": {
    "npl-mcp": {
      "url": "http://127.0.0.1:8765/mcp"
    }
  }
}
```

This mode provides:
- MCP tools via HTTP/SSE transport
- Web UI at `http://127.0.0.1:8765/`
- Session and chat room browsing
- Artifact viewing

After configuration, restart Claude Code. Tools will appear with `mcp__npl-mcp__` prefix.

## Web UI Routes

When running in HTTP mode (`npl-mcp-unified` or `npl-mcp-launcher`):

| Route | Description |
|-------|-------------|
| `/` | Index page with sessions and chat rooms |
| `/session/{session_id}` | Session detail view |
| `/session/{session_id}/room/{room_id}` | Chat room in session context |
| `/room/{room_id}` | Standalone chat room view |
| `/artifact/{artifact_id}` | Artifact viewer |

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/sessions` | GET | List all sessions |
| `/api/session/{id}` | GET | Get session details |
| `/api/room/{id}/feed` | GET | Get chat room feed |
| `/api/artifact/{id}` | GET | Get artifact details |
| `/mcp` | POST/SSE | MCP protocol endpoint |
