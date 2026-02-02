# PRD-009: MCP Tools Implementation

**Version**: 1.0
**Status**: Draft
**Owner**: NPL Framework Team
**Last Updated**: 2026-02-02

---

## Executive Summary

The NPL MCP server architecture documents 23 tools across 4 functional domains, but only 2 tools are currently implemented (init-project, hello-world), representing a 91% implementation gap. This PRD defines the complete implementation of all MCP tools required for artifact management, chat room collaboration, task queue coordination, and browser automation workflows.

**Current State**:
- 23 tools documented in architecture
- 2 tools implemented (init-project family)
- 21 tools pending implementation (91% gap)

**Target State**:
- Full implementation of all 23 documented tools
- SQLite-backed persistence for all domain managers
- Comprehensive test coverage for each tool

---

## Problem Statement

The NPL framework requires runtime artifact management, collaborative workflows, and browser automation capabilities exposed through the MCP server. Without these tools, Claude Code sessions cannot:

1. Create and version artifacts with inline code reviews
2. Collaborate through persistent chat rooms with reactions and todos
3. Manage task queues with complexity scoring and artifact linking
4. Automate browser interactions for screenshot comparison and form testing

The gap between documented architecture and implementation blocks all user stories requiring MCP tool integration.

---

## User Stories

**Artifact Management**: US-008-030
**Chat Room Collaboration**: US-031-045
**Task Queue Management**: US-046-060
**Browser Automation**: US-061-077
**Cross-Domain Integration**: US-078-083

---

## Functional Requirements

### 1. Artifact Management Tools (6 tools)

#### 1.1 create_artifact
**Purpose**: Create a new versioned artifact with metadata
**Parameters**:
- `name` (required): Artifact identifier
- `artifact_type` (required): Type classification (code, document, config, schema)
- `content` (required): Initial content blob
- `metadata` (optional): JSON metadata object

**Returns**: `ArtifactRecord` with id, version, created_at

**Behavior**:
- Validates artifact name uniqueness within project scope
- Creates initial version (v1) in SQLite artifacts table
- Stores content blob with compression for large files
- Triggers notification event for artifact watchers

#### 1.2 version_artifact
**Purpose**: Create a new version of an existing artifact
**Parameters**:
- `artifact_id` (required): Existing artifact identifier
- `content` (required): Updated content blob
- `change_summary` (optional): Description of changes

**Returns**: `VersionRecord` with version number, diff stats, previous_version_id

**Behavior**:
- Validates artifact exists and is not locked
- Increments version counter atomically
- Stores diff metadata for efficient comparison
- Maintains full content for each version (no delta encoding)

#### 1.3 create_review
**Purpose**: Initiate a code review on an artifact version
**Parameters**:
- `artifact_id` (required): Target artifact
- `version` (optional): Specific version (default: latest)
- `reviewers` (optional): List of reviewer identifiers

**Returns**: `ReviewRecord` with review_id, status, created_at

**Behavior**:
- Creates review record in pending state
- Associates review with specific artifact version
- Notifies designated reviewers
- Blocks artifact modification during active review (configurable)

#### 1.4 add_inline_comment
**Purpose**: Add a line-specific comment during review
**Parameters**:
- `review_id` (required): Active review identifier
- `line_start` (required): Starting line number
- `line_end` (optional): Ending line number (default: same as start)
- `comment` (required): Comment text with markdown support
- `severity` (optional): comment | suggestion | issue | blocker

**Returns**: `CommentRecord` with comment_id, position, severity

**Behavior**:
- Validates review exists and is not completed
- Stores line range and comment content
- Supports threaded replies via parent_comment_id
- Tracks resolution status per comment

#### 1.5 complete_review
**Purpose**: Finalize a review with approval or rejection
**Parameters**:
- `review_id` (required): Active review identifier
- `decision` (required): approved | changes_requested | rejected
- `summary` (optional): Review summary text

**Returns**: `ReviewResult` with decision, unresolved_count, completed_at

**Behavior**:
- Validates all blocker-severity comments are resolved (for approval)
- Updates review status to completed
- Unlocks artifact for modification
- Triggers completion notification

#### 1.6 annotate_screenshot
**Purpose**: Add annotations to a captured screenshot artifact
**Parameters**:
- `artifact_id` (required): Screenshot artifact
- `annotations` (required): Array of annotation objects
  - `type`: box | arrow | text | highlight
  - `coordinates`: {x, y, width, height} or {x1, y1, x2, y2}
  - `content`: Annotation text or style properties

**Returns**: `AnnotatedArtifact` with annotation_layer_id

**Behavior**:
- Validates artifact is image type
- Stores annotations as separate layer (non-destructive)
- Supports multiple annotation versions
- Generates preview with annotations composited

---

### 2. Chat Room Tools (7 tools)

#### 2.1 create_chat_room
**Purpose**: Create a persistent chat room for collaboration
**Parameters**:
- `name` (required): Room identifier
- `topic` (optional): Room description/purpose
- `visibility` (optional): public | private | restricted
- `members` (optional): Initial member list

**Returns**: `ChatRoomRecord` with room_id, created_at, invite_code

**Behavior**:
- Validates room name uniqueness
- Creates room with event-sourced message log
- Generates invite code for restricted rooms
- Initializes member roster with creator as admin

#### 2.2 send_message
**Purpose**: Send a message to a chat room
**Parameters**:
- `room_id` (required): Target room
- `content` (required): Message text with markdown support
- `reply_to` (optional): Parent message ID for threading
- `mentions` (optional): List of mentioned member IDs

**Returns**: `MessageRecord` with message_id, timestamp, sequence

**Behavior**:
- Validates sender has room access
- Appends immutable event to room log
- Triggers mention notifications
- Updates room activity timestamp

#### 2.3 react
**Purpose**: Add emoji reaction to a message
**Parameters**:
- `message_id` (required): Target message
- `emoji` (required): Emoji character or shortcode
- `action` (optional): add | remove (default: add)

**Returns**: `ReactionRecord` with reaction_id, emoji, count

**Behavior**:
- Validates message exists and is in accessible room
- Toggles reaction state (add if not present, remove if present)
- Updates reaction counts atomically
- Appends reaction event to room log

#### 2.4 share_artifact
**Purpose**: Share an artifact in a chat room
**Parameters**:
- `room_id` (required): Target room
- `artifact_id` (required): Artifact to share
- `version` (optional): Specific version (default: latest)
- `comment` (optional): Accompanying message

**Returns**: `ShareRecord` with share_id, preview_url

**Behavior**:
- Validates artifact exists and user has access
- Creates artifact share event in room log
- Generates preview/thumbnail for display
- Maintains link to specific version (not auto-updating)

#### 2.5 create_todo
**Purpose**: Create a todo item associated with a room
**Parameters**:
- `room_id` (required): Associated room
- `title` (required): Todo description
- `assignee` (optional): Assigned member
- `due_date` (optional): ISO date string
- `linked_message` (optional): Related message ID

**Returns**: `TodoRecord` with todo_id, status, created_at

**Behavior**:
- Creates todo in pending state
- Associates with room for visibility
- Links to message context if provided
- Notifies assignee if specified

#### 2.6 receive_notifications
**Purpose**: Retrieve pending notifications for current user
**Parameters**:
- `since` (optional): Timestamp cursor for pagination
- `types` (optional): Filter by notification types
- `limit` (optional): Max notifications to return

**Returns**: `NotificationList` with items, next_cursor, unread_count

**Behavior**:
- Retrieves notifications for authenticated user
- Filters by type (mention, reaction, todo, artifact, review)
- Supports cursor-based pagination
- Marks retrieved notifications as read (configurable)

#### 2.7 role_based_access
**Purpose**: Manage room member roles and permissions
**Parameters**:
- `room_id` (required): Target room
- `member_id` (required): Member to modify
- `role` (required): admin | moderator | member | observer
- `action` (optional): grant | revoke (default: grant)

**Returns**: `RoleUpdateRecord` with member_id, role, effective_permissions

**Behavior**:
- Validates requester has admin role
- Updates member role in room roster
- Computes effective permissions based on role
- Logs role change event for audit

---

### 3. Task Queue Tools (7 tools)

#### 3.1 create_task
**Purpose**: Create a task in the queue
**Parameters**:
- `title` (required): Task title
- `description` (optional): Detailed description
- `priority` (optional): low | medium | high | critical
- `labels` (optional): Array of label strings
- `parent_task` (optional): Parent task ID for subtasks

**Returns**: `TaskRecord` with task_id, status, created_at

**Behavior**:
- Creates task in backlog status
- Validates parent task exists if specified
- Applies default priority (medium) if not specified
- Triggers queue update notification

#### 3.2 pick_task
**Purpose**: Claim the next available task from queue
**Parameters**:
- `agent_id` (required): Claiming agent identifier
- `filter` (optional): Filter criteria object
  - `labels`: Required labels
  - `priority_min`: Minimum priority
  - `complexity_max`: Maximum complexity score
- `count` (optional): Number of tasks to pick (default: 1)

**Returns**: `TaskAssignment` with task_id, assigned_at, deadline_estimate

**Behavior**:
- Atomically claims task to prevent race conditions
- Applies filter criteria to available tasks
- Updates task status to in_progress
- Records assignment timestamp

#### 3.3 update_status
**Purpose**: Update task status
**Parameters**:
- `task_id` (required): Target task
- `status` (required): backlog | in_progress | review | blocked | completed | cancelled
- `notes` (optional): Status change notes
- `blockers` (optional): Blocking task IDs (for blocked status)

**Returns**: `StatusUpdate` with previous_status, new_status, updated_at

**Behavior**:
- Validates status transition is valid
- Records status history for tracking
- Notifies watchers of status change
- Updates task metrics (time in status)

#### 3.4 assign_task
**Purpose**: Assign task to specific agent
**Parameters**:
- `task_id` (required): Target task
- `assignee_id` (required): Agent identifier
- `force` (optional): Override existing assignment (default: false)

**Returns**: `AssignmentRecord` with previous_assignee, new_assignee, assigned_at

**Behavior**:
- Validates assignee exists and is available
- Updates assignment atomically
- Notifies previous and new assignee
- Records assignment history

#### 3.5 link_artifact
**Purpose**: Link an artifact to a task
**Parameters**:
- `task_id` (required): Target task
- `artifact_id` (required): Artifact to link
- `relationship` (required): input | output | reference | deliverable

**Returns**: `LinkRecord` with link_id, relationship, linked_at

**Behavior**:
- Validates both task and artifact exist
- Creates bidirectional link record
- Updates artifact's task associations
- Tracks relationship type for workflow

#### 3.6 ask_question
**Purpose**: Submit a question about a task
**Parameters**:
- `task_id` (required): Related task
- `question` (required): Question text
- `blocking` (optional): Whether question blocks progress (default: false)
- `notify` (optional): List of member IDs to notify

**Returns**: `QuestionRecord` with question_id, status, asked_at

**Behavior**:
- Creates question in unanswered state
- Links question to task for context
- Optionally blocks task progress until answered
- Notifies specified members or task owner

#### 3.7 assign_complexity
**Purpose**: Score task complexity
**Parameters**:
- `task_id` (required): Target task
- `complexity` (required): Integer 1-13 (Fibonacci-like scale)
- `rationale` (optional): Explanation of scoring
- `factors` (optional): Complexity factor breakdown

**Returns**: `ComplexityRecord` with score, factors, scored_at

**Behavior**:
- Validates complexity is in valid range
- Records scoring rationale for reference
- Updates task estimated effort
- Recalculates queue metrics

---

### 4. Browser Automation Tools (7 tools)

#### 4.1 navigate
**Purpose**: Navigate browser to URL
**Parameters**:
- `session_id` (required): Browser session identifier
- `url` (required): Target URL
- `wait_for` (optional): Element selector to wait for
- `timeout` (optional): Navigation timeout in milliseconds

**Returns**: `NavigationResult` with status, load_time, final_url

**Behavior**:
- Validates URL is in allowed domains
- Performs navigation with timeout handling
- Waits for specified element or networkidle
- Captures final URL after redirects

#### 4.2 screenshot
**Purpose**: Capture browser screenshot
**Parameters**:
- `session_id` (required): Browser session identifier
- `selector` (optional): Element selector for partial capture
- `full_page` (optional): Capture entire scrollable page (default: false)
- `format` (optional): png | jpeg | webp

**Returns**: `ScreenshotArtifact` with artifact_id, dimensions, file_size

**Behavior**:
- Captures viewport or specified element
- Stores as versioned artifact
- Supports full-page scrolling capture
- Compresses based on format selection

#### 4.3 form_fill
**Purpose**: Fill form fields on page
**Parameters**:
- `session_id` (required): Browser session identifier
- `fields` (required): Array of field definitions
  - `selector`: Field selector
  - `value`: Value to enter
  - `type`: text | select | checkbox | radio | file
- `submit` (optional): Submit form after filling (default: false)

**Returns**: `FormResult` with fields_filled, validation_errors, submitted

**Behavior**:
- Validates all selectors exist before filling
- Handles different input types appropriately
- Captures validation errors if present
- Optionally submits form and captures result

#### 4.4 compare_screenshots
**Purpose**: Compare two screenshots for visual differences
**Parameters**:
- `baseline_id` (required): Baseline screenshot artifact ID
- `comparison_id` (required): Comparison screenshot artifact ID
- `threshold` (optional): Difference threshold percentage (default: 0.1)
- `ignore_regions` (optional): Regions to exclude from comparison

**Returns**: `ComparisonResult` with match, diff_percentage, diff_artifact_id

**Behavior**:
- Loads both screenshot artifacts
- Performs pixel-by-pixel comparison
- Generates diff image highlighting changes
- Reports match status based on threshold

#### 4.5 manage_session
**Purpose**: Create, configure, or destroy browser session
**Parameters**:
- `action` (required): create | configure | destroy
- `session_id` (optional): Session ID for configure/destroy
- `config` (optional): Session configuration object
  - `viewport`: {width, height}
  - `user_agent`: Custom user agent string
  - `cookies`: Initial cookies array
  - `headers`: Custom headers object

**Returns**: `SessionRecord` with session_id, status, config

**Behavior**:
- Creates isolated browser context for new sessions
- Applies configuration to existing sessions
- Cleans up resources on destroy
- Enforces session timeout limits

#### 4.6 inject_scripts
**Purpose**: Inject JavaScript into page context
**Parameters**:
- `session_id` (required): Browser session identifier
- `script` (required): JavaScript code to inject
- `context` (optional): isolated | page (default: isolated)
- `await_promise` (optional): Wait for promise resolution (default: true)

**Returns**: `ScriptResult` with result, logs, errors

**Behavior**:
- Injects script in specified context
- Captures console output during execution
- Returns script result or error
- Supports async script execution

#### 4.7 timeout_retry
**Purpose**: Execute action with timeout and retry logic
**Parameters**:
- `session_id` (required): Browser session identifier
- `action` (required): Action specification object
- `timeout` (required): Action timeout in milliseconds
- `retries` (optional): Retry count (default: 3)
- `backoff` (optional): Exponential backoff factor (default: 2)

**Returns**: `RetryResult` with success, attempts, final_result

**Behavior**:
- Wraps action with timeout enforcement
- Implements exponential backoff between retries
- Captures all attempt results for debugging
- Returns final result or last error

---

## Technical Architecture

### Manager Pattern

Each tool domain is implemented via a dedicated manager class:

```
ArtifactManager
├── create_artifact()
├── version_artifact()
├── create_review()
├── add_inline_comment()
├── complete_review()
└── annotate_screenshot()

ChatManager
├── create_chat_room()
├── send_message()
├── react()
├── share_artifact()
├── create_todo()
├── receive_notifications()
└── role_based_access()

TaskManager
├── create_task()
├── pick_task()
├── update_status()
├── assign_task()
├── link_artifact()
├── ask_question()
└── assign_complexity()

BrowserManager
├── navigate()
├── screenshot()
├── form_fill()
├── compare_screenshots()
├── manage_session()
├── inject_scripts()
└── timeout_retry()
```

### FastMCP Integration

All managers are initialized via FastMCP lifespan hooks and registered as tools:

```python
@mcp.tool()
async def create_artifact(
    name: str,
    artifact_type: Literal["code", "document", "config", "schema"],
    content: str,
    metadata: dict | None = None,
    ctx: Context
) -> ArtifactRecord:
    return await ctx.artifact_manager.create(name, artifact_type, content, metadata)
```

---

## Database Schema

### artifacts.db

```sql
CREATE TABLE artifacts (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    artifact_type TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    locked_by TEXT,
    metadata JSON
);

CREATE TABLE artifact_versions (
    id TEXT PRIMARY KEY,
    artifact_id TEXT REFERENCES artifacts(id),
    version INTEGER NOT NULL,
    content BLOB NOT NULL,
    change_summary TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(artifact_id, version)
);

CREATE TABLE reviews (
    id TEXT PRIMARY KEY,
    artifact_id TEXT REFERENCES artifacts(id),
    version INTEGER NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    decision TEXT,
    summary TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

CREATE TABLE inline_comments (
    id TEXT PRIMARY KEY,
    review_id TEXT REFERENCES reviews(id),
    line_start INTEGER NOT NULL,
    line_end INTEGER NOT NULL,
    comment TEXT NOT NULL,
    severity TEXT DEFAULT 'comment',
    parent_id TEXT REFERENCES inline_comments(id),
    resolved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### chat.db

```sql
CREATE TABLE chat_rooms (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    topic TEXT,
    visibility TEXT DEFAULT 'public',
    invite_code TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE chat_events (
    id TEXT PRIMARY KEY,
    room_id TEXT REFERENCES chat_rooms(id),
    event_type TEXT NOT NULL,
    payload JSON NOT NULL,
    sequence INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE room_members (
    room_id TEXT REFERENCES chat_rooms(id),
    member_id TEXT NOT NULL,
    role TEXT DEFAULT 'member',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (room_id, member_id)
);

CREATE TABLE todos (
    id TEXT PRIMARY KEY,
    room_id TEXT REFERENCES chat_rooms(id),
    title TEXT NOT NULL,
    assignee TEXT,
    due_date DATE,
    linked_message TEXT,
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### tasks.db

```sql
CREATE TABLE tasks (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'backlog',
    priority TEXT DEFAULT 'medium',
    complexity INTEGER,
    parent_id TEXT REFERENCES tasks(id),
    assignee TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE task_labels (
    task_id TEXT REFERENCES tasks(id),
    label TEXT NOT NULL,
    PRIMARY KEY (task_id, label)
);

CREATE TABLE task_artifacts (
    task_id TEXT REFERENCES tasks(id),
    artifact_id TEXT NOT NULL,
    relationship TEXT NOT NULL,
    linked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (task_id, artifact_id)
);

CREATE TABLE task_questions (
    id TEXT PRIMARY KEY,
    task_id TEXT REFERENCES tasks(id),
    question TEXT NOT NULL,
    blocking BOOLEAN DEFAULT FALSE,
    answer TEXT,
    status TEXT DEFAULT 'unanswered',
    asked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    answered_at TIMESTAMP
);
```

---

## Success Criteria

1. **Tool Coverage**: All 23 documented tools implemented and registered
2. **Test Coverage**: >90% coverage for all manager classes
3. **Performance**: Tool response time <500ms for standard operations
4. **Persistence**: All state survives server restart
5. **Concurrency**: Race conditions prevented for atomic operations
6. **Error Handling**: Graceful failures with actionable error messages

---

## Testing Strategy

### Unit Tests
- Manager method isolation with mocked dependencies
- Schema validation for all input/output types
- Edge case coverage (empty inputs, large payloads, unicode)

### Integration Tests
- Database operations with real SQLite
- Cross-manager operations (artifact linking to tasks)
- Event propagation through chat rooms

### E2E Tests
- Full MCP tool invocation via STDIO transport
- Multi-step workflows (create artifact -> review -> approve)
- Browser automation with headless Chromium

---

## Legacy Reference

- **Architecture**: `.tmp/docs/PROJECT-ARCH.brief.md`
- **FastMCP Integration**: `.tmp/docs/fastmcp/summary.brief.md`
- **Tool Categories**: `.tmp/docs/fastmcp/03-tools.brief.md`
