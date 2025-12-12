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
playwright install chromium  # For browser/screenshot features
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

The server runs as an HTTP service with a web UI. Use the launcher to manage it:

```bash
# Start server (or confirm already running)
npl-mcp-launcher

# Check status
npl-mcp-launcher --status

# Stop server
npl-mcp-launcher --stop

# Force restart
NPL_MCP_FORCE=true npl-mcp-launcher

# Show Claude Code config snippet
npl-mcp-launcher --config
```

Default endpoints:
- **Web UI**: http://127.0.0.1:8765/
- **MCP**: http://127.0.0.1:8765/mcp

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

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `NPL_MCP_HOST` | `127.0.0.1` | Server bind address |
| `NPL_MCP_PORT` | `8765` | Server port |
| `NPL_MCP_DATA_DIR` | `./data` | Data directory path |
| `NPL_MCP_FORCE` | `false` | Force restart on launch |

## Claude Code Configuration

### Option 1: stdio mode (Recommended for single-user)

1. Start the server: `npl-mcp-launcher`

2. Add to your `~/.claude/settings.json` (or project `.claude/settings.json`):

```json
{
  "mcpServers": {
    "npl-mcp": {
      "url": "http://127.0.0.1:8765/mcp"
    }
  }
}
```

3. Restart Claude Code. Tools will appear with `mcp__npl-mcp__` prefix.

### Data Files

- `data/npl-mcp.db` - SQLite database
- `data/artifacts/` - Artifact files by artifact/revision
- `data/server.log` - Server logs
- `data/.npl-mcp.pid` - PID file for running server

## Web UI Routes

| Route | Description |
|-------|-------------|
| `/` | Index page with sessions and chat rooms |
| `/session/{session_id}` | Session detail view |
| `/session/{session_id}/room/{room_id}` | Chat room in session context |
| `/room/{room_id}` | Standalone chat room view |
| `/artifact/{artifact_id}` | Artifact viewer |

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/sessions` | GET | List all sessions |
| `/api/session/{id}` | GET | Get session details |
| `/api/room/{id}/feed` | GET | Get chat room feed |
| `/api/artifact/{id}` | GET | Get artifact details |
| `/mcp` | POST/SSE | MCP protocol endpoint |
