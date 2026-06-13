# Confirmation Prompt Card

| Field | Value |
|-------|-------|
| **ID** | `confirmation-prompt-card` |
| **Category** | AI-Specific |
| **Used In** | 32-Confirmation Gate Prompt |

## Description

Human-in-the-loop approval card for AI agent tool invocations. Shows tool name, caller identity, argument preview (configurable), timeout countdown, and approve/deny buttons.

## Size Variants

| Variant | Description |
|---------|-------------|

## Props / Configuration

- `tool`
- `caller`
- `arguments`
- `showArgs`
- `timeout`
- `onApprove`
- `onDeny`

## Interactions

- Approve
- Deny
- View full arguments
- Auto-deny on timeout expiry

