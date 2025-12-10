# PRD: MCP-Based Persona Testing

**Status**: Draft
**Created**: 2025-12-10
**Author**: Claude Code

---

## Objective

Validate persona behavior through the **MCP server** infrastructure:
1. Chat rooms with persona members
2. Multi-reviewer artifacts with independent persona reviews
3. Notification system for @mentions and task assignments
4. Persona isolation - each persona operates independently

---

## MCP Server Architecture

Location: `mcp-server/`

| Component | Purpose |
|-----------|---------|
| `ChatManager` | Multi-room persona collaboration |
| `ReviewManager` | Collaborative artifact reviews |
| `ArtifactManager` | Version-controlled artifacts |
| SQLite DB | Persistent state (chat_events, notifications, reviews) |

---

## Test Scenarios

### 1. Multi-Persona Chat Room

```python
# Create room with multiple personas
room = await create_chat_room(
    name="architecture-discussion",
    members=["alice-architect", "bob-backend", "charlie-security"],
    description="Architecture review discussion"
)

# Send message with @mention
await send_message(
    room_id=room["room_id"],
    persona="alice-architect",
    message="Hey @bob-backend, can you review the API design?"
)

# Verify bob received notification
notifications = await get_notifications(persona="bob-backend", unread_only=True)
# Should show mention from alice
```

### 2. Multi-Reviewer Artifact Review (Persona Isolation)

```python
# Create artifact
artifact = await create_artifact(
    name="api-design",
    artifact_type="document",
    file_content=b"# API Design\n...",
    filename="api-design.md",
    created_by="alice-architect"
)

# Each persona creates INDEPENDENT review
alice_review = await create_review(artifact_id=1, revision_id=1, reviewer_persona="alice-architect")
bob_review = await create_review(artifact_id=1, revision_id=1, reviewer_persona="bob-backend")
charlie_review = await create_review(artifact_id=1, revision_id=1, reviewer_persona="charlie-security")

# Each persona adds their own comments
await add_inline_comment(review_id=alice_review["review_id"], location="line:5", comment="Consider caching", persona="alice-architect")
await add_inline_comment(review_id=bob_review["review_id"], location="line:5", comment="Need rate limiting", persona="bob-backend")
await add_inline_comment(review_id=charlie_review["review_id"], location="line:5", comment="Security concern here", persona="charlie-security")

# Aggregate all reviews
annotated = await generate_annotated_artifact(artifact_id=1, revision_id=1)
# Result: reviewer_files with separate sections per persona
```

### 3. Notification & Event Stream

```python
# Share artifact in chat
await share_artifact(
    room_id=room["room_id"],
    persona="alice-architect",
    artifact_id=1,
    revision=0
)

# All other members should be notified
bob_notifications = await get_notifications(persona="bob-backend")
charlie_notifications = await get_notifications(persona="charlie-security")
# Both should have artifact_share notification
```

### 4. Todo Assignment Between Personas

```python
# Alice assigns task to Bob
await create_todo(
    room_id=room["room_id"],
    persona="alice-architect",
    description="Review the authentication flow",
    assigned_to="bob-backend"
)

# Bob should see notification
bob_notifications = await get_notifications(persona="bob-backend")
# Should include todo assignment
```

---

## Test Execution Steps

### Step 1: Run Existing Tests (Baseline)
```bash
cd mcp-server
uv run pytest tests/ -v
# Should pass 22 tests
```

### Step 2: Manual MCP Testing
Use MCP client (or direct Python) to:
1. Create chat room with personas
2. Send messages, verify notifications
3. Create artifact, have multiple personas review
4. Verify each persona's state is isolated

---

## Key MCP Tools

| Tool | Purpose |
|------|---------|
| `create_chat_room(name, members, description)` | Set up persona collaboration |
| `send_message(room_id, persona, message)` | Persona sends message |
| `get_notifications(persona, unread_only)` | Check what persona sees |
| `create_review(artifact_id, revision_id, reviewer_persona)` | Persona starts review |
| `add_inline_comment(review_id, location, comment, persona)` | Persona adds feedback |
| `generate_annotated_artifact(artifact_id, revision_id)` | Aggregate all persona reviews |

---

## Files Involved

| File | Purpose |
|------|---------|
| `mcp-server/src/npl_mcp/server.py` | MCP server entry point |
| `mcp-server/src/npl_mcp/chat/rooms.py` | ChatManager implementation |
| `mcp-server/src/npl_mcp/artifacts/reviews.py` | ReviewManager implementation |
| `mcp-server/tests/test_basic.py` | Existing tests (22 passing) |
| `mcp-server/tests/test_additional.py` | Extended tests |

---

## Success Criteria

1. MCP server starts without errors
2. Existing 22 tests pass
3. Chat rooms support multiple persona members
4. Each persona receives independent notifications
5. Multi-reviewer artifacts aggregate correctly
6. Personas maintain isolated review state
