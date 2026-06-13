# Agent Pipes — Inter-Agent Messaging

Agent pipes provide structured pub/sub messaging between agents. Agents push YAML messages with explicit targets (session UUID, agent handle, or group) and pull messages addressed to them. Messages are durably stored in PostgreSQL with upsert semantics.

---

## Overview

```
Agent A                              Agent B
   │                                    │
   │  AgentOutputPipe(agent=A,          │
   │    body=YAML with target=B)        │
   │ ──────────────────────►            │
   │                     npl_agent_pipe_entries
   │                          (PostgreSQL)
   │                                    │
   │            AgentInputPipe(agent=B) │
   │                ◄────────────────── │
   │              dashboard of messages │
```

---

## Database Schema (Changeset 015)

### `npl_agent_groups`

Group registry for broadcast messaging.

| Column | Type | Notes |
|--------|------|-------|
| id | SERIAL | PK |
| group_name | TEXT | UNIQUE |
| group_handle | UUID | UNIQUE, auto-generated |
| description | TEXT | nullable |
| created_at | TIMESTAMPTZ | DEFAULT NOW() |

### `npl_agent_group_members`

Maps agents to groups (by session UUID or handle).

| Column | Type | Notes |
|--------|------|-------|
| id | SERIAL | PK |
| group_id | INT | FK → npl_agent_groups, CASCADE |
| session_id | UUID | nullable, FK → npl_tool_sessions |
| agent_handle | TEXT | nullable |
| created_at | TIMESTAMPTZ | DEFAULT NOW() |

### `npl_agent_pipe_entries`

Core message storage with upsert semantics.

| Column | Type | Notes |
|--------|------|-------|
| id | SERIAL | PK |
| sender_agent_id | UUID | NOT NULL, FK → npl_tool_sessions |
| sender_agent_handle | TEXT | NOT NULL |
| message_name | TEXT | NOT NULL |
| target_agent | UUID | nullable — direct session target |
| target_agent_handle | TEXT | nullable — target by agent name |
| target_group | TEXT | nullable — target by group name |
| target_group_handle | UUID | nullable — target by group UUID |
| body | TEXT | NOT NULL (YAML payload) |
| created_at | TIMESTAMPTZ | DEFAULT NOW() |
| updated_at | TIMESTAMPTZ | DEFAULT NOW() |

**Unique constraint** (functional, with COALESCE for NULLs):
```sql
UNIQUE (sender_agent_id, message_name,
        COALESCE(target_agent::text, ''),
        COALESCE(target_agent_handle, ''),
        COALESCE(target_group, ''),
        COALESCE(target_group_handle::text, ''))
```

This enables **upsert**: re-sending the same (sender, message_name, target) replaces the body and bumps `updated_at`.

---

## Targeting

A message can target agents via four mechanisms:

| Target Field | Type | Use Case |
|--------------|------|----------|
| `target_agent` | UUID | Direct session-to-session (most specific) |
| `target_agent_handle` | TEXT | Target by agent name across all sessions |
| `target_group` | TEXT | Broadcast to named group members |
| `target_group_handle` | UUID | Broadcast to group by UUID |

An agent receives a message if **any** target field matches:
1. `target_agent == agent's session UUID`
2. `target_agent_handle == agent's handle`
3. `target_group` or `target_group_handle` matches any group the agent belongs to

---

## Output Pipe — Pushing Messages

### MCP Tool: `AgentOutputPipe`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `agent` | str | yes | Sender's session UUID (short or full) |
| `body` | str | yes | YAML mapping of message sections |

### YAML Message Format

```yaml
message-name-1:
  target:
    agent: <uuid>              # Direct session target
    agent-handle: <name>       # Target by agent name
    group: <name>              # Target group by name
    group-handle: <uuid>       # Target group by UUID
  data:
    <arbitrary YAML payload>

message-name-2:
  target:
    group: wave-o-agents
  data:
    phase: planning
    progress: 75
```

Each top-level key is a `message_name`. The `target` specifies who receives it. The `data` is serialized to YAML and stored in the `body` column.

### Behavior

- Resolves sender by session UUID
- Parses body as YAML; rejects non-mapping types
- For each section: upserts entry (INSERT ... ON CONFLICT DO UPDATE)
- Returns `{status: "ok", upserted: <count>, sender: "<uuid>"}`

---

## Input Pipe — Pulling Messages

### MCP Tool: `AgentInputPipe`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `agent` | str | yes | Agent's session UUID |
| `since` | str | no | ISO-8601 timestamp — only entries after this time |
| `full` | bool | no | If true, ignore time filter, return all |
| `with_sections` | list[str] | no | Filter to specific message_name values |

### Behavior

1. Resolves agent by session UUID → gets agent handle and project_id
2. Queries group memberships (by session_id or agent_handle)
3. Builds OR conditions matching all target fields
4. Optionally filters by `since` timestamp and `with_sections`
5. Returns dashboard grouped by message_name

### Response Format

```json
{
  "status": "ok",
  "agent": "<encoded-uuid>",
  "agent_handle": "<handle>",
  "groups": ["group-1", "group-2"],
  "entries": 3,
  "dashboard": {
    "orchestration-status": {
      "sender": {"agent_id": "<uuid>", "agent_handle": "coordinator"},
      "updated_at": "2026-04-22T12:00:00Z",
      "data": {"phase": "planning", "progress": 75}
    },
    "code-review": [
      {"sender": {...}, "updated_at": "...", "data": {...}},
      {"sender": {...}, "updated_at": "...", "data": {...}}
    ]
  }
}
```

When multiple messages share the same `message_name`, the dashboard value becomes a list.

---

## REST API

| Method | Path | Body | Description |
|--------|------|------|-------------|
| `POST` | `/api/pipes/output` | `{agent, body}` | Push messages |
| `POST` | `/api/pipes/input` | `{agent, since?, full?, with_sections?}` | Pull messages |

---

## Key Properties

- **Durable**: Messages persist in PostgreSQL, survive restarts
- **Upsert**: Same (sender, message_name, target) replaces previous body
- **Time-filterable**: Input pipe supports `since` for incremental polling
- **Group-aware**: Dynamic group membership via session UUID or agent handle
- **YAML-structured**: Arbitrary nested payloads
- **No acknowledgment**: Messages remain until overwritten; reads are non-destructive
- **UUID flexibility**: Both shortuuid and standard UUID formats accepted
