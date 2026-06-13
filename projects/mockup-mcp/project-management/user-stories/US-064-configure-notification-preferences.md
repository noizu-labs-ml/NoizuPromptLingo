---
id: US-064
title: "Configure notification preferences (email, in-app)"
slug: "configure-notification-preferences"
personas: [P-002, P-004, P-006]
epic: "Settings & Preferences"
priority: "could-have"
complexity: "S"
tags: [notifications, email, in-app, settings, preferences]
---

# US-064: Configure Notification Preferences

## User Story

**As a** Product Manager (P-002),
**I want to** control which events trigger email or in-app notifications,
**So that** I receive alerts for feedback on my mockups without being overwhelmed by noise.

## Acceptance Criteria

- [ ] Given the notification settings page, when I toggle email notifications for "new feedback received", then subsequent feedback events send (or suppress) email to my registered address accordingly
- [ ] Given the notification settings page, when I toggle in-app notifications for "generation complete" on long-running jobs, then the companion site shows (or hides) in-app alerts for those events
- [ ] Given I disable all notifications for a category, when that event fires, then no notification of that type is sent regardless of other settings
- [ ] Given I save notification preferences, when I revisit the settings page, then my saved choices are correctly reflected

## Notes

Notification types in scope: feedback received on shared mockup, generation job complete (async), API key activity alert. Email delivery routes through the platform's transactional email provider configured in the Phoenix backend.
