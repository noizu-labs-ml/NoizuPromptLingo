# 13: Thread Header

| Field | Value |
|-------|-------|
| ID | CMP-13 |
| Category | Navigation & Layout |
| Surfaces | web, cli-ink |
| Used In | SCR-04, SCR-19 |

## Description
Fixed header atop Thread Viewer: title, project, date, message count, model. Anchors the ActionBar (CMP-14) beneath/beside it.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Default | Thread Viewer top of page |

## Props / Configuration
- `title`, `projectPath`, `date`, `messageCount`, `model`

## Interactions
- Title is inline-editable in some contexts (`n` key on cli-ink opens edit-title overlay)
