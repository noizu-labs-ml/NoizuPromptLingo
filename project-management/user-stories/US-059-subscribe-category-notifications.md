---
id: US-059
title: "Subscribe to notifications for new tools in watched categories"
slug: "subscribe-category-notifications"
personas: [P-001, P-007]
epic: "Registry & Discovery"
priority: "could-have"
complexity: "M"
tags: [registry, notifications, subscriptions, discovery]
---

# US-059: Subscribe to Notifications for New Tools in Watched Categories

## User Story

**As a** Solo AI Hobbyist (P-007),
**I want to** subscribe to notifications when new MCP servers are published in categories I care about,
**So that** I can stay current with the ecosystem without manually checking the registry every day.

## Acceptance Criteria

- [ ] Given the user is viewing a category page (US-052), when they click the "Watch this category" toggle, then the category is added to their watched categories list and the toggle reflects the active state.
- [ ] Given the user has watched categories, when they navigate to their notification settings, then they can view and manage all watched categories, add new ones, and remove existing ones.
- [ ] Given a new MCP server is published (US-074) to a watched category, when the publication goes live, then subscribed users receive an in-app notification within 5 minutes containing the server name, publisher, and a link to the detail page (US-054).
- [ ] Given the user has enabled email notifications for category watches, when a new server is published, then an email digest is sent at most once per day summarizing all new servers across watched categories.
- [ ] Given the user has watched a category, when a server in that category is deprecated (US-058), then the user receives a deprecation notification distinct from new-tool notifications.
- [ ] Given the user has not engaged with category notifications for 90 days, when the system evaluates subscription staleness, then it sends a single prompt asking if they want to continue watching and auto-unsubscribes after an additional 30 days of inactivity.

## Notes

Notification delivery should support in-app, email, and optional webhook channels. Users should be able to set per-category notification preferences (immediate vs daily digest). Related: US-052, US-054, US-058, US-074.
