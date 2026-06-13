# Create Space

| Field | Value |
|-------|-------|
| **ID** | `create-space` |
| **Type** | Storyboard |
| **Category** | Spaces |
| **User Stories** | US-005, US-090, US-082 |

## Description

Form for creating new spaces. Collects name, description, visibility, and optional tags. Supports team-only private spaces for org members.

## Key Components

- **Space name input** — 3-50 character text field (US-005)
- **Description textarea** — 10-500 character description (US-005)
- **Visibility selector** — Public / Restricted / Private / Org Only dropdown (US-082)
- **Tag/category input** — Autocomplete-powered tag entry (US-005)
- **"Create Space" button** — Submits the form and creates the space (US-005)
- **Inline validation errors** — Real-time field validation messages (US-005)

## Interactions

- Fill form fields (name, description, tags)
- Select visibility level
- Add tags via autocomplete
- Submit to create the space

## Navigation

- Accessible from: Any authenticated page
- Links to: Space Detail (11) after creation
