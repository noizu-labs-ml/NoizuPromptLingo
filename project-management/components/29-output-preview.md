# 29: Output Preview

| Field | Value |
|-------|-------|
| ID | CMP-29 |
| Category | Data Display |
| Surfaces | web, cli-ink |
| Used In | SCR-06, SCR-08, SCR-22 |

## Description
Rendered, syntax-highlighted preview of a generated artifact (Convert Wizard Step 4) or merged document (Merge View), shown before export/write-to-filesystem.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Default | Full-width preview pane |

## Props / Configuration
- `content` — generated artifact/document text
- `syntax` — language/format for highlighting
- `exportControls` — download / write-to-path actions

## Interactions
- Live re-render as upstream configuration (Convert Step 3 metadata, Merge assembly order) changes
- Export triggers the corresponding write endpoint; failures surface inline without losing the preview
