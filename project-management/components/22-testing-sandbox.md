# Testing Sandbox

| Field | Value |
|-------|-------|
| **ID** | `testing-sandbox` |
| **Category** | Domain-Specific |
| **Used In** | 05-Prompt Detail, 12-Rubric Detail |

## Description

Interactive pane for testing prompts or rubrics against a live agent without creating a full run. In prompt mode: select agent, bind variables, send, view response. In rubric mode: paste sample input/response, click "Score now", view judge output.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Split pane within detail page — input on left, output on right |

## Props / Configuration

- `mode` — `prompt-test` | `rubric-preview`
- `agentPicker` — Embedded agent/version selector (prompt mode)
- `variableBindings` — Current variable values to render prompt (prompt mode)
- `sampleInput` / `sampleResponse` — Text areas for scoring input (rubric mode)
- `onSend` / `onScore` — Execute test action

## Interactions

- Select agent and bind variables (prompt mode)
- Paste sample text (rubric mode)
- Click "Send" or "Score now" to execute
- View response or scoring output in result pane
- Iterate: modify input and re-test
