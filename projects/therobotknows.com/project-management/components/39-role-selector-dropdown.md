# Role Selector Dropdown

| Field | Value |
|-------|-------|
| **ID** | `role-selector-dropdown` |
| **Category** | Forms / Permissions |
| **Used In** | S02 Profile Setup, S17 Collaborator Panel |

## Description

Dropdown component for selecting a user's self-declared narrative role (Novelist, Game Master, Narrative Designer, Screenwriter, Hobbyist, Other) during onboarding, or for setting a collaborator's permission level (Owner, Editor, Commenter, Viewer) within a universe. The two modes are configured via the `mode` prop. Each option includes a short description to aid selection. The selected value influences AI prompt defaults and feature visibility.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Single-row trigger with selected value + chevron; options in a standard dropdown menu |
| **Expanded** | Card-grid picker with icon, label, and description per option; used in onboarding step |

## Props / Configuration

- `mode` — `narrative-role | permission-level`; determines the option set
- `value` — Currently selected option key
- `onChange` — Callback `(value: string) => void`
- `options` — Optional override array of `{ value, label, description, icon }`; replaces the default option set for the mode
- `disabled` — Boolean; prevents interaction; used when the current user cannot change their own owner role
- `size` — `inline | expanded`
- `label` — Form field label text; defaults to "Role" or "Permission" based on mode
- `helperText` — Optional string below the field explaining the impact of the selection

## Interactions

- Inline dropdown opens a listbox with keyboard navigation (arrow keys, Enter to select, Escape to close)
- Expanded card-grid highlights selected card with a border and checkmark; click selects
- Selecting "Owner" in permission-level mode shows a confirmation step explaining ownership transfer
- When `disabled`, trigger renders in muted style with a tooltip explaining why it is locked
- Selection triggers `onChange` immediately; parent decides whether to auto-save or wait for form submit
