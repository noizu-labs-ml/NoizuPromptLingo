---
id: US-056
title: "Saved Searches with Notifications"
slug: "saved-searches-notifications"
personas: [P-003, P-008, P-001]
epic: "Search & Filtering"
priority: "could-have"
complexity: "M"
tags: [search, saved, notifications, alerts, email]
---

# US-056: Saved Searches with Notifications

## User Story

**As a** research journalist (P-003),
**I want to** save a search query and receive notifications when new matching sites are listed,
**So that** I am alerted to quality sources in my beat areas without manually re-checking.

## Acceptance Criteria

- [ ] Given I am logged in and viewing search results, when I click "Save this search", then the current query and active filters are saved to my account
- [ ] Given a search is saved, when new site listings are added to the directory that match the saved query, then I receive an email digest (at most daily) summarizing new matches
- [ ] Given I have saved searches, when I visit my account settings, then I can view, rename, and delete saved searches
- [ ] Given a saved search notification email, when I click a result link, then I am taken to the site detail page on gotta.cc
- [ ] Given a saved search notification, when I want to pause alerts without deleting the search, then I can toggle notifications off per-search

## Notes

Saved searches require an authenticated account (see US-068). Notification frequency should default to daily digest rather than immediate to avoid email fatigue. Related: US-051 (keyword search), US-068 (sign up).
