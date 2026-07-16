# Polymorphic Link Panel

| Field | Value |
|-------|-------|
| **ID** | `polymorphic-link-panel` |
| **Category** | Domain-Specific |
| **Used In** | 19-project-detail, 21-session-detail, 26-ticket-detail |

## Description

A cross-entity summary/links panel that points at heterogeneous entity types from a single owning record — a session's linked rooms/tickets/artifacts, a project's scoped sessions/tickets, or a ticket's blocks/relates-to links plus links to non-ticket entities (wiki pages, artifacts, reviews). The ticket variant additionally degrades gracefully with an orphaned-link placeholder when a linked target is later deleted, rather than erroring.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Linked-entity counts with shortcuts (project/session summary) |
| **Expanded** | Full link list across entity types, with add-link and orphaned-link placeholder states |

## Props / Configuration

- `links` — heterogeneous entity references (type + id + display label)
- `linkableTypes` — which entity types can be linked from this owner
- `orphanPlaceholder` — rendered in place of a link whose target no longer exists

## Interactions

- User clicks a linked entry → routes to that entity's own detail screen, regardless of type
- User adds a new link (e.g. "link user story," blocks/relates-to) → it appears in the panel immediately
- If a linked target is later deleted, the panel shows the orphaned-link placeholder in its place instead of erroring
