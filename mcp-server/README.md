# NPL MCP Server

Comprehensive MCP server for Noizu Prompt Lingo (NPL) providing:

- **Script Tools**: Access to existing NPL scripts (dump-files, git-tree, npl-load)
- **Artifact Management**: Version-controlled artifacts with revision history
- **Review System**: Collaborative reviews with inline comments and image overlays
- **Chat System**: Multi-room persona collaboration with @mentions and notifications

## Installation

```bash
cd mcp-server
uv pip install -e .
```

## Usage

```bash
npl-mcp
```

## MCP Tools

### Script Tools
- `dump_files(path, glob_filter)` - Dump file contents respecting .gitignore
- `git_tree(path)` - Show directory tree
- `git_tree_depth(path)` - Show directories with nesting depth
- `npl_load(type, items, skip)` - Load NPL components/metadata/styles

### Artifact Management
- `create_artifact(name, type, file)` - Create artifact with initial revision
- `add_revision(artifact_id, file, metadata)` - Add new revision
- `get_artifact(artifact_id, revision)` - Retrieve artifact revision
- `list_artifacts()` - List all artifacts
- `get_artifact_history(artifact_id)` - Show revision timeline

### Review System
- `create_review(artifact_id, revision, persona)` - Start review
- `add_inline_comment(review_id, location, comment)` - Add inline comment
- `add_overlay_annotation(review_id, x, y, comment)` - Add image annotation
- `get_review(review_id)` - Get full review
- `generate_annotated_artifact(artifact_id, revision)` - Create annotated version

### Chat System
- `create_chat_room(name, members)` - Create chat room
- `send_message(room_id, persona, message)` - Send message (with @mention support)
- `react_to_message(event_id, persona, emoji)` - Add emoji reaction
- `share_artifact(room_id, persona, artifact_id, revision)` - Share artifact
- `create_todo(room_id, persona, description)` - Create shared todo
- `get_chat_feed(room_id, since, limit)` - Get event stream
- `get_notifications(persona, unread_only)` - Get notifications
- `mark_notification_read(notification_id)` - Mark notification as read

## Data Storage

By default, data is stored in `data/` directory:
- `data/npl-mcp.db` - SQLite database
- `data/artifacts/` - Artifact files organized by artifact/revision
- `data/chats/` - Chat-related data

## Configuration

Set environment variable `NPL_MCP_DATA_DIR` to customize data location.

### Claude Code Setup

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

After configuration, restart Claude Code. Tools will appear with `mcp__npl-mcp__` prefix.
