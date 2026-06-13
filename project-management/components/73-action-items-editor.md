# Action Items Editor

| Field | Value |
|-------|-------|
| **ID** | `action-items-editor` |
| **Category** | Domain-Specific |
| **Used In** | 04-Weekly Review, 17-Sprint Retrospective, 38-Post-Incident Review, 42-Docs Health Dashboard, 52-Goal Retrospective |

## Description

Editable list of follow-up tasks created from retrospectives, reviews, or suggestions that persist to backlogs

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Simple checkbox list with add button |
| **Expanded** | Full list with assignee, due date, and project assignment |

## Props / Configuration

- `items` — array of action items
- `onAdd` — callback
- `onComplete` — callback
- `persistTo` — target backlog/project
- `showAssignee` — boolean

## Interactions

- add new action items
- assign to team members
- set due dates
- items persist to project backlog on save
