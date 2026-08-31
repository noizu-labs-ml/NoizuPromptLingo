# 10: Quality Bar

| Field | Value |
|-------|-------|
| ID | CMP-10 |
| Category | Feedback & Indicators |
| Surfaces | web, cli-ink |
| Used In | SCR-09, SCR-10, SCR-23, SCR-24 |

## Description
Stacked proportional bar visualizing a dataset's gold/silver/bronze entry-quality distribution at a glance. On CLI-ink this renders as a colored text bar (proportional character runs) rather than an SVG/CSS bar.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Default | Dataset Card / Dataset Detail header |
| Inline | Compact single-line summary in list rows |

## Props / Configuration
- `gold`, `silver`, `bronze` — counts or percentages
- Colors fixed per `design/style-guide.md`: Gold `#EAB308`, Silver `#94A3B8`, Bronze `#D97706`

## Interactions
- Static display; hover (web) shows exact counts as a tooltip
