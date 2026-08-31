# 03: Tag Chips

| Field | Value |
|-------|-------|
| ID | CMP-03 |
| Category | Input & Forms |
| Surfaces | web, cli-ink |
| Used In | SCR-02, SCR-03, SCR-04, SCR-11, SCR-12, SCR-17, SCR-19, SCR-25, SCR-26 |

## Description
Inline, editable list of colored tag pills — the shared display+edit pattern for tags on conversations, projects, and prompts, and the row unit inside the Tags Manager itself. Mirrored 1:1 on CLI-ink as `TagChips.tsx`.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Read-only | Compact card/row contexts (e.g. ThreadCard) |
| Editable | Detail contexts — add/remove chips inline (Project card, Thread metadata panel, Tags Manager) |

## Props / Configuration
- `tags` — string[]
- `onAdd(tag)` / `onRemove(tag)` — callbacks
- `colorMap` — tag name → color hex, sourced from tag metadata (`COLOR_PRESETS`: cyan, green, orange, purple, pink, gold, red, blue)
- `editable` — boolean

## Interactions
- Click/keypress to enter "adding" state, reveals a text input, `Enter` commits, `Esc` cancels
- Each chip has an inline remove affordance when editable
- Colors are looked up from centrally managed tag metadata (Tags Manager, SCR-12/26) rather than set per-instance
