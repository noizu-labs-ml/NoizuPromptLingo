# Run Trigger Modal

| Field | Value |
|-------|-------|
| **ID** | `run-trigger-modal` |
| **Type** | Modal |
| **Category** | Run Execution |
| **User Stories** | US-015, US-036, US-052, US-067, US-070, US-076, US-124 |

## Description

Modal dialog for configuring and triggering a new run. Allows selecting agent version, persona(s), run config options (timeout, cost cap, freeball budget), and displays cost prediction. Supports single-agent and batch (multi-agent) modes.

## Key Components

- **Agent version picker** — Select which agent version to run against (US-015)
- **Persona multi-select** — Optional persona(s) for fan-out (US-036, US-052)
- **Run config panel** — Timeout, cost cap, freeball budget, threshold (US-067)
- **Batch mode toggle** — Switch to multi-agent selection for batch runs (US-070)
- **Cost prediction** — Estimated USD cost based on script size, agents, personas (US-124)
- **Runner capability warning** — Shown when freeball runner is weaker than target agent (US-076)
- **Trigger button** — Starts the run and redirects to Run Detail

## Interactions

- Select agent version (current published pre-selected)
- Optionally add personas for fan-out
- Configure run parameters
- Review cost estimate
- Acknowledge capability warnings if shown
- Trigger the run

## Navigation

- Accessible from: Graph Editor (Run button), Script List (quick action)
- Links to: Run Detail (after trigger)
