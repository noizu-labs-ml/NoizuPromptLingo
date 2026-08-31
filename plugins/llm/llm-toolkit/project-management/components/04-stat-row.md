# 04: Stat Row / Stat Card

| Field | Value |
|-------|-------|
| ID | CMP-04 |
| Category | Data Display |
| Surfaces | web |
| Used In | SCR-01, SCR-02 |

## Description
Row of summary metric cards — conversation count, project count, indexed tokens, dataset entries — giving at-a-glance orientation at the top of Explore's dashboard-mode state and Projects List.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Default | 4-up stat row (Explore dashboard mode) |
| Single | Standalone StatCard reused wherever one metric needs highlighting |

## Props / Configuration
- `label` — string
- `value` — number/string, formatted (e.g. token counts abbreviated)
- `trend` — optional delta indicator

## Interactions
- Static display; no click-through by default (values are informational, not filters)
