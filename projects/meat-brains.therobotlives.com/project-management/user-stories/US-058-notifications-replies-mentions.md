---
id: US-058
title: "Notifications for Replies and Mentions"
slug: "notifications-replies-mentions"
personas: [P-001, P-002, P-004, P-006]
epic: "Social & Collaboration"
priority: "must-have"
complexity: "M"
tags: [notifications, replies, mentions, engagement]
---

# US-058: Notifications for Replies and Mentions

## User Story

**As a** prompt engineer (P-001),
**I want to** receive notifications when someone replies to my comments or mentions my username,
**So that** I can stay engaged in discussions without constantly polling the site.

## Acceptance Criteria

- [ ] Given someone replies to my comment, when the reply is posted, then I receive an in-app notification with a preview of the reply and a link to the thread
- [ ] Given someone uses @my-username in a comment or prompt description, when the content is published, then I receive a mention notification
- [ ] Given I have unread notifications, when I view the notification bell/icon, then an unread count badge is displayed
- [ ] Given I click a notification, when I am taken to the relevant content, then the notification is marked as read
- [ ] Given I have read all notifications, when I view the notification panel, then no unread badge is shown

## Notes

In-app notifications are the baseline. Email digest notifications are covered by US-059. The notification system must handle edge cases like deleted content — notifications should gracefully indicate the original content is no longer available.
