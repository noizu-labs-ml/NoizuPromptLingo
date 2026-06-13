# Publish Button

| Field | Value |
|-------|-------|
| **ID** | `publish-button` |
| **Category** | Input & Forms |
| **Used In** | 02-Graph Editor, 05-Prompt Detail, 07-Agent Detail, 12-Rubric Detail, 14-Persona Detail, 19-Dataset Detail |

## Description

Primary action button that locks the current draft state into an immutable published version. Runs validation before publishing (e.g., graph completeness checks for scripts). Shows confirmation with version number preview.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Standard button in a toolbar or header bar |

## Props / Configuration

- `entityType` — What is being published (script, prompt, agent, rubric, persona, dataset)
- `onPublish` — Callback on successful publish
- `validationErrors` — Array of blocking issues that prevent publishing
- `disabled` — Whether the button is disabled (no changes since last publish)
- `nextVersion` — Preview of the version number that will be created

## Interactions

- Click triggers validation; if errors, shows validation error list
- On success, creates immutable version and updates version history
- Disabled state when no changes exist since last publish
- Optional confirmation dialog showing what will be locked
