# Multi-Section Accordion Form

| Field | Value |
|-------|-------|
| **ID** | `multi-section-accordion-form` |
| **Category** | Input & Forms |
| **Used In** | 01-Task Creation Form, 06-Agent Registration Form |

## Description

Accordion-style form container with collapsible labeled sections and inline validation. Supports draft auto-save, section-level error states, and both single-open and all-expanded display modes.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Single section open at a time; others collapsed |
| **Expanded** | All sections visible simultaneously for overview or review |

## Props / Configuration

- `sections[]` — Array of section definitions with id, label, fields, and validation rules
- `validationRules` — Validation schema applied per field on change and submit
- `onSave` — Callback to save draft state
- `onPublish` — Callback to submit the completed form
- `draftStatus` — Current draft save state (e.g., "saved", "saving", "unsaved")
- `expandedSections[]` — Array of section IDs currently expanded (controlled mode)

## Interactions

- Click a section header to expand or collapse it
- Tab through fields within an open section
- Real-time inline validation triggers on field blur
- Section header shows error indicator when that section has validation failures
