# NPL MCP Server Usage Guide

This guide demonstrates common workflows with the NPL MCP server.

## Installation

```bash
cd mcp-server
uv pip install -e .
```

## Starting the Server

```bash
npl-mcp
```

The server will automatically:
- Initialize the SQLite database at `data/npl-mcp.db`
- Create directory structure for artifacts and chats
- Expose all MCP tools

## Environment Configuration

```bash
# Optional: Set custom data directory
export NPL_MCP_DATA_DIR=/path/to/data
```

## Example Workflows

### 1. Artifact Management Workflow

```python
# Example using MCP client

# Create an artifact
artifact = await create_artifact(
    name="design-mockup-v1",
    artifact_type="image",
    file_content_base64=base64_encoded_image,
    filename="mockup.png",
    created_by="sarah-designer",
    purpose="Initial design concept for dashboard"
)
# Returns: {"artifact_id": 1, "revision_num": 0, ...}

# Add a revision
revision = await add_revision(
    artifact_id=1,
    file_content_base64=base64_encoded_updated_image,
    filename="mockup-v2.png",
    created_by="sarah-designer",
    purpose="Updated colors per feedback",
    notes="Changed primary color to #3498db"
)
# Returns: {"revision_id": 2, "revision_num": 1, ...}

# Get current artifact
current = await get_artifact(artifact_id=1)

# Get specific revision
old_version = await get_artifact(artifact_id=1, revision=0)

# View history
history = await get_artifact_history(artifact_id=1)
# Returns: [
#   {"revision_num": 1, "created_by": "sarah-designer", "purpose": "Updated colors..."},
#   {"revision_num": 0, "created_by": "sarah-designer", "purpose": "Initial design..."}
# ]
```

### 2. Collaborative Review Workflow

```python
# Create a review
review = await create_review(
    artifact_id=1,
    revision_id=2,
    reviewer_persona="mike-developer"
)
# Returns: {"review_id": 1, ...}

# Add inline comments (for text/code files)
comment1 = await add_inline_comment(
    review_id=1,
    location="line:58",
    comment="This section needs refactoring for better readability",
    persona="mike-developer"
)

# Add image annotations (for images)
annotation = await add_overlay_annotation(
    review_id=1,
    x=100,
    y=200,
    comment="Button placement seems off-center here",
    persona="mike-developer"
)

# Get full review
full_review = await get_review(review_id=1)
# Returns: {
#   "review_id": 1,
#   "artifact_name": "design-mockup-v1",
#   "revision_num": 1,
#   "reviewer_persona": "mike-developer",
#   "comments": [
#     {"location": "line:58", "comment": "...", "persona": "mike-developer"},
#     {"location": "@x:100,y:200", "comment": "...", "persona": "mike-developer"}
#   ]
# }

# Generate annotated version with footnotes
annotated = await generate_annotated_artifact(
    artifact_id=1,
    revision_id=2
)
# Returns: {
#   "annotated_content": "...[^mike-developer-1]...",
#   "reviewer_files": {
#     "mike-developer": "# Inline Comments by @mike-developer\n..."
#   }
# }

# Complete review
await complete_review(
    review_id=1,
    overall_comment="Great work! Just minor adjustments needed."
)
```

### 3. Multi-Persona Chat Workflow

```python
# Create a chat room
room = await create_chat_room(
    name="dashboard-redesign",
    members=["sarah-designer", "mike-developer", "alex-pm"],
    description="Discussion for dashboard redesign project"
)
# Returns: {"room_id": 1, "name": "dashboard-redesign", ...}

# Send message with @mention
message = await send_message(
    room_id=1,
    persona="sarah-designer",
    message="Hey @mike-developer, I've uploaded the latest mockup. Can you review it?"
)
# Returns: {
#   "event_id": 1,
#   "mentions": ["mike-developer"],
#   "notifications": [{"notification_id": 1, "persona": "mike-developer"}]
# }

# Mike checks his notifications
notifications = await get_notifications(
    persona="mike-developer",
    unread_only=True
)
# Returns: [
#   {
#     "notification_id": 1,
#     "notification_type": "mention",
#     "event_data": {"message": "Hey @mike-developer, ..."}
#   }
# ]

# Mike shares an artifact in chat
share = await share_artifact(
    room_id=1,
    persona="mike-developer",
    artifact_id=1,
    revision=1
)

# Add emoji reaction
reaction = await react_to_message(
    event_id=1,
    persona="alex-pm",
    emoji="👍"
)

# Create a todo
todo = await create_todo(
    room_id=1,
    persona="alex-pm",
    description="Update API documentation",
    assigned_to="mike-developer"
)

# Get chat feed
feed = await get_chat_feed(
    room_id=1,
    limit=50
)
# Returns: [
#   {"event_type": "persona_join", "persona": "sarah-designer", ...},
#   {"event_type": "message", "persona": "sarah-designer", "data": {...}},
#   {"event_type": "artifact_share", "persona": "mike-developer", ...},
#   {"event_type": "emoji_reaction", "persona": "alex-pm", ...},
#   {"event_type": "todo_create", "persona": "alex-pm", ...}
# ]

# Mark notification as read
await mark_notification_read(notification_id=1)
```

### 4. NPL Script Tools

```python
# Dump files from a directory
files = await dump_files(
    path="./src",
    glob_filter="*.py"
)

# Get directory tree
tree = await git_tree(path=".")

# Get directory depth info
depth = await git_tree_depth(path="./src")

# Load NPL components
npl_syntax = await npl_load(
    resource_type="c",
    items="syntax,agent,formatting",
    skip="syntax"  # Already loaded
)
```

## Multi-Reviewer Scenario

Here's a complete scenario with multiple reviewers:

```python
# 1. Create artifact
artifact = await create_artifact(
    name="Q4-2025-profit-loss-report",
    artifact_type="document",
    file_content_base64=encoded_report,
    filename="q4-report.md",
    created_by="finance-team"
)

# 2. Multiple reviewers create reviews
review_ceo = await create_review(
    artifact_id=artifact["artifact_id"],
    revision_id=artifact["revision_id"],
    reviewer_persona="ceo"
)

review_cfo = await create_review(
    artifact_id=artifact["artifact_id"],
    revision_id=artifact["revision_id"],
    reviewer_persona="cfo"
)

review_editor = await create_review(
    artifact_id=artifact["artifact_id"],
    revision_id=artifact["revision_id"],
    reviewer_persona="copy-editor"
)

# 3. Each reviewer adds comments
await add_inline_comment(
    review_id=review_ceo["review_id"],
    location="line:10",
    comment="Need more detail on market expansion costs",
    persona="ceo"
)

await add_inline_comment(
    review_id=review_cfo["review_id"],
    location="line:25",
    comment="These numbers don't match the spreadsheet. Please verify.",
    persona="cfo"
)

await add_inline_comment(
    review_id=review_editor["review_id"],
    location="line:3",
    comment="Typo: 'proffit' should be 'profit'",
    persona="copy-editor"
)

# 4. Generate annotated version with all comments
annotated = await generate_annotated_artifact(
    artifact_id=artifact["artifact_id"],
    revision_id=artifact["revision_id"]
)

# Result structure:
# {
#   "annotated_content": "...with [^ceo-1], [^cfo-1], [^copy-editor-1] markers",
#   "reviewer_files": {
#     "ceo": "# Inline Comments by @ceo\n[^ceo-1]: line:10: Need more detail...",
#     "cfo": "# Inline Comments by @cfo\n[^cfo-1]: line:25: These numbers...",
#     "copy-editor": "# Inline Comments by @copy-editor\n[^copy-editor-1]: line:3: Typo..."
#   },
#   "total_comments": 3,
#   "reviewers": ["ceo", "cfo", "copy-editor"]
# }
```

## Data Organization

After using the server, your data directory will look like:

```
data/
├── npl-mcp.db                           # SQLite database
├── artifacts/
│   ├── design-mockup-v1/
│   │   ├── revision-0-mockup.png
│   │   ├── revision-0.meta.md
│   │   ├── revision-1-mockup-v2.png
│   │   └── revision-1.meta.md
│   └── Q4-2025-profit-loss-report/
│       ├── revision-0-q4-report.md
│       ├── revision-0.meta.md
│       ├── revision-1-q4-report-updated.md
│       └── revision-1.meta.md
└── chats/
    └── (future: exported chat logs)
```

## Metadata File Format

Each artifact revision has a `.meta.md` file:

```yaml
---
revision: 1
artifact_name: design-mockup-v1
created_by: sarah-designer
created_at: 2025-10-09T14:30:00
purpose: Updated colors per feedback
filename: mockup-v2.png
---

# Notes

Changed primary color to #3498db based on brand guidelines.
Also adjusted button hover states.
```

## Best Practices

1. **Artifact Naming**: Use descriptive, hyphenated names (e.g., `user-dashboard-v2`)
2. **Purpose Fields**: Always provide clear purpose for revisions
3. **Review Comments**: Be specific with locations (`line:58` not just "line 58")
4. **Chat Mentions**: Use @persona-slug format for notifications
5. **Personas**: Use consistent persona slugs across the system
6. **Revisions**: Create new revisions rather than overwriting files
7. **Room Names**: Use descriptive room names that indicate purpose

## Troubleshooting

### Database locked errors
The database uses SQLite with WAL mode. If you get locking errors, ensure no other processes are accessing the database.

### File not found errors
Ensure the data directory exists and has proper permissions:
```bash
chmod -R 755 data/
```

### Module import errors
Reinstall the package:
```bash
uv pip install -e . --force-reinstall
```
