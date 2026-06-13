# Admin Moderation Queue

| Field | Value |
|-------|-------|
| **ID** | `admin-moderation-queue` |
| **Type** | Primary |
| **Category** | Admin & Moderation |
| **User Stories** | US-087, US-088, US-091 |

## Description

Platform admin view for reviewing flagged servers, managing publisher verification applications, and taking enforcement actions (suspend, warn, dismiss).

## Key Components

- **ModerationQueueList**
- **FlagDetailPanel**
- **ServerManifestViewer**
- **ModerationActionButtons**
- **PublisherApplicationList**
- **VerificationChecklist**
- **SuspensionDialog**

## Interactions

- Review flagged servers
- Dismiss or escalate flags
- Suspend server
- Approve/reject publisher verification
- Revoke verified status
- Bulk actions

## Navigation

- Admin -> Moderation Queue
