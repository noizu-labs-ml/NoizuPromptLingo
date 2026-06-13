# Invite Form

| Field | Value |
|-------|-------|
| **ID** | `invite-form` |
| **Category** | Collaboration |
| **Used In** | S-16 Collaborators Panel |

## Description

Form for inviting collaborators to a universe. Accepts one or more email addresses, a role assignment, and an optional personal message. Tracks invite status (pending, accepted, expired) and surfaces errors inline.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Single email input + role selector + send button in one row — embedded within the collaborators panel |
| **Expanded** | Multi-line email input, role selector with role descriptions, optional message textarea, and send button — used in a modal when more context is needed |

## Props / Configuration

- `universeId` — Universe the invite is scoped to
- `availableRoles` — Array of role objects `{ id, label, description }` (e.g., Viewer, Editor, Co-Author)
- `defaultRole` — Pre-selected role ID
- `maxEmails` — Maximum number of email addresses per submission (default: 10)
- `onSend` — Callback invoked with `{ emails[], roleId, message }` on submission
- `onSuccess` — Callback invoked after successful invite dispatch; receives array of created invite records
- `onError` — Callback receiving error message string on failure

## Interactions

- Email input accepts comma-separated or line-separated addresses; each is tokenized into a removable chip on Enter or comma
- Invalid email format triggers inline validation error per chip before submission
- Role selector is a labeled dropdown; hovering a role shows its permission description in a tooltip
- Send button is disabled until at least one valid email is entered
- On submission, the button shows a spinner and is disabled to prevent double-send
- Success state replaces the form with a confirmation message listing sent addresses and a "Invite Another" link
- Pending invites are listed below the form with status badges (Pending, Accepted, Expired) and a Resend / Revoke action per invite
- Expired invites (older than 7 days) show a warning badge and a one-click Resend button
