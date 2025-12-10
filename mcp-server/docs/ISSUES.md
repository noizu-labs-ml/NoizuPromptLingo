# NPL MCP Server - Testing Issues

Testing performed: 2025-12-10

## Summary

All MCP tools were tested systematically. Core functionality works correctly. Several minor issues and enhancement opportunities identified.

---

## Issues Found

### 1. `git_tree_depth` Tool Returns Empty String

**Severity:** Low
**Location:** `mcp-server/src/npl_mcp/scripts/wrapper.py`

**Description:**
The `git_tree_depth` tool returns an empty result when called:
```python
mcp__npl-mcp__git_tree_depth(path="/Volumes/OSX-Extended/workspace/ai/npl/mcp-server")
# Returns: {"result": ""}
```

**Expected:** Directory listing with depth numbers relative to target path.

---

### 2. `npl_load` Tool Returns Empty for Wildcard Queries

**Severity:** Low
**Location:** `mcp-server/src/npl_mcp/scripts/wrapper.py`

**Description:**
The `npl_load` tool returns empty result for wildcard patterns:
```python
mcp__npl-mcp__npl_load(resource_type="m", items="*")
# Returns: {"result": ""}
```

**Expected:** Should load all metadata files matching the pattern.

---

### 3. Reply Indicator Missing in Chat UI

**Severity:** Low
**Location:** `mcp-server/src/npl_mcp/unified.py:746-751`

**Description:**
Messages that are replies to other messages (`reply_to_id` set) don't show any visual indicator in the web UI. The `reply_to_id` field is available in the event data but not rendered.

**Current Behavior:**
Reply messages appear as regular messages with no context.

**Expected:**
Should show "Replying to [persona]:" or similar indicator with quote of original message.

---

### 4. Artifact Not Linked to Session

**Severity:** Medium
**Location:** `mcp-server/src/npl_mcp/unified.py` and `mcp-server/src/npl_mcp/artifacts/manager.py`

**Description:**
When listing session contents, `artifact_count` is 0 even though artifacts were created and shared in a session chat room:
```json
{"artifact_count": 0}
```

The `create_artifact` MCP tool doesn't accept a `session_id` parameter, so artifacts cannot be associated with sessions.

**Expected:**
- `create_artifact` should accept optional `session_id` parameter
- Artifacts shared in a session's chat room should be linked to that session

---

### 5. Assigned-To Not Shown for Todos

**Severity:** Low
**Location:** `mcp-server/src/npl_mcp/unified.py:752-757`

**Description:**
Todo events have `assigned_to` field in data but it's not displayed in the web UI:
```python
# Todo event data:
{"description": "Review the test document artifact", "assigned_to": "bob", "status": "pending"}
# Rendered as:
"📋 Review the test document artifact"
```

**Expected:**
Should show "📋 Review the test document artifact (assigned to @bob)"

---

### 6. Emoji Reactions Not Grouped

**Severity:** Low
**Location:** `mcp-server/src/npl_mcp/unified.py:758-764`

**Description:**
Each emoji reaction is shown as a separate message entry. Multiple reactions to the same message appear as individual items rather than grouped under the target message.

**Expected:**
Reactions should be visually grouped with their target message, like "alice reacted with 👍 to this message."

---

## Working Features Verified

| Tool | Status | Notes |
|------|--------|-------|
| `create_session` | ✅ Pass | Creates session with ID and URL |
| `get_session` | ✅ Pass | Returns session with contents |
| `list_sessions` | ✅ Pass | Lists with room/artifact counts |
| `update_session` | ✅ Pass | Updates title and status |
| `create_chat_room` | ✅ Pass | Creates room linked to session |
| `send_message` | ✅ Pass | Sends with @mentions and reply_to |
| `react_to_message` | ✅ Pass | Adds emoji reactions |
| `create_todo` | ✅ Pass | Creates todo with assignment |
| `get_chat_feed` | ✅ Pass | Returns all event types |
| `get_notifications` | ✅ Pass | Returns mentions and shares |
| `mark_notification_read` | ✅ Pass | Sets read_at timestamp |
| `create_artifact` | ✅ Pass | Creates with base64 content |
| `add_revision` | ✅ Pass | Adds new revision |
| `get_artifact` | ✅ Pass | Returns content and metadata |
| `list_artifacts` | ✅ Pass | Lists all artifacts |
| `get_artifact_history` | ✅ Pass | Shows revision history |
| `share_artifact` | ✅ Pass | Creates share event |
| `create_review` | ✅ Pass | Starts review session |
| `add_inline_comment` | ✅ Pass | Adds line comments |
| `add_overlay_annotation` | ✅ Pass | Adds position comments |
| `get_review` | ✅ Pass | Returns review with comments |
| `complete_review` | ✅ Pass | Marks complete with comment |
| `generate_annotated_artifact` | ✅ Pass | Generates footnoted version |
| `git_tree` | ✅ Pass | Shows directory tree |
| `dump_files` | ✅ Pass | Dumps file contents |

## Web UI Features Verified

| Feature | Status | Notes |
|---------|--------|-------|
| Landing page | ✅ Pass | Shows sessions list |
| Session detail | ✅ Pass | Shows rooms and artifacts |
| Chat room view | ✅ Pass | Renders messages, joins, shares |
| Send message form | ✅ Pass | Auto-joins room if needed |
| Artifact link in chat | ✅ Pass | Links to /artifact/{id} |
| Artifact detail page | ✅ Pass | Shows content preview |
| Dark theme | ✅ Pass | Consistent styling |

---

## Recommendations

1. **High Priority:** Add `session_id` parameter to `create_artifact` tool
2. **Medium Priority:** Fix `git_tree_depth` script functionality
3. **Low Priority:** Enhance chat UI with reply indicators and grouped reactions
4. **Low Priority:** Show todo assignments in web UI
