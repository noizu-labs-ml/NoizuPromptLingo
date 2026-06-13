---
id: US-098
title: "Offline Mode & PWA Support"
slug: "offline-mode-pwa"
personas: [P-001, P-002, P-004, P-005]
epic: "Accessibility, i18n & Performance"
priority: "could-have"
complexity: "XL"
tags: [pwa, offline, service-worker, performance, mobile]
---

# US-098: Offline Mode & PWA Support

## User Story

**As a** user who works in locations with unreliable internet (P-001, P-002, P-004, P-005),
**I want to** continue reading and drafting canon entries when I am offline and have changes sync automatically when reconnected,
**So that** my creative sessions are not interrupted by connectivity issues.

## Acceptance Criteria

- [ ] Given the app has been loaded once with a valid session, when I go offline, then I can still navigate to and read any previously viewed universe entry from the local cache.
- [ ] Given I edit or create a canon entry while offline, when I save, then the change is stored in a local pending-sync queue and a visual indicator shows the entry is "pending sync."
- [ ] Given my internet connection is restored, when sync occurs, then all pending-queue changes are sent to the server and the "pending sync" indicators are cleared.
- [ ] Given a sync conflict occurs (the same entry was edited offline and online), when sync runs, then a conflict resolution dialog shows both versions and lets me choose which to keep or merge.
- [ ] Given the app meets PWA criteria, when a user on a supported mobile browser visits the site, then they are prompted to install it to their home screen with a native app-like icon and splash screen.

## Notes

This is a significant infrastructure investment (service worker, IndexedDB, conflict resolution). Recommend deferring to post-MVP. AI generation and graph visualization are excluded from offline mode in the initial implementation. Related: US-097 (loading states).
