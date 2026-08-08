# Modal Dialog

| Field | Value |
|-------|-------|
| **ID** | `modal-dialog` |
| **Category** | Modals & Overlays |
| **Used In** | 10-admin-users, 13-admin-github-integration, 20-sessions-list, 45-org-settings |

## Description

Center-screen dialog used for either a short creation form (new session, new access grant) or an intercepting confirmation before a consequential change (a self-lockout role change, a Danger Zone deletion/archival action).

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Confirmation dialog — message plus confirm/cancel |
| **Expanded** | Form dialog — one or more fields plus submit/cancel |

## Props / Configuration

- `intent` — `form` \| `confirm` \| `warning`
- `blocking` — prevents the underlying change from applying until the dialog resolves
- `fields` — when `intent` is `form`

## Interactions

- Triggering action opens the dialog; backdrop click or Cancel closes it without applying changes
- `intent: 'warning'` dialogs intercept an in-flight change (e.g. an admin's own role edit) and require explicit confirmation before it commits
- Form dialogs collect input and, on submit, create/apply the entity, then close
