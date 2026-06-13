# Freeball Confidence Histogram

| Field | Value |
|-------|-------|
| **ID** | `freeball-confidence-histogram` |
| **Type** | Dashboard |
| **Category** | Freeball Protocol |
| **User Stories** | US-126 |

## Description

Histogram visualization of runner confidence distribution across freeball nodes, available at both run-level and org-level. Split by runner model for orgs with multiple configurations.

## Key Components

- **Histogram chart** — 10 confidence buckets (0.0-0.1 through 0.9-1.0)
- **Scope toggle** — Run-level vs org-wide
- **Runner model split** — Separate series per runner model
- **Drill-through** — Click bucket to see underlying freeball nodes

## Interactions

- Toggle between run and org scope
- Click histogram buckets to drill into nodes
- Compare distribution across runner models

## Navigation

- Accessible from: Run Detail (analytics), Org Dashboard
- Links to: Freeball nodes (drill-through)
