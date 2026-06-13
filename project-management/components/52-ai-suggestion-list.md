# AI Suggestion List

| Field | Value |
|-------|-------|
| **ID** | `ai-suggestion-list` |
| **Category** | AI-Specific Components |
| **Used In** | 02-Morning Planning, 05-Inbox, 14-Sprint Planning, 17-Sprint Retrospective, 18-Backlog Grooming, 25-Root Cause Dashboard, 47-Agent-Generated Checklist Review, 52-Goal Retrospective, 72-Prompt Refinement Suggestions |

## Description

Ranked list of AI-generated suggestions with rationale, accept/reject controls, and confidence indicators

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Suggestion chips with accept/dismiss |
| **Expanded** | Full suggestion cards with rationale and actions |
| **Full_Page** | Dedicated suggestion review page |

## Props / Configuration

- `suggestions` — array of {text, rationale, confidence, id}
- `onAccept` — callback
- `onReject` — callback
- `bulkActions` — boolean
- `showRationale` — boolean

## Interactions

- accept/reject individual items
- bulk accept high-confidence
- hover for rationale
- reorder accepted items
- keyboard shortcuts for triage
