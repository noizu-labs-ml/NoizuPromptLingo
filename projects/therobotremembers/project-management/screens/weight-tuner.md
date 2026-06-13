---
id: screen-weight-tuner
title: "Weight Tuner"
route: /admin/weights
personas: [persona-the-archivist, persona-the-curator]
priority: should-have
---

# Weight Tuner

## Purpose
Admin panel for adjusting global weight parameters, decay curves, and reinforcement/denforcement dynamics. Operators use this to tune how aggressively memories decay, how much reinforcement boosts weights, and how the system balances content relevance against emotional resonance. Includes simulation mode to preview the impact of parameter changes before applying.

## Layout

```
+------------------------------------------------------------------+
|  Weight Tuner                                     [Apply] [Reset] |
|  ⚠ Changes affect all future weight calculations. Use simulation  |
|  mode to preview impact before applying.                          |
+------------------------------------------------------------------+
|                                                                    |
|  Tabs: [Decay] [Reinforcement] [Recall Weights] [Simulation]      |
|                                                                    |
+------------------------------------------------------------------+
|  === Decay Tab ===                                                 |
|                                                                    |
|  +---------------------------+  +-------------------------------+  |
|  | Half-Life Settings        |  | Decay Curve Preview           |  |
|  |                           |  | (Interactive chart)           |  |
|  | Episodic:  [168] hrs      |  |                               |  |
|  |   ████████████░░░ 1 week  |  | 1.0 |\                        |  |
|  |                           |  |     |  \                      |  |
|  | Semantic:  [720] hrs      |  | 0.5 |    \___                 |  |
|  |   ████████████░░░ 30 days |  |     |        \___             |  |
|  |                           |  | 0.0 |____________\______      |  |
|  | Procedural:[2160] hrs     |  |     0    7d   30d   90d       |  |
|  |   ████████████░░░ 90 days |  |                               |  |
|  |                           |  | [episodic] [semantic] [proc]  |  |
|  | Pruning threshold: [0.05] |  |                               |  |
|  | Grace period: [48] hrs    |  |                               |  |
|  +---------------------------+  +-------------------------------+  |
|                                                                    |
+------------------------------------------------------------------+
|  === Reinforcement Tab ===                                         |
|                                                                    |
|  Base reinforcement boost:   [0.15]  (WeightSlider 0.01–0.50)     |
|  Emotional resonance bonus:  [0.50]  (WeightSlider 0.00–1.00)     |
|  Edge reinforcement factor:  [0.10]  (WeightSlider 0.01–0.30)     |
|  Co-recall (Hebbian) factor: [0.05]  (WeightSlider 0.01–0.20)     |
|  Denforcement penalty:       [0.20]  (WeightSlider 0.05–0.50)     |
|                                                                    |
+------------------------------------------------------------------+
|  === Recall Weights Tab ===                                        |
|                                                                    |
|  Content relevance weight:      [0.40]  (WeightSlider)             |
|  Emotional resonance weight:    [0.25]  (WeightSlider)             |
|  Recency weight:                [0.15]  (WeightSlider)             |
|  Association strength weight:   [0.10]  (WeightSlider)             |
|  Diversity factor:              [0.10]  (WeightSlider)             |
|                                    Total: [1.00] ✓                 |
|                                                                    |
|  Context injection budget: [2000] tokens                           |
|  Max traversal depth:      [3]                                     |
|  Default min edge weight:  [0.2]                                   |
|                                                                    |
+------------------------------------------------------------------+
|  === Simulation Tab ===                                            |
|                                                                    |
|  "What if" simulator                                               |
|                                                                    |
|  With current settings:                                            |
|  - Memories that would be pruned in 7 days:  [45]                  |
|  - Avg memory lifetime (episodic):           [12.3 days]           |
|  - Avg reinforcement needed to survive 30d:  [3.2 recalls]        |
|                                                                    |
|  With proposed changes:                                            |
|  - Memories that would be pruned in 7 days:  [23] (↓ 49%)         |
|  - Avg memory lifetime (episodic):           [18.7 days] (↑ 52%)  |
|  - Avg reinforcement needed to survive 30d:  [2.1 recalls] (↓ 34%)|
|                                                                    |
|  [Run Full Simulation] → runs against actual memory store          |
|                                                                    |
+------------------------------------------------------------------+
```

## Key Components
- **Decay Settings** (uses `component-weight-slider`): Numeric inputs and sliders for half-life per memory type, pruning threshold, and grace period. Linked to the decay curve preview chart.
- **Decay Curve Preview**: Interactive chart showing the decay curve for each memory type. Updates in real-time as parameters are adjusted. X-axis is time, Y-axis is weight. Shows the pruning threshold as a horizontal dashed line.
- **Reinforcement Settings** (uses `component-weight-slider`): Sliders for base boost, emotional resonance bonus, edge factor, Hebbian factor, and denforcement penalty.
- **Recall Weight Distribution** (uses `component-weight-slider`): Sliders for the weighting factors used during winnowing. Must sum to 1.0 — adjusting one auto-adjusts others proportionally (or shows a warning if total deviates).
- **Simulation Panel**: "What if" analysis comparing current vs. proposed settings. Shows projected pruning counts, average lifetimes, and reinforcement requirements. Can run against the actual memory store for accurate projections.

## Interactions
- **Adjust any parameter** → Decay curve preview updates immediately. Simulation panel shows "Stale — re-run simulation" indicator.
- **Apply** → Confirmation dialog showing diff of changes. After confirmation, new parameters take effect globally. Toast: "Weight parameters updated."
- **Reset** → Revert all parameters to their current saved values (discard unsaved changes).
- **Run Full Simulation** → Spinner while computing projections against actual data. Results populate the simulation panel.
- **Recall weight slider adjustment** → Other sliders auto-adjust to maintain sum = 1.0. If the user locks a slider (click the lock icon), it is excluded from auto-adjustment.

## Data Requirements
- `GET /api/v1/admin/weight-config` — Current weight parameters
- `PUT /api/v1/admin/weight-config` — Update weight parameters
- `GET /api/v1/admin/decay-config` — Current decay parameters
- `PUT /api/v1/admin/decay-config` — Update decay parameters
- `POST /api/v1/admin/simulate` — Run simulation with proposed parameters, returns projected metrics
- `GET /api/v1/admin/metrics` — Current memory counts by type, avg weights, etc. (for simulation baseline)

## States
- **Initial state**: All parameters loaded from current config. Simulation panel shows current projections.
- **Loading state**: Skeleton sliders while config loads.
- **Unsaved changes**: "Apply" button turns amber. Banner: "You have unsaved changes."
- **Simulation running**: Spinner on simulation panel. Other tabs remain interactive.
- **Error state**: Error toast if apply fails. Parameters revert to last saved values. Detail error message in a collapsible section.
