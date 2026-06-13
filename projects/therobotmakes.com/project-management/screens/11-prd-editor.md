# PRD Editor

| Field | Value |
|-------|-------|
| **ID** | `prd-editor` |
| **Type** | Primary |
| **Category** | Sketch Phase |
| **User Stories** | INK-017, INK-018, INK-019, INK-020 |

## Description

Auto-assembled PRD from Sketch artifacts (pitch, personas, stories). Supports rich-text editing, annotations, revision history, export, and phase completion gate.

## Key Components

- **PRD Document View** — Formatted sections: Executive Summary, Target Personas, User Stories, Scope Boundaries, Open Questions (INK-017)
- **Section Editor** — Per-section rich-text editing with "Restore Original" option (INK-018)
- **Annotation Overlay** — Inline annotations pinned to document regions (INK-018)
- **Revision History** — Sidebar showing edit history per section (INK-018)
- **Export Action** — Format picker modal (Markdown primary) with download (INK-019)
- **Complete Phase Button** — "Complete Sketch" action with confirmation dialog (INK-020)

## Interactions

- Document auto-generates from accepted Sketch artifacts
- Click any section to enter edit mode
- Annotations are pinnable with click-to-add
- "Export" opens modal with format selection and download trigger
- "Complete Sketch" requires confirmation, then advances phase and updates dashboard badge

## Navigation

- Accessible from: Story Curation completion
- Links to: Style Preset Picker (on phase completion), Export download
