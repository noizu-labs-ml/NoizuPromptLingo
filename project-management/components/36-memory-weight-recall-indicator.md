# Memory Weight & Recall Indicator

| Field | Value |
|-------|-------|
| **ID** | `memory-weight-recall-indicator` |
| **Category** | AI-Specific |
| **Used In** | 36-agent-memory-browser |

## Description

Two paired read-only visualizations on a memory entry: its current reinforcement weighting (reflecting agent-driven reinforce/de-emphasize actions over time) and the store's recall latency as it scales. Both surface state driven by agent-side MCP calls rather than direct user writes.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Weight value / latency figure |
| **Expanded** | Weight history over time for a single memory |

## Props / Configuration

- `weight` — current reinforcement weighting
- `weightHistory` — prior reinforce/de-emphasize events
- `recallLatencyMs` — current recall response time

## Interactions

- User opens a memory to inspect its weight history after an agent has reinforced or de-emphasized it — the indicator itself is read-only, reflecting agent-driven state rather than accepting direct edits
