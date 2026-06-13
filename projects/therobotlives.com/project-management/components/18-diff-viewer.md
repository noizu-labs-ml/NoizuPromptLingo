# Diff Viewer

| Field | Value |
|-------|-------|
| **ID** | `diff-viewer` |
| **Category** | Domain-Specific |
| **Used In** | 27-Version History |

## Description

Side-by-side content comparison highlighting additions, removals, and modifications. Supports syntax highlighting and clickable changed lines.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Unified diff with inline additions/removals |
| **Expanded** | Side-by-side with line numbers |
| **Full Page** | Full-width comparison with navigation |

## Props / Configuration

- `leftVersion` — Original content
- `rightVersion` — Modified content
- `language` — Syntax highlighting language

## Interactions

- Scroll through diff; click changed line → jump to section
- Lazy loading for large files
