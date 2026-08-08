# Dynamic Custom-Field Form

| Field | Value |
|-------|-------|
| **ID** | `dynamic-custom-field-form` |
| **Category** | Input & Forms |
| **Used In** | 25-tickets-list |

## Description

Renders a ticket-creation form whose fields are generated at runtime from the selected custom ticket type's schema, rather than a fixed field set. The type selector drives which fields subsequently appear, so the form has no static shape — its complexity lives in correctly reflecting org/project-scoped schema definitions (authored via the Custom Field & Type Editor) back into a usable input form. Single-screen but structurally complex enough to warrant its own component.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full new-entity form with type selector and dynamically rendered fields |

## Props / Configuration

- `typeOptions` — the custom ticket types available in this project
- `schema` — the field set + validation rules for the currently selected type
- `onSubmit`

## Interactions

- User selects a custom ticket type → the field set re-renders to match that type's schema
- User fills the dynamic fields and submits → a new ticket is created with those field values attached
