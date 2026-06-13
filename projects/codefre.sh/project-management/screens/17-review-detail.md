# Review Detail

| Field | Value |
|-------|-------|
| **ID** | `review-detail` |
| **Type** | Primary |
| **Category** | Review & Promotion |
| **User Stories** | US-089, US-090, US-139 |

## Description

Full context view for a claimed freeball review item. Shows the parent script node, freeball prompt, agent response, confidence, and runner-generated expectations. Provides resolution actions: approve, reject as regression, or dismiss.

## Key Components

- **Context panel** — Parent script node, authored prompt, original edge conditions (US-089)
- **Freeball content** — Generated prompt text, agent response, confidence value (US-089)
- **Runner expectations** — Generated expectations with confidence per each (US-089)
- **Resolution actions** — Approve / Reject as regression / Dismiss buttons (US-089)
- **Notes field** — Required for reject/dismiss, optional for approve (US-089)
- **Promotion preview** — On approve, shows diff of new script version (US-090)
- **Persona promotion option** — Promote as persona_expectation instead of base (US-139)

## Interactions

- Review full context of the deviation
- Approve (queues for promotion)
- Reject as regression (flags for regression suite)
- Dismiss (resolves without action)
- On approve: preview promotion diff, edit expectations before confirming

## Navigation

- Accessible from: Review Queue (click claimed item)
- Links to: Graph Editor (view parent node), Run Detail (view source run), Script Version Diff (promotion preview)
