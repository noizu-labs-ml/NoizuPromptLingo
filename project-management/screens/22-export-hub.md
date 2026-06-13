# Export Hub

| Field | Value |
|-------|-------|
| **ID** | `export-hub` |
| **Type** | Primary |
| **Category** | Draft Phase / Cross-Phase |
| **User Stories** | INK-038, INK-039, INK-040, INK-094 |

## Description

Unified export interface accessible from any phase. Format options vary by phase (Sketch: MD/PDF; Draft: HTML/Figma/.fig/PDF+SVG; Ink: ZIP/GitHub; Publish: ZIP/changelog). Handles large export generation asynchronously.

## Key Components

- **Format Picker** — Phase-appropriate export format cards (INK-094)
- **HTML Style Guide Export** — Self-contained interactive HTML file (INK-038)
- **Figma Export** — .fig file with named layers/frames and local styles (INK-039)
- **PDF + SVG Bundle** — Comprehensive report with TOC + vector asset zip + JSON manifest (INK-040)
- **Progress Indicator** — Async generation progress for large exports (INK-040)

## Interactions

- Select format → configure options (e.g., agency branding for PDF)
- Large exports generate asynchronously with progress bar
- Download triggers on completion
- Metadata headers included in all exports

## Navigation

- Accessible from: PRD Editor export action, Mockup Viewer, any phase toolbar
- Links to: Download (file), Email notification for async exports
