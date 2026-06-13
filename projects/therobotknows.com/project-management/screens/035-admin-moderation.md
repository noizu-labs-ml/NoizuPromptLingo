# Admin Moderation Queue

| Field | Value |
|-------|-------|
| **ID** | admin-moderation |
| **Type** | Primary |
| **Category** | Admin |
| **User Stories** | US-087, US-089, US-090 |

## Description

Content moderation interface for flagged public content.

## Key Components

- **Moderation Queue** — Listed reports with reason, reporter, content link (US-087)
- **Flagged Item Preview** | View content being reported (US-087)
- **Unpublish Button** — Hide content from public views (US-087)
- **Dismiss Button** — Resolve report with no action (US-087)
- **Audit Record** — Moderator, timestamp, action, notes (US-087)
- **AI Generated Badge** | Indicate AI vs user-authored content (US-087)
- **Abuse Alerts List** — Automated abuse detection flags (US-089)
- **Escalate Button** | Bring abuse to higher priority (US-089)
- **Policy Table** — Active policies with version, effective date, action count (US-090)
- **Create Policy Form** | New policy rule, severity, action (US-090)
- **Policy Version History** | Archived previous versions (US-090)

## Interactions

- Unpublish immediately hides content
- Owner notified by automated email
- Dismiss resolves, decrements queue count
- All actions written to audit log
- Abuse detection auto-flags thresholds
- Policy rules apply within 60 seconds
- Policy versions never deleted

## Navigation

- Accessible from: Admin Dashboard (Moderation link)
- Links to: Flagged Content Detail, Policy Detail