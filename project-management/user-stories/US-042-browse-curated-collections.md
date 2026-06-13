---
id: US-042
title: "Browse Curated Collections and Topics"
slug: "browse-curated-collections"
personas: [P-002, P-007, P-008]
epic: "Search & Discovery"
priority: "should-have"
complexity: "M"
tags: [collections, curation, discovery, topics]
---

# US-042: Browse Curated Collections and Topics

## User Story

**As an** enterprise AI lead evaluating the platform (P-007),
**I want to** browse curated collections of prompts organized around specific topics or use cases,
**So that** I can efficiently find vetted, expert-approved prompts relevant to my business domain.

## Acceptance Criteria

- [ ] Given I navigate to the Collections page, when the page loads, then a grid of named collections is displayed, each showing title, description, curator name, item count, and a cover image
- [ ] Given I open a collection, when the prompts list renders, then items are displayed in the curator-defined order and include the curator's annotation for each item where provided
- [ ] Given a moderator or high-reputation user creates a collection, when they add prompts to it, then they can reorder items, add annotations, and set the collection as public or unlisted
- [ ] Given a collection is marked as "Official" by an admin, when it is displayed, then a verified badge distinguishes it from community-curated collections

## Notes

Collections are analogous to playlists — a user can add the same prompt to multiple collections. Collections should be discoverable via search. A collection's follower count and last-updated date should be visible to help users identify active, relevant collections.
