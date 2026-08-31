# 25: CLI Prompts

| Field | Value |
|-------|-------|
| ID | SCR-25 |
| Surface | cli-ink |
| Type | primary |
| Category | Core |
| Route / Entry | interactive router: `prompts` |
| Primary Personas | P-002, P-004 |
| User Stories | US-048 |

## Description
Terminal counterpart to Web Prompts Library (SCR-11): filter, create, edit, tag, copy, and delete saved prompt snippets from the keyboard.

## Entry Points
- Router/sidebar navigation

## Key Components
- SelectableList of PromptCard-equivalent rows (title, role, tag chips, truncated content)
- InputModal — filter, create-title, edit-title, add-tag overlays
- ConfirmDialog — confirm-delete

## States
- **Loading:** Spinner while prompt list resolves
- **Empty:** "No saved prompts" row
- **Filter mode:** live-narrows the list as text is typed

## Interactions
Exact key bindings (from `PromptsPage.tsx`):
- `/` — filter mode
- `n` — create-title overlay (new prompt)
- `e` — edit-title overlay
- `t` — add-tag overlay
- `d` — confirm-delete overlay
- `c` — copy focused prompt's content to clipboard

## Navigation
- **From:** router / sidebar
- **To:** n/a (flat list, no drill-down page)
