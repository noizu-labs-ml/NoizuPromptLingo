# Waterfall Span View

| Field | Value |
|-------|-------|
| **ID** | `waterfall-span-view` |
| **Category** | Data Display |
| **Used In** | 09-Run Detail, 23-OTel Span Drilldown |

## Description

Hierarchical timeline visualization of OpenTelemetry spans. Shows parent-child span relationships as nested bars with duration proportional to time, color-coded by status. Used to inspect an agent's internal tool calls, retrievals, and reasoning traces.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Embedded tab within Run Detail (OTel Trace tab) |
| **Full Page** | Standalone drilldown view with full span tree |

## Props / Configuration

- `spans` — Hierarchical array of span objects (name, service, startTime, duration, status, children, attributes)
- `selectedSpanId` — Currently selected span for detail panel
- `onSpanSelect` — Callback when a span is clicked
- `emptyState` — Message when no spans available (explains possible causes)

## Interactions

- Browse hierarchical span tree
- Click span bar to open attribute detail panel
- Collapse/expand span subtrees
- Flag interesting spans for capture library
- Lazy-loaded when tab is opened
