---
id: US-091
title: "Offline Indicator and Graceful Offline Mode"
slug: "offline-indicator-graceful-mode"
personas: [P-001, P-002, P-005]
epic: "Performance & Scale"
priority: "could-have"
complexity: "M"
tags: [offline, pwa, service-worker, resilience, ux]
---

# US-091: Offline Indicator and Graceful Offline Mode

## User Story

**As an** AI Hobbyist (P-002) or Prompt Engineer (P-001),
**I want to** know when I lose internet connectivity and continue reading cached content,
**So that** a temporary network outage does not abruptly break my browsing session.

## Acceptance Criteria

- [ ] Given a user's network connection drops, when the browser detects the offline state, then a non-blocking banner appears at the top of the page indicating the user is offline
- [ ] Given the user is offline and attempts to vote or submit a comment, when the action is triggered, then the action is queued locally and a tooltip informs the user it will be submitted when connectivity is restored
- [ ] Given a user has previously visited prompt pages, when they go offline and navigate to a cached page, then the cached version is served from the service worker with an "Viewing cached version" indicator
- [ ] Given the user's connection is restored, when the browser detects online state, then the offline banner disappears, queued actions are submitted automatically, and the user is notified of successful sync

## Notes

Requires a service worker with a stale-while-revalidate caching strategy for read content and an offline queue for write actions (votes, comments). The queuing mechanism must handle conflicts (e.g., the prompt was deleted while offline). This feature moves the app meaningfully toward PWA compliance.
