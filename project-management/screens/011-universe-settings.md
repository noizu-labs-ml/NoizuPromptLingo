# Universe Settings

| Field | Value |
|-------|-------|
| **ID** | universe-settings |
| **Type** | Settings |
| **Category** | Universe |
| **User Stories** | US-010, US-013, US-014, US-015, US-019, US-050, US-091, US-092, US-093 |

## Description

Configuration screen for universe properties, collaborators, and sharing.

## Key Components

- **Basic Settings** — Name, description, visibility (private/team/public) (US-010)
- **Genre & Tone Panel** — Genre tags, tone dropdown, style note field (US-015)
- **Style Guide Editor** — Tone descriptor, vocabulary lists, example passages, narrative perspective (US-050)
- **Collaborators Panel** — Invite, list, roles (Viewer/Editor/Co-owner), remove (US-091, US-092)
- **Public Sharing Toggle** — Make public switch with confirmation (US-093)
- **Import Panel** — File upload for Markdown/text/JSON import review (US-019)
- **Danger Zone** — Delete Universe with name confirmation dialog (US-013)
- **Duplicate Button** — Duplicate Universe prompt with new name (US-014)
- **Unsaved Changes Warning** — Confirmation dialog on navigation (US-010)

## Interactions

- Updates reflected in Generation Studio prompts on save
- Breadcrumbs and page titles update on name change
- Import shows review UI before committing
- Delete requires typing exact name for confirmation
- Duplicate shows progress indicator for large universes
- Invites expire after 7 days

## Navigation

- Accessible from: Universe Overview, Canon Editor, Knowledge Graph
- Links to: Universe Overview (save), Collaborators (sub-panel), Public Universe URL (on publish)