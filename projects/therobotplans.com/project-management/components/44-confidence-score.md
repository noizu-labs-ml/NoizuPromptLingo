# Confidence Score

| Field | Value |
|-------|-------|
| **ID** | `confidence-score` |
| **Category** | Feedback & Indicators |
| **Used In** | 05-Inbox, 18-Backlog Grooming, 37-Anomaly Correlation, 47-Agent-Generated Checklist Review, 72-Prompt Refinement Suggestions |

## Description

Visual indicator showing AI confidence level in a suggestion or classification

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Percentage or dot with color |
| **Compact** | Badge with score and color |
| **Expanded** | Score with breakdown factors |

## Props / Configuration

- `score` — number (0-1)
- `label` — optional string
- `showBreakdown` — boolean
- `colorScale` — low|medium|high mapping

## Interactions

- hover for breakdown
- click for full analysis
