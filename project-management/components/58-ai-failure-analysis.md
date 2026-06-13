# AI Failure Analysis

| Field | Value |
|-------|-------|
| **ID** | `ai-failure-analysis` |
| **Category** | AI-Specific Components |
| **Used In** | 27-Pipeline Status, 31-Rollback Confirmation, 37-Anomaly Correlation |

## Description

Agent-generated hypothesis panel explaining why something failed (pipeline, deploy, test) with evidence links

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Summary hypothesis text |
| **Expanded** | Full analysis with evidence links and confidence |

## Props / Configuration

- `hypothesis` — string
- `confidence` — number
- `evidence` — array of links
- `suggestedAction` — optional string

## Interactions

- click evidence links to navigate
- accept/dismiss hypothesis
- create action item from suggestion
