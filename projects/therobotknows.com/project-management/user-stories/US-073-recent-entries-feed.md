---
id: US-073
title: "Recent Entries Feed"
slug: "recent-entries-feed"
personas: [P-001, P-003, P-005, P-008]
epic: "Search & Discovery"
priority: "must-have"
complexity: "S"
tags: [search, discovery, feed, recent, activity]
---

# US-073: Recent Entries Feed

## User Story

**As a** narrative designer (P-003),
**I want to** see a feed of recently created and modified entries in my universe,
**So that** my team and I always know what changed since we last worked, without running a search.

## Acceptance Criteria

- [ ] Given a universe has activity, when I open the Universe Explorer or Dashboard, then a "Recent Activity" panel displays the 20 most recently created or modified entries, each showing entry name, type, editor, and time since last edit.
- [ ] Given the recent entries feed, when I click an entry in the feed, then I navigate directly to that entry's detail view.
- [ ] Given a universe has multiple collaborators, when any collaborator creates or edits an entry, then that entry appears at the top of the feed for all collaborators within 60 seconds of the save completing.
- [ ] Given I want to see older activity, when I click "Load more" at the bottom of the feed, then the next 20 entries in chronological order are appended to the list without a full page reload.

## Notes

The recent entries feed is the primary ambient awareness mechanism for collaborative universes. It should be present on the Dashboard (US-001 area) and Universe Explorer. No dependency on search infrastructure — powered by a simple activity log query. Related: US-069 (full-text search).
