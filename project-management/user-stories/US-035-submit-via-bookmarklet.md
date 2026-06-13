---
id: US-035
title: "Submit a Site via Browser Bookmarklet"
slug: "submit-via-bookmarklet"
personas: [P-001, P-008]
epic: "Site Submission"
priority: "could-have"
complexity: "M"
tags: [submission, bookmarklet, browser, convenience]
---

# US-035: Submit a Site via Browser Bookmarklet

## User Story

**As a** web nostalgia explorer (P-001),
**I want to** submit a site I am currently browsing with a single bookmarklet click,
**So that** I can share great discoveries instantly without leaving the page I found them on.

## Acceptance Criteria

- [ ] Given I have installed the gotta.cc bookmarklet, when I click it while on any web page, then a lightweight popup appears pre-filled with the current page's URL and title
- [ ] Given the popup is open, when I am already logged in to gotta.cc, then my session is recognized and I can submit with one additional click
- [ ] Given the popup is open, when I am not logged in, then I am prompted to log in via a minimal inline form before submitting
- [ ] Given I submit via bookmarklet, when submission is queued, then the popup shows a success confirmation with a link to track status and automatically closes after 3 seconds

## Notes

The bookmarklet installation page lives in the user account settings area. The bookmarklet should degrade gracefully on pages with strict Content Security Policy headers by falling back to opening a new tab with the URL pre-filled.
