---
id: US-065
title: "Bulk Operations"
slug: "bulk-operations"
personas: [P-007]
epic: "Admin Dashboard"
priority: "could-have"
complexity: "M"
tags: [admin, bulk, export, email, operations]
---

# US-065: Bulk Operations

## User Story

**As a** site administrator,
**I want to** perform bulk actions on clients, inquiries, and projects — including mass email, export to CSV, and status updates,
**So that** I can manage a growing client base without performing the same action dozens of times individually.

## Acceptance Criteria

- [ ] Given I am on the admin client list, when I select multiple clients via checkboxes and click "Bulk Action", then I see options: Send Email, Export CSV, Change Status.
- [ ] Given I choose "Send Email" with multiple clients selected, when I compose and send, then the message is dispatched to all selected clients and each send is logged against the respective client record.
- [ ] Given I choose "Export CSV", when the export runs, then a CSV file is generated and downloaded containing selected clients' name, company, email, engagement type, and status.
- [ ] Given I am on the inquiry list, when I select multiple inquiries and choose "Mark Resolved", then all selected inquiries are updated to Resolved status in one action.
- [ ] Given a bulk email is queued to more than 10 recipients, when sent, then it is dispatched via the job queue (not synchronously) and I receive a confirmation notification when complete.
- [ ] Given I trigger a bulk export, when the export file is generated, then it is available for download for 24 hours via a secure link.

## Notes

Bulk email should include unsubscribe compliance if sent to all clients (even in a B2B context, follow CAN-SPAM/CASL best practice). CSV exports must not include passwords or sensitive auth tokens. Related: US-052, US-056.
