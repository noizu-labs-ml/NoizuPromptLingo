# Raw JSON Viewer

| Field | Value |
|-------|-------|
| **ID** | `raw-json-viewer` |
| **Category** | Data Display |
| **Used In** | 09-Run Detail, 21-Capture Detail, 23-OTel Span Drilldown |

## Description

Syntax-highlighted JSON viewer with collapsible sections and copy-to-clipboard. Used to inspect raw payloads for run steps, captured interactions, and OTel span attributes.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Collapsed by default, expandable inline within a step or span detail |
| **Expanded** | Full panel with search and path navigation |

## Props / Configuration

- `data` — JSON object to display
- `collapsedDepth` — Default collapse depth (e.g., 2 levels expanded)
- `searchable` — Enable search within JSON keys/values
- `copyToClipboard` — Show copy button
- `maxHeight` — Scrollable container height

## Interactions

- Expand/collapse JSON nodes
- Copy entire payload or specific paths to clipboard
- Search within JSON content
