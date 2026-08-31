# 27: Compare View / Thread Panel

| Field | Value |
|-------|-------|
| ID | CMP-27 |
| Category | Domain-Specific |
| Surfaces | web |
| Used In | SCR-08 |

## Description
Side-by-side, independently-scrollable panels (one per selected thread, 2–5 total) used in Merge View, each showing that thread's messages with drag handles for assembling a merged document.

## Size Variants

| Variant | Use Case |
|---------|---------|
| 2-panel | Two-thread merge |
| N-panel (3–5) | Multi-thread merge, panels compress proportionally |

## Props / Configuration
- `threads` — array of loaded thread message sets
- `scrollSync` — off by default (independent scroll per panel)

## Interactions
- Drag a message range from any panel into the Assembly Zone (CMP-28)
