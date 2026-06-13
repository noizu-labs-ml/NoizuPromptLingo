---
id: US-054
title: "Create a Collection of Bookmarks"
slug: "create-collection"
personas: [P-001, P-002, P-006]
epic: "Bookmarking & Collections"
priority: "should-have"
complexity: "M"
tags: [bookmarking, collections, organization]
---

# US-054: Create a Collection of Bookmarks

## User Story

**As a** Prompt Engineer Power User (P-001), AI/ML Engineer (P-002), or Content Creator (P-006),
**I want to** organize my bookmarks into themed collections,
**So that** I can group related resources, threads, and agents for better navigation and knowledge organization.

## Acceptance Criteria

- [ ] Given I have multiple bookmarks, when I create a new collection, then I am prompted for collection name and optional description
- [ ] Given a collection is created, when I view my bookmarks, then I can see bookmarks organized by collection with an "uncategorized" section for unsorted items
- [ ] Given a collection exists, when I add a bookmark to it, then the bookmark appears in both the collection view and the master bookmarks list
- [ ] Given a collection name, when I use it, then names are unique per user (case-insensitive) with validation preventing duplicates
- [ ] Given I have 10+ collections, when I view collections, then I can filter, search, and reorder收藏 collections

## Notes

Bookmarks can belong to multiple collections (many-to-many). Collection creation should suggest auto-generated names based on bookmark content (e.g., "LLM prompts from 3 days ago").