# Password Input

| Field | Value |
|-------|-------|
| **ID** | password-input |
| **Type** | Simple |
| **Category** | Authentication |
| **Screen Usage** | Sign Up, Login, Password Reset, Password Change |

## Description

Password field with show/hide toggle and requirements display.

## Size Variants

- Small — Inline fields
- Medium — Default form fields
- Large — Password reset flow

## Props

- `id` — Unique identifier
- `name` — Form field name
- `value` — Current password value
- `placeholder` — Placeholder text
- `required` — Required field indicator
- `disabled` — Disabled state
- `error` — Error message string
- `showRequirements` — Display requirements checklist
- `minComplexity` — Password complexity rules

## Interactions

- Toggle password visibility (show/hide icon)
- Requirements display real-time validation
- Show checkmarks for met requirements
- Inline error on mismatch (confirm field)
- Copy-to-clipboard button disabled (security)

## Accessibility

- `type="password"` attribute
- Toggle button has `aria-label`
- Requirements list uses `ul` with role="list"
- `autocomplete="current-password"` or `new-password`