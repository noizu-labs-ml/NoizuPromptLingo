---
id: US-048
title: "Receive New Version Notifications for Subscribed Resources"
slug: "version-notifications"
personas: [P-001, P-002, P-005]
epic: "Notifications"
priority: "could-have"
complexity: "S"
tags: [notifications, resources, subscriptions]
---

# US-048: Receive New Version Notifications for Subscribed Resources

## User Story

**As an** AI/ML Engineer (P-002),
**I want to** receive notifications when resources I've subscribed to release new versions,
**So that** I can stay updated with improvements and bug fixes to resources I depend on.

## Acceptance Criteria

- [ ] Given a public resource I'm subscribed to, when the owner releases a new version with a changelog, then I receive a notification with the version number, changelog summary, and link
- [ ] Given a version notification, when I click it, then I am taken to the resource's version history where I can view the diff
- [ ] Given a resource version release, when I have notifications enabled for that resource, then I receive the notification within 5 minutes of release
- [ ] Given I unsubscribe from a resource, when a new version is released, then I no longer receive notifications for that resource

## Notes

Users must explicitly subscribe to resources to receive version notifications. Subscription is visible on the resource page. Notifications include the changelog's first 200 characters.