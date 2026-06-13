# Report Modal

| Field | Value |
|-------|-------|
| **ID** | `report-modal` |
| **Category** | Modals & Overlays |
| **Used In** | 17-Thread View, 26-Resource Detail |

## Description

Modal for reporting posts or resources. Collects reason category, free-text details, and confirmation. Prevents self-reporting and shows "already reported" state.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** — Reason category select + submit |
| **Expanded** | Reason category + free-text details + submit |

## Props / Configuration

- `targetType` — Post or Resource
- `targetId` — Entity being reported
- `categories` — Spam, Harassment, Hate, Misinformation, Abuse, Other

## Interactions

- Select category → optionally add details → submit
- Already reported → show status message
- Self-report → prevention message
