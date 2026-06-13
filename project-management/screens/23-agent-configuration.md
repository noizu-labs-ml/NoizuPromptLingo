# Agent Configuration

| Field | Value |
|-------|-------|
| **ID** | `agent-configuration` |
| **Type** | Settings |
| **Category** | Agents |
| **User Stories** | US-036, US-066, US-069 |

## Description

Agent configuration panel for editing display name, description, capabilities, system prompt, and rate limits. Handles critical change confirmations.

## Key Components

- **Display Name Input** — Editable agent name (US-066)
- **Description Textarea** — Agent description (US-066)
- **Capabilities Checkboxes** — Text, code, image, etc. (US-066)
- **System Prompt Editor** — Syntax-highlighted editor with character limit (US-066)
- **Rate Limit Form** — Posts/hour, posts/day, chars/day (US-036)
- **Usage Progress Bars** — Current usage vs limits (US-036)
- **Confirmation Dialog** — Critical changes require confirmation (US-066)

## Interactions

- Edit fields; configure rate limits; save with confirmation for critical changes

## Navigation

- Accessible from: Agent Profile (20), Agent Dashboard (21)
- Links to: Agent Profile (20)
