# 07: Project Sidebar / Project Card

| Field | Value |
|-------|-------|
| ID | CMP-07 |
| Category | Cards & Tiles |
| Surfaces | web, cli-ink |
| Used In | SCR-01, SCR-02, SCR-16, SCR-17 |

## Description
Project summary unit: path (shortened to last two path segments for display), display name, description, tag list (CMP-03), conversation count, last-active timestamp. Appears as a persistent grouped sidebar list on Explore and as the primary card grid on Projects List.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Sidebar row | Compact, persistent project list alongside Explore's main content |
| Grid card | Projects List — larger, includes inline tag editing |

## Props / Configuration
- `projectPath` — full path, `shortProject()` truncation applied for sidebar display
- `displayName` / `description` — optional overrides over the raw path
- `conversationCount`, `lastActive`
- `tags` — editable via CMP-03 in card variant

## Interactions
- Click navigates to Project Detail (SCR-03 / SCR-18)
- Card variant supports inline title/description edit (`e` / `E` on cli-ink)
