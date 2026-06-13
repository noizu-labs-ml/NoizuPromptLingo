# Confirmation Dialog

| Field | Value |
|-------|-------|
| **ID** | `confirmation-dialog` |
| **Category** | Modals / Destructive Actions |
| **Used In** | S03 Delete Universe, S05 Delete Entry, S17 Remove Collaborator, S19 Discard Draft |

## Description

Modal dialog requiring explicit user confirmation before executing irreversible or destructive actions. Standard risk level shows action description and Cancel / Confirm buttons. High-risk actions (delete universe, delete entry with dependents) additionally require the user to type the entity name exactly before the confirm button activates. Designed to interrupt accidental triggers while keeping intentional flows low-friction.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Headline + description + Cancel / Confirm buttons; standard risk |
| **Expanded** | Headline + consequence list + entity-name text field + Cancel / Confirm; high risk |

## Props / Configuration

- `title` — Dialog headline; e.g. "Delete Universe?"
- `description` — Supporting copy explaining what will happen and what cannot be undone
- `consequences` — Optional string array; each item rendered as a bullet in expanded variant (e.g. "All 142 canon entries will be permanently deleted")
- `confirmLabel` — Button label; defaults to "Delete" for delete actions, "Confirm" otherwise
- `confirmVariant` — `destructive | warning | primary`; controls button color
- `requireTyping` — Boolean; when true activates the entity-name confirmation field
- `entityName` — String; the exact name the user must type when `requireTyping` is true
- `onConfirm` — Callback invoked after validation passes and user clicks confirm
- `onCancel` — Callback invoked on cancel or Escape

## Interactions

- Dialog traps focus on open; Escape key triggers `onCancel`
- When `requireTyping` is true, confirm button is disabled until input matches `entityName` exactly (case-sensitive)
- Input field shows inline error message if user attempts to submit with a non-matching value
- Confirm button shows a spinner and disables during async `onConfirm` execution
- Backdrop click triggers `onCancel` for standard risk; is inert for high-risk (requires explicit cancel)
