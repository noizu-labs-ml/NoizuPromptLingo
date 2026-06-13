# Gopher Domain

**Renamed from:** Tasker

Gophers are ephemeral agent instances spawned to handle sub-tasks. They have a managed lifecycle with idle timers, nag/keepalive mechanics, and graceful dismissal. Gophers execute work on behalf of a parent session or orchestration pipeline.

## Methods

| Method | Visibility | Description |
|--------|-----------|-------------|
| `Gopher.Overview` | visible | List gopher tools |
| `Gopher.Spawn` | hidden | Spawn an ephemeral agent for a sub-task |
| `Gopher.Get` | hidden | Get a gopher's current state |
| `Gopher.List` | hidden | List gophers filtered by status/session |
| `Gopher.Queue` | hidden | Queue a task for the next available gopher |
| `Gopher.Dismiss` | hidden | Terminate a gopher |
| `Gopher.Touch` | hidden | Reset a gopher's idle timer |
| `Gopher.KeepAlive` | hidden | Respond to nag by keeping alive |

---

### Gopher.Overview

Returns a list of all gopher tools with descriptions.

**Parameters:** None

---

### Gopher.Spawn

Spawn a new ephemeral agent instance. The gopher runs until dismissed, its task completes, or it times out from idle.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `task` | str | yes | Task description for the gopher |
| `agent` | str | no | Agent definition to use (defaults to general-purpose) |
| `session_id` | str | no | Parent session UUID |
| `timeout` | int | no | Idle timeout in seconds (default 300) |
| `metadata` | dict | no | Additional context to pass to the gopher |

**Returns:** Gopher object with `id`, `status`, `agent`, `created_at`.

**Aliases:** `Tasker.Spawn`

---

### Gopher.Get

Get the current state of a gopher including status, last activity, and output.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `gopher_id` | str | yes | Gopher ID |

**Aliases:** `Tasker.Get`

---

### Gopher.List

List gophers with optional filtering.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `status` | str | no | Filter by status: `"running"`, `"idle"`, `"completed"`, `"dismissed"` |
| `session_id` | str | no | Filter by parent session |
| `limit` | int | no | Max results (default 50) |

**Aliases:** `Tasker.List`

---

### Gopher.Queue

Queue a task to be picked up by the next available gopher. If no gopher is idle, one is spawned automatically.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `task` | str | yes | Task description |
| `agent` | str | no | Preferred agent definition |
| `priority` | str | no | Queue priority: `"low"`, `"normal"` (default), `"high"` |
| `session_id` | str | no | Parent session UUID |

**Returns:** Queue entry with `id`, `status` (`"queued"` or `"assigned"`), `gopher_id` (if assigned).

---

### Gopher.Dismiss

Explicitly terminate a gopher. If the gopher has pending output, it is preserved.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `gopher_id` | str | yes | Gopher ID |
| `reason` | str | no | Reason for dismissal |

**Aliases:** `Tasker.Dismiss`

---

### Gopher.Touch

Reset a gopher's idle timer to prevent timeout. Use when a gopher is actively working but hasn't produced output recently.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `gopher_id` | str | yes | Gopher ID |

**Aliases:** `Tasker.Touch`

---

### Gopher.KeepAlive

Respond to a nag (idle warning) by keeping a gopher alive. This is the response to the gopher lifecycle's idle-check mechanism.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `gopher_id` | str | yes | Gopher ID |
| `reason` | str | no | Why the gopher should stay alive |

**Aliases:** `Tasker.KeepAlive`
