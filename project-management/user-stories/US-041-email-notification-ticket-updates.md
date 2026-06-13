---
id: US-041
title: "Email Notification for Ticket Updates"
slug: "email-notification-ticket-updates"
personas: [P-007, P-001, P-002, P-003]
epic: "Support & Communication"
priority: "must-have"
complexity: "S"
tags: [support, notifications, email, tickets]
---

# US-041: Email Notification for Ticket Updates

## User Story

**As a** client with an open support ticket (P-007),
**I want to** receive an email when my ticket is updated — whether Keith replies, changes the status, or resolves the issue,
**So that** I am notified promptly without needing to check the dashboard constantly.

## Acceptance Criteria

- [ ] Given Keith posts a reply to my ticket, when the reply is saved, then I receive an email notification within 2 minutes containing a summary of the reply and a link to the ticket
- [ ] Given Keith changes a ticket status (e.g. to "in-progress" or "resolved"), when the status changes, then I receive an email notification of the change
- [ ] Given I have opted out of ticket email notifications in my preferences (US-034), when a ticket is updated, then no email is sent but the update is still visible in-app
- [ ] Given I reply to the notification email, when the reply is received by the system, then it is appended as a message on the ticket thread
- [ ] Given a ticket is resolved, when I receive the resolution email, then it includes a link to the satisfaction feedback form (US-042)

## Notes

Email-to-ticket reply threading requires a dedicated inbound email address per ticket or a shared catch-all with ticket ID parsing. Transactional email via Resend, Postmark, or SES. Notification content should include: ticket subject, latest reply text (truncated to ~200 chars), ticket status, and a direct link. Respect unsubscribe/preferences from US-034.
