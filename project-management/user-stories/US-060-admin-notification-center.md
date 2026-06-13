---
id: US-060
title: "Admin Notification Center"
slug: "admin-notification-center"
personas: [P-007]
epic: "Admin Dashboard"
priority: "should-have"
complexity: "S"
tags: [admin, notifications, alerts, inbox]
---

# US-060: Admin Notification Center

## User Story

**As a** site administrator,
**I want to** receive and manage in-app notifications for key events (new inquiries, overdue milestones, client messages, invoice statuses),
**So that** I can respond to time-sensitive items without relying solely on email alerts.

## Acceptance Criteria

- [ ] Given a triggering event occurs (new inquiry, milestone overdue, invoice overdue, new client message), when the event fires, then an in-app notification is created and the notification bell badge count increments.
- [ ] Given I click the notification bell, when the panel opens, then I see up to 50 recent notifications with event type icon, brief description, and relative timestamp.
- [ ] Given I click a notification, when opened, then I am navigated to the relevant resource (inquiry detail, project milestone, invoice) and the notification is marked as read.
- [ ] Given I click "Mark all read", when confirmed, then all unread notifications are cleared and the badge resets to zero.
- [ ] Given notifications exist older than 90 days, when the nightly cleanup runs, then they are archived and no longer shown in the panel.
- [ ] Given notification preferences exist, when I toggle a notification type off, then events of that type no longer generate in-app notifications (but may still generate emails based on separate email preference settings).

## Notes

Email delivery is handled by a separate transactional email layer. This story covers in-app only. Related: US-051, US-056, US-058.
