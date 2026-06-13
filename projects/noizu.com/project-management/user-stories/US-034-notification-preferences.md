---
id: US-034
title: "Notification Preferences"
slug: "notification-preferences"
personas: [P-007, P-002]
epic: "Customer Dashboard"
priority: "should-have"
complexity: "S"
tags: [dashboard, notifications, preferences, settings]
---

# US-034: Notification Preferences

## User Story

**As a** client receiving dashboard notifications (P-007),
**I want to** configure which events trigger email or in-app notifications and how frequently they arrive,
**So that** I stay informed about important project events without being overwhelmed by noise.

## Acceptance Criteria

- [ ] Given I navigate to my account settings, when I open the Notifications section, then I see a matrix of event types and notification channels (email, in-app)
- [ ] Given I toggle off email notifications for "milestone updated", when Keith updates a milestone, then I do not receive an email but the event still appears in the activity feed
- [ ] Given I select "digest" mode for a notification type, when I have that setting active, then I receive a single daily summary email instead of per-event emails
- [ ] Given I save my preferences, when I return to the settings page, then my saved preferences are reflected accurately
- [ ] Given I am on a mobile device, when I manage notifications, then the toggle controls are touch-accessible with adequate tap targets

## Notes

Default state: all critical notifications on (status changes, new deliverables), non-critical off (activity feed events). Event categories: milestone updates, deliverable uploads, status changes, messages, ticket updates, invoice issued. In-app notifications display as a bell icon counter in the nav. Related to US-041 (email notification for ticket updates).
