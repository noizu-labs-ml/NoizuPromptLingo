# Cross-Cutting Patterns

Four operations are shared across multiple domains via generic polymorphic handlers. Rather than reimplementing attachment, comment, reaction, and watch logic per domain, each domain's tool delegates to a shared service layer.

This document describes the generic patterns. For domain-specific parameter wrappers, see each domain's doc.

---

## Attach

Attach an artifact, URL, git branch, or file reference to any entity. Each domain provides a convenience wrapper (e.g., `Ticket.Attach`, `Chat.Attach`, `Wiki.Attach`, `Review.Attach`) that sets the `entity_type` automatically.

### Generic Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `entity_type` | str | yes | Target entity type: `"ticket"`, `"review"`, `"chat_event"`, `"wiki_page"` |
| `entity_id` | int | yes | Target entity ID |
| `artifact_id` | int | no | Artifact ID to attach (for `artifact_type="artifact"`) |
| `artifact_type` | str | no | Type: `"artifact"` (default), `"url"`, `"git_branch"`, `"file"` |
| `url` | str | no | URL (when `artifact_type="url"`) |
| `git_branch` | str | no | Branch name (when `artifact_type="git_branch"`) |
| `description` | str | no | Human-readable description of the attachment |
| `created_by` | str | no | Persona slug of the attacher |

### Storage

Polymorphic table `npl_attachments` with composite index on `(entity_type, entity_id)`.

### Domain Usage

| Domain Tool | entity_type | Primary use case |
|-------------|-------------|-----------------|
| `Ticket.Attach` | `"ticket"` | Link artifacts, branches, or URLs to work items |
| `Review.Attach` | `"review"` | Attach supplementary materials to a review |
| `Chat.Attach` | `"chat_event"` | Share an artifact in a chat room |
| `Wiki.Attach` | `"wiki_page"` | Attach files or references to wiki pages |

---

## Comment

Add threaded comments to any entity. Supports inline comments (at a specific location within the entity) and general comments. Each domain provides a convenience wrapper (e.g., `Ticket.Comment`, `Review.Comment`, `Wiki.Comment`).

### Generic Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `entity_type` | str | yes | Target entity type: `"ticket"`, `"review"`, `"wiki_page"` |
| `entity_id` | int | yes | Target entity ID |
| `content` | str | yes | Comment body (markdown) |
| `author` | str | yes | Persona slug of the commenter |
| `location` | str | no | Inline location (line number, section, heading, text selection). Omit for general comment. |
| `reply_to_id` | int | no | Parent comment ID for threaded replies |

### Storage

Polymorphic table `npl_comments` with:
- Composite index on `(entity_type, entity_id, created_at)`
- Self-referencing `reply_to_id` for threading

### Domain Usage

| Domain Tool | entity_type | Supports inline? |
|-------------|-------------|-----------------|
| `Ticket.Comment` | `"ticket"` | No (general comments only) |
| `Review.Comment` | `"review"` | Yes (line numbers, sections, selectors) |
| `Wiki.Comment` | `"wiki_page"` | Yes (headings, line numbers, text selections) |

---

## React

Add emoji reactions to any entity. Reactions are unique per (entity, persona, emoji) — adding the same reaction twice is a no-op. Domains provide convenience wrappers (e.g., `Chat.React`).

### Generic Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `entity_type` | str | yes | Target entity type: `"chat_event"`, `"comment"`, `"ticket"` |
| `entity_id` | int | yes | Target entity ID |
| `persona` | str | yes | Persona slug |
| `emoji` | str | yes | Emoji character or shortcode (e.g., `"thumbsup"`, `"fire"`) |

### Storage

Polymorphic table `npl_reactions` with unique constraint on `(entity_type, entity_id, persona, emoji)`.

### Domain Usage

| Domain Tool | entity_type | Typical targets |
|-------------|-------------|----------------|
| `Chat.React` | `"chat_event"` | Messages, events, shared artifacts |

React is also available generically via `ToolCall` for comments and tickets when direct reaction is needed.

---

## Watch

Subscribe a persona to change notifications on an entity. When the watched entity changes (status update, new comment, etc.), watchers receive notifications. Domains provide convenience wrappers (e.g., `Ticket.Watch`).

### Generic Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `entity_type` | str | yes | Target entity type: `"ticket"`, `"wiki_page"` |
| `entity_id` | int | yes | Target entity ID |
| `persona` | str | yes | Persona slug to subscribe |
| `action` | str | no | `"watch"` (default) or `"unwatch"` |

### Storage

Polymorphic table `npl_watches` with unique constraint on `(entity_type, entity_id, persona)`.

### Domain Usage

| Domain Tool | entity_type | Notification triggers |
|-------------|-------------|----------------------|
| `Ticket.Watch` | `"ticket"` | Status changes, new comments, attachments, link changes |
| *(Wiki.Watch — future)* | `"wiki_page"` | Page edits, new comments |

---

## Implementation Notes

### Service Layer

Each pattern is implemented as a shared module under `src/npl_mcp/crosscutting/`:

```
crosscutting/
├── __init__.py
├── attachments.py    # attach(), list_attachments(), remove_attachment()
├── comments.py       # add_comment(), list_comments(), update_comment()
├── reactions.py      # add_reaction(), remove_reaction(), list_reactions()
└── watches.py        # watch(), unwatch(), list_watchers()
```

Domain tool handlers delegate to these functions:

```python
# Example: Ticket.Attach handler
from npl_mcp.crosscutting.attachments import attach

async def ticket_attach(ticket_id: int, artifact_id: int, ...):
    return await attach(
        entity_type="ticket",
        entity_id=ticket_id,
        artifact_id=artifact_id,
        ...
    )
```

### Migration from Existing Tables

- `npl_task_artifacts` data migrates to `npl_attachments` with `entity_type="ticket"`
- `npl_chat_events` where `event_type="reaction"` migrates to `npl_reactions` with `entity_type="chat_event"`
- Existing `npl_inline_comments` migrates to `npl_comments` with `entity_type="review"`
