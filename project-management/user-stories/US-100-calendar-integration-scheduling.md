---
id: US-100
title: "Calendar Integration for Scheduling Consultations"
slug: "calendar-integration-scheduling"
personas: [P-001, P-002, P-003, P-004, P-006]
epic: "Integration & API"
priority: "must-have"
complexity: "L"
tags: [scheduling, calendar, google-calendar, calendly, integration, contact, conversion]
---

# US-100: Calendar Integration for Scheduling Consultations

## User Story

**As a** startup CTO / technical co-founder (P-001),
**I want to** schedule a consultation with Keith directly from the website by seeing his real availability and booking a time slot,
**So that** I can bypass email back-and-forth and secure a meeting without friction.

## Acceptance Criteria

- [ ] Given the Contact or Services page, when the user clicks "Schedule a Consultation," then an embedded scheduling widget (Calendly or custom Google Calendar integration) is displayed
- [ ] Given the scheduling widget, when it loads, then it reflects Keith's real-time availability with blocked slots for existing appointments and buffer times
- [ ] Given available slots, when the user selects a date and time, then they are prompted for their name, email, company, and a brief description of the engagement need
- [ ] Given a completed booking form, when submitted, then a confirmation email is sent to the user with calendar invite attachment (.ics), and Keith receives a notification
- [ ] Given the booking, when confirmed, then it is added to Keith's Google Calendar with the user-provided context in the event description
- [ ] Given the scheduling embed, when viewed on a mobile device, then the calendar picker and booking form are fully usable without horizontal scrolling
- [ ] Given a booked appointment, when the user needs to reschedule, then the confirmation email includes a link to modify or cancel the booking

## Notes

Phase 1 implementation: Calendly embed (fastest to deploy, handles availability sync, reminders, and rescheduling out of the box). Phase 2: custom Google Calendar API integration for tighter control over branding and data ownership. Event type: 30-minute intro call. Buffer time: 15 minutes between meetings. Related to US-001 (homepage hero CTA), US-006 (contact form). The scheduling CTA should be prominent on the Services page alongside each service offering.
