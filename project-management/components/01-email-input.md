# Email Input

| Field | Value |
|-------|-------|
| **ID** | email-input |
| **Type** | Simple |
| **Category** | Authentication |
| **Screen Usage** | Sign Up, Login, Password Reset, Invite Collaborators, Login |

## Description

Standard email input field with validation and formatting.

## Size Variants

- Small (inline forms)
- Medium (default)
- Large (wizard steps)

## Props

- `id` — Unique identifier
- `name` — Form field name
- `value` — Current email value
- `placeholder` — Placeholder text
- `required` — Required field indicator
- `disabled` — Disabled state
- `error` — Error message string

## Interactions

- Validates email format on blur
- Shows inline error if format invalid
- Auto-lowercases on input
- Trims whitespace on blur
- Focus outline on keyboard nav

## Accessibility

- `type="email"` attribute
- `aria-label` or `aria-invalid` on error
- `autocomplete="email"` on sign-up forms