# Training Gym

| Field | Value |
|-------|-------|
| **ID** | `training-gym` |
| **Type** | Primary |
| **Category** | Core Gameplay |
| **User Stories** | US-007, US-030, US-051, US-052, US-055, US-056, US-057, US-059 |

## Description

Environment for training fighters against sparring partners with configurable seeds, batch scheduling, and research-grade analytics. Supports data export for academic use.

## Key Components

- **Sparring Partner Browser** — Filter by archetype, rank tier, win rate, complexity; favorites and queue (US-007, US-055)
- **Training Configuration Form** — Seed input, epoch count, partner selection, graph selection (US-051, US-056)
- **Loss Curve Chart** — Real-time loss curve with reward-per-episode overlay (US-052)
- **Weight Update Heatmap** — Node weight changes visualized on graph canvas (US-052)
- **Research Mode Toggle** — Enables research-grade visualization panels (US-052)
- **Batch Queue Panel** — Queue up to 10 training runs with per-run export links (US-056)
- **Run Comparison View** — Side-by-side action distribution, entropy, reward curves between runs (US-057)
- **Training Data Export** — Per-step logs in CSV/Parquet with size estimate (US-030, US-059)
- **Session History List** — Past training sessions with metadata and export options (US-030)

## Interactions

- Select sparring partners from library or saved fighters
- Configure and launch training runs with reproducible seeds
- Monitor real-time training progress via charts
- Queue batch runs and receive notifications on completion
- Compare runs side-by-side
- Export training data in multiple formats

## Navigation

- Accessible from: Fighter Studio, Home
- Links to: Fighter Studio, Batch Summary, Run Comparison, Training Data Export
