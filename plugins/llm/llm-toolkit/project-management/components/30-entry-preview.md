# 30: Dataset Entry Preview

| Field | Value |
|-------|-------|
| ID | CMP-30 |
| Category | Tables & Lists |
| Surfaces | web, cli-ink |
| Used In | SCR-10, SCR-24 |

## Description
Compact system/user/assistant message sequence preview for one dataset entry — the training-example unit shown per row in Dataset Detail.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Default | Dataset Detail entry list |
| Expanded | Full sequence on click/focus |

## Props / Configuration
- `messages` — `{ system?, user, assistant }` sequence
- `truncateAt` — character limit before "show more"

## Interactions
- Click/Enter expands to full sequence; pairs with SourceBadge (CMP-12) and QualitySelector (CMP-11) in the same row
