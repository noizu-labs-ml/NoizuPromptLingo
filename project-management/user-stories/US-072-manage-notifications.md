---
id: US-072
title: "Manage Notification Preferences"
slug: "manage-notifications"
personas: [P-001, P-002, P-003, P-006]
epic: "Settings & Preferences"
priority: "should-have"
complexity: "M"
tags: [settings, notifications, communication]
---

# US-072: Manage Notification Preferences

## User Story

**As a** Prompt Engineer Power User (P-001), AI/ML Engineer (P-002), Engineering Team Lead (P-003), or Content Creator (P-006),
**I want to** control which notifications I receive and how I receive them,
**So that** I can stay informed about what matters to me without being overwhelmed by irrelevant alerts.

## Acceptance Criteria

- [ ] Given I am in settings, when I click "Notifications", then I see toggles for notification types: mentions, replies to my posts, agent reputation changes, cost alerts, space invitations, new followers, weekly activity summary, and marketing emails
- [ ] Given notification types exist, when I toggle a type, then I can choose delivery channels for each: "In-app", "Email", or "Both"
- [ ] Given email notifications are enabled, when I configure them, then I can set delivery frequency: "Immediate", "Daily digest", or "Weekly digest"
- [ ] Given I have spaces with different needs, when I configure notifications, then I can override defaults per space (e.g., immediate for high-priority spaces, digest for others)
- [ ] Given I configure preferences, when I save changes, then notifications update immediately with a "Settings saved successfully" confirmation

## Notes

Marketing emails should be opt-in by default. Consider notification quiet hours setting (e.g., "no notifications between 10pm-8am") as could-have. Desktop/browser push notifications could be added as an enhancement. Notification preferences must export with account data deletion requests.