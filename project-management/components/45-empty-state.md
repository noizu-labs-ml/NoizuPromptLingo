# Empty State

| Field | Value |
|-------|-------|
| **ID** | `empty-state` |
| **Category** | Feedback & Indicators |
| **Used In** | 08-Run List, 23-OTel Span Drilldown, 01-Script List, 18-Dataset List |

## Description

Placeholder content shown when a list or view has no data. Includes an illustration/icon, explanatory message, and a call-to-action button guiding the user to create their first item or explaining why data is missing.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Inline message within a panel (e.g., "No spans found — check exporter config") |
| **Expanded** | Centered full-area display with illustration, message, and CTA button |

## Props / Configuration

- `icon` — Illustration or icon to display
- `title` — Primary message (e.g., "No runs yet")
- `description` — Explanatory text with guidance
- `ctaLabel` — Call-to-action button text
- `ctaAction` — Callback when CTA is clicked
- `possibleCauses` — List of reasons why data might be missing (for diagnostic empty states)

## Interactions

- Click CTA button to begin the relevant creation flow
- For diagnostic states: expandable "possible causes" list
