---
id: US-093
title: "Offline & Connection-Loss Resilience"
slug: "offline-connection-loss-resilience"
personas: [P-007, P-001, P-002]
epic: "Edge Cases & Error States"
priority: "could-have"
complexity: "M"
tags: [offline, resilience, ux, error-handling, pwa]
---

# US-093: Offline & Connection-Loss Resilience

## User Story

**As an** existing client reviewing project updates (P-007),
**I want to** receive clear feedback when I lose internet connectivity and continue reading cached content,
**So that** I am not confused by silent failures and can resume work seamlessly when my connection is restored.

## Acceptance Criteria

- [ ] Given an authenticated user who goes offline, when the browser detects the loss, then a subtle offline indicator appears in the site UI (banner or status icon)
- [ ] Given the offline state, when the user navigates to a previously visited page, then cached content is served by the service worker and marked as "Last updated [time]"
- [ ] Given the offline state, when the user attempts to submit a form, then the form is disabled with a "No internet connection" message rather than failing silently
- [ ] Given the connection being restored, when the browser comes back online, then the offline indicator disappears and stale data refreshes automatically
- [ ] Given a failed API request due to network error (not 4xx/5xx), when the error occurs, then the UI shows a "Connection problem — retrying…" message with exponential backoff before surfacing a manual retry button

## Notes

Service worker scope: cache static assets and last-fetched read-only pages (research papers, public content). Dashboard data is not cached for offline use in phase 1 — display graceful fallback. Network-status detection via `navigator.onLine` + `online`/`offline` events. Related to US-094 (form data recovery). Full PWA offline mode is won't-have-yet.
