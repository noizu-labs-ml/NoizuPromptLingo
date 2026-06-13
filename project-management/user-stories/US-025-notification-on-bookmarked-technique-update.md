---
id: US-025
title: "Receive Notification When a Bookmarked Technique Is Updated"
slug: "notification-on-bookmarked-technique-update"
personas: [P-001, P-002, P-005, P-006]
epic: "Attack Catalog"
priority: "won't-have-yet"
complexity: "M"
tags: [catalog, notifications, bookmarks, alerts, email]
---

# US-025: Receive Notification When a Bookmarked Technique Is Updated

## User Story

**As a** practitioner who has bookmarked techniques relevant to my deployment (P-001, P-002, P-005, P-006),
**I want to** receive a notification when a bookmarked technique is updated with new information,
**So that** I am alerted to newly discovered mitigations, severity changes, or newly affected models without having to manually re-check the catalog.

## Acceptance Criteria

- [ ] Given a technique I have bookmarked is updated, when the update is published, then I receive an email notification within 1 hour summarizing what changed (fields updated, new severity, new models added)
- [ ] Given I have multiple bookmarked techniques updated in the same day, when notifications are sent, then they are batched into a single daily digest email rather than individual emails per update
- [ ] Given I navigate to my notification preferences, when I configure settings, then I can choose between: immediate email, daily digest, or in-app only (no email)
- [ ] Given I receive a notification, when I click "View updated technique" in the email, then I am taken directly to the technique's detail page with the updated sections highlighted

## Notes

Depends on US-022 (bookmarks) being implemented first. Notification infrastructure (email provider, event queue) is non-trivial to build; deferred to later milestone. In-app notification bell is a prerequisite UI component. Daily digest batching prevents notification fatigue for active users.
