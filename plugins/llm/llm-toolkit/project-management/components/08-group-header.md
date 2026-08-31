# 08: Group Header

| Field | Value |
|-------|-------|
| ID | CMP-08 |
| Category | Navigation & Layout |
| Surfaces | web, cli-ink |
| Used In | SCR-01, SCR-16 |

## Description
Section divider for grouped list views — project name plus conversation count — separating one project's conversations from the next when group mode is active.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Default | Explore grouped-by-project mode |

## Props / Configuration
- `projectPath` — string
- `count` — number of conversations in the group
- `collapsed` — optional collapse state for long grouped lists

## Interactions
- Optionally collapsible to hide/show the group's rows
- Click navigates to the group's Project Detail screen
