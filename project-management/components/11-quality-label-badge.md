# 11: Quality Label Badge / Selector

| Field | Value |
|-------|-------|
| ID | CMP-11 |
| Category | Data Display |
| Surfaces | web, cli-ink |
| Used In | SCR-10, SCR-24 |

## Description
Per-entry quality label — gold, silver, or bronze — rendered as a colored badge in read contexts and as a three-way toggle (`QualitySelector`) in edit contexts within a dataset entry row.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Badge (read) | Compact display in entry lists |
| Selector (interactive) | Dataset Detail entry rows — click/keypress cycles gold → silver → bronze |

## Props / Configuration
- `quality` — `"gold" \| "silver" \| "bronze"`
- `onChange` — callback, fires `PATCH /api/datasets/:name/entries/:id`

## Interactions
- Web: click cycles or opens a small dropdown; cli-ink: dedicated key cycles the value on the focused entry
