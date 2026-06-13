# OTel Span Search

| Field | Value |
|-------|-------|
| **ID** | `otel-span-search` |
| **Type** | Primary |
| **Category** | Observability |
| **User Stories** | US-098, US-100 |

## Description

Search interface for querying OTel spans by attribute key/value filters and semantic similarity. Results link to owning run steps and support flagging.

## Key Components

- **Attribute filter builder** — Add conditions: key, operator (equals, presence, numeric range), value (US-098)
- **Semantic search bar** — Free-text natural language search using embeddings (US-100)
- **Results table** — Span name, service, duration, status, run step link, attributes preview (US-098)
- **Sort controls** — By similarity score (semantic) or timestamp (US-098, US-100)
- **Flag action** — Flag any span for capture library (US-106)

## Interactions

- Build attribute filters (AND logic)
- Enter semantic search query
- Combine attribute + semantic filters
- Click results to drill down to span detail
- Flag interesting spans

## Navigation

- Accessible from: Global sidebar navigation (under Observability)
- Links to: OTel Span Drilldown (click result), Run Detail (click run step link), Flagged Captures Library (flag action)
