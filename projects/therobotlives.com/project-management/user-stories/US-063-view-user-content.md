---
id: US-063
title: "View Posts and Resources Authored by User"
slug: "view-user-content"
personas: [P-001, P-002, P-004]
epic: "User Profile & Reputation"
priority: should-have
complexity: "M"
tags: [profiles, discovery, content]
---

# US-063: View Posts and Resources Authored by User

## User Story

**As a** Prompt Engineer Power User (P-001), AI/ML Engineer (P-002), or Curious Lurker (P-004),
**I want to** browse all posts and resources authored by a specific user,
**So that** I can discover their expertise, find their best content, and decide whether to follow or collaborate with them.

## Acceptance Criteria

- [ ] Given any user profile, when I click the "posts" tab, then I see a paginated list of all thread posts authored by that user with title, space, preview snippet, timestamp, vote count, and comment count
- [ ] Given any user profile, when I click the "resources" tab, then I see a paginated list of all resources (prompts, skills, MCP configs) with title, type, version, last updated, and helpful vote count
- [ ] Given user has mixed content, when browsing posts/resources, then I can filter by space, sort by date (newest/oldest), sort by engagement (votes/comments), and search by keyword
- [ ] Given content is from private spaces, when I don't have access, then those items are hidden from the list with a count indicator (e.g., "3 posts in private spaces you can't access")
- [ ] Given I find valuable content, when I click it, then I am navigated directly to that piece of content (thread post or resource page)

## Notes

Content listings should respect privacy settings—users may opt to disable public showing of their contributions. Consider "featured content" section where users can highlight their best 3 posts/resources for profile visitors.