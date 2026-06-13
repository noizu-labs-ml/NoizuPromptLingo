---
id: US-047
title: "Receive Resource Fork Notifications"
slug: "fork-notifications"
personas: [P-001, P-002, P-005]
epic: "Notifications"
priority: "should-have"
complexity: "S"
tags: [notifications, resources, forking]
---

# US-047: Receive Resource Fork Notifications

## User Story

**As a** Prompt Engineer Power User (P-001),
**I want to** receive notifications when someone forks my public resources,
**So that** I can track which of my resources are valuable to the community.

## Acceptance Criteria

- [ ] Given I own a public resource, when someone forks it, then I receive a notification with the forker's name, the resource title, and a link to the fork
- [ ] Given a fork notification, when I click it, then I am taken to the new fork's page where I can see the fork's lineage
- [ ] Given multiple forks of the same resource, when they occur in quick succession, then notifications are grouped (e.g., "3 new forks of [Resource Name]")
- [ ] Given I own a private resource, when someone attempts to fork it, then no notification is generated and the fork fails

## Notes

Fork notifications are optional in user settings (disabled by default). Forker name is shown unless the forker has a private profile (then shows "Anonymous"). Notification summary shows total fork count per resource.