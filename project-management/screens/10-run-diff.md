# Run Diff

| Field | Value |
|-------|-------|
| **ID** | `run-diff` |
| **Type** | Primary |
| **Category** | Results & Dashboards |
| **User Stories** | US-077 |

## Description

Side-by-side comparison of two runs of the same script. Steps aligned by node, with textual diff of agent responses and score deltas highlighted. Used for proving regression or improvement between agent releases.

## Key Components

- **Run headers** — Both runs' metadata side-by-side (agent version, persona, date)
- **Step alignment** — Steps matched by (from_node_id, step_index) with mismatch highlighting
- **Response diff** — Textual side-by-side or inline markup of agent_message differences
- **Score delta** — Per-expectation score comparison with delta values
- **Verdict comparison** — Overall verdict change highlighted at top

## Interactions

- Steps aligned automatically; scroll in sync
- Click any step pair to expand detailed diff
- View aggregate score delta summary

## Navigation

- Accessible from: Run List (compare action)
- Links to: Run Detail (click either run header)
