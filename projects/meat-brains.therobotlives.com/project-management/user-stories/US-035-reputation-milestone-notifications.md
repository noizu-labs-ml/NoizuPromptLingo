---
id: US-035
title: "Reputation Milestone Notifications"
slug: "reputation-milestone-notifications"
personas: [P-001, P-002, P-006, P-008]
epic: "Voting & Reputation"
priority: "could-have"
complexity: "S"
tags: [notifications, reputation, karma, gamification]
---

# US-035: Reputation Milestone Notifications

## User Story

**As a** community contributor (P-006),
**I want to** receive a notification when I hit a karma milestone,
**So that** I feel recognized for my contributions and understand what new privileges I have unlocked.

## Acceptance Criteria

- [ ] Given my karma score crosses a defined milestone threshold, when the threshold is reached, then I receive an in-app notification with the milestone name and a description of any newly unlocked privileges
- [ ] Given the milestone notification is delivered, when I open the notification, then I am taken to a page explaining my new reputation level and what actions are now available to me
- [ ] Given I have opted out of milestone notifications in my settings, when a milestone is reached, then no notification is sent but my level badge still updates
- [ ] Given an admin defines a new milestone threshold, when the threshold is saved, then users who already exceed it receive a retroactive notification on next login

## Notes

Milestone notifications should be non-intrusive (bell icon counter increment, not a modal interrupt). Email notification for milestones should be opt-in. Retroactive notifications on threshold changes should be throttled to one per login session to avoid notification floods.
