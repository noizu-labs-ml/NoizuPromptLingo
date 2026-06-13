# Capture Detail

| Field | Value |
|-------|-------|
| **ID** | `capture-detail` |
| **Type** | Primary |
| **Category** | Flagged Captures |
| **User Stories** | US-106, US-108, US-109 |

## Description

Full view of a single flagged capture showing the captured input, agent response, linked OTel trace, original run step (if any), and promotion actions.

## Key Components

- **Capture metadata** — Title, tags, reason, notes, flagged_by, timestamp (US-106)
- **Input display** — Full captured user message / input (US-106)
- **Response display** — Full captured agent response (US-106)
- **OTel trace link** — Link to original span in OTel viewer (US-106)
- **Run step link** — Link to original run step if correlated (US-106)
- **Promote to Script action** — Picker for target script + node (US-108)
- **Promote to Dataset action** — Picker for target dataset (US-109)
- **Redaction controls** — Scrub PII from captured content (US-106)

## Interactions

- Review full capture content
- Redact sensitive information
- Promote to script node (opens picker)
- Promote to dataset entry (opens picker with edit)
- Navigate to linked OTel trace or run step

## Navigation

- Accessible from: Flagged Captures Library (click row)
- Links to: OTel Span Drilldown, Run Detail, Graph Editor (promote), Dataset Detail (promote)
