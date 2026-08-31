# 37: Pagination

| Field | Value |
|-------|-------|
| ID | CMP-37 |
| Category | Navigation & Layout |
| Surfaces | web, cli-ink |
| Used In | SCR-01, SCR-03, SCR-16, SCR-18 |

## Description
Server-side page controls for list/search results. Mirrored directly on cli-ink as `Pagination.tsx`.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Default | Page number + prev/next |

## Props / Configuration
- `page`, `pageSize`, `total`
- `onPageChange`

## Interactions
- Web: click prev/next or a page number; cli-ink: dedicated keys page forward/back
