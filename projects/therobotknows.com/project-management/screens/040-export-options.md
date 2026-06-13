# Export Options

| Field | Value |
|-------|-------|
| **ID** | export-options |
| **Type** | Modal |
| **Category** | Export |
| **User Stories** | US-099, US-100 |

## Description

Export format selection and options for universe data.

## Key Components

- **Format Selector** — Markdown, JSON, PDF, Game Engine Schema (US-099, US-100)
- **Include Private Toggle** | Include private entries checkbox (US-099)
- **Game Engine Format Selector** — Generic JSON-LD, RPG Systems Schema, Custom (US-100)
- **Custom Mapping Form** | Map custom field names (US-100)
- **Export Button** | Trigger download (US-099)
- **Async Processing Notice** | Shows for large universes (>500 entries) (US-099)
- **Email Download Link** | For async exports (US-099)
- **Schema Version Reference** | Link to export schema documentation (US-100)

## Interactions

- Markdown: ZIP of .md files with frontmatter
- JSON: Single structured file
- PDF: Formatted with TOC and hyperlinks
- Game Engine: Structured schema per format
- Large universes process async, email link sent
- Private entries excluded by default
- Schema versioning in headers

## Navigation

- Accessible from: Universe Settings (Export)
- Links to: Documentation (schema reference)