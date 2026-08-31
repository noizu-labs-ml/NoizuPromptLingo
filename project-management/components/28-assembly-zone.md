# 28: Assembly Zone / Merged Section

| Field | Value |
|-------|-------|
| ID | CMP-28 |
| Category | Domain-Specific |
| Surfaces | web |
| Used In | SCR-08 |

## Description
Drop target for Merge View: an ordered list of MergedSection entries, each tagged with its source-thread badge, message range, and a reorder handle, assembling into the final merged document.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Empty | Placeholder drop-target state before any section is added |
| Populated | Ordered list of MergedSection entries |

## Props / Configuration
- `sections` — ordered array of `{ sourceThreadId, range, order }`

## Interactions
- Drag-and-drop from Compare View (CMP-27) adds a section
- Drag handle reorders sections within the zone
- Remove affordance per section
