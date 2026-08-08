# Create Entity Button

| Field | Value |
|-------|-------|
| **ID** | `create-entity-button` |
| **Category** | Input & Forms |
| **Used In** | 06-organization-picker, 18-projects-list, 20-sessions-list, 22-chat-room-list, 25-tickets-list, 29-reviews-list, 31-artifacts-list, 37-github-repos-list, 38-github-repo-detail-prs, 41-mock-mcp-llm-pool |

## Description

The standard primary-action button that opens an entity's creation flow — an inline form, a modal, or an OAuth/connection handoff — from any list screen. The single most-repeated interactive element across the product's list surfaces.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Icon-only button for tight toolbars |
| **Compact** | Labeled button ("Create Ticket", "Connect Repository", "Add Model") |

## Props / Configuration

- `label` — action label, entity-specific ("Create Session", "Create Room", "Connect Repository"...)
- `flow` — `inline-form` \| `modal` \| `oauth-handoff`
- `scopePicker` — whether a scope/context picker (org/project/session) precedes the creation form
- `onCreated` — callback/navigation once the new entity exists

## Interactions

- User clicks the button → the configured `flow` launches (inline form expands, modal opens, or an external OAuth flow starts)
- If `scopePicker` is set, the user resolves scope (e.g. org/project) before the entity form appears
- On success, the new entity appears in the bound list and, for detail-oriented flows, the user is routed directly into it
