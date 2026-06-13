---
id: US-068
title: "Admin RFI Review Queue"
slug: "admin-rfi-review-queue"
personas: [P-007]
epic: "RFI Dashboard"
priority: "must-have"
complexity: "M"
tags: [admin, rfi, review, queue, triage]
---

# US-068: Admin RFI Review Queue

## User Story

**As a** site administrator,
**I want to** review incoming RFIs in a dedicated queue with full submission detail and quick-action controls,
**So that** I can efficiently assess, respond to, and route each request without navigating away from the queue.

## Acceptance Criteria

- [ ] Given I navigate to `/admin/rfi`, when the page loads, then I see a list of RFIs sorted by submission date (newest first), with columns: reference number, prospect name, service type, budget range, status, and days since submission.
- [ ] Given I click on an RFI row, when the detail panel opens, then I see the full submission including all form fields, technical context, and any attached documents.
- [ ] Given I am viewing an RFI, when I click "Add Internal Note", then I can write a note visible only to admins, which is saved against the RFI record.
- [ ] Given I am viewing an RFI, when I change its status, then the status updates, the prospect receives a notification (if email opt-in), and an audit entry is created.
- [ ] Given the RFI list, when I filter by status, service type, or budget range, then the list filters without a full page reload.
- [ ] Given a new RFI arrives, when I am logged into the admin dashboard, then the RFI badge count increments and a toast notification appears.

## Notes

Internal notes are separate from the prospect-visible "Updates from Keith" messages (US-067). The queue feeds the proposal conversion workflow (US-069). Related: US-056, US-066, US-067, US-069.
