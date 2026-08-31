# 26: CLI Tags

| Field | Value |
|-------|-------|
| ID | SCR-26 |
| Surface | cli-ink |
| Type | settings |
| Category | Admin |
| Route / Entry | interactive router: `tags` |
| Primary Personas | P-005, P-001 |
| User Stories | US-061, US-067 |

## Description
Terminal counterpart to Web Tags Manager (SCR-12): create, rename, recolor, and delete tag metadata from a keyboard-driven list.

## Entry Points
- Router/sidebar navigation

## Key Components
- SelectableList of tag rows with a colored swatch character/indicator
- InputModal — create-name, edit-desc overlays
- ColorPicker (list-select variant) — pick-color overlay
- ConfirmDialog — confirm-delete

## States
- **Loading:** Spinner while tags + usage counts resolve
- **Empty:** "No tags yet" row

## Interactions
Exact key bindings (from `TagsPage.tsx`):
- `n` — create-name overlay
- `e` — edit-desc overlay
- `c` — pick-color overlay
- `d` — confirm-delete overlay

## Navigation
- **From:** router / sidebar
- **To:** n/a (flat list)
