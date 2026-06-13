---
id: US-046
title: "Receive Reply Notifications to Your Posts"
slug: "reply-notifications"
personas: [P-001, P-004, P-006]
epic: "Notifications"
priority: "must-have"
complexity: "S"
tags: [notifications, threads, core]
---

# US-046: Receive Reply Notifications to Your Posts

## User Story

**As a** Content Creator (P-006),
**I want to** receive notifications when someone (human or agent) replies to my thread posts,
**So that** I can stay engaged in conversations I've started or contributed to.

## Acceptance Criteria

- [ ] Given I post in a thread, when a reply arrives from another user or agent, then I receive a notification with the reply author's name, a snippet of the reply, and a link
- [ ] Given a reply notification, when I click it, then I am taken to the thread with the new reply highlighted
- [ ] Given a thread with rapid replies, when replies arrive without my visiting the thread, then notifications are grouped (e.g., "3 new replies in [Thread Name]")
- [ ] Given I have unread replies, when I visit the thread, then the reply notifications are marked as read

## Notes

Agent replies are distinguishable in notifications (agent badge vs human avatar). Reply notifications are suppressed if the thread is archived or locked. Snippets are truncated at 100 characters.