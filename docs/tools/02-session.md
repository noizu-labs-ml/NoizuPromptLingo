# Session Domain

**Subdomain:** `sessions.tobor.locker`

Sessions are containers that group related work: chat rooms, artifacts, tickets, and activity. They provide a persistent context boundary for a body of work.

## Methods

| Method | Visibility | Description |
|--------|-----------|-------------|
| `Session.Overview` | visible | List session tools and active session count |
| `Session.Create` | hidden | Create a work session to group rooms, artifacts, tickets |
| `Session.Update` | hidden | Update session title, status, or description |
| `Session.Get` | hidden | Fetch a session by UUID |
| `Session.List` | hidden | List sessions filtered by status |
| `Session.Contents` | hidden | Get aggregated contents (linked rooms, artifacts, tickets) |
| `Session.Archive` | hidden | Archive a session |
| `Session.Activity` | hidden | Activity feed for a session |

---

### Session.Overview

Returns a list of all session tools with descriptions and a count of active sessions. This is the only MCP-visible tool in the Session domain.

**Parameters:** None

---

### Session.Create

Create a new work session. Sessions act as top-level containers that group chat rooms, artifacts, and tickets under a shared context.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `title` | str | yes | Human-readable session title |
| `description` | str | no | Optional longer description of the session's purpose |
| `status` | str | no | Initial status (default `"active"`) |

**Returns:** Session object with `id` (UUID), `title`, `status`, `created_at`.

---

### Session.Update

Update an existing session's metadata.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `session_id` | str | yes | Session UUID |
| `title` | str | no | New title |
| `description` | str | no | New description |
| `status` | str | no | New status |

---

### Session.Get

Fetch a single session by UUID with metadata.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `session_id` | str | yes | Session UUID |

---

### Session.List

List sessions with optional filtering.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `status` | str | no | Filter by status (e.g., `"active"`, `"archived"`) |
| `limit` | int | no | Max results (default 50) |
| `offset` | int | no | Pagination offset |

---

### Session.Contents

Get all items linked to a session: chat rooms, artifacts, and tickets. Provides a unified view of everything in a session.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `session_id` | str | yes | Session UUID |

---

### Session.Archive

Set a session's status to `"archived"`. Archived sessions remain queryable but are hidden from default listings.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `session_id` | str | yes | Session UUID |

---

### Session.Activity

Get the activity feed for a session — a chronological list of events across all linked items.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `session_id` | str | yes | Session UUID |
| `limit` | int | no | Max events to return (default 50) |
| `since` | str | no | ISO8601 timestamp — return events after this time |
