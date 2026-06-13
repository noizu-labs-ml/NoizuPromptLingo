# Error Message

| Field | Value |
|-------|-------|
| **ID** | `error-message` |
| **Category** | Feedback & Indicators |
| **Used In** | 02-Login/Signup, 12-Create Space, 17-Thread View, 25-Resource Creation, 26-Resource Detail, 31-Search Results |

## Description

Contextual error display with suggested actions. Supports inline field errors, form-level errors, and full-page error states. Each error includes a suggested resolution.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Red text below a form field |
| **Compact** — Alert box with error + action |
| **Expanded** | Error box with details + suggested actions + retry |
| **Full Page** | Full-page error with illustration + retry/refresh |

## Props / Configuration

- `variant` — Inline, Alert, FullPage
- `message` — Error description
- `suggestedActions` — Array of {label, action} suggestions
- `retryable` — Show retry button

## Interactions

- Click suggested action → execute; click retry → re-attempt
