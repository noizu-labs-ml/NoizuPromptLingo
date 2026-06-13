---
id: US-057
title: "Share Collection as Curated Reading List"
slug: "share-collection"
personas: [P-001, P-006, P-007]
epic: "Bookmarking & Collections"
priority: "could-have"
complexity: "XL"
tags: [bookmarking, collections, sharing, social]
---

# US-057: Share Collection as Curated Reading List

## User Story

**As a** Prompt Engineer Power User (P-001), Content Creator (P-006), or Startup Founder (P-007),
**I want to** publish my bookmark collections as shareable curated lists,
**So that** I can share knowledge with my team, community, or audience and establish thought leadership.

## Acceptance Criteria

- [ ] Given a collection exists, when I choose to publish it, then I can set a public URL slug and optional cover image description
- [ ] Given a collection is published, when someone accesses the public URL, then they see the collection name, curator profile (if visible), and list of bookmarks with titles, descriptions, and permalinks
- [ ] Given a collection contains deleted or private content, when viewed publicly, then those items are shown as "[private content]" or omitted gracefully
- [ ] Given a published collection, when I edit it, then changes reflect immediately on the public version
- [ ] Given a collection is shared, when visitors browse, then they can "follow" the collection to be notified of new additions (requires account)

## Notes

Public collections should be discoverable via search (by title, curator, tags). Collection owners can unpublish to make private again. Consider collection versions/snapshots for permalink stability.