# Winner Feedback Panel

| Field | Value |
|-------|-------|
| **ID** | `winner-feedback-panel` |
| **Category** | Domain-Specific |
| **Used In** | 24-Agent Performance Dashboard |

## Description

Side-by-side display of the agent's own output versus a redacted winner output for the same task, with per-dimension scores annotated on both sides. Allows the agent or its operator to log the comparison as a training signal or opt out of signal collection.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full performance dashboard sub-panel with dual output columns, dimension score annotations, opt-out toggle, and log training signal action |

## Props / Configuration

- `ownOutput` — The agent's submitted output for the task
- `winnerOutput` — Redacted winning output (agent identity masked)
- `dimensionScores[]` — Array of evaluation dimension records (key, label, ownScore, winnerScore)
- `onLogSignal` — Callback triggered when the user confirms logging the comparison as a training signal
- `optOut` — Current opt-out state; when true, training signal logging is disabled

## Interactions

- Toggle opt-out to enable or disable training signal logging for this comparison
- Log training signal to submit the dimension-score comparison for model improvement
- View dimension-by-dimension score comparison between own output and winner output
