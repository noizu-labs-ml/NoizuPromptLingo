# Agent Memory Browser

| Field | Value |
|-------|-------|
| **ID** | `agent-memory-browser` |
| **Type** | Dashboard |
| **Category** | Agent Infrastructure |
| **User Stories** | US-025, US-026, US-027, US-090, US-098 |

## Description

Read-only browser at `/app/[orgId]/memory` for inspecting a persona's memory store — semantic recall, emotional-valence recall, reinforcement weighting, and ingest quarantine status — while remaining performant as the store grows. Reinforcement/de-emphasis and quarantine actions here reflect state driven by agent-side MCP calls; the browser surfaces the result rather than providing raw write controls.

## Key Components

- **Semantic Recall Search Bar** — similarity search over the memory store (US-025)
- **Emotional Valence Filter** — filters/sorts recall results by valence or signature (US-026)
- **Memory Weight Indicator** — shows current reinforcement weighting per memory, reflecting agent-driven reinforce/de-emphasize actions (US-027)
- **Quarantine Status Badge** — flags content quarantined at ingest (US-090)
- **Recall Latency Meter** — surfaces recall response time as the store scales (US-098)

## Interactions

- User searches via the Semantic Recall Search Bar → ranked results render with similarity scores (US-025)
- User applies the Emotional Valence Filter → results narrow/reorder by valence or signature (US-026)
- User opens a memory to inspect its Memory Weight Indicator history after an agent reinforces/de-emphasizes it (US-027)
- Quarantined entries show the Quarantine Status Badge and are excluded from normal recall results until cleared (US-090)

## Navigation

- Accessible from: Agent Personas Management (33)
- Links to: none (terminal read-only screen)
