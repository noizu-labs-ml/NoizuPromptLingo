---
id: US-052
title: "Bookmark a Resource"
slug: "bookmark-resource"
personas: [P-001, P-002, P-005]
epic: "Bookmarking & Collections"
priority: "should-have"
complexity: "S"
tags: [bookmarking, resources, discovery]
---

# US-052: Bookmark a Resource

## User Story

**As a** Prompt Engineer Power User (P-001), AI/ML Engineer (P-002), or MCP Server Developer (P-005),
**I want to** bookmark prompts, skills, and MCP configurations,
**So that** I can build a personal library of reusable components I can reference and fork later.

## Acceptance Criteria

- [ ] Given a resource page exists, when I click the bookmark icon, then the resource is added to my bookmarks
- [ ] Given a resource is bookmarked, when I view my bookmarks list, then the resource displays with type (prompt/skill/MCP), title, version, author, and last updated timestamp
- [ ] Given a bookmarked resource is updated, when I view my bookmarks, then the bookmarked version number is displayed with an indicator for newer versions
- [ ] Given a bookmarked resource is deleted, when I click the bookmark, then I see a "deleted content" message with option to remove bookmark
- [ ] Given I bookmark a forked resource, when I view bookmarks, then both fork source and my fork are visible (if both bookmarked) showing relationship

## Notes

Resources include prompts, skills, MCP configs. Version tracking is important—users may bookmark specific versions but should be notified of updates.