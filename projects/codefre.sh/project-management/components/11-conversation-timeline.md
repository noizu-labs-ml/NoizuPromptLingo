# Conversation Timeline

| Field | Value |
|-------|-------|
| **ID** | `conversation-timeline` |
| **Category** | Data Display |
| **Used In** | 09-Run Detail, 10-Run Diff, 17-Review Detail |

## Description

Chat-bubble timeline displaying the step-by-step conversation between the runner and agent during a test run. User messages appear on one side, agent responses on the other. Freeball steps are visually distinct (orange tint). Each step is expandable to show scores, raw JSON, and OTel links.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Preview of first few turns (used in Review Detail context panel) |
| **Expanded** | Full scrollable conversation with all steps and expandable details |

## Props / Configuration

- `steps` — Array of step objects (role, message, scores, metadata, isFreeballStep)
- `expandedStepId` — Currently expanded step
- `onStepExpand` — Callback when a step is expanded
- `showScores` — Whether to display per-step scores inline
- `personaFilter` — Filter steps by persona (for fan-out runs)
- `highlightFreeball` — Visual distinction for freeball-generated steps

## Interactions

- Scroll through conversation turns
- Click a step bubble to expand and see scores, raw JSON, OTel link
- Filter by persona on fan-out runs
- Freeball steps show confidence and parent node link
