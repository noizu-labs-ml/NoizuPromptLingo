---
id: screen-recall-console
title: "Recall Console"
route: /recall/console
personas: [persona-the-archivist, persona-the-guardian]
priority: must-have
---

# Recall Console

## Purpose
Interactive recall testing interface. Operators and developers use this to test memory retrieval with precise control over emotional parameters, contextual filters, and traversal settings. The console shows not just what was recalled, but *why* — relevance scores, emotional resonance values, the association paths that led to each result, and a preview of the context injection output.

## Layout

```
+------------------------------------------------------------------+
|  Recall Query Panel (left, 40% width)                             |
+------------------------------------------------------------------+
|                                                                    |
|  Query Text                                                        |
|  +--------------------------------------------------------------+ |
|  | "that time we debugged the Postgres deadlock"                 | |
|  +--------------------------------------------------------------+ |
|                                                                    |
|  Emotional Parameters                                              |
|  [x] Match current agent mood                                     |
|  [ ] Override mood:                                                |
|      Valence: [-1.0 ────●──── 1.0]  = -0.5                        |
|      Arousal: [0.0 ──────●── 1.0]   = 0.8                         |
|      Dominance: [0.0 ──●──── 1.0]   = 0.4                         |
|                                                                    |
|  Contextual Filters                                                |
|  Domain: [debugging ▼]                                             |
|  Time of day: [Any ▼]                                              |
|  Season: [Any ▼]                                                   |
|  Collaborators: [multi-select]                                     |
|                                                                    |
|  Traversal Settings                                                |
|  Max depth: [1] [2] [●3] [4] [5]                                  |
|  Min edge weight: [0.0 ──●──── 1.0] = 0.2                         |
|  Edge types: [x]Semantic [x]Emotional [x]Temporal                  |
|              [x]Causal [x]Co-occurrence [ ]Synthetic               |
|  Max results: [10 ▼]                                               |
|                                                                    |
|  [▶ Run Recall]                          [Save as Preset ▼]       |
|                                                                    |
+------------------------------------------------------------------+
|  Results Panel (right, 60% width)                                  |
+------------------------------------------------------------------+
|                                                                    |
|  Tabs: [Results] [Association Paths] [Context Preview]             |
|                                                                    |
|  === Results Tab ===                                               |
|  Recalled 7 memories from 23 candidates in 142ms                  |
|                                                                    |
|  #1  relevance: 0.92  resonance: 0.87  [MemoryCard]               |
|      "Postgres deadlock during migration. Advisory locks..."       |
|      [EmotionBadge: frustrated] weight: 0.82                      |
|      Path: direct match                                            |
|                                                                    |
|  #2  relevance: 0.78  resonance: 0.91  [MemoryCard]               |
|      "DNS timeout during midnight deploy, same frustration..."     |
|      [EmotionBadge: frustrated] weight: 0.71                      |
|      Path: via #1 (emotional, w=0.8) → (temporal, w=0.6)          |
|                                                                    |
|  #3  ...                                                           |
|                                                                    |
|  === Association Paths Tab ===                                     |
|  Mini force-directed graph showing only recalled memories          |
|  and the edges that connected them during traversal.               |
|  Highlighted paths show how each result was reached.               |
|                                                                    |
|  === Context Preview Tab ===                                       |
|  <memories recalled="7" total_candidates="23" ...>                 |
|    <memory id="m-abc123" relevance="0.92" ...>                     |
|      Postgres deadlock during migration...                         |
|    </memory>                                                       |
|    ...                                                             |
|  </memories>                                                       |
|  Token count: 847 / 2000 budget                                    |
|                                                                    |
+------------------------------------------------------------------+
```

## Key Components
- **Query Text Input**: Multi-line text area for the recall query. Supports natural language.
- **Emotional Parameters**: Toggle between matching the agent's current mood (pulled live from the Monitor) or manually overriding with sliders for valence, arousal, dominance.
- **Contextual Filters**: Optional filters for domain, time-of-day, season, collaborators.
- **Traversal Settings**: Controls for graph traversal depth, minimum edge weight threshold, which edge types to follow, and max result count.
- **Preset System**: Save and load recall parameter presets for repeated testing.
- **Results List** (uses `component-memory-card`, `component-emotion-badge`): Ranked results with relevance score, emotional resonance score, memory card preview, and the association path that led to this result.
- **Association Paths View**: Mini graph visualization showing only the recalled memories and the edges between them. Highlights the traversal paths.
- **Context Preview**: The exact XML/text that would be injected into an LLM's context window. Shows token count against the configured budget.

## Interactions
- **Run Recall** → Execute recall request with current parameters. Results populate in the right panel.
- **Adjust parameter + re-run** → Modify any parameter and re-run to see how results change. Previous results remain visible with a "stale" indicator until re-run.
- **Click memory in results** → Navigate to `/memories/:id`
- **Click "Reinforce" on a result** → Send reinforcement signal for that memory
- **Click "Denforce" on a result** → Send denforcement signal
- **Switch to Association Paths tab** → See the graph structure that produced the results
- **Switch to Context Preview tab** → See the formatted output that would be injected into context
- **Copy context preview** → Copy the context injection XML to clipboard
- **Save as Preset** → Name and save the current parameter set for reuse

## Data Requirements
- `POST /api/v1/recall` — Primary recall endpoint with full parameter body
- `GET /api/v1/agents/monitor/state` — Current agent emotional state (for "match current mood")
- `POST /api/v1/memories/:id/reinforce` — Reinforce from results
- `POST /api/v1/memories/:id/denforce` — Denforce from results
- Recall response includes: `results[]`, `candidates_count`, `execution_time_ms`, `traversal_paths[]`, `context_injection_preview`

## States
- **Initial state**: Left panel with default parameters, right panel showing "Run a recall query to see results." No previous query.
- **Loading state**: "Run Recall" button shows spinner. Right panel shows "Recalling..." with elapsed time counter.
- **No results**: "No memories matched your query and parameters. Try broadening filters or reducing minimum edge weight."
- **Error state**: Error message in the results panel with the recall parameters that caused the error. Left panel remains editable for adjustment and retry.
