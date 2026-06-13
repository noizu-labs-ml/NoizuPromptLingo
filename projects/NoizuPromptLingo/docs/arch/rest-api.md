# REST API Reference

The NPL MCP server exposes a JSON REST API under `/api/*` via FastAPI. All endpoints are defined in `src/npl_mcp/api/router.py`. The API serves the Next.js frontend and can be used by any HTTP client.

**Authentication**: None currently — all endpoints are open.
**Timestamps**: ISO 8601 UTC (Z suffix).
**UUIDs**: Short-form via shortuuid encoding.
**Errors**: `{"detail": "message"}` with standard HTTP status codes.

---

## Health & Status

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/health/ping` | Liveness probe — returns `{status, ts}` |
| `GET` | `/health` | Full subsystem report: server uptime, database latency, LiteLLM status, catalog counts, frontend build |

---

## Catalog (Tool Discovery)

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/catalog` | List all tools in the unified catalog |
| `GET` | `/catalog/categories` | List categories with tool counts |
| `GET` | `/catalog/search?q=&mode=` | Search tools by text (substring) or intent (LLM) |
| `GET` | `/catalog/tool/{name}` | Get a single tool's full definition |

---

## Sessions (Tool Sessions)

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/sessions` | List sessions — filter by `project`, `agent`, `search`, `limit` |
| `GET` | `/sessions/{uuid}` | Get a single session |
| `GET` | `/sessions/{uuid}/tree` | Recursive child-session tree |
| `GET` | `/sessions/{uuid}/activity` | Activity feed (child sessions + errors) |
| `POST` | `/sessions/{uuid}/notes` | Append a note (substring-deduped) |

---

## Instructions

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/instructions` | List/search — filter by `query`, `mode`, `tags`, `limit` |
| `GET` | `/instructions/{uuid}` | Get instruction with all versions |
| `POST` | `/instructions` | Create instruction with v1 body |

**Body (POST)**: `{title, description?, tags?, body?, session?}`
**Response**: Includes `versions[]` array with `{version, body, change_note, created_at}`.

---

## Projects

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/projects` | List all projects with persona/story counts |
| `GET` | `/projects/{id}` | Get a single project |
| `POST` | `/projects` | Create project — `{name, title?, description?}` |
| `GET` | `/projects/{id}/personas` | List personas for a project |
| `GET` | `/projects/{id}/stories` | List stories — filter by `status`, `priority`, `persona_id` |

---

## Stories

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/stories/{story_id}` | Get a single user story |
| `PATCH` | `/stories/{story_id}` | Partial update — `{status?, priority?, story_points?, tags?, title?}` |

---

## PRDs

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/prds` | List all PRDs from `project-management/PRDs/` (sorted by number) |
| `GET` | `/prds/{prd_id}` | Get PRD detail with FR/AT summaries and full markdown body |
| `GET` | `/prds/{prd_id}/functional-requirements` | Full FR bodies for a PRD |
| `GET` | `/prds/{prd_id}/acceptance-tests` | Full AT bodies for a PRD |

---

## NPL (Noizu Prompt Lingo)

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/npl/coverage` | Coverage report — complete components per section |
| `GET` | `/npl/elements` | Flat list of all NPL components across convention YAMLs |
| `POST` | `/npl/load` | Load components via expression DSL — `{expression, layout?, skip?}` |
| `POST` | `/npl/spec` | Generate NPL definition block — `{components[], concise?, xml?}` |

---

## Documentation

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/docs/schema` | Returns `PROJ-SCHEMA.md` content |
| `GET` | `/docs/arch` | Returns `PROJ-ARCH.md` content |
| `GET` | `/docs/layout` | Returns `PROJ-LAYOUT.md` content |

---

## Project File Explorer

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/project/tree` | Recursive directory listing — `path?` (default `.`), `depth?` (1–6, default 3) |
| `GET` | `/project/file` | File content (max 256 KB) — `path` required. Binary files return `kind: "binary"` |

---

## Errors & Metrics

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/errors` | Recent tool-call errors (newest first) — `limit?` (default 50) |
| `GET` | `/metrics/tool-calls` | 501 — not yet implemented |
| `GET` | `/metrics/llm-calls` | 501 — not yet implemented |

---

## Tasks

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/tasks` | List tasks — filter by `status`, `assigned_to`, `limit` |
| `POST` | `/tasks` | Create task — `{title, description?, status?, priority?, assigned_to?, notes?}` |
| `GET` | `/tasks/{task_id}` | Get a single task |
| `PATCH` | `/tasks/{task_id}/status` | Update status — `{status, notes?}` |
| `PATCH` | `/tasks/{task_id}/complexity` | Assign complexity — `{complexity, notes?}` |
| `POST` | `/tasks/{task_id}/artifacts` | Link artifact/branch to task |
| `GET` | `/tasks/{task_id}/artifacts` | List linked artifacts |
| `GET` | `/tasks/{task_id}/feed` | Activity feed — `since?`, `limit?` |

---

## Task Queues

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/task-queues` | List queues — `status?`, `limit?` |
| `POST` | `/task-queues` | Create queue — `{name, description?, session_id?, chat_room_id?}` |
| `GET` | `/task-queues/{queue_id}` | Get queue with task counts |
| `GET` | `/task-queues/{queue_id}/feed` | Activity feed |
| `POST` | `/task-queues/{queue_id}/tasks` | Create task in queue — `{title, description?, priority?, assigned_to?, acceptance_criteria?, deadline?, complexity?}` |

---

## Work Sessions

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/work-sessions` | List sessions — `status?`, `limit?` |
| `POST` | `/work-sessions` | Create — `{title?, description?, status?, created_by?}` |
| `GET` | `/work-sessions/{session_id}` | Get a single work session |
| `PATCH` | `/work-sessions/{session_id}` | Update — `{title?, status?, description?}` |
| `GET` | `/work-sessions/{session_id}/contents` | Aggregated chat rooms + artifacts |
| `POST` | `/work-sessions/{session_id}/archive` | Archive a session |

---

## Artifacts

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/artifacts` | List — `kind?`, `limit?` |
| `POST` | `/artifacts` | Create — `{title, content, kind?, description?, created_by?, notes?}` |
| `GET` | `/artifacts/{artifact_id}` | Get with optional `revision?` query param |
| `GET` | `/artifacts/{artifact_id}/revisions` | List revision summaries |
| `POST` | `/artifacts/{artifact_id}/revisions` | Add text revision — `{content, notes?, created_by?}` |
| `POST` | `/artifacts/upload` | Create binary artifact (multipart, max 15 MB) |
| `POST` | `/artifacts/{artifact_id}/revisions/upload` | Add binary revision (multipart, max 15 MB) |
| `GET` | `/artifacts/{artifact_id}/revisions/{revision}/raw` | Stream raw binary content |

---

## Reviews

| Method | Path | Purpose |
|--------|------|---------|
| `POST` | `/reviews` | Start review — `{artifact_id, revision_id, reviewer_persona}` |
| `GET` | `/reviews/{review_id}` | Get review with inline comments (`include_comments?`) |
| `POST` | `/reviews/{review_id}/comments` | Add inline comment — `{location, comment, persona}` |
| `POST` | `/reviews/{review_id}/complete` | Complete review — `{overall_comment?}` |

---

## Agent Pipes

| Method | Path | Purpose |
|--------|------|---------|
| `POST` | `/pipes/output` | Push structured YAML to target agents — `{agent, body}` |
| `POST` | `/pipes/input` | Pull messages for an agent — `{agent, since?, full?, with_sections?}` |

---

## Orchestration

| Method | Path | Purpose |
|--------|------|---------|
| `POST` | `/orchestration/trigger` | Queue a pipeline run — `{feature_description, agent?}` (default: `npl-tdd-coder`) |

---

## Agents

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/agents` | List all agent definitions from `agents/*.md` |
| `GET` | `/agents/{name}` | Get agent with full markdown body |

---

## Browser Tools

| Method | Path | Purpose |
|--------|------|---------|
| `POST` | `/browser/to-markdown` | Convert URL/file to markdown — `{source, heading_filter?, collapse_depth?, with_image_descriptions?, bare?}` |

---

## Skills

| Method | Path | Purpose |
|--------|------|---------|
| `POST` | `/skills/validate` | Validate skill file — `{content, filename?}` → `{valid, errors, warnings, summary}` |
| `POST` | `/skills/evaluate` | Quality score — `{content, filename?}` → `{overall_score, dimensions, suggestions}` |

---

## Chat

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/chat/rooms` | List rooms (by recent activity) — `limit?` |
| `POST` | `/chat/rooms` | Create room — `{name, description?}` |
| `GET` | `/chat/rooms/{room_id}` | Get room details |
| `GET` | `/chat/rooms/{room_id}/messages` | List messages (newest first) — `limit?`, `before_id?` |
| `POST` | `/chat/rooms/{room_id}/messages` | Post message — `{content, author?}` |
| `GET` | `/chat/rooms/{room_id}/members` | List room members |
| `POST` | `/chat/rooms/{room_id}/members` | Add member — `{persona_slug}` |
| `GET` | `/chat/rooms/{room_id}/events` | List events — `since?`, `limit?` |
| `POST` | `/chat/rooms/{room_id}/events` | Create event — `{event_type, persona, data?}` |
| `POST` | `/chat/rooms/{room_id}/events/{event_id}/react` | React — `{persona, emoji}` |
| `POST` | `/chat/rooms/{room_id}/todos` | Create todo — `{persona, description, assigned_to?}` |
| `POST` | `/chat/rooms/{room_id}/share-artifact` | Share artifact — `{persona, artifact_id, revision?}` |
| `GET` | `/chat/notifications/{persona}` | Notifications — `unread_only?` |
| `PATCH` | `/chat/notifications/{notification_id}/read` | Mark notification read |

---

## Taskers (Executor)

| Method | Path | Purpose |
|--------|------|---------|
| `POST` | `/taskers` | Spawn tasker — `{task, chat_room_id, parent_agent_id?, patterns?, session_id?, timeout_minutes?, nag_minutes?}` |
| `GET` | `/taskers` | List — `status?`, `session_id?` |
| `GET` | `/taskers/{tasker_id}` | Get tasker |
| `POST` | `/taskers/{tasker_id}/dismiss` | Dismiss — `{reason?}` |
| `POST` | `/taskers/{tasker_id}/keep-alive` | Respond to nag |
| `POST` | `/taskers/{tasker_id}/touch` | Reset idle timer |

---

## Fabric (Content Processing)

| Method | Path | Purpose |
|--------|------|---------|
| `POST` | `/fabric/apply` | Apply pattern to content — `{content, pattern, model?, timeout?}` |
| `POST` | `/fabric/analyze` | Apply multiple patterns — `{content, patterns[], combine_results?}` |
| `GET` | `/fabric/patterns` | List available patterns |

---

## Standard Error Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 400 | Bad request (validation error) |
| 404 | Resource not found |
| 413 | Payload too large (file upload > 15 MB) |
| 500 | Internal server error |
| 501 | Not implemented (stub endpoint) |
| 503 | Database unavailable |

## Database-Backed Endpoints

Most CRUD endpoints require an active asyncpg connection pool. If the database is down, they return 503. File-system endpoints (`/prds`, `/docs/*`, `/npl/*`, `/project/*`, `/agents`) read from disk and work without the database.
