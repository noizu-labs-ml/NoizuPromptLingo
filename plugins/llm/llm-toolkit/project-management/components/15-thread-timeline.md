# 15: Thread Timeline

| Field | Value |
|-------|-------|
| ID | CMP-15 |
| Category | Domain-Specific |
| Surfaces | web |
| Used In | SCR-04 |

## Description
Visual timeline above the message list marking decision points and direction changes in a conversation, used for jump-to-message navigation (US-036) on long threads.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Default | Thread Viewer, always visible for threads above a length threshold |

## Props / Configuration
- `markers` — array of `{ messageIndex, label, kind }` (e.g. tool-call cluster, tangent start, decision point)

## Interactions
- Click a marker to jump/scroll the message list to that point
- Hover shows a short label preview of what happens at that point
