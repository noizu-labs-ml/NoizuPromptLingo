---
id: US-031
title: "Meeting and Call Scheduling"
slug: "meeting-call-scheduling"
personas: [P-007, P-001, P-002, P-003]
epic: "Customer Dashboard"
priority: "should-have"
complexity: "M"
tags: [dashboard, scheduling, meetings, calendar]
---

# US-031: Meeting and Call Scheduling

## User Story

**As a** client who needs to sync with Keith regularly (P-007),
**I want to** schedule a call or meeting directly from the dashboard,
**So that** I don't need to go through back-and-forth emails to find a time.

## Acceptance Criteria

- [ ] Given I am on the dashboard or project detail page, when I click "Schedule a Call", then I am presented with available time slots based on Keith's calendar
- [ ] Given I select a time slot, when I confirm, then a calendar invite is sent to both my email and Keith's
- [ ] Given I have a scheduled meeting, when I view the dashboard, then upcoming meetings are shown in a "Next Meeting" widget
- [ ] Given I need to cancel a meeting, when I cancel from the dashboard, then both parties receive a cancellation notification
- [ ] Given I attempt to schedule fewer than 24 hours out, when I submit, then I see a warning that short-notice bookings may not be confirmed

## Notes

Integration with Calendly or Cal.com preferred over building a custom scheduler. Meeting types: check-in (30m), working session (60m), executive briefing (45m). Keith's availability driven by an external calendar. Future: allow rescheduling without cancelling. Consider linking scheduled meetings to specific projects for context.
