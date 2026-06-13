# Version Selector

| Field | Value |
|-------|-------|
| **ID** | `version-selector` |
| **Category** | Domain-Specific |
| **Used In** | 39-Wiki Editor, 41-Runbook Manager, 61-Prompt Version Timeline, 62-Prompt Comparison, 69-Eval Rubric Builder |

## Description

Dropdown or timeline-based picker for selecting between versions of a prompt, template, runbook, or document

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Dropdown with version number/date |
| **Compact** | Selector with version label and author |
| **Expanded** | Timeline-based version browser |

## Props / Configuration

- `versions` — array of {id, label, date, author}
- `selected` — current version
- `onChange` — callback
- `showDiff` — boolean

## Interactions

- select version to view
- compare two versions
- restore previous version
