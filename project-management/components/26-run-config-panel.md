# Run Config Panel

| Field | Value |
|-------|-------|
| **ID** | `run-config-panel` |
| **Category** | Domain-Specific |
| **Used In** | 15-Run Trigger Modal, 25-Schedule List |

## Description

Configuration form for run parameters: timeout, cost cap, freeball budget, confidence threshold, batch mode toggle. Includes cost prediction display and capability warnings.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full form section within Run Trigger Modal or schedule creation |

## Props / Configuration

- `timeout` — Max run duration
- `costCap` — Maximum USD spend
- `freeballBudget` — Max freeball steps allowed
- `confidenceThreshold` — Minimum confidence for freeball acceptance
- `batchMode` — Enable multi-agent selection
- `costPrediction` — Estimated cost based on script size and configuration
- `capabilityWarning` — Warning message when runner is weaker than target agent

## Interactions

- Adjust parameters via numeric inputs and toggles
- Cost prediction updates dynamically as config changes
- Capability warning shown/dismissed
- Batch mode toggle reveals multi-agent picker
