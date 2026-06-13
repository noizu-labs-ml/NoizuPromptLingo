---
id: US-067
title: "RFI Status Tracking for Prospects"
slug: "rfi-status-tracking"
personas: [P-001, P-002, P-003]
epic: "RFI Dashboard"
priority: "must-have"
complexity: "M"
tags: [rfi, prospect, status, tracking, transparency]
---

# US-067: RFI Status Tracking for Prospects

## User Story

**As a** non-technical founder who submitted an RFI (P-003),
**I want to** check the current status of my request and see any messages or next steps from Keith,
**So that** I am not left wondering whether my inquiry was received and what happens next.

## Acceptance Criteria

- [ ] Given I submitted an RFI and received a reference number, when I navigate to `/rfi/status/{reference}`, then I see my RFI detail with current status, submission date, and service type requested.
- [ ] Given my RFI is in progress, when I view the status page, then a progress indicator shows the current stage: Submitted → Under Review → Response Sent → Proposal Issued → Closed.
- [ ] Given the admin has added a message to my RFI record, when I view the status page, then the message is displayed in a "Updates from Keith" section with timestamp.
- [ ] Given my RFI has been responded to (status: Response Sent), when I view the status page, then a "View Response" button or linked document is shown.
- [ ] Given my RFI has been open for more than 3 business days with no activity, when I view the status page, then an estimated response time notice is shown.
- [ ] Given I provided an email at submission, when the RFI status changes, then I receive an email notification with a link back to the status page.

## Notes

Status page is accessible without login using the reference number as a token (link-based access). For registered prospects, it also appears in their dashboard. Related: US-066, US-068.
