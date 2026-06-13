# Ticket Domain

**Subdomain:** `tickets.tobor.locker`
**Renamed from:** Tasks

Tickets are typed work items (story, bug, epic, task, or custom types). They support custom field definitions, inter-ticket links, queues, watchers, comments, and attachments via cross-cutting patterns.

## Methods

| Method | Visibility | Description |
|--------|-----------|-------------|
| `Ticket.Overview` | visible | List ticket tools and available ticket types |
| `Ticket.Create` | hidden | Create a ticket with typed fields |
| `Ticket.Get` | hidden | Fetch ticket by ID with fields, links, attachments |
| `Ticket.Update` | hidden | Update ticket fields |
| `Ticket.List` | hidden | List tickets with filters |
| `Ticket.Comment` | hidden | Add a comment (cross-cutting) |
| `Ticket.Watch` | hidden | Subscribe to change notifications (cross-cutting) |
| `Ticket.Attach` | hidden | Attach artifact, URL, or git branch (cross-cutting) |
| `Ticket.Feed` | hidden | Activity feed for a ticket |
| `Ticket.Link` | hidden | Link two tickets |
| `Ticket.Unlink` | hidden | Remove a ticket link |
| `Ticket.Queue.Create` | hidden | Create a ticket queue |
| `Ticket.Queue.Get` | hidden | Get queue with status counts |
| `Ticket.Queue.List` | hidden | List ticket queues |
| `Ticket.Queue.Feed` | hidden | Queue activity feed |
| `Ticket.Definition.Create` | hidden | Define a ticket type |
| `Ticket.Definition.Get` | hidden | Get ticket type definition |
| `Ticket.Definition.Update` | hidden | Update ticket type definition |
| `Ticket.Definition.Delete` | hidden | Soft-delete ticket type definition |
| `Ticket.Field.Definition.Create` | hidden | Define a custom field |
| `Ticket.Field.Definition.Update` | hidden | Update custom field definition |
| `Ticket.Field.Definition.Delete` | hidden | Soft-delete custom field definition |

---

## Core CRUD

### Ticket.Overview

Returns a list of all ticket tools with descriptions, and the available ticket types (story, bug, epic, task, plus any custom types).

**Parameters:** None

---

### Ticket.Create

Create a new ticket. The `ticket_type` determines which fields are expected. Custom fields are passed as a JSON object.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `title` | str | yes | Ticket title |
| `description` | str | no | Detailed description (markdown) |
| `ticket_type` | str | no | Type slug: `"story"`, `"bug"`, `"epic"`, `"task"`, or custom (default `"task"`) |
| `status` | str | no | Initial status (default `"open"`) |
| `priority` | str | no | Priority level: `"low"`, `"medium"`, `"high"`, `"critical"` |
| `assignee` | str | no | Persona slug of the assignee |
| `queue_id` | int | no | Ticket queue to add to |
| `parent_id` | int | no | Parent ticket ID (for epic → story hierarchy) |
| `custom_fields` | dict | no | Values for custom field definitions |

**Returns:** Ticket object with `id`, `title`, `ticket_type`, `status`, `created_at`.

**Aliases:** `Tasks.Create`

---

### Ticket.Get

Fetch a ticket by ID including all fields, linked tickets, attachments, and recent comments.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `ticket_id` | int | yes | Ticket ID |

**Aliases:** `Tasks.Get`

---

### Ticket.Update

Update one or more ticket fields. Only provided fields are changed.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `ticket_id` | int | yes | Ticket ID |
| `title` | str | no | New title |
| `description` | str | no | New description |
| `status` | str | no | New status |
| `priority` | str | no | New priority |
| `assignee` | str | no | New assignee persona slug |
| `custom_fields` | dict | no | Updated custom field values (merged with existing) |

**Aliases:** `Tasks.UpdateStatus`

---

### Ticket.List

List tickets with optional filters. Returns paginated results ordered by most recently updated.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `status` | str | no | Filter by status |
| `ticket_type` | str | no | Filter by type slug |
| `queue_id` | int | no | Filter by queue |
| `assignee` | str | no | Filter by assignee |
| `priority` | str | no | Filter by priority |
| `parent_id` | int | no | Filter by parent ticket (children of an epic) |
| `limit` | int | no | Max results (default 50) |
| `offset` | int | no | Pagination offset |

**Aliases:** `Tasks.List`

---

## Cross-Cutting Operations

### Ticket.Comment

Add a comment to a ticket. Uses the generic [Comment](12-cross-cutting.md#comment) pattern with `entity_type="ticket"`.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `ticket_id` | int | yes | Ticket ID |
| `content` | str | yes | Comment body (markdown) |
| `author` | str | yes | Persona slug of commenter |
| `reply_to_id` | int | no | Parent comment ID for threaded replies |

---

### Ticket.Watch

Subscribe a persona to receive notifications on ticket changes. Uses the generic [Watch](12-cross-cutting.md#watch) pattern with `entity_type="ticket"`.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `ticket_id` | int | yes | Ticket ID |
| `persona` | str | yes | Persona slug to subscribe |

---

### Ticket.Attach

Attach an artifact, URL, or git branch reference to a ticket. Uses the generic [Attach](12-cross-cutting.md#attach) pattern with `entity_type="ticket"`.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `ticket_id` | int | yes | Ticket ID |
| `artifact_id` | int | no | Artifact ID to attach |
| `artifact_type` | str | no | Type: `"artifact"`, `"url"`, `"git_branch"`, `"file"` (default `"artifact"`) |
| `url` | str | no | URL if artifact_type is `"url"` |
| `git_branch` | str | no | Branch name if artifact_type is `"git_branch"` |
| `description` | str | no | Description of the attachment |

**Aliases:** `Tasks.AddArtifact`

---

### Ticket.Feed

Get the activity feed for a single ticket — status changes, comments, attachments, link changes.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `ticket_id` | int | yes | Ticket ID |
| `limit` | int | no | Max events (default 50) |

**Aliases:** `Tasks.Feed`

---

## Ticket Links

### Ticket.Link

Create a directional relationship between two tickets.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `source_id` | int | yes | Source ticket ID |
| `target_id` | int | yes | Target ticket ID |
| `link_type` | str | yes | Relationship: `"blocks"`, `"depends_on"`, `"relates_to"`, `"duplicates"` |

---

### Ticket.Unlink

Remove a link between two tickets.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `source_id` | int | yes | Source ticket ID |
| `target_id` | int | yes | Target ticket ID |
| `link_type` | str | yes | Relationship type to remove |

---

## Queue Management

### Ticket.Queue.Create

Create a ticket queue for organizing work items into backlogs, sprints, or categories.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `name` | str | yes | Queue name |
| `description` | str | no | Queue description |

**Aliases:** `TaskQueue.Create`

---

### Ticket.Queue.Get

Get a queue by ID with ticket status counts (open, in_progress, done, etc.).

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `queue_id` | int | yes | Queue ID |

**Aliases:** `TaskQueue.Get`

---

### Ticket.Queue.List

List ticket queues with optional status filter.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `status` | str | no | Filter by queue status |
| `limit` | int | no | Max results (default 50) |

**Aliases:** `TaskQueue.List`

---

### Ticket.Queue.Feed

Get the activity feed for a queue — tickets added, status changes, completions.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `queue_id` | int | yes | Queue ID |
| `limit` | int | no | Max events (default 50) |

**Aliases:** `TaskQueue.Feed`

---

## Type & Field Definitions

### Ticket.Definition.Create

Define a new ticket type with a custom field schema and status workflow.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `slug` | str | yes | Unique type identifier (e.g., `"feature-request"`) |
| `name` | str | yes | Display name |
| `description` | str | no | Type description |
| `icon` | str | no | Emoji or icon identifier |
| `default_fields` | list | no | Ordered list of field definition slugs |
| `status_workflow` | dict | no | Allowed status transitions (JSON) |

---

### Ticket.Definition.Get

Get a ticket type definition by slug.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `slug` | str | yes | Type slug |

---

### Ticket.Definition.Update

Update a ticket type definition.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `slug` | str | yes | Type slug |
| `name` | str | no | New display name |
| `description` | str | no | New description |
| `icon` | str | no | New icon |
| `default_fields` | list | no | Updated field list |
| `status_workflow` | dict | no | Updated status transitions |

---

### Ticket.Definition.Delete

Soft-delete a ticket type definition. Existing tickets of this type are unaffected.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `slug` | str | yes | Type slug |

---

### Ticket.Field.Definition.Create

Define a custom field that can be associated with ticket types.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `slug` | str | yes | Unique field identifier (e.g., `"story_points"`) |
| `name` | str | yes | Display name |
| `field_type` | str | yes | Type: `"text"`, `"number"`, `"select"`, `"date"`, `"persona"` |
| `options` | list | no | Allowed values for `"select"` type |
| `required` | bool | no | Whether field is required (default false) |
| `default_value` | str | no | Default value |

---

### Ticket.Field.Definition.Update

Update a custom field definition.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `slug` | str | yes | Field slug |
| `name` | str | no | New display name |
| `field_type` | str | no | New type |
| `options` | list | no | New options |
| `required` | bool | no | New required flag |
| `default_value` | str | no | New default |

---

### Ticket.Field.Definition.Delete

Soft-delete a custom field definition. Existing field values on tickets are preserved.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `slug` | str | yes | Field slug |
