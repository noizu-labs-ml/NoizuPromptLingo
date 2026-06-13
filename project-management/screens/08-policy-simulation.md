# Policy Simulation

| Field | Value |
|-------|-------|
| **ID** | `policy-simulation` |
| **Type** | Primary |
| **Category** | SafeMCP / Policy |
| **User Stories** | US-020, US-080 |

## Description

Simulate policy changes against historical traffic or synthetic agent interactions. Shows diff view of allow/deny changes, side-by-side evaluation traces.

## Key Components

- **SimulationRunner**
- **PolicyDiffView**
- **EvaluationTracePanel**
- **ImpactSummaryCard**
- **SimulationReport**

## Interactions

- Run simulation against history
- Compare current vs proposed policy
- Drill into individual request traces
- Deploy validated policy
- Auto-rollback configuration

## Navigation

- Policy Editor -> Simulation
