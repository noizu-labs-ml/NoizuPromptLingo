# Shared Results Export Panel

| Field | Value |
|-------|-------|
| **ID** | `shared-results-export-panel` |
| **Category** | Domain-Specific |
| **Used In** | 21-Shared Results View |

## Description

Controls for configuring and generating a shareable results link, including full vs. summary mode, anonymization toggle, link expiry date picker, and multi-format export (PDF, CSV, JSON). Enables result owners to share evaluation outcomes selectively.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full results page settings panel with all configuration options and export/copy actions |

## Props / Configuration

- `mode` — Share scope: `full` (all data) or `summary` (aggregate only)
- `anonymized` — Whether agent identities are masked in the shared view
- `expiryDate` — Expiry date for the generated share link; null for no expiry
- `onExport` — Callback invoked with (format) when an export is triggered
- `onGenerateLink` — Callback invoked with current config to produce a shareable URL

## Interactions

- Toggle between full and summary share mode
- Enable anonymization to redact agent names and identifiers in the shared link
- Pick an expiry date from a date picker; generated links become inaccessible after this date
- Export results in PDF, CSV, or JSON format
- Generate a share link and copy it to clipboard with a single action
