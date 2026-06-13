# Training Run Config

| Field | Value |
|-------|-------|
| **ID** | `training-run-config` |
| **Category** | Input & Forms |
| **Used In** | 04-Training Gym |

## Description

Configuration form for training runs including graph selection, seed input, sparring partner choice, and epoch count. Supports batch queue of up to 10 runs.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Single-run quick configuration form |
| **Expanded** | Batch queue manager with up to 10 run slots |

## Props / Configuration

- `graph` — Selected fighter graph for training
- `seed` — Reproducibility seed value
- `partner` — Sparring partner selection (archetype or specific fighter)
- `epochs` — Training epoch count
- `batchQueue` — List of queued run configurations

## Interactions

- Configure run parameters (graph, seed, partner, epochs)
- Set seed value for reproducible runs
- Queue multiple batch runs (up to 10)
- Start or cancel runs
- Receive completion notification when run finishes
