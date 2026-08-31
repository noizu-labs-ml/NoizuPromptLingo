# MCP Tool Reference

The NPL MCP server exposes **58 MCP-visible tools** and **22 hidden discoverable tools** callable via `ToolCall`. Tools are registered in `src/npl_mcp/launcher.py` using `@mcp_discoverable` (visible) or `register_discoverable()` (hidden).

> **Naming (F5):** canonical tool names use UNDERSCORE separators (`Session_Create`, `Organization_List`). The legacy dotted spelling (`Session.Create`) is accepted as an alias at dispatch, discovery, and `ToolCall`, but is never emitted.

---

## Discovery (5 tools)

| Tool | Parameters | Returns | When to Use |
|------|-----------|---------|-------------|
| **ToolSummary** | `filter?` (category path or `Category#Tool`) | Tool listing grouped by category | Browse catalog structure |
| **ToolSearch** | `query`, `mode?` (text\|intent), `limit?`, `verbose?` | Matching tools with relevance | Find tools by name or semantic intent |
| **ToolDefinition** | `tools` (list of names) | Full parameter definitions | Get complete tool parameter docs |
| **ToolHelp** | `tool`, `task`, `verbose?` (1-3) | LLM-generated usage guidance | Get contextual instructions for a task |
| **ToolCall** | `tool`, `arguments?` | Tool result or status (mcp/stub/error) | Invoke hidden or discoverable tools |

---

## NPL (2 tools)

| Tool | Parameters | Returns | When to Use |
|------|-----------|---------|-------------|
| **NPLSpec** | `components[]`, `rendered[]`, `component_priority?`, `example_priority?`, `extension?`, `concise?`, `xml?` | Full NPL definition block | Generate complete NPL specifications |
| **NPLLoad** | `expression`, `layout?` (yaml_order\|classic\|grouped), `skip?` | Formatted NPL components | Load selective NPL sections via expression DSL |

---

## Tool Sessions (2 tools)

| Tool | Parameters | Returns | When to Use |
|------|-----------|---------|-------------|
| **ToolSession_Generate** | `agent`, `brief`, `task`, `project`, `parent?`, `notes?` | UUID + action (created\|existing) | Create/lookup agent session by (project, agent, task) |
| **ToolSession** | `uuid`, `verbose?` | Session metadata | Retrieve session info by UUID |

---

## Instructions (3 visible + 3 hidden)

| Tool | Tier | Parameters | When to Use |
|------|------|-----------|-------------|
| **Instructions** | Visible | `uuid`, `session`, `version?`, `json?` | Retrieve versioned instruction document |
| **Instructions_Create** | Visible | `title`, `description`, `tags[]`, `body`, `session` | Create new instruction with v1 |
| **Instructions_List** | Visible | `session`, `query?`, `mode?`, `tags?`, `limit?` | Search/list instructions |
| **Instructions_Update** | Hidden | `uuid`, `body`, `change_note?`, `session` | Create new version of instruction |
| **Instructions_ActiveVersion** | Hidden | `uuid`, `version`, `session` | Switch active version |
| **Instructions_Versions** | Hidden | `uuid`, `session` | List version history |

---

## Agents (2 tools)

| Tool | Parameters | Returns | When to Use |
|------|-----------|---------|-------------|
| **Agent_List** | — | Agent metadata list (name, model, description) | List available agent definitions |
| **Agent_Load** | `name` | Full agent spec with markdown body | Load complete agent specification |

---

## Tasks — Flat (4 tools)

| Tool | Parameters | When to Use |
|------|-----------|-------------|
| **Tasks_Create** | `title`, `description?`, `status?`, `priority?`, `assigned_to?`, `notes?` | Create a task |
| **Tasks_Get** | `task_id` | Fetch task by ID |
| **Tasks_List** | `status?`, `assigned_to?`, `limit?` | List tasks with filtering |
| **Tasks_UpdateStatus** | `task_id`, `status`, `notes?` | Update status, append note |

---

## Tasks — Queue Enhanced (10 tools)

| Tool | Parameters | When to Use |
|------|-----------|-------------|
| **TaskQueue_Create** | `name`, `description?`, `session_id?`, `chat_room_id?` | Create named task queue |
| **TaskQueue_Get** | `queue_id` | Get queue with task counts |
| **TaskQueue_List** | `status?`, `limit?` | List queues |
| **TaskQueue_Feed** | `queue_id`, `since?`, `limit?` | Queue activity feed |
| **Tasks_CreateInQueue** | `queue_id`, `title`, `description?`, `status?`, `priority?`, `assigned_to?`, `acceptance_criteria?`, `deadline?`, `complexity?` | Create task in queue |
| **Tasks_AssignComplexity** | `task_id`, `complexity`, `notes?` | Set complexity score |
| **Tasks_AddArtifact** | `task_id`, `artifact_type`, `artifact_id?`, `git_branch?`, `description?` | Link artifact/branch to task |
| **Tasks_ListArtifacts** | `task_id` | List linked artifacts |
| **Tasks_Feed** | `task_id`, `since?`, `limit?` | Task activity feed |

---

## Artifacts (6 tools)

| Tool | Parameters | When to Use |
|------|-----------|-------------|
| **Artifact_Create** | `title`, `content?`, `kind?`, `description?`, `created_by?`, `notes?`, `binary_content_b64?`, `mime_type?` | Create text or binary artifact |
| **Artifact_AddRevision** | `artifact_id`, `content?`, `notes?`, `created_by?`, `binary_content_b64?`, `mime_type?` | Add revision to artifact |
| **Artifact_Get** | `artifact_id`, `revision?` | Fetch artifact with specific revision |
| **Artifact_GetBinary** | `artifact_id`, `revision?` | Get binary content as base64 |
| **Artifact_List** | `kind?`, `limit?` | List artifacts |
| **Artifact_ListRevisions** | `artifact_id` | List revision summaries |

---

## Sessions — Work Sessions (6 tools)

| Tool | Parameters | When to Use |
|------|-----------|-------------|
| **Session_Create** | `title?`, `description?`, `status?`, `created_by?` | Create generic work session |
| **Session_Get** | `session_id` | Fetch session |
| **Session_List** | `status?`, `limit?` | List sessions |
| **Session_Update** | `session_id`, `title?`, `status?`, `description?` | Update session metadata |
| **Session_Contents** | `session_id` | Get aggregated chat rooms + artifacts |
| **Session_Archive** | `session_id` | Archive a session |

---

## Pipes (2 tools)

| Tool | Parameters | When to Use |
|------|-----------|-------------|
| **AgentOutputPipe** | `agent` (sender UUID), `body` (YAML with target + data) | Push structured messages to agents/groups |
| **AgentInputPipe** | `agent` (UUID), `since?`, `full?`, `with_sections?` | Pull messages addressed to this agent |

→ *See [arch/agent-pipes.md](agent-pipes.md) for message format and targeting details*

---

## Chat (14 tools)

| Tool | Parameters | When to Use |
|------|-----------|-------------|
| **Chat_ListRooms** | `limit?` | List rooms by activity |
| **Chat_CreateRoom** | `name`, `description?` | Create chat room |
| **Chat_GetRoom** | `room_id` | Get room details |
| **Chat_ListMessages** | `room_id`, `limit?`, `before_id?` | List messages (newest first) |
| **Chat_SendMessage** | `room_id`, `content`, `author?` | Post message |
| **Chat_AddMember** | `room_id`, `persona_slug` | Add persona to room |
| **Chat_ListMembers** | `room_id` | List room members |
| **Chat_CreateEvent** | `room_id`, `event_type`, `persona`, `data?` | Create structured event |
| **Chat_ListEvents** | `room_id`, `since?`, `limit?` | List events |
| **Chat_React** | `event_id`, `persona`, `emoji` | React to event |
| **Chat_CreateTodo** | `room_id`, `persona`, `description`, `assigned_to?` | Create todo item |
| **Chat_ShareArtifact** | `room_id`, `persona`, `artifact_id`, `revision?` | Share artifact in room |
| **Chat_Notifications** | `persona`, `unread_only?` | List notifications |
| **Chat_ReadNotification** | `notification_id` | Mark notification read |

---

## Reviews (5 tools)

| Tool | Parameters | When to Use |
|------|-----------|-------------|
| **Review_Create** | `artifact_id`, `revision_id`, `reviewer_persona` | Start review for artifact revision |
| **Review_AddComment** | `review_id`, `location`, `comment`, `persona` | Add inline comment |
| **Review_AddOverlay** | `review_id`, `x`, `y`, `comment`, `persona` | Add coordinate annotation (images) |
| **Review_Get** | `review_id`, `include_comments?` | Fetch review with comments |
| **Review_Complete** | `review_id`, `overall_comment?` | Mark review completed |

---

## Orchestration (1 tool)

| Tool | Parameters | When to Use |
|------|-----------|-------------|
| **Orchestration_Trigger** | `feature_description`, `agent?` (default: npl-tdd-coder) | Queue feature for TDD pipeline |

---

## Skills (2 tools)

| Tool | Parameters | When to Use |
|------|-----------|-------------|
| **Skill_Validate** | `content`, `filename?` | Validate skill file structure |
| **Skill_Evaluate** | `content`, `filename?` | Score skill quality (0.0–1.0) across dimensions |

---

## Executors (9 tools)

| Tool | Parameters | When to Use |
|------|-----------|-------------|
| **Tasker_Spawn** | `task`, `chat_room_id`, `parent_agent_id?`, `patterns?`, `session_id?`, `timeout_minutes?`, `nag_minutes?` | Spawn ephemeral tasker |
| **Tasker_Get** | `tasker_id` | Fetch tasker status |
| **Tasker_List** | `status?`, `session_id?` | List taskers |
| **Tasker_Touch** | `tasker_id` | Reset idle timer |
| **Tasker_Dismiss** | `tasker_id`, `reason?` | Terminate tasker |
| **Tasker_KeepAlive** | `tasker_id` | Respond to nag |
| **Fabric_Apply** | `content`, `pattern`, `model?`, `timeout?` | Apply fabric pattern |
| **Fabric_Analyze** | `content`, `patterns[]`, `combine_results?` | Apply multiple patterns |
| **Fabric_ListPatterns** | — | List available patterns |

---

## Browser (10 visible + 5 hidden)

### Visible

| Tool | Parameters | When to Use |
|------|-----------|-------------|
| **Browser_Capture** | `url`, `viewport?`, `theme?`, `full_page?`, `session_key?` | Screenshot a web page |
| **Browser_Interact.Navigate** | `session_id`, `url` | Navigate browser session |
| **Browser_Interact.Click** | `session_id`, `selector` | Click element |
| **Browser_Interact.Fill** | `session_id`, `selector`, `value` | Fill form field |
| **Browser_Interact.GetState** | `session_id` | Get page state (URL, title, scroll) |
| **Browser_ListSessions** | — | List active browser sessions |
| **Browser_CloseSession** | `session_id` | Close browser session |
| **Browser_Diff** | `baseline_bytes`, `comparison_bytes`, `threshold?` | Compare two screenshots |
| **Browser_Checkpoint** | `name`, `urls[]`, `base_url?`, `viewports?`, `themes?` | Multi-URL visual checkpoint |
| **Browser_CompareCheckpoints** | `baseline_slug`, `comparison_slug`, `threshold?` | Compare checkpoint sets |

### Hidden (via ToolCall)

| Tool | When to Use |
|------|-------------|
| **ToMarkdown** | Convert URL to markdown |
| **Ping** | Check URL connectivity |
| **Download** | Download file from URL |
| **Screenshot** | Take page screenshot (legacy) |
| **Rest** | Make REST API calls |

---

## Project Management (hidden, 10 tools)

All callable via `ToolCall`. Provide DB-backed CRUD for projects, personas, and stories.

| Tool | When to Use |
|------|-------------|
| **Proj_Projects.Create/Get/List** | Project CRUD |
| **Proj_UserPersonas.Create/Get/Update/Delete/List** | Persona CRUD |
| **Proj_UserStories.Create/Get/Update/Delete/List** | Story CRUD |

---

## Utility (hidden, 1 tool)

| Tool | When to Use |
|------|-------------|
| **Secret** | Store/retrieve secrets and environment variables |

---

## Summary

| Category | Visible | Hidden | Total |
|----------|---------|--------|-------|
| Discovery | 5 | 0 | 5 |
| NPL | 2 | 0 | 2 |
| Tool Sessions | 2 | 0 | 2 |
| Instructions | 3 | 3 | 6 |
| Agents | 2 | 0 | 2 |
| Tasks (Flat) | 4 | 0 | 4 |
| Tasks (Queue) | 10 | 0 | 10 |
| Artifacts | 6 | 0 | 6 |
| Sessions | 6 | 0 | 6 |
| Pipes | 2 | 0 | 2 |
| Chat | 14 | 0 | 14 |
| Reviews | 5 | 0 | 5 |
| Orchestration | 1 | 0 | 1 |
| Skills | 2 | 0 | 2 |
| Executors | 9 | 0 | 9 |
| Browser | 10 | 5 | 15 |
| Project Mgmt | 0 | 10 | 10 |
| Utility | 0 | 1 | 1 |
| **Total** | **58** | **22** | **80** |
