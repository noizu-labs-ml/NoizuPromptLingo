# AI-Generated Badge

| Field | Value |
|-------|-------|
| **ID** | `ai-generated-badge` |
| **Category** | Provenance / Attribution |
| **Used In** | S05 Canon List, S06 Canon Entry Detail, S12 Generation History, S14 Session Log |

## Description

Indicator badge that distinguishes AI-generated content from human-authored content within canon entries and history views. Renders a small robot/spark icon with a label and optionally the model name used. Supports a "reviewed" state (human has verified the content) that softens the visual treatment to indicate editorial approval.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Icon-only pill with tooltip; used in list rows and table cells |
| **Compact** | Icon + "AI" label; used in entry headers and sidebar chips |
| **Expanded** | Icon + "AI Generated" label + model name + review state toggle |

## Props / Configuration

- `reviewed` — Boolean; when true renders a checkmark overlay and muted color indicating human review
- `modelName` — Optional string (e.g. `gpt-4o`, `claude-3-5`); displayed in expanded variant and tooltip
- `generatedAt` — ISO timestamp; shown in tooltip and expanded variant
- `size` — `inline | compact | expanded`
- `onMarkReviewed` — Callback invoked when user toggles the reviewed state in expanded variant

## Interactions

- Hover on any variant shows tooltip: model name, generation date, review status
- Expanded variant includes a "Mark as Reviewed" button that calls `onMarkReviewed`; transitions badge to reviewed state with optimistic update
- Badge does not block editing; it is decorative and informational only
- Screen reader label: "AI generated content" or "AI generated content, reviewed by human"
