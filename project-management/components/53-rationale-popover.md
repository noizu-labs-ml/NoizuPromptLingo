# Rationale Popover

| Field | Value |
|-------|-------|
| **ID** | `rationale-popover` |
| **Category** | AI-Specific Components |
| **Used In** | 02-Morning Planning, 05-Inbox, 14-Sprint Planning, 18-Backlog Grooming, 25-Root Cause Dashboard, 47-Agent-Generated Checklist Review, 72-Prompt Refinement Suggestions |

## Description

Hover/click popover explaining why the AI made a specific suggestion or decision

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Inline italic text explanation |
| **Compact** | Popover tooltip on hover |
| **Expanded** | Panel with full reasoning chain |

## Props / Configuration

- `rationale` — string
- `trigger` — hover|click
- `factors` — optional array of contributing factors

## Interactions

- hover to show popover
- click to pin open
- navigate to related data points
