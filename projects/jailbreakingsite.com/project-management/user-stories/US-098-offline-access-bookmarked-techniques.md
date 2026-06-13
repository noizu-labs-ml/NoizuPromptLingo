---
id: US-098
title: "Offline Access to Bookmarked Techniques"
slug: "offline-access-bookmarked-techniques"
personas: [P-001, P-006]
epic: "Accessibility & Performance"
priority: "won't-have-yet"
complexity: "L"
tags: [offline, pwa, bookmarks, service-worker, performance]
---

# US-098: Offline Access to Bookmarked Techniques

## User Story

**As a** researcher who works in network-restricted environments (P-001, P-006),
**I want to** access my bookmarked techniques offline,
**So that** I can reference threat intelligence during air-gapped assessments, flight travel, or conference environments with unreliable connectivity.

## Acceptance Criteria

- [ ] Given the site is a PWA, when I add it to my home screen, then it registers a service worker that caches bookmarked technique pages
- [ ] Given I have bookmarked techniques while online, when I go offline, then those technique detail pages are readable with full content (description, examples, mitigations)
- [ ] Given an offline cached page, when I view it, then an "Offline — cached [date]" indicator is shown so I know the data may be stale
- [ ] Given I reconnect, when the service worker detects connectivity, then cached technique data is refreshed in the background silently
- [ ] Given a technique I have not bookmarked, when I try to access it offline, then I see a friendly "This page isn't available offline — bookmark it to access offline" message
- [ ] Given the cache storage, when it exceeds 50MB, then the oldest uncached techniques are evicted in LRU order to stay within storage budget

## Notes

Deferred to a future release due to service worker complexity, content security policy considerations, and the need for a mature bookmarks feature (implied dependency). PWA manifest and installability should be implemented independently of offline caching. Consider using Workbox for service worker implementation.
