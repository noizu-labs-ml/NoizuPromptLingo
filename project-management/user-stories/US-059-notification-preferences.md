---
id: US-059
title: "Notification Preferences"
slug: "notification-preferences"
personas: [P-001, P-002, P-005, P-007]
epic: "Social & Collaboration"
priority: "should-have"
complexity: "M"
tags: [notifications, preferences, settings, email]
---

# US-059: Notification Preferences

## User Story

**As an** indie developer (P-005),
**I want to** control which events trigger notifications and via which channels,
**So that** I receive only the alerts I care about and avoid inbox noise.

## Acceptance Criteria

- [ ] Given I am authenticated, when I navigate to notification settings, then I see a list of notification event types (replies, mentions, follows, upvotes, moderation actions)
- [ ] Given an event type, when I toggle its in-app notification off, then I no longer receive in-app alerts for that event
- [ ] Given an event type with email enabled, when the event fires, then I receive an email notification within a reasonable delivery window
- [ ] Given I disable all email notifications, when events occur, then no emails are sent but in-app notifications still function according to their own settings
- [ ] Given I save my preferences, when the page reloads, then my preferences are persisted and reflected accurately

## Notes

Granularity should cover at minimum: replies to my prompts, replies to my comments, mentions, new followers, and moderation actions on my content. Email batching (e.g., daily digest) should be a future option to reduce email volume.
