# OTel Span Drilldown

| Field | Value |
|-------|-------|
| **ID** | `otel-span-drilldown` |
| **Type** | Primary |
| **Category** | Observability |
| **User Stories** | US-099 |

## Description

Waterfall timeline view of OTel spans linked to a specific run step. Shows the agent's internal tool calls, retrievals, and reasoning traces as a hierarchical span tree.

## Key Components

- **Waterfall visualization** — Hierarchical span tree with duration bars, status colors (US-099)
- **Span detail panel** — Attributes, events, status, service name on click (US-099)
- **Empty state** — Explains possible causes (no exporter, correlation pending, sampling) (US-099)
- **Flag action** — Flag any span for capture (US-106)

## Interactions

- Browse span waterfall
- Click spans to see attribute detail
- Flag interesting spans
- Lazy-loaded when OTel Trace tab is opened in Run Detail

## Navigation

- Accessible from: Run Detail (OTel Trace tab), OTel Span Search (click result)
- Links to: Flagged Captures Library (flag action)
