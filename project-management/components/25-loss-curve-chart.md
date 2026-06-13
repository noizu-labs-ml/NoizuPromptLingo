# Loss Curve Chart

| Field | Value |
|-------|-------|
| **ID** | `loss-curve-chart` |
| **Category** | Data Display |
| **Used In** | 04-Training Gym |

## Description

Real-time line chart showing training loss curve with reward-per-episode overlay. Part of Research Mode visualization panel. Supports animation export.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Sparkline preview of loss trend |
| **Expanded** | Full dual-axis chart with loss curve and reward overlay |

## Props / Configuration

- `lossData` — Loss values per training step
- `rewardData` — Reward values per episode
- `realTime` — Enable streaming updates during active training run
- `theme` — Graph color theme

## Interactions

- View real-time training progress during active run
- Hover data points for exact values (desktop)
- Export chart as animated MP4 or GIF
