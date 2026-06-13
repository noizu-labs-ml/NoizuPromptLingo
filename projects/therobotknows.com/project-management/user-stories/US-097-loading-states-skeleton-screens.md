---
id: US-097
title: "Loading States & Skeleton Screens"
slug: "loading-states-skeleton-screens"
personas: [P-001, P-002, P-003, P-004, P-005, P-008]
epic: "Accessibility, i18n & Performance"
priority: "should-have"
complexity: "M"
tags: [performance, ux, loading, skeleton, perceived-performance]
---

# US-097: Loading States & Skeleton Screens

## User Story

**As a** user navigating between views or waiting for AI generation results (P-001, P-002, P-003, P-004, P-005, P-008),
**I want to** see meaningful loading indicators and skeleton screens rather than blank or spinner-only states,
**So that** the app feels responsive and I understand what is loading without being disoriented.

## Acceptance Criteria

- [ ] Given I navigate to the Universe Explorer, when the entry list is loading, then skeleton cards of the correct dimensions are displayed for up to 3 seconds before real content appears.
- [ ] Given I submit a generation request in the Generation Studio, when the request is in-flight, then a progress indicator shows the generation stage (queued → processing → complete) and the submit button is disabled to prevent double submission.
- [ ] Given an API call takes longer than 10 seconds, when the timeout occurs, then an error state with a "Try again" button is shown in place of the skeleton, and the error is logged.
- [ ] Given I am navigating on a slow connection (simulated 3G), when I load any primary view, then skeleton screens appear within 500ms and are replaced with real content within 5 seconds.
- [ ] Given a skeleton screen is present, when it is announced by a screen reader, then it reads as "Loading [section name]..." rather than announcing the placeholder shapes.

## Notes

Skeleton screen dimensions must match actual content to prevent layout shift (CLS < 0.1 per Core Web Vitals). Related: US-085 (analytics) — time-to-interactive should be tracked. Related: US-096 (accessibility) — loading state announcements for screen readers.
