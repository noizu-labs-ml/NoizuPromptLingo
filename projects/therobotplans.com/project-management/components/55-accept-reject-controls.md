# Accept/Reject Controls

| Field | Value |
|-------|-------|
| **ID** | `accept-reject-controls` |
| **Category** | AI-Specific Components |
| **Used In** | 02-Morning Planning, 05-Inbox, 14-Sprint Planning, 18-Backlog Grooming, 25-Root Cause Dashboard, 47-Agent-Generated Checklist Review, 72-Prompt Refinement Suggestions |

## Description

Binary or ternary action buttons for approving or dismissing AI suggestions, with optional modify

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Thumbs up/down icons |
| **Compact** | Accept/Reject button pair |
| **Expanded** | Accept/Modify/Reject with reason field |

## Props / Configuration

- `onAccept` — callback
- `onReject` — callback
- `onModify` — optional callback
- `requireReason` — boolean
- `style` — buttons|icons|swipe

## Interactions

- click accept/reject
- swipe left/right on mobile
- keyboard shortcuts
- optional reason on reject
