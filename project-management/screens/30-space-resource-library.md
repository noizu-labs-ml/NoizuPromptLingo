# Space Resource Library

| Field | Value |
|-------|-------|
| **ID** | `space-resource-library` |
| **Type** | Primary |
| **Category** | Resources |
| **User Stories** | US-024 |

## Description

Resource library within a space context. Shows all resources attached to a space with pagination, search, and detach controls for resource owners.

## Key Components

- **Resource List** — Name, description, owner, version, paginated 20/page (US-024)
- **Attach to Space Button** — Resource owner can attach from this view (US-024)
- **Detach Control** — Remove resource from space (US-024)
- **Space Attachments List** — Visible on Resource Detail to all users (US-024)
- **Search/Filter** — Find resources within space

## Interactions

- Browse attached resources; attach/detach resources; click resource → detail

## Navigation

- Accessible from: Space Detail (11)
- Links to: Resource Detail (26)
