---
id: US-082
title: "Scheduled Report Delivery"
slug: "scheduled-report-delivery"
personas: [P-002, P-003]
epic: "Insights & Reporting"
priority: "could-have"
complexity: "M"
tags: [reports, scheduling, email, automation]
---

# US-082: Scheduled Report Delivery

## User Story

**As an** Industrial Operations Manager (P-002),
**I want to** schedule automatic report delivery to my email and my team's email on a recurring basis,
**So that** stakeholders receive regular updates without manual effort from me.

## Acceptance Criteria

- [ ] Given I am on a report page, when I click Schedule Delivery, then a modal lets me set frequency (daily, weekly, monthly), recipient email addresses, format (PDF/CSV), and start date
- [ ] Given a schedule is saved, when the scheduled time arrives, then the system generates and emails the report to all listed recipients with a subject line including the report name and date range
- [ ] Given I have active schedules, when I navigate to Report Schedules, then I see a list of all active schedules with their frequency, recipients, last sent date, and an option to pause or delete each
- [ ] Given a scheduled report fails to send, when the failure occurs, then the primary account owner receives an alert email within 15 minutes

## Notes

Recipients do not need an IoTGo account to receive scheduled PDF reports. Relates to US-081 (exportable reports). Initial release may limit recipients to 10 per schedule.
