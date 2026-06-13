# Confirmation Gate Prompt

| Field | Value |
|-------|-------|
| **ID** | `confirmation-gate-prompt` |
| **Type** | Modal |
| **Category** | SafeMCP / Policy |
| **User Stories** | US-015 |

## Description

Human-in-the-loop approval dialog shown when a tool invocation triggers a confirmation gate. Shows tool name, arguments (if configured), approve/deny actions with timeout countdown.

## Key Components

- **ConfirmationPromptCard**
- **ArgumentPreview**
- **TimeoutCountdown**
- **ApproveButton**
- **DenyButton**

## Interactions

- Approve invocation
- Deny invocation
- View full arguments
- Auto-deny on timeout

## Navigation

- Triggered from dashboard notification or push
