---
id: US-071
title: "RFI Follow-Up Scheduling"
slug: "rfi-follow-up-scheduling"
personas: [P-007]
epic: "RFI Dashboard"
priority: "should-have"
complexity: "S"
tags: [admin, rfi, follow-up, scheduling, crm]
---

# US-071: RFI Follow-Up Scheduling

## User Story

**As a** site administrator,
**I want to** schedule follow-up reminders on open RFIs so I am prompted to re-engage prospects at the right time,
**So that** warm leads don't go cold due to simple oversight.

## Acceptance Criteria

- [ ] Given I am viewing an RFI record, when I click "Schedule Follow-Up", then I can set a date, time, and optional note for the reminder.
- [ ] Given a follow-up is scheduled, when the scheduled date/time arrives, then an admin notification is created and an email reminder is sent to the admin.
- [ ] Given the admin RFI queue, when I view the "Follow-Ups Due" filter, then I see all RFIs with a scheduled follow-up due today or overdue, sorted by urgency.
- [ ] Given I complete a follow-up action (sent a message, updated status), when I mark it as "Done", then the follow-up is cleared and I can optionally schedule the next one.
- [ ] Given a follow-up is overdue by 2+ days, when I view the RFI list, then the overdue follow-up is visually flagged (e.g., red badge on the row).
- [ ] Given I cancel a scheduled follow-up, when confirmed, then the reminder is removed and no notification fires.

## Notes

Follow-up scheduling is lightweight — a single next-action date per RFI at MVP. Multi-sequence drip follow-ups are future scope. Related: US-068, US-069.
