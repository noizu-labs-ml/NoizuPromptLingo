# 02: Filter Bar

| Field | Value |
|-------|-------|
| ID | CMP-02 |
| Category | Input & Forms |
| Surfaces | web, cli-ink |
| Used In | SCR-01, SCR-03, SCR-16, SCR-18 |

## Description
Composable filter row: project scope, date range, role, and include/exclude tags, plus sort and group-mode controls. On web it's a horizontal control bar; on CLI-ink each control becomes its own UI sub-mode (`sort`, `include-tags`, `exclude-tags`, `page-size`) entered and exited with dedicated keys.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Full | Explore / Project Detail (project, date, role, tags, sort, group) |
| Scoped | Project Detail — project dimension implicit, remaining filters still available |

## Props / Configuration
- `sort` — `"updated_at" \| "started_at" \| "message_count" \| "title"`
- `groupMode` — `"grouped" \| "flat"`
- `includeTags` / `excludeTags` — comma-separated tag strings, parsed and lowercased
- `dateRange` — `{ from, to }`
- `role` — `"user" \| "assistant" \| "tool"`
- `pageSize` — one of a fixed option set (web: 25/50/100 equivalent)

## Interactions
- Filters combine additively (AND) against the active query or browse list
- Web: FilterBar renders inline, always visible; CLI-ink: only one filter sub-mode is active at a time, captured via footer prompt
