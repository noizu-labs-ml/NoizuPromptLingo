# Policy Rule Editor

| Field | Value |
|-------|-------|
| **ID** | `policy-rule-editor` |
| **Category** | Admin / Moderation |
| **Used In** | S25 Admin Moderation Settings |

## Description

Form component for creating and editing moderation policy rules that govern AI generation behavior and content flagging. Composed of three sections: a condition builder (what triggers the rule), a severity selector (how the match is classified), and an action picker (what happens when the rule fires). Supports both simple keyword/pattern conditions and structured logical conditions (AND / OR groups). Used exclusively in the admin moderation settings screen.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full three-section form with condition builder, severity selector, action picker; only applicable variant |

## Props / Configuration

- `rule` — Rule object `{ id, name, enabled, conditions, severity, actions }`; null for new rule creation
- `onSave` — Async callback `(rule) => Promise<void>`; receives the validated rule; handles both create and update
- `onCancel` — Callback invoked when user cancels without saving
- `onDelete` — Optional callback; when provided renders a "Delete Rule" button that triggers a confirmation dialog
- `availableActions` — Array of `{ value, label, description }`; list of actions the rule can trigger (e.g., `flag_for_review`, `block_generation`, `add_warning_badge`, `notify_admin`)
- `testMode` — Boolean; when true renders a "Test Rule" panel where admin can paste sample text and see if the rule would fire

## Interactions

- Condition builder supports adding/removing condition rows; each row has: field selector, operator dropdown, value input
- AND/OR group logic rendered as nested condition groups with "Add condition" and "Add group" buttons
- Severity selector is a segmented control: Suggestion / Warning / Error
- Action picker is a multi-select checklist; actions incompatible with the selected severity are dimmed with tooltip explanation
- "Test Rule" panel shows real-time match highlight as admin types sample text
- Save button disabled until rule name is filled and at least one condition and one action are defined
- Unsaved changes show a dirty indicator in the form header; navigating away triggers a "Discard changes?" confirmation
